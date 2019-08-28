//
//  Attribute.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/03/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// An attribute of `Table`.
public struct Attribute {
    /// Attribute name.
    public var name: String
    /// Attribute type (storage, calculated, relatedEntity, and alias)
    public var kind: AttributeKind = .storage
    /// Scope of the attribute (only those attributes whose scope is Public will appear).
    public var scope: AttributeScope = .public
    /// Attribute type (bool, blob, byte, date, duration, image, long, long64, number, string, uuid, or word) or the table class for a N->1 relation attribute.
    public var type: AttributeType = AttributeStorageType.string

    /// his property returns True if the Identifying property was checked. Otherwise, this property does not appear.
    public var identifying: Bool = false
    /// If any Index Kind was selected, this property will return true. Otherwise, this property does not appear.
    public var indexed: Bool = false

    public var simpleDate: Bool = false

    /// Boolean	This property is True if the attribute is of type calculated or alias.
    public var readOnly: Bool = false

    ///	This property returns the value entered for the Min Length property, if one was entered.
    public var minLength: Int?
    /// This property returns the value entered for the Max Length property, if one was entered.
    public var maxLength: Int?

    /// This property returns True if the Autocomplete property was checked. Otherwise, this property does not appear.
    public var autoComplete: Bool = false

    /// If you define a format for the attribute in the Default Format property, it will appear in the "format" property.
    public var defaultFormat: Bool = false

    /// Foreign key for link.
    public var foreignKey: String?
    /// String For an alias attribute, the type is a path (e.g., employer.name)
    /// else path could be used for relation
    public var path: String?
    /// If true, the path is the inverse link name
    public var reversePath: Bool = false

    // special
    public var nameTransformer: AttributeNameTransformer = .none

    // Init for test purpose
    public init(name: String, kind: AttributeKind, scope: AttributeScope, type: AttributeType) {
        self.name = name
        self.kind = kind
        self.scope = scope
        self.type = type
    }
}

// MARK: Hashable
extension Attribute: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }

    public static func == (lhs: Attribute, rhs: Attribute) -> Bool {
        return lhs.name == rhs.name //
            && lhs.kind == rhs.kind && lhs.scope == rhs.scope
        // XXX check other fields
    }
}

// MARK: Codable
extension Attribute: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case kind, scope, type
        case path
        case identifying, indexed, simpleDate, autoComplete, defaultFormat, readOnly, reversePath
        case minLength, maxLength
        case foreignKey
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        kind = try values.decode(AttributeKind.self, forKey: .kind)
        scope = try values.decode(AttributeScope.self, forKey: .scope)
        do {
            type = try values.decode(AttributeStorageType.self, forKey: .type)
        } catch {
            type = try values.decode(AttributeRelativeType.self, forKey: .type)
        }
        path = try? values.decode(String.self, forKey: .path)

        identifying = try values.decode(Bool.self, forKey: .identifying)
        indexed = try values.decode(Bool.self, forKey: .indexed)
        simpleDate = try values.decode(Bool.self, forKey: .simpleDate)
        autoComplete = try values.decode(Bool.self, forKey: .autoComplete)
        defaultFormat = try values.decode(Bool.self, forKey: .defaultFormat)
        readOnly = try values.decode(Bool.self, forKey: .readOnly)
        reversePath = try values.decode(Bool.self, forKey: .reversePath)
        foreignKey = try? values.decode(String.self, forKey: .foreignKey)

        minLength = try? values.decode(Int.self, forKey: .minLength)
        maxLength = try? values.decode(Int.self, forKey: .maxLength)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(kind, forKey: .kind)
        try container.encode(scope, forKey: .scope)
        if let type = type as? AttributeRelativeType {
            try container.encode(type, forKey: .type)
        } else if let type = type as? AttributeStorageType {
            try container.encode(type, forKey: .type)
        }
        try container.encode(path, forKey: .path)

        try container.encode(identifying, forKey: .identifying)
        try container.encode(indexed, forKey: .indexed)
        try container.encode(simpleDate, forKey: .simpleDate)
        try container.encode(autoComplete, forKey: .autoComplete)
        try container.encode(defaultFormat, forKey: .defaultFormat)
        try container.encode(readOnly, forKey: .readOnly)
        try container.encode(reversePath, forKey: .reversePath)
        try container.encode(foreignKey, forKey: .foreignKey)

        try container.encode(minLength, forKey: .minLength)
        try container.encode(maxLength, forKey: .maxLength)
    }
}

// MARK: JSON
extension Attribute: JSONDecodable {
    // swiftlint:disable:next function_body_length
    public init?(json: JSON) {
        // mandatory
        guard let name = json["name"].string else {
            logger.warning("No name in attribute \(json)")
            return nil
        }
        if let transformer = AttributeNameTransformer.find(for: name) {
            self.nameTransformer = transformer
        } else {
            logger.warning("Invalid attribute \(name). Attribute must contains only alphabetic characters. Attribute will be skipped")
        }
        guard let scope = json["scope"].attributeScope else {
            logger.warning("No scope or unknown scope, \(json["scope"]). Attribute \(name) will be skipped")
            return nil
        }
        guard let kind = json["kind"].attributeKind else {
            logger.warning("No kind or unknown kind, \(json["kind"]). Attribute \(name) will be skipped")
            return nil
        }
        switch kind {
        case .relatedEntity, .relatedEntities:
            guard let type = json["type"].attributeRelativeType else {
                logger.warning("No type or unknown type, \(json["type"]). Attribute \(name) will be skipped")
                return nil
            }

            var relativetype = type
            switch kind {
            case .relatedEntity:
                relativetype.isToMany = false

            case .relatedEntities:
                relativetype.isToMany = true

            default:
                assertionFailure("Must not be reach")
            }
            self.type = relativetype

        case .storage, .alias, .calculated:
            guard let type = json["type"].attributeStorageType else {
                logger.warning("No type or unknown type, \(json["type"]). Attribute \(name) will be skipped")
                return nil
            }
            self.type = type
        }

        self.name = name
        self.kind = kind
        self.scope = scope

        // optional
        self.identifying = json["identifying"].bool ?? false
        self.indexed = json["indexed"].bool ?? false

        self.simpleDate = json["simpleDate"].bool ?? false

        self.reversePath = json["reversePath"].bool ?? false
        self.path = json["path"].string
        self.foreignKey = json["foreignKey"].string

        self.readOnly = json["readOnly"].bool ?? false

        self.minLength = json["minLength"].int
        self.maxLength = json["maxLength"].int

        self.autoComplete = json["autoComplete"].bool ?? false
        self.defaultFormat = json["defaultFormat"].bool ?? false
    }
}
