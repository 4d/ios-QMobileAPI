//
//  StatusTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 12/12/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Alamofire
import Foundation
import Moya

public class StatusTarget: ChildTargetType {
    let parentTarget: TargetType
    init(parentTarget: BaseTarget) { self.parentTarget = parentTarget }

    let childPath = ""
    public let method = Moya.Method.get

    public let task = Task.requestPlain
    public var sampleData: Data {
        return stubbedData("status")
    }

    public var validationType: ValidationType {
        return .customCodes([200, 401/*unauth*/, 403/*forbidden*/])
    }
}

/// A protocol for Moya target to specify a custom timeout.
public protocol TimeoutTarget {
    /// The timeout defined by the target.
    var timeoutInterval: TimeInterval { get }
}

extension StatusTarget: TimeoutTarget {
    public var timeoutInterval: TimeInterval { return 2 }
}

extension BaseTarget {
    /// Create a status target from base target.
    public var status: StatusTarget { return StatusTarget(parentTarget: self) }
}

extension StatusTarget: DecodableTargetType {
    public typealias ResultType = Status
}
