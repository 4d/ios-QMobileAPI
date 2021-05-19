//
//  URL+Qmobile.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 11/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Prephirences

extension Prephirences {
    struct Key {
        static let serverURLScheme = "server.url.scheme"
        static let serverURL = "server.url"
        static let serverURLEdited = "server.url.edited"
        static let serverURLs = "server.urls"
        static let serverURLPort = "server.url.port"
        static let serverURLHTTPSPort = "server.url.portHTTPS"
        static let serverURLLocalhost = "server.url.localhost"
    }

    /// Wanted url scheme for server: http or https
    public static var serverURLScheme: String? {
        guard let scheme = Prephirences.sharedInstance.string(forKey: Key.serverURLScheme) else {
            return nil
        }
        if scheme.isEmpty {
            return nil
        }
        assert(["http", "https"].contains(scheme))
        return scheme
    }

    /// The server url
    public static var serverURL: String? {
        get {
            return serverURLInternal
        }
        set {
            serverURLInternal = newValue
            serverURLHasBeenEdited = true
        }
    }

    static var serverURLInternal: String? {
        get {
            return Prephirences.sharedInstance.string(forKey: Key.serverURL)
        }
        set {
            let pref: MutablePreference<String>? = Prephirences.sharedMutableInstance?.preference(forKey: Key.serverURL)
            if pref?.value != newValue {
                if newValue.isEmpty {
                    pref?.value = nil // do not store empty string
                } else {
                    pref?.value = newValue
                }
            }
        }
    }

    /*static var serverURLImmutable: String? {
        guard let compositePref = Prephirences.sharedInstance as? CompositePreferences else {
            return serverURLInternal
        }
        let onlyImmutable = CompositePreferences(compositePref.array.filter({ !($0 is MutablePreferencesType)}))
        return onlyImmutable.string(forKey: Key.serverURL)
    }*/

    /// The server url has been edited
    public private(set) static var serverURLHasBeenEdited: Bool {
        get {
            return Prephirences.sharedInstance.bool(forKey: Key.serverURLEdited)
        }
        set {
            let pref: MutablePreference<Bool>? = Prephirences.sharedMutableInstance?.preference(forKey: Key.serverURLEdited)
            if pref?.value != newValue {
                pref?.value = newValue
            }
        }
    }

    public static var serverURLForceLocalhost: Bool {
        return Prephirences.sharedInstance[Key.serverURLLocalhost] as? Bool ?? true
    }

    /// All local server urls for developments purpose.
    public static var serverURLs: [String]? {
        if let array = Prephirences.sharedInstance.stringArray(forKey: Key.serverURLs) {
            return array
        }
        if let string = Prephirences.sharedInstance.string(forKey: Key.serverURLs) {
            return string.components(separatedBy: ",")
        }
        return nil
    }

    /// Server port if http.
    static var serverPort: Int? {
        guard let port = Prephirences.sharedInstance[Key.serverURLPort] as? Int else {
            return nil
        }
        guard port > 0 && port <= 65_535 else {
            return nil
        }
        return port
    }

    /// Server port if https.
    static var serverHTTPSPort: Int? {
        guard let port = Prephirences.sharedInstance[Key.serverURLHTTPSPort] as? Int else {
            return nil
        }
        guard port > 0 && port <= 65_535 else {
            return nil
        }
        return port
    }

    // observe

    /// return value when changed
    public static func serverURLChanged(_ observer: @escaping (String) -> Void) -> NSObjectProtocol {
        // XXX: use KVO ?
        return observe(forKeyPath: Key.serverURL) { (_: String?) in
            let pref = serverURL ?? URL.qmobile.absoluteString
            observer(pref)
        }
    }

    static func observe<T: Equatable>(forKeyPath key: String, _ observer: @escaping (T?) -> Void) -> NSObjectProtocol {
        let observed = UserDefaults.standard

        var initial = observed.value(forKey: key) as? T // conform to equatable...
        return observed.observeChange {
            // send only if value change
            let current = observed.value(forKey: key) as? T
            if current != initial {
                initial = current
                observer(initial)
            }
        }
    }
}

extension UserDefaults {
    /// Observe user default change
   fileprivate func observeChange( _ observer: @escaping () -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: self, queue: nil) { notification in
            if let observed = notification.object as? UserDefaults, observed == self {
                observer()
            }
        }
    }
}

// MARK: url with information from settings
let validIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
extension String {
    var isIpAddress: Bool {
        let host = self
        guard !host.isEmpty else { return false }
        return host.range(of: validIpAddressRegex, options: .regularExpression) != nil
    }
}
extension URL {
    var isIpAddress: Bool {
        guard let host = self.host else { return false }
        return host.isIpAddress
    }

    var withScheme: URL {
        let urlFromString = self
        if urlFromString.isHttpOrHttps {
            return urlFromString
        } else if let currentScheme = urlFromString.scheme, absoluteString.contains("\(currentScheme)://") { // fix scheme
            return URL(string: absoluteString.replacingOccurrences(of: "\(currentScheme)://", with: "\(URL.defaultScheme)://")) ?? .localhost
        } else { // add the scheme
           return URL(string: "\(URL.defaultScheme)://\(absoluteString)") ?? .localhost
        }
    }
}

extension URL {
    /// Default scheme for server url.
    public static var defaultScheme: String {
        return Prephirences.serverURLScheme ?? "http"
    }

    /// Return a new url with `defaultScheme`.
    public func withDefaultScheme() -> URL {
        return self.with(scheme: URL.defaultScheme)
    }

    /// localhost url with defined port by settings.
    public static var qmobileLocalhost: URL {
        return URL.localhost.withPort
    }

    /// use localhost or not
    static var forceLocalhost: Bool {
        if Prephirences.serverURLForceLocalhost {
            return Device.current.isSimulatorCase && !Prephirences.serverURLHasBeenEdited
        }
        return false
    }

    public static var qmobile: URL {
        var urlString: String?
        var addPort = true

        // If simulator do not use main url, use localhost, but only if not defined by user
        if forceLocalhost {
            urlString = URL.localhost.absoluteString
        } else {
            // Get from settings or user data
            urlString = Prephirences.serverURL
            /*if urlString.isEmpty {
                urlString = Prephirences.serverURLImmutable
            }*/

            // if not defined explicitely, take one from binding urls
            if urlString.isEmpty {
                if let urls = Prephirences.serverURLs, let first = urls.first, !first.isEmpty {
                    urlString = first

                    if first.isIpAddress { // dev mode with ip, try to find the best urls
                        let urls = urls.compactMap { URL(string: $0)?.withScheme }
                        _ = APIManager.ping(on: urls, onlyFirstSuccess: true) { result in
                            // asynchronous code, could not return the good url
                            switch result {
                            case .success(let (url, status)):
                                logger.info("Server \(url) \(status)")
                                Prephirences.serverURLInternal = url.absoluteString
                                APIManager.instance = APIManager(url: url)
                                 // XXX DataSync.instance.apiManager = apiManager

                            case .failure(let error):
                                logger.debug("No accessible server \(error)")
                            }
                        }
                    }

                } else {
                    logger.debug("Unable to get configuration for server url, localhost will be used. (Maybe not loaded preferences yet).")
                    urlString = URL.localhost.absoluteString
                }
            } else {
                addPort = false // we do not add port to already computed value, or setting value
            }
            // check parsing validity
            if let forURL = urlString, URL(string: forURL) == nil {
                // invalid, fix it by reseting to default
                urlString = URL.localhost.absoluteString
            }
        }

        // just check not parsable; programmation error
        guard let tempUrlString = urlString, let urlFromString = URL(string: tempUrlString) else {
            assertionFailure("Must be parsable here")
            return URL.localhost.withPort
        }

        // If not http or https try to fix it
        let url: URL = urlFromString.withScheme

        /// add port if necessary
        let finalUrl = addPort ? url.withPort: url
        Prephirences.serverURLInternal = finalUrl.absoluteString // cache
        return finalUrl
    }

    /// Return the url defined to reach the servers.
    public static var qmobileURLs: [URL]? {
        guard let urlsString = Prephirences.serverURLs else {
            guard let urlString = Prephirences.serverURL, let url = URL(string: urlString) else {
                logger.debug("Unable to get configuration for server url, localhost will be used. Maybe not loaded preferences yet.")
                return nil
            }
            return [url.withPort]
        }
        return urlsString.compactMap {
            URL(string: $0)?.withPort
        }
    }

    func with(port: Int, ifNoPort: Bool = false) -> URL {
        if self.defaultPort/*For Scheme*/ == port {
            return self
        }
        let hasPort = self.port != nil
        if hasPort || ifNoPort, var compo = self.components() {
            compo.port = port
            return compo.url ?? self
        }
        return self
    }

    var withHTTPPort: URL {
        if let prefPort = Prephirences.serverPort {
            return with(port: prefPort, ifNoPort: true)
        }
        logger.verbose("No http port defined in preferences")
        return self
    }

    var withHTTPSPort: URL {
        if let prefPort = Prephirences.serverHTTPSPort {
            return with(port: prefPort, ifNoPort: true)
        }
        logger.verbose("No https port defined in preferences")
        return self
    }

    var withPort: URL {
        if isHttps {
            return self.withHTTPSPort
        }
        return self.withHTTPPort
    }
}
