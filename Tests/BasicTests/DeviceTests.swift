//
//  DeviceTests.swift
//  Tests
//
//  Created by Eric Marchand on 09/03/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//

import Foundation

import XCTest
@testable import QMobileAPI
#if(os(iOS))
import DeviceKit
#endif
class DeviceTests: XCTestCase {

    let requestTimeout: TimeInterval = 5

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCurrent() {
        let current = Device.current
        XCTAssertNotNil(current)
    }

    func testUnderlying() {
        let model = Device.current.realDevice
        #if os(iOS)
        if case .simulator = Device.current {
            XCTAssertNotEqual(Device.current, model)
        }
        #endif
    }

    func testToken() {
        let token = Device.token
        XCTAssertNotNil(token)
    }

    func testFetchToken() {
        let expectation = self.expectation()

        Device.fetchToken { result in
            switch result {
            case .success(let token):
                print("\(token)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }

        wait(timeout: requestTimeout)
    }
 
}
