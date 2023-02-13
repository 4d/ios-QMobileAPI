//
//  Key.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/03/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct Key {
    public let name: String
    public var attribute: Attribute?

    public init(name: String, attribute: Attribute?) {
        self.name = name
        self.attribute = attribute
    }
}

// MARK: Codable
extension Key: Codable {}

// MARK: JSON
extension Key: JSONDecodable {
    public init?(json: JSON) {
        // mandatory
        guard let name = json["name"].string else {
            logger.warning("No name in attribute \(json)")
            return nil
        }
        self.name = name
    }
}

extension Key {
    public var safeName: String {
        let name = self.name
        return self.attribute?.nameTransformer.decode(name) ?? name
    }
}

// MARK: Key
extension Key: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        return ["name": name]
    }
}

// MARK: Equatable
extension Key: Equatable {
    public static func == (lhf: Key, rhf: Key) -> Bool {
        return lhf.name == rhf.name
    }
}
