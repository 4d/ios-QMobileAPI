//
//  RecordTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 24/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

protocol RecordTargetType: ChildTargetType {
    var table: String { get }
    var attributes: [String] { get }
}

// MARK: one record

//  /rest/<table>(<key>)/<attributes,>
/// Returns the data for the specific record defined by the table's primary key
public class RecordTarget: RecordTargetType, RecordsTargetType {

    let parentTarget: TargetType
    public let table: String
    public let key: CustomStringConvertible
    public let attributes: [String]
    public var bodyParameters: [String: Any] = [:]
    fileprivate var parametersEncoding: ParameterEncoding = URLEncoding.default
    init(parentTarget: BaseTarget, table: String, key: CustomStringConvertible, attributes: [String: Any] = [:]) {
        self.parentTarget = parentTarget
        self.table = table
        self.key = key
        self.attributes = [] // ignore
        if RecordsTarget.attributeInBody {
            bodyParameters = attributes
            if bodyParameters.isEmpty {
                method = .get
            } else {
                method = .post
                setParameter(.extendedAttributes, "true")
            }
        } else if !RecordsTarget.attributeInPath {
            self.attributes(Array(attributes.keys)) // use $attributes=
        }
    }
    @discardableResult public func attributes(_ attributes: [String]) -> Self {
        setParameter(.attributes, "\(attributes.joined(separator: ","))") // XXX maybe encode or espace?
        return self
    }
    var childPath: String {
        if !attributes.isEmpty && RecordsTarget.attributeInPath {
            return "\(table)(\(key))/\(attributes.joined(separator: ","))"
        } else {
            return "\(table)(\(key))"
        }
    }
    public var method: Moya.Method  = .get
    public func setHTTPMethod(_ method: Moya.Method) {
        self.method = method
    }

    public var parameters: [String: Any] = [:]

    public var task: Task {
        if parameters.isEmpty {
            return .requestPlain
        }
        if RecordsTarget.attributeInBody {
            if !bodyParameters.isEmpty {
                return .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: JSONEncoding.default, urlParameters: parameters)
            }
        }
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }

    public var sampleData: Data {
        if let restMethod = restMethod {
            switch restMethod {
            case .delete:
                return stubbedData("status")

            default:
                break
            }
        }
        return stubbedData("restrecord")
    }
}

extension RecordTarget {
    // MARK: record $method

    /// Set the $method.
    @discardableResult public func restMethod(_ method: Method) -> Self {
        self.setParameter(.method, method.rawValue)
        self.method = method.method
        // XXX maybe also change parameters encoding, add body or parameters (post  update etc...)
        // parametersEncoding = JSONEncoding
        return self
    }

    public func setParameter(_ key: RecordsRequestKey, _ value: Any) {
        parameters[kRecordsRequestKey + key.rawValue] = value
    }

    public func getParameter(_ key: RecordsRequestKey) -> Any? {
        return parameters[kRecordsRequestKey + key.rawValue]
    }

    /// Return the current rest `Method`
    public var restMethod: Method? {
        guard let string = getParameter(.method) as? String else {
            return nil
        }
        return Method(rawValue: string)
    }
}

extension BaseTarget {
    // Returns the data for the specific record defined by the table's primary key
    public func record(from table: String, key: CustomStringConvertible, attributes: [String: Any] = [:]) -> RecordTarget {
        return RecordTarget(parentTarget: self, table: table, key: key, attributes: attributes)
    }
}

extension RecordTarget: DecodableTargetType {
    public typealias ResultType = RecordJSON
}

// XXX see if could be children of RecordsTarget instead ...
