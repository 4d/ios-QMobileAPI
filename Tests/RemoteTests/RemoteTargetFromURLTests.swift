//
//  RemoteTargetFromURLTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/05/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI
import Moya


class RemoteTargetFromURLTests: XCTestCase {

    let requestTimeout: TimeInterval = 5
    let instance = APIManager.instance

    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCatalogURI() {
        let expectation = self.expectation()

        let cancellable = instance.catalog { result in
            switch result {
            case .success(let catalogs):
                XCTAssertFalse(catalogs.isEmpty)

                for catalog in catalogs {
                    XCTAssertFalse(catalog.name.isEmpty)
                    if let uri = catalog.dataURI {
                        let target = self.instance.target(for: uri)
                        XCTAssertNotNil(target, "Could not find target for uri \(uri)")
                        let expected = self.instance.base.records(from: catalog.name)
                        if let target = target {
                            XCTAssertEqualTargetType(target, expected)
                        }
                    } else {
                        XCTFail("Cannot test, no uri")
                    }
                    if let uri = catalog.uri {
                        let target = self.instance.target(for: uri)
                        XCTAssertNotNil(target)
                        let expected = self.instance.base.catalog.table(catalog.name)
                        XCTAssertEqualTargetType(target!, expected)
                    } else {
                        XCTFail("Cannot test, no uri")
                    }
                }
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testRest() {
        let path = self.instance.base.path
        let rest = self.instance.target(for: path)
        XCTAssertNotNil(rest)
        XCTAssertEqualTargetType(rest!, self.instance.base)

        let status = self.instance.target(for: "\(path)/")
        XCTAssertNotNil(status)
        XCTAssertEqualTargetType(status!, self.instance.base.status)
    }

    func testRecords() {
        let table = "PRODUCTS"
        var url = self.instance.base.baseURL.appendingPathComponent(self.instance.base.path)
            .appendingPathComponent(table)
        var target = self.instance.target(for: url)
        XCTAssertNotNil(target)
        if let recordsTarget = target as? RecordsTarget {
            XCTAssertEqual(recordsTarget.table, table)
        } else {

            XCTFail("wrong target type \(String(describing: target)), expected \(RecordsTarget.self)")
        }

        url = self.instance.base.baseURL.appendingPathComponent(self.instance.base.path)
            .appendingPathComponent("\(table)?%24filter=__stamp%3D50&%24limit=100")
        target = self.instance.target(for: url)
        XCTAssertNotNil(target)
        if let recordsTarget = target as? RecordsTarget {
            XCTAssertEqual(recordsTarget.table, table)
        } else {
            XCTFail("wrong target type \(String(describing: target)), expected \(RecordsTarget.self)")
        }
    }

    func testInfo() {
        let expected = self.instance.base.info
        let path = expected.path
        let value = self.instance.target(for: "\(path)/")
        XCTAssertNotNil(value)
        XCTAssertEqualTargetType(value!, expected)
    }

    // LINK add test on table link when implemented
}

func XCTAssertEqualTargetType(_ value: TargetType, _ expected: TargetType) {
    XCTAssertEqual(value.path, expected.path)
    XCTAssertEqual(value.baseURL, expected.baseURL)
    XCTAssertEqual(value.basePath, expected.basePath)
}
