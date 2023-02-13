//
//  EntitySetInfo.swift
//  QMobileAPI
//
//  Created by anass talii on 04/07/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct EntitySetInfo {
    public var entitySetCount: Int
    public var entitySet: [EntitySet] = []
}

// MARK: Codable
extension EntitySetInfo: Codable {}

// MARK: JSON
extension EntitySetInfo: JSONDecodable {
    public init?(json: JSON) {
        guard let _entitySetCount = json["entitySetCount"].int else {
            return nil
        }
        entitySetCount = _entitySetCount
        entitySet = json["entitySet"].arrayValue.map { EntitySet(json: $0)! }
    }
}

// MARK: DictionaryConvertible
extension EntitySetInfo: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["entitySetCount"] = self.entitySetCount
        dictionary["entitySet"] = self.entitySet
        return dictionary
    }
}

// MARK: Equatable
extension EntitySetInfo: Equatable {
    public static func == (lhf: EntitySetInfo, rhf: EntitySetInfo) -> Bool {
        return lhf.entitySetCount == rhf.entitySetCount && lhf.entitySet == rhf.entitySet
    }
}
