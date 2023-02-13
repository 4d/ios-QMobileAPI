//
//  KeyTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI

import SwiftyJSON

class KeyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKeyName() {
        let aName = "aName"
        let key = Key(name: aName, attribute: nil)

        XCTAssertEqual(key.name, aName)

        let json = key.json

        XCTAssertEqual(json["name"].string, aName)
    }

    func testKeyNoName() {
        let key = Key(json: JSON(["fake": name]))

        XCTAssertNil(key)
    }

    func testKeyPredicates() {

        let aName = "city"
        let value = "MyString"

        let attribute = Attribute(name: aName, kind: .storage, scope: .public, type: AttributeStorageType.string)
        let key = Key(name: aName, attribute: attribute)

        let importable = MockRecordImportable()
        importable.values[attribute] = value

        let notMatching = MockRecordImportable()
        notMatching.values[attribute] = "notMatching"

        let predicateForValue = key.predicate(for: value)
        XCTAssertTrue(predicateForValue.evaluate(with: importable))
        XCTAssertFalse(predicateForValue.evaluate(with: notMatching))
        // var predicateForJSON = key.predicate(for json: JSON)

        let predicateOnImportable = key.predicate(for: importable)
        XCTAssertNotNil(predicateOnImportable)
        XCTAssertTrue(predicateOnImportable!.evaluate(with: importable))
        XCTAssertFalse(predicateOnImportable!.evaluate(with: notMatching))

        let unknownAttribute = Attribute(name: "unknownsdasd", kind: .storage, scope: .public, type: AttributeStorageType.string)
        let unknownKey = Key(name: "unknownsdasd", attribute: unknownAttribute)
        let predicateOnImportableNil = unknownKey.predicate(for: importable)
        XCTAssertNil(predicateOnImportableNil)

    }
}

class MockRecordImportable: NSObject, RecordImportable {


    var values: [Attribute: Any?] = [:]
    var tableName: String {
        return "mock"
    }

    func has(key: String) -> Bool {
        for attribute in values.keys {
            if attribute.name == key {
                return true
            }
        }
        return false
    }
    func isRelation(key: String) -> Bool {
        for attribute in values.keys {
            if attribute.name == key {
                return attribute.type.isRelative
            }
        }
        return false
    }

    func isField(key: String) -> Bool {
        for attribute in values.keys {
            if attribute.name == key {
                return attribute.type.isStorage
            }
        }
        return false
    }

    func set(attribute: Attribute, value: Any?, with mapper: AttributeValueMapper) {

    }

    func get(attribute: Attribute, with mapper: AttributeValueMapper) -> Any? {
        return values[attribute] ?? nil
    }

    func setPrivateAttribute(key: String, value: Any?) {
        // do nothing
    }

    func getPrivateAttribute(key: String) -> Any? {
        return nil
    }

    override func value(forUndefinedKey key: String) -> Any? {
        for (attribute, _) in values {
            if attribute.name == key {
                return get(attribute: attribute, with: AttributeValueMapper.default)
            }
        }
        return nil
    }

}
