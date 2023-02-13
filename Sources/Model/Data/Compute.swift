//
//  Compute.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 02/05/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public typealias ComputeResultType = String
public struct Compute {
    // public var attribute: Attribute?

    public var attribute: String
    public var results: [ComputeOperation: ComputeResultType]

    public init(attribute: String, results: [ComputeOperation: ComputeResultType]) {
        self.attribute = attribute
        self.results = results
    }

    public init(attribute: String, operation: ComputeOperation, result: ComputeResultType) {
       self.init(attribute: attribute, results: [operation: result])
    }
}

extension Compute: Codable {}

// MARK: JSON

/*
 {
 "salary": {
 "count": 4,
 "sum": 335000,
 "average": 83750,
 "min": 70000,
 "max": 99000
 }
 }
 */
/// XXX cannot parse simple request without JSON currently
extension Compute: JSONDecodable {
    public init?(json: JSON) {
        // mandatory
        guard let result = json.dictionary?.first else {
            logger.warning("No result for compute operation")
            return nil
        }
        attribute = result.key
        let values = result.value

        results = [:]
        guard let dico = values.dictionary else {
            logger.warning("Empty results for \(attribute)")
            return nil
        }
        for (key, value) in dico {
            if let operation = ComputeOperation(rawValue: key) {
                results[operation] = value.stringValue
            } else {
                logger.warning("Unknown compute operation '\(key)' (atribute \(attribute))")
            }
        }
    }
}

extension Compute {
    public subscript(operation: ComputeOperation) -> ComputeResultType? {
        return results[operation]
    }
}

// MARK: DictionaryConvertible

extension Compute: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary[attribute] = results
        return dictionary
    }
}

// MARK: Equatable
extension Compute: Equatable {
    public static func == (lhf: Compute, rhf: Compute) -> Bool {
        guard lhf.attribute == rhf.attribute else {
            return false
        }
        let keys = Array(lhf.results.keys)
        guard keys == Array(rhf.results.keys) else {
            return false
        }
        for key in keys where lhf.results[key] != rhf.results[key] {
            return false
        }
        return true
    }
}
