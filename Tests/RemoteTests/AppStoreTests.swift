//
//  AppStoreTests.swift
//  Tests
//
//  Created by Eric Marchand on 05/12/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
import QMobileAPI

class AppStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLookupAppStore() {
        let expectation = self.expectation()

        let _ = ItunesAPI.lookup(bundleId: "com.apple.iBooks") { result in
            do {
                let items = try result.get()
                XCTAssertTrue(items.resultCount > 0)
                XCTAssertEqual(items.results.count, items.resultCount)

                if let first = items.results.first {
                    XCTAssertNotNil(first.version)

                    let info = first.applicationInfo
                    XCTAssertNotNil(info.bundleId)
                    XCTAssertNotNil(info.version)
                }
            } catch {
                XCTFail("\(error)")
            }

            expectation.fulfill()
        }

        wait(timeout: 10)
    }

}
