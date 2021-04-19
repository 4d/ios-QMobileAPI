//
//  Deferred.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 15/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Define info from rest api that must requested by another request ie. deferred, such as image, relation info.
public struct Deferred {
    /// The uri to request.
    public let uri: String
    /// `true` if is an image.
    public let image: Bool
    /// An identiier key.
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
