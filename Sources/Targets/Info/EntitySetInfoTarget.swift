//
//  EntitySetTarget.swift
//  QMobileAPI
//
//  Created by anass talii on 04/07/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//
import Foundation
import Moya
import Alamofire

public class EntitySetInfoTarget: ChildTargetType {
    let parentTarget: TargetType
    init(parentTarget: InfoTarget) { self.parentTarget = parentTarget }
    let childPath = "entitySet"
    public let method = Moya.Method.get
    public let task = Task.requestPlain
    public var sampleData: Data {
        return stubbedData("EntitySetInfo")
    }
}

extension EntitySetInfoTarget: DecodableTargetType {
    public typealias ResultType = EntitySetInfo
}

extension InfoTarget {
    /// Target to get progress info
    public var entitySetInfo: EntitySetInfoTarget { return EntitySetInfoTarget(parentTarget: self) }
}
