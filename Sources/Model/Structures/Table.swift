//
//  Table.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/03/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Table structure for stored data.
public struct Table {
    public var name: String
    public var className: String?
    public var collectionName: String?
    public var scope: String?
    public var dataURI: String?

    public var attributes: [String: Attribute] = [:]
    public var attributesBySafeName: [String: Attribute] = [:]

    public var keys: [String: Key] = [:]

    public var methods: [TableMethod] = []

    public init(name: String) {
        self.name = name
    }
}

// MARK: Codable
extension Table: Codable {}

// MARK: subscript for Attribute
extension Table {
    /// Get one attribute by key
    public subscript(key: String) -> Attribute? {
        return attributes[key]
    }

    public func attribute(forSafeName key: String) -> Attribute? {
        // XXX cache info to optimize
        /*for attribute in self.attributes.values {
            if key == attribute.safeName {
                return attribute
            }
        }*/

        return attributesBySafeName[key]
    }
}

// MARK: Hashable
extension Table: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
    // equals?
}

// MARK: JSON key

enum TableJSONKey: String {
    case dataClasses
    case name
    case key
    case attributes
    case className
    case collectionName
    case scope
    case dataURI
    case methods
}

extension JSON {
    subscript(key: TableJSONKey) -> JSON {
        return self[key.rawValue]
        /*switch key {
        case .dataClasses: return json.string
        case .name: return json.string
        case .key: return json.array
        case .attributes: return json.array
        case .className: return json.string
        case .collectionName: return json.string
        case .scope: return json.string
        case .dataURI: return json.string
        }*/
    }
}

let ignoredTables = ["__DeletedRecords", "__Uploads"]

// MARK: JSON
extension Table: JSONDecodable {
    public init?(json: JSON) {
        let jsonTable: JSON

        // Be king by allowing to load one table or multiple tables

        // multiple table
        if let dataClass = json[.dataClasses].array?.first {
            jsonTable = dataClass
        }
        // or unique table
        else if json[.name].string != nil {
            jsonTable = json
        } else {
            logger.warning("No 'dataClasses' or table 'name' when parsing JSON table structure")
            return nil
        }

        // mandatory
        guard let name = jsonTable[.name].string else {
            logger.warning("No name in attribute \(json)")
            return nil
        }
        if ignoredTables.contains(name) {
            return nil
        }

        self.name = name

        guard let jsonAttributes = jsonTable[.attributes].array else {
            logger.warning("No attributes")
            return nil
        }

        for jsonAttribute in jsonAttributes {
            if let attribute = Attribute(json: jsonAttribute) {
                attributes[attribute.name] = attribute
                attributesBySafeName[attribute.safeName] = attribute
            }
        }
        // ASK: support only one key? support no key?
        if let jsonKeys = jsonTable[.key].array {
            for jsonKey in jsonKeys {
                if var key = Key(json: jsonKey) {
                    let name = key.name
                    if let attribute = attributes[name] {
                        key.attribute = attribute
                        keys[name] = key
                    } else {
                        logger.warning("Key \(name) not valid, no corresponding attribute found")
                    }
                }
            }
            if keys.isEmpty {
                logger.warning("No valid primary key found")
            }
        } else {
            logger.warning("No primary key when parsing JSON table \(name) structure")
        }

        // optional
        className = jsonTable[.className].string
        collectionName = jsonTable[.collectionName].string
        scope = jsonTable[.scope].string
        dataURI = jsonTable[.dataURI].string
        methods = jsonTable[.methods].array(of: TableMethod.self) ?? []
    }
}

extension Table {
    public static func all(json: JSON) -> [Table] {
        var tables = [Table]()
        if let dataClasses = json[.dataClasses].array {
            for dataClass in dataClasses {
                if let table = Table(json: dataClass) {
                    tables.append(table)
                }
            }
        }
        return tables
    }

    public static func array(json: JSON) -> [Table]? {
        if json[.dataClasses].array != nil {
            return all(json: json)
        }
        guard let instance = Table(json: json) else {
            return nil
        }
        return [instance]
    }
}

extension Table {
    public func attributes(of type: AttributeStorageType) -> [Attribute] {
        return self.attributes.values.filter {
            $0.storageType == type
        }
    }
}

// MARK: DictionaryConvertible
extension Table: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary[TableJSONKey.dataClasses.rawValue] = self.name
        dictionary[TableJSONKey.className.rawValue] = self.className
        dictionary[TableJSONKey.dataURI.rawValue] = self.dataURI
        dictionary[TableJSONKey.collectionName.rawValue] = self.collectionName
        dictionary[TableJSONKey.scope.rawValue] = self.scope

        dictionary[TableJSONKey.attributes.rawValue] = self.attributes
        dictionary[TableJSONKey.key.rawValue] = self.keys

        return dictionary
    }
}

// MARK: Equatable
extension Table: Equatable {
    public static func == (lhf: Table, rhf: Table) -> Bool {
        return lhf.name == rhf.name &&
            lhf.dataURI == rhf.dataURI &&
            lhf.className == rhf.className &&
            lhf.collectionName == rhf.collectionName &&
            lhf.scope == rhf.scope &&
            lhf.keys == rhf.keys &&
            lhf.attributes == rhf.attributes
    }
}
