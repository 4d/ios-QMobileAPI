//
//  RemoteDeletedRecordsTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 14/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

import XCTest
@testable import QMobileAPI
import Moya


class RemoteDeletedRecordsTests: XCTestCase {

    let requestTimeout: TimeInterval = 5

    let instance = APIManager.instance

    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
    }

    func testLoadPageObject() {
        let expectation = self.expectation()

        let limit = 10000000

        let cancellable = self.instance.deletedRecordPage(configure: { builder in
            builder.limit(limit) // expected more than count

        }) { result  in
            switch result {
            case .success(let page):
                print("\(page)")

                let pageInfo = page.info

                XCTAssertTrue(limit > pageInfo.count)
                XCTAssertTrue(pageInfo.isLast)
                XCTAssertTrue(pageInfo.isFirst)
                XCTAssertFalse(pageInfo.isEmpty)

                XCTAssertEqual(page.records.count, pageInfo.count)

                for record in page.records {

                    XCTAssertNotNil(record.key)
                    XCTAssertNotNil(record.stamp)
                    XCTAssertNotNil(record.timestamp)
                    XCTAssertEqual(record.tableName, DeletedRecordKey.entityName)
                }

                if let deletedRecords = page.deletedRecords {
                    XCTAssertEqual(deletedRecords.count, pageInfo.count)
                    for deletedRecord in deletedRecords {
                        XCTAssertFalse(deletedRecord.tableName.isEmpty)
                        XCTAssertFalse(deletedRecord.primaryKey.isEmpty)

                        let json = deletedRecord.json
                        XCTAssertNotNil(json[DeletedRecordKey.primaryKey])
                        XCTAssertNotNil(json[DeletedRecordKey.tableName])
                        XCTAssertNotNil(json[DeletedRecordKey.tableNumber])
                        XCTAssertNotNil(json[DeletedRecordKey.stamp])
                    }
                } else {
                    XCTFail("Fail to get deleted records information. maybe table renamed")
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
