//
//  RecordsTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 27/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Prephirences

/// Returns the data for the records of  specified table
public final class RecordsTarget: RecordTargetType, RecordsTargetType {
    let parentTarget: TargetType
    public let table: String
    public let attributes: [String]

    static let attributeInPath = false

    init(parentTarget: BaseTarget, table: String, attributes: [String] = []) {
        self.parentTarget = parentTarget
        self.table = table
        self.attributes = attributes
        if !RecordsTarget.attributeInPath {
            self.attributes(attributes)
        }
    }

    var childPath: String {
        if attributes.isEmpty {
            return table
        }
        if RecordsTarget.attributeInPath {
            return "\(table)/\(attributes.joined(separator: ","))"
        } else {
            return table
        }
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

            default:
                break
            }
        }
        if table == DeletedRecordKey.entityName {
            return stubbedData("restdeletedrecords")
        }
        /*if Prephirences.sharedInstance["stub.records.dataAsset"] as? Bool ?? false {
            if let dataSet = NSDataAsset(name: table) {
                return dataSet.data
            }
            return Data()
        }*/
        if Prephirences.sharedInstance["stub.records.withTable"] as? Bool ?? false {
            return stubbedData("\(table).data")
        }
        return stubbedData("restrecords")
    }
}

extension BaseTarget {
    /// Returns the data for the records of  specified table
    public func records(from table: String, attributes: [String] = []) -> RecordsTarget {
        return RecordsTarget(parentTarget: self, table: table, attributes: attributes)
    }

    /// Returns the data for the special table for deleted records
    public func deletedRecords() -> RecordsTarget {
        return RecordsTarget(parentTarget: self, table: DeletedRecordKey.entityName, attributes: [])
    }

    /// Returns the data for the records of  specified table
    public func records(from table: Table, attributes: [String] = []) -> RecordsTarget {
        return RecordsTarget(parentTarget: self, table: table.name, attributes: attributes)
    }
}

extension RecordsTarget: DecodableTargetType {
    public typealias ResultType = Page
}

// To avoid mutating
extension RecordsTarget {
    public func setParameter(_ key: RecordsRequestKey, _ value: Any) {
        parameters[kRecordsRequestKey + key.rawValue] = value
    }

    public func getParameter(_ key: RecordsRequestKey) -> Any? {
        return parameters[kRecordsRequestKey + key.rawValue]
    }

    public func setHTTPMethod(_ method: Moya.Method) {
        self.method = method
    }
}
