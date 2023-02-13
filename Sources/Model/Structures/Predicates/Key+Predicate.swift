//
//  Key+Predicate.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

// MARK: Predicate
extension Key {
    public func predicate(for importable: RecordImportable, with mapper: AttributeValueMapper = .default, ifNotImportable: Bool = true) -> NSPredicate? {
        if let attribute = self.attribute, importable.has(attribute: attribute), let value = importable.get(attribute: attribute, with: mapper) {
            let lhs = NSExpression(forKeyPath: self.safeName)
            let rhs = NSExpression(forConstantValue: value)
            return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .equalTo, options: [])
        }
        return nil
    }

    public func predicate(for json: JSON) -> NSPredicate {
        let value = json[self.name].object
        return predicate(for: value)
    }

    public func predicate(for value: Any) -> NSPredicate {
        let lhs = NSExpression(forKeyPath: self.safeName)
        let rhs = NSExpression(forConstantValue: value)
        return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .equalTo, options: [])
    }

    public func predicate(forDeletedRecord deletedRecord: DeletedRecord) -> NSPredicate {
        let value = deletedRecord.primaryKey
        let lhs = NSExpression(forKeyPath: self.safeName)
        let rhs = NSExpression(forConstantValue: value)
        return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .equalTo, options: [])
    }
}
