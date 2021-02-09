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
        case parameters, context, metadata

        static let all: [ActionParametersRootKey] = [.parameters, .context, .metadata]
    }

    public enum State: String, Codable {
        case ready, executing, /* pending,*/ finished, cancelled
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

    }

    /// The action to request.
    public var action: Action

    /// Unique id.
    public var id: String
    /// Parameters value for the actions.
    @StringDictContainer public var actionParameters: ActionParameters?
    /// Context of action executions (ie. record, table, ...)
    @StringDictContainer public var contextParameters: ActionParameters?

    public var state: ActionRequest.State

    /// Creation of request.
    public var creationDate: Date

    /// Last tentative date.
    public var lastDate: Date?

    /// The result, when has been executed
    public var result: Result<ActionResult, ActionRequest.Error>? {
        didSet {
            tryCount += 1
        }
    }

    /// Try count
    public var tryCount: Int = 0

    public var summary: String {
        if let statusText = statusText {
            return statusText
        }
        var summary = ""
        /*if let parameters = self.contextParameters {
            summary += parameters.values.compactMap({$0 as? String}).joined(separator: ",")
        }*/
        if let parameters = self.actionParameters {
            if self.contextParameters != nil {
                summary += ","
            }
            summary += parameters.values.compactMap({$0 as? String}).joined(separator: ",")
        }
        return summary
    }

    /// Create a new action request
    public init(action: Action, actionParameters: ActionParameters? = nil, contextParameters: ActionParameters? = nil, id: String? = nil, state: ActionRequest.State? = nil, result: Result<ActionResult, APIError>? = nil) {
        self.action = action
        self.actionParameters = actionParameters
        self.contextParameters = contextParameters
        self.id = id ?? UUID().uuidString.replacingOccurrences(of: "-", with: "")
        self.creationDate = Date()
        self.state = state ?? .ready
        self.result = result?.mapError { ActionRequest.Error($0) }
    }
}

/// Some well known key for ActionParameters (not public yet)
public struct ActionParametersKey {
    public static let table = "dataClass"
    public static let record = "entity"
    public static let primaryKey = "primaryKey"
    public static let parent = "parent"
    public static let relationName = "relationName"
}

extension ActionRequest {

    public var statusText: String? {
        return result?.statusText
    }

    public var tableName: String {
        guard let context = self.contextParameters else {
            return ""
        }
        return context[ActionParametersKey.table] as? String ?? ""
    }

}

extension Result where Success == ActionResult, Failure == ActionRequest.Error {

    public var statusText: String? {
        switch self {
        case .success(let value):
            return value.statusText
        case .failure(let error):
            return error.statusText
        }
    }
}

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
        case id
        case actionParameters
        case contextParameters
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
        let id = try container.decode(String.self, forKey: .id)
        let actionParameters = try container.decodeIfPresent(StringDictContainer.self, forKey: .actionParameters)?.wrappedValue
        let contextParameters = try container.decodeIfPresent(StringDictContainer.self, forKey: .contextParameters)?.wrappedValue
        self.init(action: action, actionParameters: actionParameters, contextParameters: contextParameters, id: id)
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
        try container.encode(id, forKey: .id)
        try container.encode(StringDictContainer(wrappedValue: actionParameters), forKey: .actionParameters)
        try container.encode(StringDictContainer(wrappedValue: contextParameters), forKey: .contextParameters)
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
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ActionRequest {

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
        switch result {
        case .success:
            return true
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

}

extension Action {
    /// New request from action.
    public func newRequest(actionParameters: ActionParameters? = nil, contextParameters: ActionParameters? = nil, id: String? = nil) -> ActionRequest {
        return ActionRequest(action: self, actionParameters: actionParameters, contextParameters: contextParameters, id: id)
    }
}

/*
extension APIError: Codable {

    private enum CodingKeys: String, CodingKey {
        case jsonMappingFailed
        case recordsDecodingFailed
        case request
        case jsonDecodingFailed
        case stringDecodingFailed
    }

    enum CodingError: Error {
        case decoding(String)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(String.self, forKey: .jsonMappingFailed) {
            self = .jsonMappingFailed(JSON(), nil)
        }
        else if let value = try? values.decode(String.self, forKey: .jsonMappingFailed) {
            self = .jsonMappingFailed(JSON(), nil)
        }

        throw CodingError.decoding("Whoops! \(dump(values))")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .jsonMappingFailed(let json, let type):
            try container.encode("", forKey: .jsonMappingFailed)
        case .recordsDecodingFailed(let json, let error):
            try container.encode("", forKey: .recordsDecodingFailed)
        case .request(let error):
            try container.encode("", forKey: .request)
        case .jsonDecodingFailed(let error):
            try container.encode("", forKey: .jsonDecodingFailed)
        case .stringDecodingFailed(let error):
            try container.encode("", forKey: .stringDecodingFailed)
        }
    }
}
*/
/*
enum DecodableEnum<Enum: RawRepresentable> where Enum.RawValue == String {
    case value(Enum)
    case error(DecodingError)

    var value: Enum? {
        switch self {
        case .value(let value): return value
        case .error: return nil
        }
    }

    var error: DecodingError? {
        switch self {
        case .value: return nil
        case .error(let error): return error
        }
    }

    enum DecodingError: Error {
        case notDefined(rawValue: String)
        case decoding(error: Error)
    }
}

extension DecodableEnum: Decodable {
    init(from decoder: Decoder) throws {
        do {
            let rawValue = try decoder.singleValueContainer().decode(String.self)
            guard let layout = Enum(rawValue: rawValue) else {
                self = .error(.notDefined(rawValue: rawValue))
                return
            }
            self = .value(layout)
        } catch let err {
            self = .error(.decoding(error: err))
        }
    }
}
*/
