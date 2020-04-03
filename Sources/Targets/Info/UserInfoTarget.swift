//
//  UserInfoTarget.swift
//  QMobileAPI
//
//  Created by Quentin Marciset on 01/04/2020.
//  Copyright © 2020 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

public class UserInfoTarget: ChildTargetType {

    let parentTarget: TargetType
    var userInfo: [String: Any]?
    var deviceToken: String?

    init(parentTarget: BaseTarget, userInfo: [String: Any]?, deviceToken: String?) {
        self.parentTarget = parentTarget
        self.userInfo = userInfo
        self.deviceToken = deviceToken
    }

    let childPath = "$userInfo"
    public let method = Moya.Method.post

    open var task: Task {
        var parameters: [String: Any] = [:]

        if let userInfo = userInfo {
            parameters["userInfo"] = userInfo
        }
        if let deviceToken = deviceToken {
            parameters["device"] = ["token": deviceToken]
        }
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }

    public var sampleData: Data {
        var testFilename = "success"
        if let userInfo = userInfo, let testFailure = userInfo["failure"] as? Bool, testFailure {
            testFilename = "failure"
        }
        return stubbedData("restuserinfo\(testFilename)")
    }
}

extension BaseTarget {
    /// Target to get server info
    public func userInfo(userInfo: [String: Any]? = nil, deviceToken: String? = nil) -> UserInfoTarget { return UserInfoTarget(parentTarget: self, userInfo: userInfo, deviceToken: deviceToken) }
}

extension UserInfoTarget: DecodableTargetType {
    public typealias ResultType = UserInfoResult
}
