//
//  QMobileAPITests.swift
//  QMobileAPITests
//
//  Created by Eric Marchand on 28/03/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI

import SwiftyJSON

class TableTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

    }

    func testJSONTable() {
        XCTAssertTrue(tablesNames.count > 0, "no test")
        for tableName in tablesNames {
            if let table = table(name: tableName) {
                XCTAssert(!table.attributes.isEmpty, "attribute must not be empty for table \(tableName)")
                XCTAssert(!table.keys.isEmpty, "key must not be empty for table \(tableName)")
                if let key = table.keys.values.first {
                    XCTAssertNotNil(key.attribute, "key attribute must not be nil for table \(tableName)")

                    if let type = key.attribute?.storageType {
                        XCTAssertEqual(type, AttributeStorageType.long, "check that we use long as key. If other types code could be changed")
                    }
                }
            }
        }
    }

    func testJSONTables() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "catalogClient", withExtension: "json") else {
            XCTFail("File not found to test all tables parsing")
            return
        }
        guard let data = try? Data(contentsOf: url, options: []) else {
            XCTFail("Failed to read data for all table at url \(url)")
            return
        }
        let jsonable = TestJSONable(data: data)

        guard let json = jsonable?.json else {
            XCTFail("Failed to parse json")
            return
        }

        let tableCount = 6

        let tables = Table.all(json: json)
        XCTAssertEqual(tables.count, tableCount)

        for tableName in tablesNames {
            var found = false
            for table in tables {
                if table.name == tableName {
                    found = true
                }
            }
            XCTAssertTrue(found, "table \(tableName) not found")
        }

        let tablesCheckArray = Table.array(json: json) ?? []
        XCTAssertEqual(tablesCheckArray.count, tableCount)
    }

    func testJSONTablesWithNoKey() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "catalog", withExtension: "json") else {
            XCTFail("File not found to test all tables parsing")
            return
        }
        guard let data = try? Data(contentsOf: url, options: []) else {
            XCTFail("Failed to read data for all table at url \(url)")
            return
        }
        let jsonable = TestJSONable(data: data)

        guard let json = jsonable?.json else {
            XCTFail("Failed to parse json")
            return
        }

        // There is no table in catalog.json because this catalog and not table
        let tables = Table.all(json: json)
        XCTAssertEqual(tables.count, 0)
    }

    func testJSONFromFile() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "catalog", withExtension: "json") else {
            XCTFail("File not found to test JSON from file")
            return
        }

        guard let json = try? JSON(fileURL: url) else {
            XCTFail("File not JSON parsable") // XXX show errors
            return
        }
        XCTAssertFalse(json.isEmpty)

    }

    func testJSONFromFakeURL() {
        let  url = URL(string: "http://example.com")!
        guard let json = try? JSON(fileURL: url) else {
            XCTFail("File not JSON parsable. Must not occurs because not file url")
            return
        }
        XCTAssertTrue(json.isEmpty)

        let jsonable = TestJSONable(fileURL: url)
        XCTAssertNil(jsonable)

    }

    func testJSONFromUnknownFile() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "catalog", withExtension: "json") else {
            XCTFail("File not found to test JSON from file")
            return
        }
        
        let json = try? JSON(fileURL: url.appendingPathExtension("fake"))
        XCTAssertTrue(json?.isEmpty ?? true)
    }


    func testTableEquatable() {
        XCTAssertEqual(Table(name: "name"), Table(name: "name"))
        XCTAssertNotEqual(Table(name: "name"), Table(name: "name2"))
    }

    func testTableDictionary() {
        let dico = Table(name: "name").dictionary

        XCTAssertEqual(dico["dataClasses"] as? String, "name")
    }

}

struct TestJSONable: JSONDecodable {

    let json: JSON
    init?(json: JSON) {
        self.json = json
    }
}
