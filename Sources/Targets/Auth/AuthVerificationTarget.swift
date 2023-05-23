//
//  AuthTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/03/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import Prephirences

// MARK: authentificate
/// mobileapp/$verify/
public class AuthVerificationTarget: ChildTargetType {
    let parentTarget: TargetType
    var token: String

    init(parentTarget: BaseTarget, token: String) {
        self.parentTarget = parentTarget
        self.token = token
    }

    // For test purpose use an alternative path
    public static var alternativePath: String?

    /// The last path component for request.
    public let childPath = "$verify"
    /// The http method
    public let method = Moya.Method.post

    /// The full path for request. Parent path + `childPath`
    public var path: String {
        return parentTarget.path + "/" + self.childPath
    }

    /// Create `.requestParameters` with user, device and application info.
    public var task: Task {
        let parameters: [String: Any] = [
            "token": self.token
        ]
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }

    public var sampleData: Data {
        return stubbedData("restauthentificate")
    }
}
extension AuthVerificationTarget: DecodableTargetType {
    public typealias ResultType = AuthToken
}
extension BaseTarget {
    /// Return an `AuthVerificationTarget` for authentification process.
    public func authentificate(token: String) -> AuthVerificationTarget {
        return AuthVerificationTarget(parentTarget: self, token: token)
    }
}
