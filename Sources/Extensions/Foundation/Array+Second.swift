//
//  Array+Second.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 27/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

extension Array {
    /// return the second element if array
    var second: Element? { return self.count > 1 ? self[1] : nil }
}

extension Array {
    /// Create a dictionary from this array.
    ///
    /// - parameter key: A closure to get hashing key from array values.
    ///
    /// - returns: the dictionary
    func dictionaryBy<T: Hashable>(key: (Element) -> T) -> [T: [Element]] {
        var result: [T: [Element]] = [:]
        self.forEach {
            let keyValue = key($0)
            if result[keyValue] == nil {
                result[keyValue] = []
            }
            result[keyValue]?.append($0)
        }
        return result
    }
}
