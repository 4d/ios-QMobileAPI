//
//  APIManager+Method.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 23/01/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Alamofire

extension APIManager {
    /// Call method on table.
    public func method(table: String,
                       name: String,
                       parameters: [String: Any] = [:],
                       httpMethod: Moya.Method = Moya.Method.get,
                       callbackQueue: DispatchQueue? = nil,
                       progress: ProgressHandler? = nil,
                       completionHandler: @escaping APIManager.Completion) -> Cancellable {
        let target: TableMethodTarget = self.base.records(from: table).method(name: name)
        target.parameters = parameters
        target.method = httpMethod
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public func method(table: Table,
                       method: TableMethod,
                       parameters: [String: Any] = [:],
                       httpMethod: Moya.Method = Moya.Method.get,
                       callbackQueue: DispatchQueue? = nil,
                       progress: ProgressHandler? = nil,
                       completionHandler: @escaping APIManager.Completion) -> Cancellable {
        let target: TableMethodTarget = self.base.records(from: table).method(name: method.name)
        target.parameters = parameters
        target.method = httpMethod
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }
}
