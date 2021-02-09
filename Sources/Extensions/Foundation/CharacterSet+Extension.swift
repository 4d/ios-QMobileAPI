//
//  CharacterSet+Extension.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

extension CharacterSet {
    /// Alpha numerics with undescore character set.s
    static let alphanumericsUndescore: CharacterSet = {
        var charactereSet = CharacterSet().union(CharacterSet.alphanumerics)
        charactereSet.insert("_")
        return charactereSet
    }()

    /// Check that a string contains only characters from this set.
    ///
    /// - parameter string: The string to check.
    ///
    /// - returns: `true` if string match requierement, `false` otherwise
    func isSuperset(ofCharactersIn string: String) -> Bool {
        for uni in string.unicodeScalars {
            if !self.contains(uni) {
                return false
            }
        }
        return true

        /*
         if string.rangeOfCharacter(from: self.inverted) != nil {
         return return false
         }
         return true
         */

        // let otherSet = CharacterSet(charactersIn: string)
        // return isSuperset(of: otherSet)  // CRASH
    }
}
