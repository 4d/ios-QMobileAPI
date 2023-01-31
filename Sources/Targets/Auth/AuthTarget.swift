//
//  AuthTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/03/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Prephirences

// MARK: authentificate
///  mobileapp/$authenticate/
public class AuthTarget: ChildTargetType {
    public enum Send: String {
        case link
        case code
    }

    let parentTarget: TargetType
    var login: String
    var password: String?
    var authParams: [String: Any]?
    var send: Send

    init(parentTarget: BaseTarget, login: String, password: String? = nil, send: Send = .link, parameters: [String: Any]? = nil) {
        self.parentTarget = parentTarget
        self.login = login
        self.password = password
        self.authParams = parameters
        self.send = send
    }

    /// The last path component for request.
    public let childPath = "$authenticate"
    /// The http method
    public let method = Moya.Method.post

    /// The full path for request. Parent path + `childPath`
    public var path: String {
        return parentTarget.path + "/" + self.childPath
    }

    /// Create `.requestParameters` with user, device and application info.
    public var task: Task {
        var parameters: [String: Any] = [
            "email": self.login,
            "application": application,
            "team": team,
            "device": device,
            "language": language
        ]
        parameters["send"] = send.rawValue
        parameters["password"] = password
        // Save password for verify request...
        KeychainPreferences.sharedInstance[childPath] = parameters["password"]
        if password?.isEmpty ?? false {
            switch send {
            case .link:
              parameters["password"] = String.random(length: 20) // If magic link only openable by iOS app, we could change that
            case .code:
                break
            }
        }
        #if DEBUG
        if let parameters = Prephirences.sharedInstance["auth.parameters"] as? [String: Any] {
            if authParams == nil {
                authParams = [:]
            }
            authParams?.merge(parameters, uniquingKeysWith: { $1 })
        }
        #endif
        if let authParams = authParams {
            parameters["parameters"] = authParams
        }

        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }

    /// Create a `Dictionary` with application info
    private var application: [String: Any] {
        let bundle = Bundle.main
        return [
            "name": bundle[.CFBundleDisplayName] ?? "",
            "id": bundle.bundleIdentifier ?? "",
            "version": bundle[.CFBundleVersion] ?? ""
        ]
    }

    /// Create a `Dictionary` with team info
    private var team: [String: Any] {
        let bundle = Bundle.main
        var team: [String: Any] = [
            "id": ""
        ]
        if let teamid = bundle["TeamID"] as? String {
            team["id"] = teamid
        } else if let appIdPrefix = bundle["AppIdentifierPrefix"] as? String {
            team["id"] = appIdPrefix.dropLast()
        }
        if let teamid = team["id"] as? String, teamid == "FAKETEAMID" {
            team["id"] = ""
        }
        if let value = bundle["TeamName"] as? String {
            team["name"] = value
        }
        return team
    }

    /// Create a `Dictionary` with current device language info
    private var language: [String: Any] {
        let locale = Locale.current
        var info: [String: Any] = [
            "id": locale.identifier
        ]
        if let langage = locale.languageCode {
            info["code"] = langage
        }
        if let region = locale.regionCode {
            info["region"] = region
        }
        return info
    }

    /// Create a `Dictionary` with current device info
    private var device: [String: Any] {
        let device = Device.current
        let realDevice = device.realDevice
        var info: [String: Any] = [
            "id": Device.token ?? "",  // could be nil if fetchToken not called before
            "description": realDevice.description
        ]
        if let systemVersion = realDevice.systemVersion {
            info["version"] = systemVersion
        }
        if let systemName = realDevice.systemName {
            info["os"] = systemName
        }
        if device.isSimulatorCase {
            info["simulator"] = true
        }
        if Device.isJailBroken {
            info["jb"] = true
        }
        return info
    }

    public var sampleData: Data {
        return stubbedData("restauthenticate")
    }
}
extension AuthTarget: DecodableTargetType {
    public typealias ResultType = AuthToken
}
extension BaseTarget {
    /// Return an `AuthTarget` for authentification process.
    public func authentificate(login: String, password: String? = nil, send: AuthTarget.Send = .link, parameters: [String: Any]? = nil) -> AuthTarget {
        return AuthTarget(parentTarget: self, login: login, password: password, send: send, parameters: parameters)
    }
}
