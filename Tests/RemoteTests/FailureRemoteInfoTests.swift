//
//  FailureRemoteInfoTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 07/07/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

import XCTest
@testable import QMobileAPI
import Moya

import SwiftyJSON

class FailureRemoteInfoTests: XCTestCase {

    let requestTimeout: TimeInterval = 5

    var expectedError: NSError?

    let instance = APIManager.instance

    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
        instance.stubDelegate = self
        self.expectedError = URLError(code: .networkConnectionLost)
    }

    override func tearDown() {
        super.tearDown()
        instance.stubDelegate = nil
        self.expectedError = nil
    }

    func testLoadStatus() {
        let expectation = self.expectation()

        let cancellable = instance.status { result in
            switch result {
            case .success(let response):
                XCTFail("\(response)")
            case .failure(let error):
                self.checkError(error)
                expectation.fulfill()
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadInfo() {
        let expectation = self.expectation()

        let cancellable = instance.info { result in
            switch result {
            case .success(let response):
                XCTFail("\(response)")
            case .failure(let error):
                self.checkError(error)
                expectation.fulfill()
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadSessionInfo() {
        let expectation = self.expectation()

        let cancellable = instance.sessionInfo { result in
            switch result {
            case .success(let response):
                XCTFail("\(response)")
            case .failure(let error):
                self.checkError(error)
                expectation.fulfill()
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadProgressInfo() {
        let expectation = self.expectation()

        let cancellable = instance.progressInfo { result in
            switch result {
            case .success(let response):
                XCTFail("\(response)")
            case .failure(let error):
                self.checkError(error)
                expectation.fulfill()
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadCacheInfo() {
        let expectation = self.expectation()

        let cancellable = instance.cacheInfo { result in
            switch result {
            case .success(let response):
                XCTFail("\(response)")
            case .failure(let error):
                self.checkError(error)
                expectation.fulfill()
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }
    func testLoadEntitySet() {
        let expectation = self.expectation()

        let cancellable = instance.entitySetInfo { result in
            switch result {
            case .success(let response):
                XCTFail("\(response)")
            case .failure(let error):
                self.checkError(error)
                expectation.fulfill()
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

}

extension FailureRemoteInfoTests: StubDelegate {

    func URLError(code: URLError.Code, userInfo dict: [String : Any]? = nil) -> NSError {
        return NSError(domain: NSURLErrorDomain, code: code.rawValue, userInfo: dict)
    }

    func checkError(_ error: APIError) {
        switch error {
        case .request(let error):
            if let moya = error as? MoyaError {
                XCTAssertEqual(moya.error?._code, self.expectedError?._code)
                if let response = moya.response {
                    XCTAssertEqual(response.statusCode, self.expectedError?._code)
                }
            } else {
                XCTAssertEqual(error._code, self.expectedError?._code)
            }
        default:
            XCTFail("unexpected error type \(error)")
        }
    }

    func sampleResponse(_ target: TargetType) -> Moya.EndpointSampleResponse? {
        if let error = expectedError {
            return .networkError(error)
        }
       /* else if let errorString = self.errorString {
            return .stringResponse(self.errorCode, errorString)
        } else {
            return .stringResponse(self.errorCode, "An Error")
        }*/
        return nil
    }

}
