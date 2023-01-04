//
//  LogOutTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 17/05/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Prephirences

// MARK: log out
///  mobileapp/$logout/
public class LogOutTarget: ChildTargetType, TimeoutTarget {
    let parentTarget: TargetType
    var token: String?

    init(parentTarget: BaseTarget, token: String? = nil) {
        self.parentTarget = parentTarget
        self.token = token
    }

    // For test purpose use an alternative path
    public static var alternativePath: String?

    /// The last path component for request.
    public let childPath = "$logout"
    /// The http method
    public let method = Moya.Method.post

    /// The full path for request. Parent path + `childPath`
    public var path: String {
        return parentTarget.path + "/" + self.childPath
    }

    public var headers: [String: String]? {
        guard let token = token else {
            return nil
        }
        return ["Authorization": "Bearer \(token)"]
    }

    /// Create `.requestParameters` with user, device and application info.
    public var task: Task { // latter maybe post token as json
        return .requestPlain
    }

    public var sampleData: Data {
        return stubbedData("restlogout")
    }

    public var timeoutInterval: TimeInterval = 1 // XXX change value if logout implemented on server
}

extension LogOutTarget: DecodableTargetType {
    public typealias ResultType = Status
}
extension BaseTarget {
    public func logout(token: String? = nil) -> LogOutTarget {
        return LogOutTarget(parentTarget: self, token: token)
    }
}
