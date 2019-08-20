//
//  RemoteInfoTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

import XCTest
@testable import QMobileAPI
import Moya


class RemoteInfoTests: XCTestCase {

    let requestTimeout: TimeInterval = 5

    let instance = APIManager.instance

    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
    }

    func testLoadWebTest() {
        let expectation = self.expectation()

        let cancellable = instance.loadWebTestInfo { result in
            switch result {
            case .success(let response):
                print("\(response)")
                XCTAssertFalse(response.info.isEmpty)
                XCTAssertTrue(response.is4D)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadStatus() {
        let expectation = self.expectation()

        let cancellable = instance.status { result in
            switch result {
            case .success(let response):
                print("\(response)")
                XCTAssertTrue(response.ok)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadInfo() {
        let expectation = self.expectation()

        let cancellable = instance.info { result in
            switch result {
            case .success(let info):
                print("\(info)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadSessionInfo() {
        let expectation = self.expectation()

        let cancellable = instance.sessionInfo { result in
            switch result {
            case .success(let info):
                print("\(info)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadProgressInfo() {
        let expectation = self.expectation()

        let cancellable = instance.progressInfo { result in
            switch result {
            case .success(let info):
                print("\(info)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadCacheInfo() {
        let expectation = self.expectation()

        let cancellable = instance.cacheInfo { result in
            switch result {
            case .success(let info):
                print("\(info)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadEntitySet() {
        let expectation = self.expectation()

        let cancellable = instance.entitySetInfo { result in
            switch result {
            case .success(let info):
                print("\(info)")
                XCTAssertFalse(info.entitySet.isEmpty)
                
                XCTAssertEqual(info.entitySet.count, info.entitySetCount,"entitySetCount is not equal to the number of entitySet")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadInfoCancel() {
        let expectation = self.expectation()
        let testQueue = DispatchQueue(label: "test.queue")

        let cancellable = instance.info(callbackQueue: testQueue) { result in

            if RemoteConfig.stub {
                // current queue should be main
            } else {
                // current queue must be testQueue
            }

            switch result {
            case .success(_):
                if RemoteConfig.stub {

                    expectation.fulfill()
                } else {
                    XCTFail("Must not succeed if cancelled")
                }
            case .failure(let error):

                XCTAssertTrue(error.isCancelled)

                if case .request(let networkError) = error {
                    let userInfo = (networkError as NSError).userInfo
                    if let _ = userInfo[NSLocalizedDescriptionKey] {
                        // XCTAssertEqual(message, "cancelled")
                    }

                } else {
                    XCTFail("Must be a network error \(error)")
                }
                expectation.fulfill()
            }
        }
        cancellable.cancel()
        XCTAssertTrue(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }
}
