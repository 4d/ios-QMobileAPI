//
//  ActionRequest.swift
//  QMobileAPI
//
//  Created by phimage on 13/10/2020.
//  Copyright © 2020 Eric Marchand. All rights reserved.
//

import Foundation

/// Represent a mobile action sent 4D server.
public final class ActionRequest {

    public enum ActionParametersKey: String {
        case parameters, context, metadata

        static let all: [ActionParametersKey] = [.parameters, .context, .metadata]
    }

    /// The action to request.
    public var action: Action

    /// Unique id.
    public var id: String
    /// Parameters value for the actions.
    @StringDictContainer public var actionParameters: ActionParameters?
    /// Context of action executions (ie. record, table, ...)
    @StringDictContainer public var contextParameters: ActionParameters?

    /// Creation of request.
    public var creationDate: Date

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
        self.creationDate = Date()
    }
}

extension ActionRequest: Codable {

    enum CodingKeys: String, CodingKey {
        case action
        case id
        case actionParameters
        case contextParameters
        case creationDate
        case lastDate
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let action = try container.decode(Action.self, forKey: .action)
        let id = try container.decode(String.self, forKey: .id)
        let actionParameters = try container.decodeIfPresent(StringDictContainer.self, forKey: .actionParameters)?.wrappedValue
        let contextParameters = try container.decodeIfPresent(StringDictContainer.self, forKey: .contextParameters)?.wrappedValue
        self.init(action: action, actionParameters: actionParameters, contextParameters: contextParameters, id: id)
        self.creationDate = try container.decode(Date.self, forKey: .creationDate)
        self.lastDate = try container.decodeIfPresent(Date.self, forKey: .lastDate)
        // TODO Add result but apiError is not encodable
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action, forKey: .action)
        try container.encode(id, forKey: .id)
        try container.encode(StringDictContainer(wrappedValue: actionParameters), forKey: .actionParameters)
        try container.encode(StringDictContainer(wrappedValue: contextParameters), forKey: .contextParameters)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(lastDate, forKey: .lastDate)
    }

}

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
