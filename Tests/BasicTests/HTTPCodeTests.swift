//
//  HTTPCodeTests.swift
//  Tests
//
//  Created by Quentin Marciset on 15/07/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import Foundation

import XCTest
@testable import QMobileAPI

class HTTPCodeTests : XCTestCase {
    
    //let clientErrors = ClientError.allCases
    //let serverErrors = ServerError.allCases
    let httpCodes = HTTPCode.allCases

    func testHTTPCodeMessage() {
        for code in HTTPCode.allCases {
            XCTAssertNotNil(code.message)
            XCTAssertFalse(code.message.isEmpty)
        }
    }
    
    func testHTTPCodeReason() {
        for code in HTTPCode.allCases {
            XCTAssertNotEqual(code.reason, "")
        }
    }
    
    /*func testClientError() {
        for error in clientErrors {
            XCTAssertTrue((400..<500).contains(error.httpCode.rawValue))
        }
    }
    
    func testServerError() {
        for error in serverErrors {
            XCTAssertTrue((500..<528).contains(error.httpCode.rawValue))
        }
    }*/
    
    func test_equals_httpCodesDiffer_isFalse() {
        let notFoundCode = HTTPCode(rawValue: 404)
        let badRequestCode = HTTPCode(rawValue: 400)
        XCTAssertNotEqual(notFoundCode, badRequestCode)
        XCTAssertNotEqual(badRequestCode, notFoundCode)
    }
}
