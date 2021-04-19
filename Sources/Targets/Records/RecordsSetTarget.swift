//
//  RecordsSetTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 27/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

/// Returns the data for the records of  specified table
public final class RecordSetTarget: RecordTargetType, RecordsTargetType {
    static let keyPath = "$entityset"

    let parentTarget: TargetType
    public let table: String
    public let attributes: [String]
    public let id: String
    init(parentTarget: RecordsTarget, id: EntitySetIdConvertible) {
        self.parentTarget = parentTarget
        self.table = parentTarget.table
        self.attributes = parentTarget.attributes
        self.id = id.entitySetID
    }

    var childPath: String {
        // parent is ReRecordsTarget, with already table set
        if attributes.isEmpty {
            return "\(RecordSetTarget.keyPath)/\(id)"
        }
        return "\(RecordSetTarget.keyPath)/\(id)/\(attributes.joined(separator: ","))" // XXX check if moya do encoding
    }
    public var method: Moya.Method = .get

    var parameters: [String: Any] = [:]

    public var task: Task {
        if parameters.isEmpty {
            return .requestPlain
        }
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    public var sampleData: Data {
        if let restMethod = restMethod {
            switch restMethod {
            case .delete:
                return stubbedData("status")

            case .release:
                return stubbedData("status")

            default:
                break
            }
        }
        return stubbedData("restrecords")
    }
}

extension RecordsTarget {
    func set(_ id: EntitySetIdConvertible) -> RecordSetTarget {
        return RecordSetTarget(parentTarget: self, id: id)
    }
}
extension RecordSetTarget: DecodableTargetType {
    public typealias ResultType = Page
}

// MARK: RecordsTargetType
extension RecordSetTarget {
    /// Fill one parameter.
    public func setParameter(_ key: RecordsRequestKey, _ value: Any) {
        parameters[kRecordsRequestKey + key.rawValue] = value
    }

    /// Get one parameter value.
    public func getParameter(_ key: RecordsRequestKey) -> Any? {
        return parameters[kRecordsRequestKey + key.rawValue]
    }

    /// Defined the HTTP method of the request.
    public func setHTTPMethod(_ method: Moya.Method) {
        self.method = method
    }
}
