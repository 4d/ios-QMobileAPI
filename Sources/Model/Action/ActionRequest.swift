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

    public enum ActionParametersRootKey: String {
        case parameters, context, metadata, id
    }

    public enum State: String, Codable {
        case ready, executing, /* pending,*/ completed, cancelled

        public var isFinal: Bool {
            switch self {
            case .completed, .cancelled:
                return true
            default:
                return false
            }
        }
    }

    // Map api error to an encodable error.
    public struct Error: Swift.Error, Codable {

        public var errorDescription: String
        public var restErrors: RestErrors?
        public var failureReason: String?
        public var isUnauthorized: Bool
        public var mustRetry: Bool

        public init(_ error: APIError) {
            self.errorDescription = error.errorDescription ?? ""
            self.restErrors = error.restErrors
            if case .sessionTaskFailed(let urlError) = error.afError {
                self.failureReason = urlError.localizedDescription
            } else if let failureReason = error.failureReason {
                self.failureReason = failureReason
            }
            self.isUnauthorized = error.isHTTPResponseWith(code: .unauthorized)
            self.mustRetry = true

            if restErrors != nil { // dev wanted error so no retry
                self.mustRetry = false
            }
        }
        public var statusText: String? {
            return self.restErrors?.statusText
        }

        public var isNoLicences: Bool {
            self.restErrors?.match(.mobile_no_licenses) ?? false
        }

        public static let cancelError = ActionRequest.Error(APIError.request(NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)))

    }

    // MARK: - properties

    /// The action to request.
    public var action: Action

    /// All parameters
    @StringDictContainer public var parameters: ActionParameters

    /// The request state.
    public var state: ActionRequest.State

    /// Creation of request.
    public var creationDate: Date

    /// Final execution date.
    public var lastDate: Date?

    /// The result, when has been executed
    public var result: Result<ActionResult, ActionRequest.Error>? {
        didSet {
            tryCount += 1
        }
    }

    /// Try count
    public var tryCount: Int = 0

    // MARK: - computed properies

    /// Unique id.
    public var id: String {
        return parameters[ActionParametersRootKey.id] as? String ?? ""
    }
    /// Parameters value for the actions.
    public var actionParameters: ActionParameters? {
        get {
            return parameters[ActionParametersRootKey.parameters] as? ActionParameters
        }
        set {
            parameters[ActionParametersRootKey.parameters] = newValue
        }
    }
    /// Set an action parameter value.
    public func setActionParameters(key: String, value: Any) {
        var actionParameters = (parameters[ActionParametersRootKey.parameters] as? ActionParameters)
        actionParameters?[key] = value
        self.parameters[ActionParametersRootKey.parameters] = actionParameters
    }
    /// Remove an action parameter value.
    public func removeActionParameters(key: String) {
        var actionParameters = (parameters[ActionParametersRootKey.parameters] as? ActionParameters)
        actionParameters?.removeValue(forKey: key)
        self.parameters[ActionParametersRootKey.parameters] = actionParameters
    }
    /// Context of action executions (ie. record, table, ...)
    public var contextParameters: ActionParameters? {
        return parameters[ActionParametersRootKey.context] as? ActionParameters
    }
    /// Meta data of action (for instance to ask server to convert JSON data to Date or Picture)
    public var metadataParameters: ActionParameters? {
        return parameters[ActionParametersRootKey.metadata] as? ActionParameters
    }

    /// Return the result status text if task finish and have status text from server.
    public var statusText: String? {
        return result?.statusText
    }

    /// Return the table name from context.
    public var tableName: String {
        guard let context = self.contextParameters else {
            return ""
        }
        return context[ActionParametersKey.table] as? String ?? ""
    }

    /// Compute a summary information of record (ie. primary id)
    public var recordSummary: String {
        guard let context = self.contextParameters,
              let recordContext = context[ActionParametersKey.record] as? [String: Any],
              let primaryKey = recordContext[ActionParametersKey.primaryKey] else {
            return ""
        }
        return "\(primaryKey)"
    }

    /// Return true if the action has been  executed and is success.
    public var isSuccess: Bool {
        switch result {
        case .success(let actionResult):
            return actionResult.success
        default:
            return false
        }
    }

    /// Return true if action has been executed without error.
    public var isCompleted: Bool {
        if state == .cancelled {
            return true
        }
        switch result {
        case .success:
            return true
        default:
            return false
        }
    }

    /// Return true if the action has been  executed and is failure.
    public var isFailure: Bool {
        switch result {
        case .success(let actionResult):
            return !actionResult.success
        default:
            return false
        }
    }

    /// Has receive result.
    public var hasResult: Bool {
        return result != nil
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

    /// Generate an ir for action.
    public static func generateID(_ action: Action) -> String {
        if action.isOnlineOnly {
            return ""
        }
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }

    // MARK: - init
    /// Create a new action request with action and context parameters
    public convenience init(
        action: Action,
        actionParameters: ActionParameters? = nil,
        contextParameters: ActionParameters? = nil,
        id: String,
        state: ActionRequest.State? = nil,
        result: Result<ActionResult, APIError>? = nil) {

        var parameters: ActionParameters = [:]
        parameters["id"] = id
        if let subParameters = actionParameters {
            parameters[ActionParametersRootKey.parameters] = subParameters
        }
        if let subParameters = contextParameters {
            parameters[ActionParametersRootKey.context] = subParameters
        }
        ActionRequest.encodeParameters(parameters: &parameters)
        self.init(action: action, parameters: parameters, state: state, result: result)
    }

    /// Create a new action request with raw attributes
    public init(action: Action, parameters: ActionParameters? = nil, state: ActionRequest.State? = nil, result: Result<ActionResult, APIError>? = nil) {
        self.action = action
        self.parameters = parameters ?? [:]
        self.creationDate = Date()
        self.state = state ?? .ready
        self.result = result?.mapError { ActionRequest.Error($0) }
    }

    // MARK: - methods

    /// Reset result ie. set no nil.
    public func resetResult() {
        result = nil
    }

    /// Encode current parmeters for request.
    public func encodeParameters() {
        ActionRequest.encodeParameters(parameters: &parameters)
    }
    /// Decode current parametes for request.
    public func decodeParameters() {
        // TODO if there is meta and encoded data find the inverse info decode it
        guard let actionParams = parameters[ActionParametersRootKey.parameters] as? ActionParameters else {
            return
        }

        /*  var metaData = parameters[ActionParametersRootKey.metadata] as? ActionParameters
        metaData = metaData?[ActionParametersRootKey.parameters.rawValue] as? ActionParameters

       for (fieldKey, type) in metaData ?? [:] {
            if type as? String == "simpleDate", let value = actionParams?[fieldKey] as? String {
                // actionParams?[fieldKey] = value.simpleDate
                setActionParameters(key: fieldKey, value: value.simpleDate ?? nil)
            }
        }*/
        for parameter in self.action.parameters ?? [] {
            switch parameter.type {
            case .date:
                // restore data type
                if let value = actionParams[parameter.name] as? String, let date = value.simpleDate {
                    setActionParameters(key: parameter.name, value: date)
                }
            default:
                break
            }
        }
    }
}

// MARK: - protocol implementation

extension ActionRequest: CustomStringConvertible {
    public var description: String {
        return "ActionRequest[\(self.action), \(self.creationDate)]"
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension ActionRequest: ObservableObject {
}

extension ActionRequest: Codable {

    enum CodingKeys: String, CodingKey {
        case action
        case parameters
        case creationDate
        case lastDate
        case tryCount
        case result
        case error
        case state
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let action = try container.decode(Action.self, forKey: .action)
        let parameters = try container.decodeIfPresent(StringDictContainer.self, forKey: .parameters)?.wrappedValue
        self.init(action: action, parameters: parameters)
        self.creationDate = try container.decode(Date.self, forKey: .creationDate)
        self.lastDate = try container.decodeIfPresent(Date.self, forKey: .lastDate)
        self.tryCount = try container.decode(Int.self, forKey: .tryCount)
        self.state = try container.decode(State.self, forKey: .state)
        if let actionResult = try container.decodeIfPresent(ActionResult.self, forKey: .result) {
            self.result = .success(actionResult)
        } else if let actionRequestError = try container.decodeIfPresent(ActionRequest.Error.self, forKey: .error) {
            self.result = .failure(actionRequestError)
        } else {
            self.result = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action, forKey: .action)
        try container.encode(StringDictContainer(wrappedValue: parameters), forKey: .parameters)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(lastDate, forKey: .lastDate)
        try container.encode(tryCount, forKey: .tryCount)
        try container.encode(state, forKey: .state)
        if let result = self.result {
            switch result {
            case .success(let value):
                try container.encode(value, forKey: .result)
            case .failure(let error):
                try container.encode(error, forKey: .error)
            }
        } else {
            // try container.encodeNil(forKey: .result)
        }
    }

}

extension ActionRequest: Equatable {
    public static func == (lhs: ActionRequest, rhs: ActionRequest) -> Bool {
        return lhs.id == rhs.id && lhs.action.name == rhs.action.name
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - others

// MARK: dico key

/// Some well known key for ActionParameters (not public yet)
public struct ActionParametersKey {
    /// Api key for table/dataClass
    public static let table = "dataClass"
    /// Api key for record/entity
    public static let record = "entity"
    /// Api key for primary key
    public static let primaryKey = "primaryKey"
    /// Api key or paret
    public static let parent = "parent"
    /// Api key for relation.
    public static let relationName = "relationName"
}

// MARK: action

extension Action {
    /// New request from action.
    public func newRequest(actionParameters: ActionParameters? = nil, contextParameters: ActionParameters? = nil, id: String) -> ActionRequest {
        return ActionRequest(action: self, actionParameters: actionParameters, contextParameters: contextParameters, id: id)
    }
}

// MARK: Result

extension Result where Success == ActionResult, Failure == ActionRequest.Error {

    /// Return `statusText` from server response if any.
    public var statusText: String? {
        switch self {
        case .success(let value):
            return value.statusText
        case .failure(let error):
            return error.statusText
        }
    }
}

// MARK: Dictionary

extension Dictionary where Key == String {
    subscript(_ key: ActionRequest.ActionParametersRootKey) -> Value? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue
        }
    }
}
