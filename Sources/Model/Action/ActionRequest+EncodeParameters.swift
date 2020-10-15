//
//  ActionRequest+EncodeParameters.swift
//  QMobileAPI
//
//  Created by phimage on 15/10/2020.
//  Copyright © 2020 Eric Marchand. All rights reserved.
//

import Foundation

extension ActionRequest {

    /// The full parameters.
    public var parameters: ActionParameters {
        var parameters: ActionParameters = [:]
        parameters["id"] = self.id
        if let subParameters = actionParameters {
            parameters[ActionParametersKey.parameters.rawValue] = subParameters
        }
        if let subParameters = contextParameters {
            parameters[ActionParametersKey.context.rawValue] = subParameters
        }
        ActionRequest.encodeParameters(parameters: &parameters)
        return parameters
    }

    static func encodeParameters( parameters: inout ActionParameters) {
        let actionsKeys: [ActionParametersKey] = [.parameters, .context]
        for actionKey in actionsKeys {
            if var actionParameters = parameters[actionKey.rawValue] as? ActionParameters {
                for (key, value) in actionParameters {
                    if let encodable = value as? ActionParameterEncodable {
                        actionParameters[key] = encodable.encodeForActionParameter()
                       // edited = true

                        if let metadataForEncodable = encodable.metadata() {
                            // get
                            var metadata: [String: [String: Any]] = parameters[ActionParametersKey.metadata.rawValue] as? [String: [String: Any]] ?? [:]
                            // modify
                            if metadata[actionKey.rawValue] == nil {
                                metadata[actionKey.rawValue] = [:]
                            }
                            metadata[actionKey.rawValue]?[key] = metadataForEncodable
                            // save
                            parameters[ActionParametersKey.metadata.rawValue] = metadata
                        }
                    }
                }
                parameters[actionKey.rawValue] = actionParameters
            }
        }
    }

}

/// Procotol to encode objects in api request.
public protocol ActionParameterEncodable {

    /// Return a JSON encodable value
    func encodeForActionParameter() -> Any

    /// Return if needed some metadata to help decoding on server.
    func metadata() -> Any?
}
extension ActionParameterEncodable {

    public func metadata() -> Any? {
        return nil
    }
}

private let actionDateFormatter: DateFormatter = DateFormatter.simpleDate // ISO8601DateFormatter()
extension Date: ActionParameterEncodable {

    public func encodeForActionParameter() -> Any {
        return actionDateFormatter.string(from: self)
    }
    public func metadata() -> Any? {
        return "simpleDate"
    }
}

extension UploadResult: ActionParameterEncodable {

    public func encodeForActionParameter() -> Any {
        return self.id
    }
    public func metadata() -> Any? {
        return "uploaded"
    }
}

extension Array: ActionParameterEncodable where Element: ActionParameterEncodable {

    public func encodeForActionParameter() -> Any {
        return self.map { $0.encodeForActionParameter() }
    }

    public func metadata() -> Any? {
        let types = self.compactMap { $0.metadata() }
        if sameType(types), let first = types.first {
            return ["collection": first]
        }
        return ["collection": self.compactMap { $0.metadata() }]
    }

    func sameType(_ types: [Any?]) -> Bool {
        // support string only for the moment
        let strings = types.compactMap { $0 as? String }
        if strings.count != types.count {
            return false
        }
        return strings.isElementEquals
    }
}

extension Array where Element: Equatable {

    fileprivate var isElementEquals: Bool {
        if let firstElem = self.first {
            for elem in self where elem != firstElem {
                return false
            }
        }
        return true
    }

}
