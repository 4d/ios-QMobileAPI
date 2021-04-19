//
//  DeletedRecord.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 14/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Generic record object which contains JSON representation of your record.
public struct DeletedRecord {

    /// The primary key of deleted record.
    public let primaryKey: String
    /// the identiier of the remote table.
    public let tableNumber: Double?
    /// The table name.
    public let tableName: String
    /// The stamp when the record has been deleted.
    public let stamp: Double

    // XXX copy also ImportKey.stamp, ImportKey.key, ImportKey.timeStamp ?

    /// create an instance
    public init(primaryKey: String, tableNumber: Double?, tableName: String, stamp: Double) {
        self.primaryKey = primaryKey
        self.tableName = tableName
        self.tableNumber = tableNumber
        self.stamp = stamp
    }
}

extension DeletedRecord: Codable {}

/// Define some key for DeletedRecord rest api
public struct DeletedRecordKey {

    /// The entity name.
    public static let entityName = "__DeletedRecords"

    /// The primary key.
    public static let primaryKey = "__PrimaryKey"
    /// The table name.
    public static let tableName = "__TableName"
    /// The table  number.
    public static let tableNumber = "__TableNumber"
    /// The stamp
    public static let stamp = "__Stamp"
}

extension DeletedRecord: JSONDecodable {
    public init?(json: JSON) {
        self.primaryKey = json[DeletedRecordKey.primaryKey].stringValue
        self.tableName = json[DeletedRecordKey.tableName].stringValue
        self.tableNumber = json[DeletedRecordKey.tableNumber].doubleValue
        self.stamp = json[DeletedRecordKey.stamp].doubleValue
    }
}

// MARK: DictionaryConvertible
extension DeletedRecord: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary[DeletedRecordKey.primaryKey] = self.primaryKey
        dictionary[DeletedRecordKey.tableName] = self.tableName
        dictionary[DeletedRecordKey.tableNumber] = self.tableNumber
        dictionary[DeletedRecordKey.stamp] = self.stamp
        return dictionary
    }
}

// MARK: Equatable
extension DeletedRecord: Equatable {
    public static func == (lhf: DeletedRecord, rhf: DeletedRecord) -> Bool {
        return lhf.tableName == rhf.tableName &&
            lhf.tableNumber == rhf.tableNumber &&
            lhf.primaryKey == rhf.primaryKey &&
            lhf.stamp == rhf.stamp
    }
}

extension RecordJSON {
    /// Return information about deleted record only if the table is special one that keep track of deleted records
    /// otherwise return nil
    public var deletedRecord: DeletedRecord? {
        guard tableName == DeletedRecordKey.entityName else {
            return nil
        }
        return DeletedRecord(json: self.json)
    }
}

extension Page {
    /// Return information about deleted record only if the table is special one that keep track of deleted records
    /// otherwise return nil
    public var deletedRecords: [DeletedRecord]? {
        guard tableName == DeletedRecordKey.entityName else {
            return nil
        }
        return records.compactMap { DeletedRecord(json: $0.json) }
    }
}
