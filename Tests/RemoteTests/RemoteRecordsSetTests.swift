//
//  RemoteRecordsSetTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/05/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI
import Moya


class RemoteRecordsSetTests: XCTestCase {

    let requestTimeout: TimeInterval = 5

    let tablePrimaryKeyValue = 1

    let instance = APIManager.instance

    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
    }

    func testLoadRecords() {
        let expectation = self.expectation()

        let limit = 10000000
        withTable(RemoteConfig.tableName, instance) { table in

            let setID = "setID"

            let cancellable = self.instance.records(table: table, setID: setID, configure: { builder in
                builder.limit(limit) // expected more than count

            }, initializer: TestBuilder()) { result  in
                switch result {
                case .success(let (records, page)):
                    print("\(records)")

                    XCTAssertTrue(limit > page.count)
                    XCTAssertTrue(page.isLast)

                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("\(error)")
                }
            }
            XCTAssertFalse(cancellable.isCancelled)
        }

        wait(timeout: requestTimeout)
    }

    func testLoadRecordsByPage() {
        let expectation = self.expectation()

        withTable(RemoteConfig.tableName, instance) { table in
            var count = 0
            let limit = 10
            var pageCount = 0

            // TODO test with stub, stub must check limit and send different data according to this limit
            let setID = "setID"

            let cancellable = self.instance.records(table: table, setID: setID, configure: { builder in
                builder.limit(limit)

            }, initializer: TestBuilder()) { result  in
                switch result {
                case .success(let (records, page)):
                    pageCount += 1
                    print("Page: \(page)")
                    print("Record in page: \(records.count)")

                    //let index = page.first % limit
                    // print("Index: \(index)")

                    count = count + records.count

                    if count == page.count {
                        XCTAssertTrue(page.isLast)

                        let expectedPageCount = (page.count - 1) / limit + 1
                        XCTAssertEqual(pageCount, expectedPageCount)

                        expectation.fulfill()
                    } else {
                        XCTAssertFalse(page.isLast)
                    }

                case .failure(let error):
                    XCTFail("\(error)")
                }
            }
            XCTAssertFalse(cancellable.isCancelled)
        }

        wait(timeout: requestTimeout * 2)
    }
 
    func testDeleteEntitySet() {
        let expectation = self.expectation()
        
        let cancellable = instance.entitySetInfo { result in
            switch result {
            case .success(let infoEntitySet):
                XCTAssertFalse(infoEntitySet.entitySet.isEmpty, "No entity set to test")
                if let entitySet = infoEntitySet.entitySet.first {
                    _ = self.instance.delete(entitySet: entitySet) { resultstatus in
                        do {
                            let status = try resultstatus.get()
                            XCTAssertTrue(status.ok)
                        } catch {
                            XCTFail("\(error)")
                        }
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
    
    func testReleaseEntitySet() {
        let expectation = self.expectation()
        
        let cancellable = instance.entitySetInfo { result in
            switch result {
            case .success(let infoEntitySet):
                XCTAssertFalse(infoEntitySet.entitySet.isEmpty, "No entity set to test")
                if let entitySet = infoEntitySet.entitySet.first {
                    _ = self.instance.release(entitySet: entitySet) { resultstatus in
                        do {
                            let status = try resultstatus.get()
                            XCTAssertTrue(status.ok)
                        } catch {
                            XCTFail("\(error)")
                        }
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
}
