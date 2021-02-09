//
//  ImportableParser.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 31/01/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//

import Foundation

public typealias ImportKey = RestKey

/// Create the importable object with tablename and json information.
public protocol ImportableBuilder {
    /// The record to import.
    associatedtype Importable: RecordImportable

    /// Setup context to import before all imports.
    ///
    /// - parameters:
    ///   - callback: execut all import in the callback context, must be synchrone
    func setup(in callback: @escaping () -> Void)
    /// Build one importable.
    func build(_ tableName: String, _ json: JSON) -> Importable?
    /// Called when the process finish.
    func teardown()

    func parseArray(json: JSON, using mapper: AttributeValueMapper) throws -> [Importable]
}

public extension ImportableBuilder {

    /// call setup, build and teardown on one call. Not optimized if multiple import.
    func recordInitializer(_ tableName: String, _ json: JSON) -> Importable? {
        var importable: Importable?
        self.setup {
            importable = self.build(tableName, json)
        }
        self.teardown()
        return importable
    }
}

/// Parser for JSON Data to Record.
public struct ImportableParser {

    /// The table associated to this parse.
    public let table: Table

    let managePrivateField = false

    /// Parsing record error.
    public enum Error: Swift.Error {
        case emptyJSON
        case noTable
        case incoherentTableName(String, String)
        case builderReturnNil
    }

    /// Create a parser with a `table` as reference.
    init(table: Table) {
        self.table = table
    }

    /// Return table name (without any check)
    public static func tableName(for json: JSON) -> String? {
        return json[ImportKey.entityModel].string
    }

    /// Return table name from json and check coherence.
    private func parseTableName(json: JSON) throws -> String {
        guard let tableName = ImportableParser.tableName(for: json) else {
            if json.isEmpty {
                logger.warning("No table name specified in json: file empty or have errors")
                throw ImportableParser.Error.emptyJSON
            } else {
                logger.warning("No table name specified in json: \(json)")
                throw ImportableParser.Error.noTable
            }
        }

        guard self.table.name == tableName else { // or assert
            logger.warning("Incoherent table name. Expected \(self.table.name) but receive \(tableName) ")
            throw ImportableParser.Error.incoherentTableName(self.table.name, tableName)
        }
        return tableName
    }

    /// Parse one `Importable` from JSON.
    public func parse<B: ImportableBuilder>(
        json: JSON,
        using mapper: AttributeValueMapper = .default,
        with builder: B) throws -> B.Importable {

        let tableName = try parseTableName(json: json)
        if let importable = builder.recordInitializer(tableName, json) {
            parseAttributes(json: json, into: importable, using: mapper, tableName: tableName)
            return importable
        } else {
            logger.warning("No importable object created for table \(tableName)")
        }
        throw ImportableParser.Error.builderReturnNil
    }

    // XXX: maybe return one by one the importable results if time too long instead of reading all objects

    /// Parse a list of `Importable` from JSON
    public func parseArray<B: ImportableBuilder>(
        json: JSON,
        using mapper: AttributeValueMapper = .default,
        with builder: B) throws ->  [B.Importable] {

        let tableName = try parseTableName(json: json)

        var results = [B.Importable]()

        builder.setup {
            if let entities = json[ImportKey.entities].array {
                for entity in entities {
                    if let importable = builder.build(tableName, entity) {
                        self.parseAttributes(json: entity, into: importable, using: mapper, tableName: tableName)
                        results.append(importable)
                    } else {
                        logger.warning("No importable object created for table \(tableName): \(entity)")
                        break
                    }
                }
            }
        }
        builder.teardown()

        return results
    }

    private func checkTableName(json: JSON, into importable: RecordImportable, tableName tableNameForce: String? = nil) -> Bool {
        let tableNameTmp: String?
        if let tableNameForce = tableNameForce {
            tableNameTmp = tableNameForce
        } else {
            tableNameTmp = json[ImportKey.entityModel].string
        }
        guard let tableName = tableNameTmp else {
            logger.warning("No table name specified when import into \(importable)")
            return false
        }

        guard self.table.name == tableName else {
            logger.warning("Incoherent table name. Expected \(self.table.name) but receive \(tableName) ")
            return false
        }
        guard self.table.name == importable.tableName else {
            logger.warning("Incoherent table name. Expected \(self.table.name) but record has \(importable.tableName) ")
            return false
        }
        return true
    }

    /// Parse attributes and set it into importable object.
    public func parseAttributes(json: JSON, into importable: RecordImportable, using mapper: AttributeValueMapper = .default, tableName tableNameForce: String? = nil) {
        guard checkTableName(json: json, into: importable, tableName: tableNameForce) else {
            return
        }

        // Statistic if list of records
        // let count = json["__COUNT"].int ?? 0
        // let first = json["__FIRST"].int ?? 0
        // let sent = json["__SENT"].int ?? 0
        // let full = sent == count

        let jsonEntity: JSON
        // Be kind by accepting to read one data from a list
        if let entities = json[ImportKey.entities].array?.first {
            jsonEntity = entities
        } else {
            jsonEntity = json
        }

        // Private records fields (other wayt to manage private fields, add to Table)
        if managePrivateField {
            for key in [ImportKey.key, ImportKey.stamp, ImportKey.globalStamp] {
                if let value = jsonEntity[key].int {
                    importable.setPrivateAttribute(key: key, value: value)
                }
            }
            if var valueString = jsonEntity[ImportKey.timestamp].string {
                valueString = valueString.replacingOccurrences(of: "\"", with: "")
                if let date = valueString.dateFromISO8601 ?? valueString.simpleDate {
                    importable.setPrivateAttribute(key: ImportKey.timestamp, value: date)
                }
            }
        }

        // All others fields
        guard let fieldValueDictionary = jsonEntity.dictionary?.filter({ !$0.key.hasPrefix(ImportKey.reserved) }) else {
            return
        }
        var fieldValues: [(Attribute, Any)] = []
        var relationValues: [(Attribute, Any)] = []
        for (key, jsonValue) in fieldValueDictionary {
            if let attribute = table[key] ?? table.attribute(forSafeName: key) {
                if attribute.type.isStorage {
                    fieldValues.append((attribute, jsonValue.object))
                } else {
                    relationValues.append((attribute, jsonValue.object))
                }
            } else {
                logger.debug("Field '\(key)' not defined in table \(tableNameForce ?? self.table.name) structure.")
                // logger.debug("Maybe your data structures is not up to date with data server")
            }
        }
        // set storage values before relative ones (primaryKey value must be set before relations)
        for (attribute, value) in fieldValues + relationValues {
            importable.set(attribute: attribute, value: value, with: mapper)
        }
    }
}

// MARK: Image

extension ImportableParser {
    /// Return the URL of the image.
    public static func parseImage(_ dico: [String: Any]) -> String? {
        // = "{    \"__deferred\" = { image = 1; uri = \"/rest/CLIENTS(1)/Logo?$imageformat=best&$version=10&$expand=Logo\";    };}";
        if let deferred = dico[ImportKey.deferred] as? [String: Any] {
            if let image = (deferred["image"] as? NSNumber)?.intValue, image == 1 { // checktype
                if let uri = deferred["uri"] as? String {
                    return uri
                }
            }
        }
        return nil
    }
}

// MARK: - Table

extension Table {
    /// A parser for specific table
    public var parser: ImportableParser {
        return ImportableParser(table: self)
    }
}
