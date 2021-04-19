//
//  APIManager.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 20/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import Prephirences
#if os(iOS)
import UIKit
#endif

/*import class Alamofire.RequestRetryCompletion*/
#if os(macOS)
let kPersistAuth = false // desactive it for command line tools, must use parameters each times -> do not need to access keychain for nothing
#else
let kPersistAuth = true
#endif
/// Main class of framework, which allow to play with the 4D rest api.
public class APIManager {
    /// Default instance of `Self` which use `URL.qmobile` as base url
    public static var instance = APIManager(url: URL.qmobile) {
        didSet {
            instance.authToken = oldValue.authToken
            oldValue.delegate?.didReplacedAsDefaultInstance(oldValue: oldValue, newValue: instance)
            Notification(name: APIManager.didChangeDefaultInstance, object: instance).post()
        }
    }

    /// Delegates.
    public weak var delegate: APIManagerDelegate?

    // MARK: retrying
    /*var isRefreshing = false
    let lock = NSLock()
    var requestsToRetry: [RequestRetryCompletion] = []*/

    // MARK: Alias
    /// Alias for network completion request callback.
    public typealias Completion = (Result<Moya.Response, APIError>) -> Swift.Void
    /// Alias for network progression request callback.
    public typealias ProgressHandler = Moya.ProgressBlock

    /// Alias to customize records request
    public typealias ConfigureRecordsRequest = (RecordsRequest) -> Void

    // MARK: Init
    /// Create an api manager using server URL
    public init(url: URL) {
        self.base = BaseTarget(baseURL: url, path: "mobileapp")
        self.webTest = WebTestTarget(baseURL: url)

        self.initAuthToken()
        self.initPlugins()
    }

    // Customize

    // MARK: Targets

    /// Target for all rest request.
    public let base: BaseTarget
    /// Target to get info from web server
    public let webTest: WebTestTarget
    /// Lattest info from server
    public var webTestInfo: WebTestInfo?

    // MARK: Authentication
    private static let authTokenKey = "auth.token"
    /// Token for authentication

    public var authToken: AuthToken? {
        didSet {
            saveAuthToken()
        }
    }

    /// Return if api shared instance has valid token ie. we are logged
    public static var isSignIn: Bool {
        guard let token = self.instance.authToken else {
            return false
        }
        return token.isValidToken
    }

    private func initAuthToken() {
        guard kPersistAuth else { return }
        let keyChain = KeychainPreferences.sharedInstance
        if let tokenOrNil = ((try? keyChain.decodable(AuthToken.self, forKey: APIManager.authTokenKey)) as AuthToken??),
            let token = tokenOrNil {
            self.authToken = token
        } else {
            #if DEBUG
            // inject from settings
            if let authTokenDico = UserDefaults.standard["auth.token"] as? [String: Any],
                let id = authTokenDico["id"] as? String,
                let token = authTokenDico["token"] as? String {
                self.authToken = AuthToken(
                    id: id,
                    statusText:
                    authTokenDico["statusText"] as? String,
                    token: token,
                    userInfo: authTokenDico["userInfo"] as? [String: Any])
            }
            #endif
        }
    }

    /// Save the auth token.
    private func saveAuthToken() {
        guard kPersistAuth else { return }
        let keyChain = KeychainPreferences.sharedInstance
        do {
            try keyChain.set(encodable: authToken, forKey: APIManager.authTokenKey) // set work with nil (will remove)
        } catch {
            logger.warning("Failed to save authentication token \(error)")
        }
    }

    /// Remove auth token from keychain.
    public static func removeAuthToken() {
        guard kPersistAuth else { return }
        let keyChain = KeychainPreferences.sharedInstance
        keyChain.removeObject(forKey: APIManager.authTokenKey)
    }

    // MARK: testing

    /// Activate stub response for test.
    public var stub: Bool = Prephirences.sharedInstance["stub.activate"] as? Bool ?? false
    /// A delegate to customize stub feature to test.
    public weak var stubDelegate: StubDelegate?

    // MARK: attributes

    /// Log level for network. By default .verbose.
    /// Pref key: api.network.logLevel
    public lazy var networkLogLevel: LogLevel = {
        let networkLogLevelPref: Preference<LogLevel> = Prephirences.sharedInstance.preference(forKey: "api.network.logLevel")
        networkLogLevelPref.transformation = LogLevel.preferenceTransformation
        return networkLogLevelPref.value ?? .verbose
    }()

    /// List of Moya plugins.
    public var plugins: [PluginType] = []
    public var defaultQueue: DispatchQueue? // could also set as parameter, change if needed

    /// URL session configuration. Configure timeout, and other properties
    public lazy var configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary

        // TIPS: this properties work only at start up, add a change listener to change that
        if let timeout = Prephirences.sharedInstance["api.request.timeout"] as? TimeInterval {
            configuration.timeoutIntervalForRequest = timeout // system default 60
        }
        if let timeout = Prephirences.sharedInstance["api.resource.timeout"] as? TimeInterval {
            configuration.timeoutIntervalForResource = timeout // 7
        }
        if let allowsCellularAccess = Prephirences.sharedInstance["api.allowsCellularAccess"] as? Bool {
            configuration.allowsCellularAccess = allowsCellularAccess // true
        }
        // configuration.connectionProxyDictionary
        // configuration.urlCredentialStorage = .shared
        // configuration.urlCache
        // configuration.requestCachePolicy
        // configuration.httpShouldSetCookies = true
        // configuration.shouldUseExtendedBackgroundIdleMode = true
        // configuration.waitsForConnectivity = true // ios11 beta

        return configuration
    }()

    // MARK: configuration functions

    /// Return the `ServerTrustManager`
    open func serverTrustManager() -> ServerTrustManager? {
        guard let host = self.base.baseURL.host  else {
            return nil
        }

        let certificates =  Bundle.main.af.certificates
        let publicKeys = Bundle.main.af.publicKeys

        if !certificates.isEmpty {
            let evaluators = [
                host: PinnedCertificatesTrustEvaluator(certificates: certificates,
                                                       performDefaultValidation: false,
                                                       validateHost: true)
            ]
            return ServerTrustManager(evaluators: evaluators)
        } else if !publicKeys.isEmpty {
            let evaluators: [String: ServerTrustEvaluating] = [
                host: PublicKeysTrustEvaluator(keys: publicKeys,
                                                performDefaultValidation: false,
                                                validateHost: true
                )
            ]
            return ServerTrustManager(evaluators: evaluators)
        }
        if Prephirences.sharedInstance["server.trust"] as? Bool ?? Device.current.isSimulatorCase {
            let evaluators: [String: ServerTrustEvaluating] = [
                host: DisabledEvaluator()
            ]
            return ServerTrustManager(evaluators: evaluators)
        }
        return nil
    }

    /// Create a moya `Session`
    open func session() -> Moya.Session {
        let manager = Session(
            configuration: configuration,
            startRequestsImmediately: false,
            interceptor: (Prephirences.sharedInstance["api.retrier.activated"] as? Bool ?? false) ? self: nil,
            serverTrustManager: serverTrustManager()
        )

        if Prephirences.sharedInstance["api.retrier.activated"] as? Bool ?? false {
            logger.info("Request retrier mecanism activated")
        }
        /* manager.backgroundCompletionHandler = {
         logger.debug("Session manager end")
         }*/
        // configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return manager
    }

    // Init plugins
    open func initPlugins() {
        plugins = []

        if logger.isEnabledFor(level: networkLogLevel) {
            let configuration = NetworkLoggerPlugin.Configuration(output: self.logNetwork, logOptions: [.verbose])
            plugins.append(NetworkLoggerPlugin(configuration: configuration))
        }

        /*// token: not possible with current Moya implementation
         let tokenClosure: () -> String = { [weak self] in
            if let authToken = self?.authToken, authToken.isValidToken, let token = authToken.token {
                return token
            }
            return ""
        }
        plugins.append(AccessTokenPlugin(tokenClosure: tokenClosure))*/
        plugins.append(ReceivePlugin { result, _ in
            if case .failure(let error) = result {
                let requestError = APIError.request(error)
                if requestError.isHTTPResponseWith(code: .unauthorized) {
                    logger.warning("Unauthorize access. Invalid credential for next request. \(String(describing: requestError.response))")
                    self.authToken = nil
                }
            }
        })

        plugins.append(PreparePlugin { request, target in
            var request = request
            if let timeoutTarget = target as? TimeoutTarget {
                let timeoutInterval = timeoutTarget.timeoutInterval
                if timeoutInterval > TimeInterval.zero {
                    request.timeoutInterval = timeoutInterval
                }
            }
            return request
        })

        #if DEBUG
            // could do some modficatio here to test
            plugins.append(PreparePlugin { request, _ in
                var request: URLRequest = request
                request.timeoutInterval = request.timeoutInterval
                // request.cachePolicy =
                // request.allowsCellularAccess = true
                return request
            })
            // Log info about server
            logger.verbose({
                self.plugins.append(ReceivePlugin { result, _ in
                    if case .success(let response) = result {
                        if let server = response.header(for: .server) {
                            let restInfo = response.header(for: .restInfo) ?? ""
                            logger.verbose("Response receive from server \(server). \(restInfo)")
                        } // else stub?
                    }
                })
            })
        #endif
    }

    /// Log all network info in debug
    internal func logNetwork(_ target: TargetType, items: [String]) { // NetworkLoggerPlugin.Configuration.OutputType
        for item in items {
            logger.logln(item, level: self.networkLogLevel)
        }
    }
}

public protocol StubDelegate: AnyObject {
    func sampleResponse(_ target: TargetType) -> Moya.EndpointSampleResponse?
}

extension APIManager {
    func sampleResponse(_ target: TargetType) -> Moya.EndpointSampleResponse {
        if let response = self.stubDelegate?.sampleResponse(target) {
            return response
        }
        return .networkResponse(200, target.sampleData)
    }

    func endpoint<T: TargetType>(_ target: T) -> Endpoint {
        // let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        // Add my sample reponse closure for stub
        var endpoint = Endpoint(
            url: url(for: target).absoluteString,
            sampleResponseClosure: { self.sampleResponse(target) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )

        endpoint = endpoint.adding(newHTTPHeaderFields: ["X-QMobile": "1"])
        if let authToken = authToken, authToken.isValidToken, let token = authToken.token {
            endpoint = endpoint.adding(newHTTPHeaderFields: [HTTPRequestHeader.authorization.rawValue: "Bearer \(token)"])
        }
        return endpoint
    }

    /// Configure a custom URL request with all needed headers.
    open func configure(request: URLRequest) -> URLRequest {
        var requestMutable = request
        requestMutable.setValue("1", forHTTPHeaderField: "X-QMobile")
        if let authToken = authToken, authToken.isValidToken, let token = authToken.token {
            requestMutable.setValue("Bearer \(token)", forHTTPHeaderField: .authorization)
        }
        return requestMutable
    }

    private final func url(for target: TargetType) -> URL {
        if target.path.isEmpty {
            return target.baseURL
        }
        return target.baseURL.appendingPathComponent(target.path)
    }

    func stubClosure<T: TargetType>() -> MoyaProvider<T>.StubClosure {
        return stub ? MoyaProvider<T>.immediatelyStub : MoyaProvider<T>.neverStub
    }

    func provider<T: TargetType>(_ target: T) -> MoyaProvider<T> {
        // XXX could add a cache on this factory according to target type, /!\ cache must be reseted if endpoint, stub, manager, plugin change
        return MoyaProvider<T>(
            endpointClosure: self.endpoint,
            // requestClodure: ,  // XXX could add also requestClosure to modify 
            stubClosure: self.stubClosure(),
            session: self.session(),
            plugins: self.plugins
        )
    }

    // MARK: request methods

    /// Make a request.
    /// - Parameters:
    ///   - target: the target.
    ///   - callbackQueue: an optional  queue for callback
    ///   - progress: callback to receive progression info
    ///   - completion: completion callback to receive raw moya response.
    /// - Returns: a cancellable object for this request.
    public func request<T: TargetType>(_ target: T, callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completion: @escaping APIManager.Completion) -> Cancellable {
        return self.provider(target).request(target, callbackQueue: callbackQueue ?? defaultQueue, progress: progress) { result in
            completion(result.mapError { APIError.error(from: $0) })
        }
    }
    func request<T: TargetType>(_ target: T, queue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completion: @escaping Moya.Completion) -> Cancellable {
        return self.provider(target).request(target, callbackQueue: queue ?? defaultQueue, progress: progress, completion: completion)
    }
    /// Make a request.
    /// - Parameters:
    ///   - target: the target.
    ///   - callbackQueue: an optional  queue for callback
    ///   - progress: callback to receive progression info
    ///   - completion: completion callback to receive data as decoded object.
    /// - Returns: a cancellable object for this request.
    public func request<T: DecodableTargetType>(_ target: T, callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completion: @escaping (Result<T.ResultType, APIError>) -> Void) -> Cancellable {
        return self.provider(target).requestDecoded(target, callbackQueue: callbackQueue ?? defaultQueue, progress: progress, completion: completion)
    }
    /// Make a request.
    /// - Parameters:
    ///   - target: the target.
    ///   - callbackQueue: an optional  queue for callback
    ///   - progress: callback to receive progression info
    ///   - completion: completion callback to receive data as a collection of decoded object.
    /// - Returns: a cancellable object for this request.
    public func request<T: DecodableTargetType>(_ target: T, callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completion: @escaping (Result<[T.ResultType], APIError>) -> Void) -> Cancellable {
        return self.provider(target).requestDecoded(target, callbackQueue: callbackQueue ?? defaultQueue, progress: progress, completion: completion)
    }
}
