//
//  StringTests.swift
//  Tests
//
//  Created by Quentin Marciset on 15/07/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import Foundation

import XCTest
@testable import QMobileAPI

class StringTests : XCTestCase {
    
    let str: String = "abcdef"
    let emptyStr = ""
    let capsStr = "ABCDEF"
    let encoded64Str = "YWJjZGVm"
    let strOptional: String? = "abcdef"
    let validUrl = "myURL-Is-Valid"
    let invalidUrl = "myURL`IsNot Valid"
    let pattern = "[a-zA-Z]"

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStringFirst() {
        XCTAssertEqual(str.first, "a")
        XCTAssertEqual(emptyStr.first, "")
    }
    
    func testStringLast() {
        XCTAssertEqual(str.last, "f")
        XCTAssertEqual(emptyStr.last, "")
    }
    
    func testUppercasedFirstCharacter() {
        XCTAssertEqual(str.uppercasedFirstCharacter(), "Abcdef")
        XCTAssertEqual(capsStr.uppercasedFirstCharacter(), "ABCDEF")
        XCTAssertEqual(emptyStr.uppercasedFirstCharacter(), "")
    }
    
    func testLowercasedFirstCharacter() {
        XCTAssertEqual(str.lowercasedFirstCharacter(), "abcdef")
        XCTAssertEqual(capsStr.lowercasedFirstCharacter(), "aBCDEF")
        XCTAssertEqual(emptyStr.lowercasedFirstCharacter(), "")
    }
    
    func testIsFirstCharacterUppercased() {
        XCTAssertEqual(str.isFirstCharacterUppercased, false)
        XCTAssertEqual(capsStr.isFirstCharacterUppercased, true)
        XCTAssertEqual(emptyStr.isFirstCharacterUppercased, false)
    }
    
    func testIsFirstCharacterLowercased() {
        XCTAssertEqual(str.isFirstCharacterLowercased, true)
        XCTAssertEqual(capsStr.isFirstCharacterLowercased, false)
        XCTAssertEqual(emptyStr.isFirstCharacterLowercased, false)
    }
    
    func testIsFirstCharacterLetter() {
        let numStr = "486848"
        XCTAssertEqual(numStr.isFirstCharacterLetter, false)
        XCTAssertEqual(str.isFirstCharacterLetter, true)
        XCTAssertEqual(capsStr.isFirstCharacterLetter, true)
        XCTAssertEqual(emptyStr.isFirstCharacterLetter, false)
    }
    
    func testInit() {
        XCTAssertEqual(String(unwrappedDescrib: str), str)
        XCTAssertEqual(String(unwrappedDescrib: strOptional), str)
        XCTAssertEqual(String(unwrappedDescrib: emptyStr), emptyStr)
        XCTAssertEqual(String(unwrappedDescrib: nil), "nil")
    }
    
    func testLocalized() {
        XCTAssertEqual("api.request".localized, "Network issue")
        XCTAssertEqual("".localized, "")
    }
    
    func testLocalizedWithComment() {
        let localized = "api.request".localized(with: "sample comment", bundle: Bundle(for: APIManager.self))
        XCTAssertEqual(localized, "Network issue")
    }

    
    func testBase64Encoded() {
        if let encodedString = str.base64Encoded {
            XCTAssertEqual(encodedString, encoded64Str)
        } else {
            XCTFail("Failed to encode string \(str)")
        }
    }
    
    func testBase64Decoded() {
        if let decodedString = encoded64Str.base64Decoded {
            XCTAssertEqual(decodedString, str)
        } else {
            XCTFail("Failed to decode string \(encoded64Str)")
        }
    }
    
    func testBase64EncodedEmpty() {
        if let encodedString = emptyStr.base64Encoded {
            XCTAssertEqual(encodedString, emptyStr)
        } else {
            XCTFail("Failed to encode empty string")
        }
    }
    
    func testBase64DecodedEmpty() {
        if let decodedString = emptyStr.base64Decoded {
            XCTAssertEqual(decodedString, emptyStr)
        } else {
            XCTFail("Failed to decode empty string")
        }
    }
    
    func testBase64DecodedData() {
        
        if let base64EncodedString = str.base64Encoded {
        
            if let data = base64EncodedString.base64DecodedData {
                let dataString = String(data: data, encoding: .utf8)
                XCTAssertEqual(dataString, str)
            } else {
                XCTFail("Failed to decode data from encoded string \(base64EncodedString)")
            }
        } else {
            XCTFail("Failed to encode string \(str)")
        }
    }
    
    func testUrlEncodedString() {
        XCTAssertEqual(validUrl.urlEncodedString, validUrl)
        XCTAssertNotEqual(invalidUrl.urlEncodedString, invalidUrl)
        XCTAssertEqual(emptyStr.urlEncodedString, emptyStr)
    }
    
    func testUrlQueryEncoded() {
        if let encodedUrl = validUrl.urlQueryEncoded {
            XCTAssertEqual(encodedUrl, validUrl)
        } else {
            XCTFail("Failed to encode URL \(validUrl)")
        }
        
        if let encodedUrl = invalidUrl.urlQueryEncoded {
            XCTAssertNotEqual(encodedUrl, invalidUrl)
        } else {
            XCTFail("Failed to encode URL \(invalidUrl)")
        }
    }

    func testRandom() {
        XCTAssertEqual(String.random(length: 20).count, 20)
        XCTAssertEqual(String.random(length: 1).count, 1)
        XCTAssertEqual(String.random(length: 0).count, 0)
    }
    
    func testMatches() {
        
        var matches = str.matches(for: pattern)
        XCTAssertNotNil(matches)
        XCTAssertTrue(matches.count == 6)
        
        matches = emptyStr.matches(for: pattern)
        XCTAssertNotNil(matches)
        XCTAssertTrue(matches.isEmpty)
        
        matches = str.matches(for: "")
        XCTAssertNotNil(matches)
        XCTAssertTrue(matches.isEmpty)
    }
}
