//
//  RecordImportable.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 03/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Protocol for any Importable objects
public protocol RecordImportable {
    /// To check type, importable must give is 'type' as table name
    var tableName: String { get }

    /// Check if field or relation exist
    func has(key: String) -> Bool
    /// Is is a relation
    func isRelation(key: String) -> Bool
    /// Is is a field
    func isField(key: String) -> Bool

    /// Import one attribute.
    func set(attribute: Attribute, value: Any?, with mapper: AttributeValueMapper)
    /// Get one attribute value.
    func get(attribute: Attribute, with mapper: AttributeValueMapper) -> Any?

    /// Import one private attribute
    func setPrivateAttribute(key: String, value: Any?)
    /// Get value for one private attribute
    func getPrivateAttribute(key: String) -> Any?
}

extension RecordImportable {
    /// Check if field or relation exist
    public func has(attribute: Attribute) -> Bool {
        return has(key: attribute.safeName)
    }
}

extension RecordImportable {
    /// Get one attribute value.
    public func get(attribute: Attribute) -> Any? {
        return get(attribute: attribute, with: .default)
    }
}
