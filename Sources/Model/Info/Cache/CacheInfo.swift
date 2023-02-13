//
//  CacheInfo.swift
//  QMobileAPI
//
//  Created by anass talii on 04/07/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct CacheInfo {
    public var cacheSize: Double
    public var usedCache: Double
    public var cacheObjects: [CacheObjects] = []
}
// MARK: Codable
extension CacheInfo: Codable {}

// MARK: JSON
extension CacheInfo: JSONDecodable {
    public init?(json: JSON) {
        guard let _cacheSize = json["cacheSize"].double else {
            return nil
        }
        cacheSize = _cacheSize
        usedCache = json["usedCache"].doubleValue
        cacheObjects = json["cacheObjects"].arrayValue.map { CacheObjects(json: $0)! }
    }
}

// MARK: DictionaryConvertible
extension CacheInfo: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["cacheSize"] = self.cacheSize
        dictionary["usedCache"] = self.usedCache
        dictionary["cacheObjects"] = self.cacheObjects.map { $0.dictionary }
        return dictionary
    }
}

// MARK: Equatable
extension CacheInfo: Equatable {
    public static func == (lhf: CacheInfo, rhf: CacheInfo) -> Bool {
        return lhf.cacheSize == rhf.cacheSize &&
            lhf.usedCache == rhf.usedCache &&
            lhf.cacheObjects == rhf.cacheObjects
    }
}
