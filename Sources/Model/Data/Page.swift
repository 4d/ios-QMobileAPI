//
//  Page.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Simple object which contains a Page and record objects.
public struct Page {
    public var info: PageInfo
    public var tableName: String
    public var records: [RecordJSON]

    public init(info: PageInfo, tableName: String, records: [RecordJSON]) {
        self.info = info
        self.tableName = tableName
        self.records = records
    }
}

extension Page: Codable {}

extension Page: JSONDecodable {
    public init?(json: JSON) {
        guard let info = PageInfo(json: json) else {
            return nil
        }
        self.info = info

        guard let tableName = json[RestKey.entityModel].string else {
            if json.isEmpty {
                logger.warning("No table name specified in json: file empty or have errors")
            } else {
                logger.warning("No table name specified in json: \(json)")
            }
            return nil
        }
        self.tableName = tableName

        self.records = [RecordJSON]()
        if let entities = json[RestKey.entities].array {
            for entity in entities {
                let record = RecordJSON(tableName: tableName, json: entity)
                records.append(record)
            }
        }
    }
}

// MARK: DictionaryConvertible

extension Page: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = info.dictionary

        dictionary[RestKey.entityModel] = tableName
        dictionary[RestKey.entities] = records.map { $0.json }

        for (key, value) in info.dictionary {
            dictionary[key] = value
        }

        return dictionary
    }
}

// MARK: Equatable
extension Page: Equatable {
    public static func == (lhf: Page, rhf: Page) -> Bool {
        guard  lhf.info == rhf.info && lhf.tableName == rhf.tableName else {
                return false
        }
        return lhf.records == rhf.records
    }
}
