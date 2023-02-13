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
public class RecordTarget: RecordTargetType {
    let parentTarget: TargetType
    public let table: String
    public let key: CustomStringConvertible
    public let attributes: [String]
    fileprivate var parametersEncoding: ParameterEncoding = URLEncoding.default
    init(parentTarget: BaseTarget, table: String, key: CustomStringConvertible, attributes: [String] = []) {
        self.parentTarget = parentTarget
        self.table = table
        self.key = key
        self.attributes = attributes
    }

    var childPath: String {
        if attributes.isEmpty {
            return "\(table)(\(key))"
        }
        return "\(table)(\(key))/\(attributes.joined(separator: ","))" // XXX check if moya do encoding
    }
    public var method: Moya.Method  = .get

    public var parameters: [String: Any] = [:]

    public var task: Task {
        if parameters.isEmpty {
            return .requestPlain
        }
        return .requestParameters(parameters: parameters, encoding: parametersEncoding)
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
    @discardableResult public func restMethod(_ method: Method) -> Self {
        self.setParameter(.method, method.rawValue)
        self.method = method.method
        // XXX maybe also change parameters encoding, add body or parameters (post  update etc...)
        // parametersEncoding = JSONEncoding
        return self
    }

    func setParameter(_ key: RecordsRequestKey, _ value: Any) {
        parameters[kRecordsRequestKey + key.rawValue] = value
    }

    func getParameter(_ key: RecordsRequestKey) -> Any? {
        return parameters[kRecordsRequestKey + key.rawValue]
    }

    public var restMethod: Method? {
        guard let string = getParameter(.method) as? String else {
            return nil
        }
        return Method(rawValue: string)
    }
}

extension BaseTarget {
    // Returns the data for the specific record defined by the table's primary key
    public func record(from table: String, key: CustomStringConvertible, attributes: [String] = []) -> RecordTarget {
        return RecordTarget(parentTarget: self, table: table, key: key, attributes: attributes)
    }
}

extension RecordTarget: DecodableTargetType {
    public typealias ResultType = RecordJSON
}

// XXX see if could be children of RecordsTarget instead ...
