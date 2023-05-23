//
//  InfoTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 24/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Alamofire

public class InfoTarget: ChildTargetType {
    let parentTarget: TargetType
    init(parentTarget: BaseTarget) { self.parentTarget = parentTarget }

    let childPath = "$info"
    public let method = Moya.Method.get

    public let task = Task.requestPlain
    public var sampleData: Data {
        return stubbedData("restinfo")
    }
}

extension BaseTarget {
    /// Target to get server info
    public var info: InfoTarget { return InfoTarget(parentTarget: self) }
}

extension InfoTarget: DecodableTargetType {
    public typealias ResultType = Info
}
