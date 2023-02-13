//
//  ArrayTests.swift
//  Tests
//
//  Created by Quentin Marciset on 15/07/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import Foundation

import XCTest
@testable import QMobileAPI

class ArrayTests : XCTestCase {

    func testSecond() {
        let simpleArray = ["banana", "apple", "berry"]
        let soloArray = ["banana"]
        XCTAssertEqual(simpleArray.second, "apple")
        XCTAssertEqual(soloArray.second, nil)
    }
    
    func testDictionaryBy() {
        let codes = HTTPCode.allCases
        let dico = codes.dictionaryBy { code in
            return code.hashValue
        }
        XCTAssertEqual(dico.count, codes.count)
    }
}
