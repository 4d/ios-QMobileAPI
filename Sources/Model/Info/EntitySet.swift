//
//  EntitySet.swift
//  QMobileAPI
//
//  Created by anass talii on 04/07/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct EntitySet {
    public var id: String
    public var tableName: String
    public var selectionSize: Int
    public var sorted: Bool
    public var refreshed: Date // "2011-11-18T10:30:30Z",
    public var expires: Date
}

// MARK: Codable
extension EntitySet: Codable {}

// MARK: JSON
extension EntitySet: JSONDecodable {
    public init?(json: JSON) {
        guard let _id = json["id"].string else {
            return nil
        }
        id = _id
        tableName = json["tableName"].stringValue
        selectionSize = json["selectionSize"].intValue
        sorted = json["sorted"].boolValue
        guard let _refresh = json["refreshed"].date else {
            return nil
        }
        guard let _expires = json["expires"].date else {
            return nil
        }
        refreshed = _refresh
        expires = _expires
    }
}

// MARK: DictionaryConvertible
extension EntitySet: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["id"] = self.id
        dictionary["tableName"] = self.tableName
        dictionary["selectionSize"] = self.selectionSize
        dictionary["sorted"] = self.sorted
        dictionary["refreshed"] = self.refreshed
        dictionary["expires"] = self.expires
        return dictionary
    }
}

// MARK: Equatable
extension EntitySet: Equatable {
    public static func == (lhf: EntitySet, rhf: EntitySet) -> Bool {
        return lhf.id == rhf.id && lhf.tableName == rhf.tableName
        && lhf.selectionSize == rhf.selectionSize && lhf.sorted == rhf.sorted
        && lhf.refreshed == rhf.refreshed && lhf.expires == rhf.expires
    }
}

// MARK: EntitySetIdConvertible
public protocol EntitySetIdConvertible {
    var entitySetID: String { get }
}

extension EntitySet: EntitySetIdConvertible {
    public var entitySetID: String { return id }
}

extension String: EntitySetIdConvertible {
    public var entitySetID: String { return self }
}
