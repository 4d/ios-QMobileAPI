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

    public enum ActionParametersKey: String {
        case parameters, context, metadata

        static let all: [ActionParametersKey] = [.parameters, .context, .metadata]
    }

    /// The action to request.
    public var action: Action

    /// Unique id.
    public var id: String
    /// Parameters value for the actions.
    public var actionParameters: ActionParameters?
    /// Context of action executions (ie. record, table, ...)
    public var contextParameters: ActionParameters?

    /// Creation of request.
    public var creationDate: Date = Date()

    /// Last tentative date.
    public var lastDate: Date?

    /// The result, when has been executed
    public var result: Result<ActionResult, APIError>?

    /// Create a new action request
    public init(action: Action, actionParameters: ActionParameters? = nil, contextParameters: ActionParameters? = nil, id: String? = nil) {
        self.action = action
        self.actionParameters = actionParameters
        self.contextParameters = contextParameters
        self.id = id ?? UUID().uuidString.replacingOccurrences(of: "-", with: "")
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

    /// Return true if action executed and success.
    public var isSuccess: Bool {
        switch result {
        case .success(let actionResult):
            return actionResult.success
        default:
            return false
        }
    }

    /// Has receive result.
    public var hasResult: Bool {
        return result != nil
    }

    /// Reset result ie. set no nil.
    public func resetResult() {
        result = nil
    }

    /// The action result if any (ie. have result and no error.
    public var actionResult: ActionResult? {
        switch result {
        case .success(let actionResult):
            return actionResult
        default:
            return nil
        }
    }

    /// The action result if any (ie. have result and no error.
    public var apiError: APIError? {
        switch result {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}

extension Action {
    /// New request from action.
    public func newRequest(actionParameters: ActionParameters? = nil, contextParameters: ActionParameters? = nil, id: String? = nil) -> ActionRequest {
        return ActionRequest(action: self, actionParameters: actionParameters, contextParameters: contextParameters, id: id)
    }
}
