//
//  QRestTargetTests.swift
//  QAPI
//
//  Created by Eric Marchand on 08/03/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI
import Moya
import Result

class RemoteRecordsTests: XCTestCase {

    let requestTimeout: TimeInterval = 5

    let tablePrimaryKeyValue = 1

    let instance = APIManager.instance

    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
    }

    func testLoadPageObject() {
        let expectation = self.expectation()

        let limit = 10000000
        withTable(RemoteConfig.tableName, instance) { table in

            let cancellable = self.instance.recordPage(table: table, configure: { builder in
                builder.limit(limit) // expected more than count

            }) { result  in
                switch result {
                case .success(let pageObject):
                    print("\(pageObject)")

                    let page = pageObject.info

                    XCTAssertTrue(limit > page.count)
                    XCTAssertTrue(page.isLast)
                    XCTAssertTrue(page.isFirst)
                    XCTAssertFalse(page.isEmpty)

                    XCTAssertEqual(pageObject.records.count, page.count)

                    for record in pageObject.records {

                        XCTAssertNotNil(record.key)
                        XCTAssertNotNil(record.stamp)
                        XCTAssertNotNil(record.timestamp)
                        XCTAssertEqual(record.tableName, RemoteConfig.tableName)
                    }

                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("\(error)")
                }
            }
            XCTAssertFalse(cancellable.isCancelled)
        }

        wait(timeout: requestTimeout)
    }

    func testLoadRecords() {
        let expectation = self.expectation()

        let limit = 10000000
        withTable(RemoteConfig.tableName, instance) { table in

            let cancellable = self.instance.records(table: table, configure: { builder in
                builder.limit(limit) // expected more than count

            }, initializer: TestBuilder()) { result  in
                switch result {
                case .success(let (records, page)):
                    print("\(records)")

                    XCTAssertTrue(limit > page.count)
                    XCTAssertTrue(page.isLast)
                    XCTAssertTrue(page.isFirst)

                    XCTAssertFalse(page.isEmpty)

                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("\(error)")
                }
            }
            XCTAssertFalse(cancellable.isCancelled)
        }

        wait(timeout: requestTimeout)
    }

    func testLoadOneRecordObject() {
        let expectation = self.expectation()

        withTable(RemoteConfig.tableName, instance) { table in

            let cancellable = self.instance.recordJSON(table: table, key: self.tablePrimaryKeyValue) { result  in
                switch result {
                case .success(let record):
                    print("\(record)")

                    XCTAssertNotNil(record.key)
                    XCTAssertNotNil(record.stamp)
                    XCTAssertNotNil(record.timestamp, record.json["__TIMESTAMP"].stringValue)

                    XCTAssertEqual(record.tableName, RemoteConfig.tableName)

                    expectation.fulfill()

                case .failure(let error):
                    XCTFail("\(error)")
                }
            }
            XCTAssertFalse(cancellable.isCancelled)
        }

        wait(timeout: requestTimeout)
    }

    func testLoadOneRecord() {
        let expectation = self.expectation()

        withTable(RemoteConfig.tableName, instance) { table in

            let cancellable = self.instance.loadRecord(table: table, key: self.tablePrimaryKeyValue, initializer: TestBuilder()) { result  in
                switch result {
                case .success(let record):
                    print("\(record)")
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

            let cancellable = self.instance.records(table: table, configure: { builder in
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
    
    func testDeleteRecord() {
        let expectation = self.expectation()

        withTable(RemoteConfig.tableName, instance) { table in

            let cancellable = self.instance.recordJSON(table: table, key: self.tablePrimaryKeyValue) { result  in
                switch result {
                case .success(let record):
                    XCTAssertNotNil(record.key)
                    
                    _ = self.instance.delete(recordJSON: record) { resultstatus in
                        do {
                            let status = try resultstatus.get()
                            XCTAssertTrue(status.ok)
                        } catch {
                            XCTFail("\(error)")
                        }
                        expectation.fulfill()
                    }
                    
                case .failure(let error):
                    XCTFail("\(error)")
                }
            }
            XCTAssertFalse(cancellable.isCancelled)
        }

        wait(timeout: requestTimeout)
    }

    func testDeleteRecords() {
        let expectation = self.expectation()

        withTable(RemoteConfig.tableName, instance) { table in
            let config: APIManager.ConfigureRecordsRequest = { request in
                request.filter("ID=11")
            }
            let cancellable = self.instance.deleteRecords(tableName: table.name, configure: config) { result  in
                do {
                    let status = try result.get()
                    XCTAssertTrue(status.ok)
                } catch {
                    XCTFail("\(error)")
                }
                expectation.fulfill()
            }
            XCTAssertFalse(cancellable.isCancelled)
        }

        wait(timeout: requestTimeout)
    }

    func testLoadRecordsFilter() {
        let expectation = self.expectation()

        let limit = 10000000
        withTable(RemoteConfig.tableName, instance) { table in

            let cancellable = self.instance.records(table: table, configure: { builder in
                builder.limit(limit) // expected more than count
                builder.filter("title = :title")
                builder.params([["title": "test"]])
            }, initializer: TestBuilder()) { result  in
                switch result {
                case .success(let (records, page)):
                    print("\(records)")

                    XCTAssertTrue(limit > page.count)
                    XCTAssertTrue(page.isLast)
                    XCTAssertTrue(page.isFirst)

                    XCTAssertFalse(page.isEmpty)

                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("\(error)")
                }
            }
            XCTAssertFalse(cancellable.isCancelled)
        }

        wait(timeout: requestTimeout)
    }

}

func withTable(_ name: String, _ instance: APIManager, function: String = #function, handler: @escaping (Table) -> Void) {
    _ = instance.table(name: name) { result in
        switch result {
        case .success(let table):
            handler(table)
        case .failure(let error):
            XCTFail("No table \(name) to test \(function): \(error)")
        }
    }
}

struct TestBuilder: ImportableBuilder {
    typealias Importable = TestJSONWrapper

    func setup(in callback: @escaping () -> Void) {
        callback()
    }
    func build(_ tableName: String, _ json: JSON) -> Importable? {
        var record = TestJSONWrapper(json: json)
        record?.tableName = tableName
        return record
    }
    func teardown() {
    }
}

struct TestJSONWrapper: JSONDecodable, RecordImportable {

    let json: JSON
    var tableName: String = ""
    init?(json: JSON) {
        self.json = json
    }

    func has(key: String) -> Bool {
        return true
    }

    func isRelation(key: String) -> Bool {
        return false
    }
    func isField(key: String) -> Bool {
        return true
    }
    func set(attribute: Attribute, value: Any?, with mapper: AttributeValueMapper) {

    }
    func get(attribute: Attribute, with mapper: AttributeValueMapper) -> Any? {
        return nil
    }

    func setPrivateAttribute(key: String, value: Any?) {

    }
    func getPrivateAttribute(key: String) -> Any? {
        return nil
    }

}
