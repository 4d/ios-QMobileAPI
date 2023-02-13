//
//  CacheObjects.swift
//  QMobileAPI
//
//  Created by anass talii on 04/07/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct CacheObjects {
    public var maxMem: Double
    public var usedMem: Double
    public var objects: [CacheObject] = []
}

// MARK: CacheObjects
extension CacheObjects: Codable {}

// MARK: JSON
extension CacheObjects: JSONDecodable {
    public init?(json: JSON) {
        guard let _maxMem = json["maxMem"].double else {
            return nil
        }
        maxMem = _maxMem
        usedMem = json["usedMem"].doubleValue
        objects = json["objects"].arrayValue.map { CacheObject(json: $0)! }
    }
}

// MARK: DictionaryConvertible
extension CacheObjects: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["maxMem"] = self.maxMem
        dictionary["usedMem"] = self.usedMem
        dictionary["objects"] = self.objects.map { $0.dictionary }
        return dictionary
    }
}

// MARK: Equatable
extension CacheObjects: Equatable {
    public static func == (lhf: CacheObjects, rhf: CacheObjects) -> Bool {
        return lhf.maxMem == rhf.maxMem &&
            lhf.usedMem == rhf.usedMem &&
            lhf.objects == rhf.objects
    }
}
