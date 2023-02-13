//
//  Objects.swift
//  QMobileAPI
//
//  Created by anass talii on 04/07/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct CacheObject {
    public var priority: Double
    public var type: Double
    public var dataBase: String
    public var table: String
    public var recordsBytes: Int
    public var recordsCount: Int
    public var recordsTotalEntries: Int
    public var blobsBytes: Double
    public var blobsCount: Int
    public var blobsTotalEntries: Int
    public var lockersBytes: Int
    public var lockersCount: Int
}

// MARK: Codable
extension CacheObject: Codable {}

// MARK: JSON
extension CacheObject: JSONDecodable {
    public init?(json: JSON) {
        guard let _priority = json["priority"].double else {
            return nil
        }
        priority = _priority
        type = json["type"].doubleValue
        dataBase = json["dataBase"].stringValue
        table = json["table"].stringValue
        recordsBytes = json["recordsBytes"].intValue
        recordsCount = json["recordsCount"].intValue
        recordsTotalEntries = json["recordsTotalEntries"].intValue
        blobsBytes = json["blobsBytes"].doubleValue
        blobsCount = json["blobsCount"].intValue
        blobsTotalEntries = json["blobsTotalEntries"].intValue
        lockersBytes = json["lockersBytes"].intValue
        lockersCount = json["lockersCount"].intValue
    }
}

// MARK: DictionaryConvertible
extension CacheObject: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["priority"] = self.priority
        dictionary["type"] = self.type
        dictionary["dataBase"] = self.dataBase
        dictionary["table"] = self.table
        dictionary["recordsBytes"] = self.recordsBytes
        dictionary["recordsCount"] = self.recordsCount
        dictionary["recordsTotalEntries"] = self.recordsTotalEntries
        dictionary["blobsBytes"] = self.blobsBytes
        dictionary["blobsCount"] = self.blobsCount
        dictionary["recordsTotalEntries"] = self.recordsTotalEntries
        dictionary["lockersBytes"] = self.lockersBytes
        dictionary["lockersCount"] = self.lockersCount

        return dictionary
    }
}

// MARK: Equatable
extension CacheObject: Equatable {
    public static func == (lhf: CacheObject, rhf: CacheObject) -> Bool {
        return lhf.priority == rhf.priority &&
            lhf.type == rhf.type &&
            lhf.dataBase == rhf.dataBase &&
            lhf.table == rhf.table &&
            lhf.recordsBytes == rhf.recordsBytes &&
            lhf.recordsCount == rhf.recordsCount &&
            lhf.recordsTotalEntries == rhf.recordsTotalEntries &&
            lhf.blobsBytes == rhf.blobsBytes &&
            lhf.blobsCount == rhf.blobsCount &&
            lhf.recordsTotalEntries == rhf.recordsTotalEntries &&
            lhf.lockersBytes == rhf.lockersBytes &&
            lhf.lockersCount == rhf.lockersCount
    }
}
