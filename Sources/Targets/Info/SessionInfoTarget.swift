//
//  SessionInfoTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 03/07/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

public class SessionInfoTarget: ChildTargetType {
    let parentTarget: TargetType
    init(parentTarget: InfoTarget) { self.parentTarget = parentTarget }

    let childPath = "sessionInfo"
    public let method = Moya.Method.get

    public let task = Task.requestPlain
    public var sampleData: Data {
        return stubbedData("restsessioninfo")
    }
}

extension SessionInfoTarget: DecodableTargetType {
    public typealias ResultType = SessionInfo
}

extension InfoTarget {
    /// Target to get session info
    public var sessionInfo: SessionInfoTarget { return SessionInfoTarget(parentTarget: self) }
}
