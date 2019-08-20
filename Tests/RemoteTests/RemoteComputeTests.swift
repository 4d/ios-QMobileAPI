//
//  RemoteComputeTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 02/05/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

import XCTest
@testable import QMobileAPI
import Moya


class RemoteComputeTests: XCTestCase {

    let requestTimeout: TimeInterval = 5

    let instance = APIManager.instance

    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
    }

    func testComputeAll() {
        let expectation = self.expectation()
        doTestCompute(.all, expectation)
        wait(timeout: requestTimeout)
    }

    func testComputeAverage() {
        let expectation = self.expectation()
        doTestCompute(.average, expectation)
        wait(timeout: requestTimeout)
    }

    func testComputeCount() {
        let expectation = self.expectation()
        doTestCompute(.count, expectation)
        wait(timeout: requestTimeout)
    }

    func testComputeMin() {
        let expectation = self.expectation()
        doTestCompute(.min, expectation)
        wait(timeout: requestTimeout)
    }

    func testComputeMax() {
        let expectation = self.expectation()
        doTestCompute(.max, expectation)
        wait(timeout: requestTimeout)
    }

    func testComputeSum() {
        let expectation = self.expectation()
        doTestCompute(.sum, expectation)
        wait(timeout: requestTimeout)
    }

    func doTestCompute(_ operation: ComputeOperation, _ expectation: XCTestExpectation) {
        withTable(RemoteConfig.tableName, instance) { table in

            let attributes = table.attributes
            guard let attribute = attributes.first else {
                XCTFail("No attribute to test in table \(table)")
                return
            }

            let cancellable = self.instance.compute(table: table.name, attribute: attribute.key, operation: operation) { result  in
                switch result {
                case .success(let compute):
                    let expected = operation.expected
                    for op in expected {
                        let result = compute[op]
                        XCTAssertNotNil(result)
                    }
                    let count = compute.results.count
                    if self.instance.stubDelegate != nil { // XXX remove if stub could return info according to operation
                        XCTAssertEqual(count, expected.count)
                    }

                    expectation.fulfill()
                case .failure(let error):
                    print(error)
                    XCTFail("\(error)")
                }
            }
            XCTAssertFalse(cancellable.isCancelled)
        }

    }

}
