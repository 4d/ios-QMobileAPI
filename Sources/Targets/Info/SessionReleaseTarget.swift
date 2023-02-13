//
//  SessionReleaseTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 03/07/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

public class SessionReleaseTarget: ChildTargetType {
    let parentTarget: TargetType
    public let id: String
    init(parentTarget: SessionInfoTarget, id: String) {
        self.parentTarget = parentTarget
        self.id = id
    }

    var childPath: String {
        return "id/\(self.id)"
    }
    public let method = Moya.Method.get

    public let task = Task.requestPlain
    public var sampleData: Data {
        return stubbedData("restsessioninfo")
    }
}

extension SessionReleaseTarget: DecodableTargetType {
    public typealias ResultType = SessionInfo
}

extension SessionInfoTarget {
    /// Target to release session
    public func sessionRelease(id: String) -> SessionReleaseTarget { return SessionReleaseTarget(parentTarget: self, id: id) }
}
