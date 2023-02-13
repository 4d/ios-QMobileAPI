//
//  TableMethod.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 17/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct TableMethod {
    public let name: String

    public var applyTo: String? = "dataClass"// enum??
    public var scope: AttributeScope = .public
    public var from: String? = "remoteServer" // enum??
    public var allowedOnHTTPGET: Bool = false

    public init(name: String) {
        self.name = name
    }
}

// MARK: Codable
extension TableMethod: Codable {}

// MARK: JSON
extension TableMethod: JSONDecodable {
    public init?(json: JSON) {
        // mandatory
        guard let name = json["name"].string else {
            logger.warning("No name, kind, scope or type in attribute \(json)")
            return nil
        }
        self.name = name
        self.applyTo = json["applyTo"].string
        self.scope = json["scope"].attributeScope ?? .public
        self.from = json["from"].string
        self.allowedOnHTTPGET = json["allowedOnHTTPGET"].boolValue
    }
}

// MARK: TableMethod
extension TableMethod: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        return ["name": name,
        "applyTo": applyTo ?? "",
        "scope": scope,
        "from": from ?? "",
        "allowedOnHTTPGET": allowedOnHTTPGET
        ]
    }
}

// MARK: Equatable
extension TableMethod: Equatable {
    public static func == (lhf: TableMethod, rhf: TableMethod) -> Bool {
        return lhf.name == rhf.name
    }
}
