//
//  APIManager+Ping.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

import class Alamofire.NetworkReachabilityManager

public typealias NetworkReachabilityManager = Alamofire.NetworkReachabilityManager
public typealias NetworkReachabilityStatus = NetworkReachabilityManager.NetworkReachabilityStatus

// Some teset about ping multiple urls
extension APIManager {
    typealias CompletionURLStatusHandler = ((Result<(URL, Status), PingError>) -> Void)

    enum PingError: Error {
        case apiError(_ apiError: APIError, _ url: URL)
    }

    static func ping(on urls: [URL], onlyFirstSuccess: Bool = false, completionHandler: @escaping CompletionURLStatusHandler) -> Cancellable {
        let cancellable = CancellableComposite()
        for url in urls {
            assert(!url.isFileURL && url.isHttpOrHttps)
            let statusCancellable = APIManager(url: url).status { result in
                completionHandler(result.map({ (url, $0) }).mapError({ PingError.apiError($0, url)}))
                if case .success = result, onlyFirstSuccess {
                    cancellable.cancel()
                }
            }
            cancellable.append(statusCancellable)
        }
        return cancellable
    }

    public func reachability(handler: @escaping NetworkReachabilityManager.Listener) -> Cancellable? {
        if let reachabilityManager = NetworkReachabilityManager(host: base.baseURL.absoluteString) {
            reachabilityManager.startListening(onUpdatePerforming: handler)
            return CancellableReachability(reachabilityManager: reachabilityManager)
        }
        return nil
    }

    /// Start reachability task.
    public static func reachability(handler: @escaping NetworkReachabilityManager.Listener) -> Cancellable? {
        if let reachabilityManager = NetworkReachabilityManager() {
            reachabilityManager.startListening(onUpdatePerforming: handler)
            return CancellableReachability(reachabilityManager: reachabilityManager)
        }
        return nil
    }
}

class CancellableReachability: Cancellable {
    private var cancelled = false
    public let reachabilityManager: NetworkReachabilityManager
    init(reachabilityManager: NetworkReachabilityManager) {
        self.reachabilityManager = reachabilityManager
    }
    var isCancelled: Bool {
        return cancelled
    }
    func cancel() {
        if !cancelled {
            cancelled = true
            reachabilityManager.stopListening()
        }
    }
}
extension NetworkReachabilityStatus {

    /// Whether the network is currently reachable.
    public var isReachable: Bool { return isReachableOnCellular || isReachableOnEthernetOrWiFi }

    /// Whether the network is currently reachable over the cellular interface.
    public var isReachableOnCellular: Bool { return self == .reachable(.cellular) }

    /// Whether the network is currently reachable over Ethernet or WiFi interface.
    public var isReachableOnEthernetOrWiFi: Bool { return self == .reachable(.ethernetOrWiFi) }

}
