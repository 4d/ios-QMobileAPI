//
//  UserInfoTarget.swift
//  QMobileAPI
//
//  Created by Quentin Marciset on 01/04/2020.
//  Copyright © 2020 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

/// Define alias for userInfo parameters values.
public typealias UserInfoParameters = [String: Any]

public class UserInfoTarget: ChildTargetType {

    let parentTarget: TargetType

    public let name: String

    init(parentTarget: BaseTarget, name: String) {
        self.parentTarget = parentTarget
        self.name = name
    }

    let childPath = "$userInfo"
    public let method = Moya.Method.post

    open var task: Task {
        if parameters.isEmpty {
            return .requestPlain
        }
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }

    open var parameters: UserInfoParameters = [:] {
        didSet {
            var edited = false
            var parameters: UserInfoParameters = self.parameters

            if var userInfoParameters = parameters["parameters"] as? UserInfoParameters {
                for (key, value) in userInfoParameters {
                    if let encodable = value as? UserInfoParameterEncodable {
                        userInfoParameters[key] = encodable.encodeForUserInfoParameter()
                        edited = true
                    }
                }
                parameters["parameters"] = userInfoParameters
            }

            if edited {
                self.parameters = parameters // do not set a non modified element or an infinite loop will occurs
            }
        }
    }

    public var sampleData: Data {
        return stubbedData("restuserinfo\(name)")
    }
}

/// Procotol to encode objects in api request.
public protocol UserInfoParameterEncodable {
    /// Return a JSON encodable value
    func encodeForUserInfoParameter() -> Any
}

extension Array: UserInfoParameterEncodable where Element: UserInfoParameterEncodable {

    public func encodeForUserInfoParameter() -> Any {
        return self.map { $0.encodeForUserInfoParameter() }
    }
}

extension BaseTarget {
    /// Target to get server info
    public func userInfo(name: String, parameters: [String: Any] =  [:]) -> UserInfoTarget { return UserInfoTarget(parentTarget: self, name: name) }
}

extension UserInfoTarget: DecodableTargetType {
    public typealias ResultType = UserInfoResult
}
