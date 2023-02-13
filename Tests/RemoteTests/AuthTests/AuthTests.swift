//
//  AuthTests.swift
//  Tests
//
//  Created by Eric Marchand on 15/03/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//
import XCTest
@testable import QMobileAPI
import Moya
import Result

class AuthTests: XCTestCase {

    let requestTimeout: TimeInterval = 5

    let instance = APIManager.instance

    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
    }

    func testAuth() {
        let expectation = self.expectation()

        let parameters = [
            "method":"OnAuthAuthorizeAll"
        ]

        let cancellable = instance.authentificate(
            login: "test@4d.com",
            parameters: parameters) { result in
                switch result {
                case .success(let token):
                    print("\(token)")
                    XCTAssertTrue(token.isValidToken)
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("\(error)")
                }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLogout() {
        let expectation = self.expectation()

        let cancellable = instance.logout{ result in
                switch result {
                case .success(let status):
                    print("\(status)")
                    XCTAssertTrue(status.ok)
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("\(error)")
                }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }
}
