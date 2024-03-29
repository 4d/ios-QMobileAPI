//
//  RecordJSON.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Generic record object which contains JSON representation of your record.
public struct RecordJSON {
    /// The table name
    public let tableName: String
    /// The JSON representation
    public let json: JSON

    init(tableName: String, json: JSON) {
        self.tableName = tableName
        self.json = json
    }
}

extension RecordJSON: Codable {
    // TODO : specify coding key (remove tableName and use only raw json one
}

/// Rest api key.
public struct RestKey {
    /// Prefix fo reserved key ie. __
    public static let reserved = "__"

    /// entity model key
    public static let entityModel = "__entityModel"
    // public static let dataClass = "__DATACLASS" // will replace entityModel?
    /// count key
    public static let count = "__COUNT"
    /// send key
    public static let sent = "__SENT"
    /// first key
    public static let first = "__FIRST"
    /// entity key
    public static let entities = "__ENTITIES"
    /// key for key
    public static let key = "__KEY"
    /// stamp key
    public static let stamp = "__STAMP"
    /// timestamp key
    public static let timestamp = "__TIMESTAMP"
    /// deferred key
    public static let deferred = "__deferred"
    /// global stamp
    public static let globalStamp = "__GlobalStamp"
}

extension RecordJSON {
    /// Get one attribute by key in JSON object foramt.
    public subscript(json key: String) -> JSON {
        return self.json[key]
    }

    /// Get one attribute value by key.
    public subscript(key: String) -> Any? {
        return self[json: key].rawValue
    }

    /// Get stamp of last modification
    public var stamp: Int? {
        return json[RestKey.stamp].int
    }

    /// Get the primary key
    public var key: String? {
        return json[RestKey.key].string
    }

    /// Get the time stamp of last modification
    public var timestamp: Date? {
        guard let string = json[RestKey.timestamp].string?.replacingOccurrences(of: "\"", with: "") else {
            return nil
        }
        if let date = string.dateFromISO8601 {
            return date
        }
        return string.simpleDate
    }

    /// Get global stamp of modification
    public var globalStamp: Int? {
        return json[RestKey.globalStamp].int
    }

    /// Get JSON data for a key.
    public func deferredJSON(_ key: String) -> JSON? {
        let deferred = json[key][RestKey.deferred]
        if deferred.isEmpty {
            return nil
        }
        return deferred
    }

    /// Get Deferred object for a key.
    public func deferred(_ key: String) -> Deferred? {
        guard let json = deferredJSON(key) else {
            return nil
        }
        return Deferred(json: json)
    }

    /// Could return a page in case of $expand request on specific field
    public func page(_ key: String) -> Page? {
        let link = json[key]
        if link.isEmpty {
            return nil
        }
        return Page(json: link)
    }

    /// Could return a record in case of $expand request on specific field
    public func record(_ key: String, tableName: String = "") -> RecordJSON? {
        let link = json[key]
        if link.isEmpty {
            return nil
        }
        return RecordJSON(tableName: tableName, json: link)
    }
}

extension RecordJSON {
    /// Return data as dictionar
    public var dictionaryObject: [String: Any]? {
        return self.json.dictionaryObject
    }

    /// Return all key of records.
    public var keys: [String]? {
        guard let keys = self.json.dictionaryObject?.keys else {
            return nil
        }
        return Array(keys)
    }
}

extension RecordJSON: JSONDecodable {
    public init?(json: JSON) {
        self.json = json
        self.tableName = json[RestKey.entityModel].stringValue
    }

    public static func array(json: JSON) -> [RecordJSON]? {
        guard let arrayJSON = json["__ENTITIES"].array else {
            return nil
        }
        var result = [RecordJSON]()
        for json in arrayJSON {
            if let object = RecordJSON(json: json) {
                result.append(object)
            }
        }
        return result
    }
}

// MARK: Equatable
extension RecordJSON: Equatable {
    public static func == (lhf: RecordJSON, rhf: RecordJSON) -> Bool {
        guard lhf.tableName == rhf.tableName else {
            return false
        }
        return lhf.json == rhf.json
    }
}
