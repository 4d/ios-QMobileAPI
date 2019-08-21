//
//  ActionTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 01/03/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

/// Define alias for action parameters values.
public typealias ActionParameters = [String: Any]

/// An abstract target to execute actions by its name.
open class ActionAbstractTarget: ChildTargetType {

    public enum ActionKey: String {
        case parameters, context, metadata

        static let all: [ActionKey] = [.parameters, .context, .metadata]
    }

    let parentTarget: TargetType
    public let name: String

    public init(parentTarget: ActionRootTarget, name: String) {
        self.parentTarget = parentTarget
        self.name = name
    }

    open var childPath: String {
        return name
    }

    open var method = ActionAbstractTarget.defaultMethod
    public static let defaultMethod = Moya.Method.post

    open var task: Task {
        if parameters.isEmpty {
            return .requestPlain
        }
        switch method {
        case .get:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            // TODO Alamofire 5 use JSONParameterEncoder?
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }

    open var parameters: ActionParameters = [:] {
        didSet {
            var edited = false
            var parameters: ActionParameters = self.parameters

            let actionsKeys: [ActionKey] = [.parameters, .context]
            for actionKey in actionsKeys {
                if var actionParameters = parameters[actionKey.rawValue] as? ActionParameters {
                    for (key, value) in actionParameters {
                        if let encodable = value as? ActionParameterEncodable {
                            actionParameters[key] = encodable.encodeForActionParameter()
                            edited = true

                            if let metadataForEncodable = encodable.metadata() {
                                // get
                                var metadata: [String: [String: Any]] = parameters[ActionKey.metadata.rawValue] as? [String: [String: Any]] ?? [:]
                                // modify
                                if metadata[actionKey.rawValue] == nil {
                                    metadata[actionKey.rawValue] = [:]
                                }
                                metadata[actionKey.rawValue]?[key] = metadataForEncodable
                                // save
                                parameters[ActionKey.metadata.rawValue] = metadata
                            }
                        }
                    }
                    parameters[actionKey.rawValue] = actionParameters
                }
            }
            if edited {
                self.parameters = parameters // do not set a non modified element or an infinite loop will occurs
            }
        }
    }

    open var sampleData: Data {
        return stubbedData("restactionabstract")
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

/*
import Alamofire
struct JSONEncoderEncoding: ParameterEncoding {
    static let `default` = JSONArrayEncoding()

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()

        guard let json = parameters?["jsonArray"] else {
            return request
        }

        let data = try JSONSerialization.data(withJSONObject: json, options: [])

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        request.httpBody = data

        return request
    }
}*/

/// A concrete target to execute actions by its name and result decoded as `ActionResult`
open class ActionTarget: ActionAbstractTarget {

    open override var sampleData: Data {
        return stubbedData("restaction\(name)")
    }
}

extension ActionTarget: DecodableTargetType {
    public typealias ResultType = ActionResult
}
