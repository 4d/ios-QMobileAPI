//
//  LicenseCheckTarget.swift
//  QMobileAPI
//
//  Created by emarchand on 22/12/2022.
//  Copyright © 2022 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Prephirences

///  mobileapp/$licensecheck/
public class LicenseCheckTarget: ChildTargetType {
    public enum Send: String {
        case link
        case code
    }

    let parentTarget: TargetType
    init(parentTarget: BaseTarget) {
        self.parentTarget = parentTarget
    }

    /// The last path component for request.
    public let childPath = "$licensecheck"
    /// The http method
    public let method = Moya.Method.get

    /// The full path for request. Parent path + `childPath`
    public var path: String {
        return parentTarget.path + "/" + self.childPath
    }

    /// Create `.requestParameters` with user, device and application info.
    public var task: Task {
        return .requestPlain
    }

    public var sampleData: Data {
        return stubbedData("restauthenticate")
    }
}
extension LicenseCheckTarget: DecodableTargetType {
    public typealias ResultType = Status
}
extension BaseTarget {
    /// Return an `LicenseCheckTarget` for license check process.
    func licenseCheck() -> LicenseCheckTarget {
        return LicenseCheckTarget(parentTarget: self)
    }
}
