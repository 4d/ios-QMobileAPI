//
//  ComputeOperation.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 15/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public enum ComputeOperation: String {
    // A JSON object that defines all the functions for the attribute (average, count, min, max, and sum for attributes of type Number and count, min, and max for attributes of type String
    case all
    case average // Get the average on a numerical attribute
    case count //Get the total number in the collection or datastore class (in both cases you must specify an attribute)
    case min // Get the minimum value on a numerical attribute or the lowest value in an attribute of type String
    case max // Get the maximum value on a numerical attribute or the highest value in an attribute of type String
    case sum

    public var expected: [ComputeOperation] {
        switch self {
        case .all:
            return [.average, .count, .min, .max, .sum]

        default:
            return [self]
        }
    }

    public var query: String {
        switch self {
        case .all:
            return "$" + self.rawValue

        default:
            return self.rawValue
        }
    }
}

extension ComputeOperation: Equatable {
    public static func == (lhf: ComputeOperation, rhf: ComputeOperation) -> Bool {
        return lhf.rawValue == rhf.rawValue
    }
}

extension ComputeOperation: Codable {}
