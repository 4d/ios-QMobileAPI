//
//  Catalog.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 25/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// a list of the datastore classes is returned along with two URIs for each datastore class in your project's active model.
public struct Catalog {
    public var name: String
    public var uri: String?
    public var dataURI: String?

    init(name: String) {
        self.name = name
    }
}
// MARK: Codable
extension Catalog: Codable {}

// MARK: JSON
extension Catalog: JSONDecodable {
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
        guard let name = jsonTable["name"].string else {
            logger.warning("No name in attribute \(json)")
            return nil
        }
        self.name = name
        self.uri = jsonTable["uri"].string
        self.dataURI = jsonTable["dataURI"].string
    }
}

extension Catalog {
    public static func all(json: JSON) -> [Catalog] {
        var tables = [Catalog]()
        if let dataClasses = json[.dataClasses].array {
            for dataClass in dataClasses {
                if let table = Catalog(json: dataClass) {
                    tables.append(table)
                }
            }
        }
        return tables
    }

    public static func array(json: JSON) -> [Catalog]? {
        if json[.dataClasses].array != nil {
            return all(json: json)
        }
        guard let instance = Catalog(json: json) else {
            return nil
        }
        return [instance]
    }
}

// MARK: DictionaryConvertible
extension Catalog: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary[TableJSONKey.dataClasses.rawValue] = self.name
        dictionary["uri"] = self.uri
        dictionary["dataURI"] = self.dataURI
        return dictionary
    }
}

// MARK: Equatable
extension Catalog: Equatable {
    public static func == (lhf: Catalog, rhf: Catalog) -> Bool {
        return lhf.name == rhf.name &&
            lhf.dataURI == rhf.dataURI &&
            lhf.uri == rhf.uri
    }
}
