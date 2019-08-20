//
//  RemoteStructureTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

import XCTest
@testable import QMobileAPI
import Moya


class RemoteStructureTests: XCTestCase {

    let requestTimeout: TimeInterval = 5

    let instance = APIManager.instance

    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
    }

    func testLoadTables() {
        let expectation = self.expectation()

        let cancellable = instance.tables { result in
            switch result {
            case .success(let tables):
                XCTAssertFalse(tables.isEmpty)

                for table in tables {

                    XCTAssertFalse(table.name.isEmpty)
                    XCTAssertFalse(table.attributes.isEmpty)
                    XCTAssertFalse(table.keys.isEmpty)

                    XCTAssertNotNil(table.keys.first?.value.attribute)
                }

                // print("\(tables)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadOneTable() {
        let expectation = self.expectation()
        let tableName = RemoteConfig.tableName
        let cancellable = instance.table(name: tableName) { result in
            switch result {
            case .success(let table):
                print("\(table)")

                XCTAssertEqual(table.name, tableName)
                XCTAssertFalse(table.attributes.isEmpty)
                XCTAssertFalse(table.keys.isEmpty)

                XCTAssertNotNil(table.keys.first?.value.attribute)

                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testLoadCatalog() {
        let expectation = self.expectation()

        let cancellable = instance.catalog { result in
            switch result {
            case .success(let catalogs):
                XCTAssertFalse(catalogs.isEmpty)

                for catalog in catalogs {
                    XCTAssertFalse(catalog.name.isEmpty)
                    XCTAssertFalse(catalog.dataURI?.isEmpty ?? false)
                    XCTAssertFalse(catalog.uri?.isEmpty ?? false)
                }

                //print("\(catalogs)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }
}
