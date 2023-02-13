//
//  Deferred.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 15/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct Deferred {
    public let uri: String
    public let image: Bool
    public let key: String?

    public init(uri: String, image: Bool = false, key: String? = nil) {
        self.uri = uri
        self.image = image
        self.key = key
    }
}

extension Deferred: Codable {}

// MARK: JSONable

extension Deferred: JSONDecodable {
    public init?(json: JSON) {
        self.uri = json["uri"].stringValue
        self.image = json["image"].boolValue
        self.key = json["__KEY"].string
    }
}

// MARK: DictionaryConvertible

extension Deferred: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["uri"] = uri
        if image {
            dictionary["image"] = image
        }
        if let key = key {
            dictionary["__KEY"] = key
        }
        return dictionary
    }
}

// MARK: Equatable
extension Deferred: Equatable {
    public static func == (lhf: Deferred, rhf: Deferred) -> Bool {
        return lhf.uri == rhf.uri &&
            lhf.image == rhf.image &&
            lhf.key == rhf.key
    }
}
