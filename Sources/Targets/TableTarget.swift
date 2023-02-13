//
//  TableTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

// rest/$catalog/{TableName}
/// Returns information about a table and its attributes.
public class TableTarget: ChildTargetType {
    public static let allPath = "$all"
    public static let deletedRecords = DeletedRecordKey.entityName

    let parentTarget: TargetType
    public let name: String
    init(parentTarget: CatalogTarget, name: String) {
        self.parentTarget = parentTarget
        self.name = name
    }

    var childPath: String {
        return name
    }
    public let method = Moya.Method.get

    // Could do $metadata=true -> never_null or autosequence, but not identifying

    public let task = Task.requestPlain
    public var sampleData: Data {
        if name == TableTarget.allPath {
            return stubbedData("restcatalogall")
        }
        // XXX maybe if file exist restcatalog + tablename...
        return stubbedData("resttable")
    }
}
extension TableTarget: DecodableTargetType {
    public typealias ResultType = Table
}

extension CatalogTarget {
    /// Returns information about all of your project's datastore classes and their attributes
    public var all: TableTarget {
        return table(TableTarget.allPath)
    }
    /// Returns information about a table and its attributes.
    public func table(_ name: String) -> TableTarget {
        return TableTarget(parentTarget: self, name: name)
    }
    /// Returns information about internal table which contains removed tables.
    public var deletedRecordsTable: TableTarget {
        return table(TableTarget.deletedRecords)
    }
}
