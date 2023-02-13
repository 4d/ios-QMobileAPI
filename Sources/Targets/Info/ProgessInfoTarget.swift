//
//  ProgessInfoTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 03/07/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

public class ProgessInfoTarget: ChildTargetType {
    let parentTarget: TargetType
    init(parentTarget: InfoTarget) { self.parentTarget = parentTarget }

    let childPath = "progressInfo"
    public let method = Moya.Method.get

    public let task = Task.requestPlain
    public var sampleData: Data {
        return stubbedData("restprogressinfo")
    }
}

extension ProgessInfoTarget: DecodableTargetType {
    public typealias ResultType = ProgressInfo
}

extension InfoTarget {
    /// Target to get progress info
    public var progressInfo: ProgessInfoTarget { return ProgessInfoTarget(parentTarget: self) }
}
