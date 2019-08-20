//
//  APIManagerAction.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/12/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

extension APIManager {

    public typealias CompletionApplicationInfoHandler = ((Result<ApplicationInfo, APIError>) -> Void)
    /// Get server status
    public func loadApplicationInfo(actionName: String = "mdm_application", bundleId: String, callbackQueue: DispatchQueue? = nil, completionHandler: @escaping CompletionApplicationInfoHandler) -> Cancellable {
        let target: ApplicationInfoTarget = self.base.actionTarget.applicationInfo(actionName: actionName, bundleId: bundleId)

        return self.request(target, callbackQueue: callbackQueue, completion: completionHandler)
    }

    /// Call mobile action by name.
    public typealias CompletionActionHandler = ((Result<ActionResult, APIError>) -> Void)
    public func action(name: String,
                       parameters: ActionParameters = [:],
                       httpMethod: Moya.Method = ActionAbstractTarget.defaultMethod,
                       callbackQueue: DispatchQueue? = nil,
                       progress: ProgressHandler? = nil,
                       completionHandler: @escaping CompletionActionHandler) -> Cancellable {
        let target: ActionTarget = self.base.actionTarget.action(name: name)
        target.parameters = parameters
        target.method = httpMethod
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    /// Call mobile action.
    public func action(_ action: Action,
                       parameters: ActionParameters = [:],
                       httpMethod: Moya.Method = ActionAbstractTarget.defaultMethod,
                       callbackQueue: DispatchQueue? = nil,
                       progress: ProgressHandler? = nil,
                       completionHandler: @escaping CompletionActionHandler) -> Cancellable {
        return self.action(name: action.name,
                           parameters: parameters,
                           httpMethod: httpMethod,
                           callbackQueue: callbackQueue,
                           progress: progress,
                           completionHandler: completionHandler)
    }
}
