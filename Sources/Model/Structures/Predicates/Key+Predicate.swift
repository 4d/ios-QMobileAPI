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
        guard let attribute = self.attribute else {
            return nil
        }
        guard importable.has(attribute: attribute) else {
            return nil
        }
        guard let value = importable.get(attribute: attribute, with: mapper) else {
            logger.warning("No \(attribute) for \(importable)")
            return nil
        }
        let lhs = NSExpression(forKeyPath: self.safeName)
        let rhs = NSExpression(forConstantValue: value)
        return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .equalTo, options: [])
    }

    public func predicate(for json: JSON) -> NSPredicate? {
        var jsonAttr = json[self.name]
        if jsonAttr == JSON.null {
            jsonAttr = json["__KEY"] // take a chance to use default key
            if jsonAttr == JSON.null {
                return nil
            }
        }
        return predicate(for: jsonAttr.object)
    }

    public func predicate(for value: Any) -> NSPredicate {
        let lhs = NSExpression(forKeyPath: self.safeName)
        let rhs = NSExpression(forConstantValue: value)
        return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .equalTo, options: [])
    }

    public func predicate(forDeletedRecord deletedRecord: DeletedRecord) -> NSPredicate {
        let value: String = deletedRecord.primaryKey
        let lhs = NSExpression(forKeyPath: self.safeName)

        var rhs: NSExpression
        if let attribute = self.attribute, let storageType = attribute.storageType {
            switch storageType {
            case .long:
                rhs = NSExpression(forConstantValue: Int32(value))
            case .long64, .duration:
                rhs = NSExpression(forConstantValue: Int64(value))
            case .number:
                rhs = NSExpression(forConstantValue: Double(value))
            case .string:
                rhs = NSExpression(forConstantValue: value)
            case .float:
                rhs = NSExpression(forConstantValue: Float(value))
            case .bool:
                rhs = NSExpression(forConstantValue: Bool(value))
            case .date:
                if let date = attribute.simpleDate ? value.simpleDate ?? value.dateFromISO8601: value.dateFromISO8601 {
                    rhs = NSExpression(forConstantValue: date)
                } else {
                    rhs = NSExpression(forConstantValue: value)
                }
            default:
                rhs = NSExpression(forConstantValue: value)
            }
        } else {
            rhs = NSExpression(forConstantValue: value)
        }
        return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .equalTo, options: [])
    }
}
