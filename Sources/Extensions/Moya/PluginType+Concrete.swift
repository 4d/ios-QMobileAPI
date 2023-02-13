//
//  PluginType+Concrete.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 31/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Result

public final class PreparePlugin: PluginType {
    public typealias Closure = (_ request: URLRequest, _ target: TargetType) -> URLRequest
    let closure: Closure

    public init(closure: @escaping Closure) {
        self.closure = closure
    }

    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return closure(request, target)
    }
}

public final class ReceivePlugin: PluginType {
    public typealias Closure = (_ result: Result<Moya.Response, MoyaError>, _ target: TargetType) -> Void
    let closure: Closure

    public init(closure: @escaping Closure) {
        self.closure = closure
    }

    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        closure(result, target)
    }
}
