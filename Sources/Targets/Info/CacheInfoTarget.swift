//
//  CacheInfo.swift
//  QMobileAPI
//
//  Created by anass talii on 04/07/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Alamofire

public class CacheInfoTarget: ChildTargetType {
    let parentTarget: TargetType
    init(parentTarget: InfoTarget) { self.parentTarget = parentTarget }

    let childPath = "cacheInfo"
    public let method = Moya.Method.get

    public let task = Task.requestPlain
    public var sampleData: Data {
        return stubbedData("CacheInfo")
    }
}

extension CacheInfoTarget: DecodableTargetType {
    public typealias ResultType = CacheInfo
}

extension InfoTarget {
    /// Target to get progress info
    public var cacheInfo: CacheInfoTarget { return CacheInfoTarget(parentTarget: self) }
}
