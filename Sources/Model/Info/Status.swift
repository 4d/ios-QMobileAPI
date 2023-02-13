//
//  Status.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 24/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Status of 4D rest server.
public struct Status {
    static let okKey = "ok"
    static let successKey = "success"

    /// `true` if server ok
    public var ok: Bool

    public init(ok: Bool) {
        self.ok = ok
    }
}

// MARK: Codable
extension Status: Codable {}

// MARK: JSON
extension Status: JSONDecodable {
    public init?(json: JSON) {
        ok = json[Status.okKey].bool ?? json[Status.successKey].boolValue
    }
}

// MARK: DictionaryConvertible
extension Status: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary[Status.okKey] = self.ok
        return dictionary
    }
}

// MARK: Equatable
extension Status: Equatable {
    public static func == (lhf: Status, rhf: Status) -> Bool {
        return lhf.ok == rhf.ok
    }
}
