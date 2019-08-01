//
//  AttributeType.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 14/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Attribute type protocol.
public protocol AttributeType: Codable {
    /// String value to represent the destination type.
    var rawValue: String { get }
    /// Is it a storage type.
    var isStorage: Bool { get }
    /// Is it a relative type.
    var isRelative: Bool { get }
}

// MARK: Relative

/// Represent the attribute type for a relation.
public struct AttributeRelativeType: RawRepresentable {

    public static let suffix = "Collection"

    public typealias RawValue = String
    public var rawValue: String

    /// Table destination of relation
    public lazy var relationTable: String = {
        if isToMany, rawValue.hasSuffix(AttributeRelativeType.suffix) {
            return String(rawValue.dropLast(AttributeRelativeType.suffix.count))
        }
        return rawValue
    } ()
    /// Is it a to many relation shipt.
    public var isToMany: Bool = false
    /// Optionnal information to know which field we want to expand for this relation.
    public var expand: String?

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension AttributeRelativeType: AttributeType {
    public var isStorage: Bool { return false }
    public var isRelative: Bool { return true }
}

// MARK: Storage

/// Type of stored attribute
public enum AttributeStorageType: String, Equatable {
    /// A sequence of characters.
    case string
    /// A whole number, greater than or equal to a standard number	-2,147,483,648 to 2,147,483,647
    case long
    /// A whole number, greater than or equal to a standard number	-9,223,372,036,854,775,808 to +9,223,372,036,854,775,807
    case long64
    /// A date
    case date
    /// A numeric value, corresponding either to a Real, and Integer or Long Integer.	±1.7e±308 (real), -32,768 to 32,767 (integer), -2^31 to (2^31)-1 (long)
    case number
    /// A float
    case float
    /// A reference to an image file or an actual image.
    case image
    /// A Boolean value: either true or false.
    case bool
    /// A sequence of 8 bits.
    case byte
    /// A 16-bit signed integer
    case word
    /// Universally Unique Identifier: a 16 bytes (128 bits) number containing 32 hexadecimal characters
    case uuid
    /// A duration between two dates
    case duration
    /// An object
    case object
    /// Binary data
    case blob
}

extension AttributeStorageType: AttributeType {
    public var isStorage: Bool { return true }
    public var isRelative: Bool { return false }
}

// MARK: casting
extension Attribute {
    /// If storage type, return it, else return nil.
    public var storageType: AttributeStorageType? {
        get {
            return type as? AttributeStorageType
        }
        set {
            if let value = newValue {
                self.type = value
            }
        }
    }

    /// If relative type, return it, else return nil.
    public var relativeType: AttributeRelativeType? {
        get {
            return type as? AttributeRelativeType
        }
        set {
            if let value = newValue {
                self.type = value
            }
        }
    }
}
