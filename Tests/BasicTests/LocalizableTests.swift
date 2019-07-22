//
//  LocalizeTests.swift
//  QMobileDataSync
//
//  Created by Eric Marchand on 22/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI

class LocalizableTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func _testAPIError() { // TODO try to exclude ir with SPM or try to make it work

        let errors: [APIError] = [
            .jsonMappingFailed(JSON([String]()), String.self),
            .recordsDecodingFailed(JSON([String]()), ImportableParser.Error.noTable),
            .request(NSError()),
            .jsonDecodingFailed(NSError()),
            .stringDecodingFailed(NSError())
        ]

        for error in errors {
            let message = error.errorDescription

            XCTAssertFalse(message?.isEmpty ?? true, "\(error)")
            XCTAssertFalse(message?.contains("api.") ?? true, "\(error) \(String(describing: message))")

            if let recover = error.recoverySuggestion {
                XCTAssertFalse(recover.isEmpty, "\(error)")
                XCTAssertFalse(recover.contains("api."), "\(error) \(recover)")
            }
        }
    }

}
