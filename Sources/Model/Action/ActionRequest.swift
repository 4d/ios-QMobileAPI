//
//  ActionRequest.swift
//  QMobileAPI
//
//  Created by phimage on 13/10/2020.
//  Copyright © 2020 Eric Marchand. All rights reserved.
//

import Foundation

/// Represent a mobile action sent 4D server.
public class ActionRequest {

    /// Unique id.
    public var id: String = UUID().uuidString + UUID().uuidString

    /// The action to request.
    public var action: Action

    public var parameters: ActionParameters = [:]

    /// Creation of request.
    public var creationDate: Date = Date()

    /// Last tentative date.
    public var lastDate: Date?

    /// The result, when has been executed
    public var result: Result<ActionResult, APIError>?

    init(action: Action, parameters: ActionParameters) {
        self.action = action
        self.parameters = parameters
    }
}

extension Action {
    /// New request from action.
    public func newRequest(parameters: ActionParameters = [:]) -> ActionRequest {
        return ActionRequest(action: self, parameters: parameters)
    }
}

// extension ActionRequest: Codable {} -> because of Any, not encodable...

extension ActionRequest: Equatable {
    public static func == (lhs: ActionRequest, rhs: ActionRequest) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ActionRequest {

    /// Parameters value for the actions.
    public var userParameters: ActionParameters? {
        return parameters["parameters"] as? ActionParameters
    }

    /// Context of action executions (ie. record, table, ...)
    public var context: ActionParameters? {
        return parameters["context"] as? ActionParameters
    }

    /// Return true if action executed and success.
    public var isSuccess: Bool {
        switch result {
        case .success(let actionResult):
            return actionResult.success
        default:
            return false
        }
    }

}
