//
//  Table+Predicate.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

// MARK: predicate for Key
extension Table {
    public func predicate(for importable: RecordImportable, with mapper: AttributeValueMapper = .default) -> NSPredicate? {
        let keys = self.keys.values
        if keys.count == 1, let key = keys.first {
            return key.predicate(for: importable, with: mapper)
        } else {
            let predicates = keys.map { key in
                key.predicate(for: importable, with: mapper) ?? NSPredicate(value: true)
            }
            return NSCompoundPredicate(type: .and, subpredicates: Array(predicates))
        }
    }

    public func predicate(for value: Any) -> NSPredicate? {
        let keys = self.keys.values
        if keys.count == 1, let key = keys.first {
            return key.predicate(for: value)
        } else {
            if let dico = value as? [String: Any] {
                let predicates = keys.map { key -> NSPredicate in
                    if let value = dico[key.name] {
                        return key.predicate(for: value)
                    }
                    assertionFailure("Missing primary key value: \(key) in \(dico) , table: \(self.name)")
                    return NSPredicate(value: true)
                }
                return NSCompoundPredicate(type: .and, subpredicates: Array(predicates))
            }
            assertionFailure("There is multiple primary key. \(value) is not a dictionary. table: \(self.name)")
            return NSPredicate(value: true)
        }
    }

    public func predicate(for json: JSON) -> NSPredicate? {
        var keyMap = self.keys
        keyMap = keyMap.filter { $0.value.attribute != nil }
        if keyMap.isEmpty {
            return nil
        }
        let keys = keyMap.values
        if keys.count == 1, let key = keys.first {
            return key.predicate(for: json)
        } else {
            let predicates = keys.map { key in
                key.predicate(for: json)
            }
            return NSCompoundPredicate(type: .and, subpredicates: Array(predicates))
        }
    }
}

extension Table {
    public func predicate(forDeletedRecord deletedRecord: DeletedRecord) -> NSPredicate {
        let keys = self.keys.values
        if keys.count == 1, let key = keys.first {
            return key.predicate(forDeletedRecord: deletedRecord)
        } else {
            let predicates = keys.map { key in
                key.predicate(forDeletedRecord: deletedRecord)
            }
            return NSCompoundPredicate(type: .and, subpredicates: Array(predicates))
        }
    }
}
