//
//  URL+Validate.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 25/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

private let httpSchemes = ["http", "https"]

extension URL {
    /// Alias for port type
    public typealias Port = Int

    /// Returm true if scheme is http or https
    public var isHttpOrHttps: Bool {
        guard let scheme = self.scheme else {
            return false
        }
        return httpSchemes.contains(scheme)
    }

    /// Return true only if scheme is https
    public var isHttps: Bool {
        return "https" == self.scheme
    }

    /// Return true only if scheme is http
   public var isHttp: Bool {
        return "http" == scheme
    }

    /// Return the default port for current scheme
    public var defaultPort: Port? {
        guard let scheme = self.scheme else {
            return nil
        }
        return URL.defaultPorts[scheme]
    }

    /// Return true if `port` is default port for url `scheme`
    public var hasDefaultPort: Bool {
        return defaultPort == self.port
    }

    /// `Dictionary` of default ports by schemes
    public static let defaultPorts: [String: Port] = [
        "http": 80,
        "https": 443,
        "ws": 80,
        "wws": 443
    ]

    /// Return true if scheme is a secure one (https, wss)
    public var isSecure: Bool {
        return self.scheme?.isSecureURLScheme ?? false
    }
}

extension String {
    var isSecureURLScheme: Bool {
        return self == "https" || self == "wss"
    }
}

// MAbRK: bulder
extension URL {
    public func with(scheme: String) -> URL {
        if var compo = self.components() {
            compo.scheme = scheme
            return compo.url ?? self
        }
        return self
    }

    public func with(host: String) -> URL {
        if var compo = self.components() {
            compo.host = host
            return compo.url ?? self
        }
        return self
    }

    func components(resolvingAgainstBaseURL: Bool = false) -> URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: resolvingAgainstBaseURL)
    }
}
