//
//  DictionaryConvertible.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Protocol to define an object convertible to `Dictionary` with `String` key.
public protocol DictionaryConvertible: JSONEncodable {
    typealias Dico = [String: Any]

    /// A `Dictionary` with `String` key.
    var dictionary: Dico { get }
}

extension DictionaryConvertible {
    // A JSON representaion of this object.
    public var json: JSON {
        return JSON(self.dictionary)
    }
}
