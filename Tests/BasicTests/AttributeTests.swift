//
//  AttributeTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 18/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI

class AttributeTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: AttributeNameTransformer
    func testNameTransformer() {
        var transformer = AttributeNameTransformer.find(for: "asdasdSSSS")
        XCTAssertNotNil(transformer)
        XCTAssertEqual(transformer!, AttributeNameTransformer.none)

        let withMaj = "QsdasdSSSS"
        transformer = AttributeNameTransformer.find(for: withMaj)
        XCTAssertNotNil(transformer)
        let decode = transformer!.decode(withMaj)
        XCTAssertEqual(decode, "qsdasdSSSS")
        XCTAssertEqual(transformer!.encode(decode), withMaj)
    }

    func testNameTransformer_NotValidWithNumber() {
        let transformer = AttributeNameTransformer.find(for: "4sdasdSSSS")
        XCTAssertNil(transformer)
    }

    func testNameTransformer_ValidWithSpace() {
        testNameTransformer_ValidWithSpace("dasd SSSS")
        testNameTransformer_ValidWithSpace(" dasd SSSS")
        testNameTransformer_ValidWithSpace("Sasd SSSS")
        testNameTransformer_ValidWithSpace("Sasd SSS  S")
        testNameTransformer_ValidWithSpace("Sasd SSS  S ")
    }

    func testNameTransformer_ValidWithSpace(_ string: String) {
        XCTAssertTrue(string.contains(" "), "No space, nothing tested")
        let transformer = AttributeNameTransformer.find(for: string)
        XCTAssertNotNil(transformer)

        if let transformer = transformer {
            let decoded = transformer.decode(string)
            XCTAssertFalse(decoded.contains(" "))

            let encoded = transformer.encode(decoded)
            XCTAssertEqual(encoded, string)

        }// Else failed, already tested
    }

    func testIsValidSwiftVar() {
        XCTAssertTrue("asdasdSSSS".isValidSwiftVar)
        XCTAssertTrue("asdasd_SSSS".isValidSwiftVar)
        // check capital
        XCTAssertFalse("QsdasdSSSS".isValidSwiftVar)
        // check number
        XCTAssertFalse("4asdasdSSSS".isValidSwiftVar)
        // check space
        XCTAssertFalse(CharacterSet.alphanumericsUndescore.isSuperset(ofCharactersIn: "a s"))
        XCTAssertFalse(CharacterSet.alphanumericsUndescore.isSuperset(ofCharactersIn: "a _ s"))
        XCTAssertFalse("asdas dSSSS".isValidSwiftVar)
    }

    func testIsReservedSwiftVar() {
        for reservedSwiftVar in AttributeNameTransformer.reservedSwiftVars {
            XCTAssertTrue(reservedSwiftVar.uppercasedFirstCharacter().isReservedSwiftVar, reservedSwiftVar)
        }
        for notReservedSwiftVar in [UUID().uuidString, "", "aeae", "descr iption", "Descr iption"] {
            XCTAssertFalse(notReservedSwiftVar.isReservedSwiftVar)
        }
    }

    func testTransformReservedSwiftVar() {

        for reservedSwiftVar in AttributeNameTransformer.reservedSwiftVars {
            let transformed = reservedSwiftVar.transformReservedSwiftVar()
            XCTAssertFalse(transformed.isReservedSwiftVar)
            XCTAssertFalse(transformed.capitalized.isReservedSwiftVar)
            XCTAssertFalse(transformed.lowercased().isReservedSwiftVar)
            XCTAssertFalse(transformed.uppercased().isReservedSwiftVar)

            XCTAssertTrue(transformed.isValidSwiftVar)
        }
    }

    func testUntransformReservedSwiftVar() {
        for reservedSwiftVar in AttributeNameTransformer.reservedSwiftVars {
            let transformed = reservedSwiftVar.transformReservedSwiftVar()

            let un = transformed.untransformReservedSwiftVar()

            XCTAssertTrue(un.isValidSwiftVar)
            XCTAssertEqual(un, reservedSwiftVar)
        }

        for notReservedSwiftVar in [UUID().uuidString, "", "aeae", "descr iption", "Descr iption"] {
            let un = notReservedSwiftVar.untransformReservedSwiftVar()
            XCTAssertEqual(un, notReservedSwiftVar, "nothing must change")
        }
    }
    /*
   func _testCheckPossibleReservedSwiftVar() {
        let object = ManagegObjectTest()
        let properties = object.propertyNames()
        XCTAssertFalse(properties.isEmpty)
        for name in properties {
            XCTAssertTrue(reservedSwiftVars.contains(name),name)
        }
    }*/

    // MARK: Filter

    func testComparisonFilter() {
        let key = "key"
        let value = "value"

        XCTAssertEqual((key.expression == value).query, "\(key) = \(value)")
        XCTAssertEqual((key.expression != value).query, "\(key) != \(value)")
        XCTAssertEqual((key.expression < value).query, "\(key) < \(value)")
        XCTAssertEqual((key.expression > value).query, "\(key) > \(value)")
        XCTAssertEqual((key.expression >= value).query, "\(key) >= \(value)")
        XCTAssertEqual((key.expression <= value).query, "\(key) <= \(value)")
    }

    func testCompoundFilter() {
        let key = "key"
        let value = "value"

        let query = (key.expression == value).query

        XCTAssertEqual(((key.expression == value) && (key.expression == value)).query, "\(query) AND \(query)")
        XCTAssertEqual(((key.expression == value) || (key.expression == value)).query, "\(query) OR \(query)")
        XCTAssertEqual((!(key.expression == value)).query, "EXCEPT \(query)")

        XCTAssertEqual(((key.expression == value) && (key.expression == value) && (key.expression == value)).query, "\(query) AND \(query) AND \(query)")
        XCTAssertEqual(((key.expression == value) || (key.expression == value) && (key.expression == value)).query, "\(query) OR \(query) AND \(query)")

        // TODO test attribute filters, with parenthesis?? operator prioriy, check how api rest could manage this, if parenthesis are available
    }

    /*func testParseFilter() {
        
        let key = "key"
        let value = "value"
        
        let expectedFilter = (key.expression == value)
        let query = expectedFilter.query
        
        if let filter = Attribute.Filter.parse(string: query) {
            XCTAssertEqualFilter(filter, expectedFilter)
            
        }
    }*/

    func testCompoundFilterWithString() {
        let key = "key"
        let value = "value"

        let addFilter = (key.expression == value)
        let query = addFilter.query

        let stringFilter = Attribute.Filter(query: query)

        let compound = stringFilter && addFilter
        XCTAssertEqual(compound.query, "\(query) AND \(query)")
    }

    func testAttributeRelativeType() {
        let tableName = "table"
        var type = AttributeRelativeType(rawValue: "table")
        XCTAssertEqual(type.relationTable, tableName)

        type = AttributeRelativeType(rawValue: "\(tableName)Collection")
        type.isToMany = true
        XCTAssertEqual(type.relationTable, tableName)
    }

}

func XCTAssertEqualFilter(_ value: Attribute.Filter, _ expected: Attribute.Filter) {
    XCTAssertEqual(value.query, expected.query)
    // XXX implement Equatable on Filter

    if let value = value as? Attribute.ComparisonFilter, let expected = expected as? Attribute.ComparisonFilter {
        XCTAssertEqual(value.comparator, expected.comparator)
    } else if let value = value as? Attribute.CompoundFilter, let expected = expected as? Attribute.CompoundFilter {
        XCTAssertEqual(value.conjunction, expected.conjunction)
    }

}

extension String {

    func transformReservedSwiftVar() -> String {
        return AttributeNameTransformer.runtimeReservedVariable.decode(self)
    }

    func untransformReservedSwiftVar() -> String {
        return AttributeNameTransformer.runtimeReservedVariable.encode(self)
    }

    var isReservedSwiftVar: Bool {
        return AttributeNameTransformer.capitalizedRuntimeReservedVariable.couldManage(self)
    }
}
/*
extension Attribute.Filter {

    static func parse(string: String) -> Attribute.Filter? {
        if string.isEmpty {
            return nil
        }
        var scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = CharacterSet.whitespaces
        
        var instruction: NSString?
        while scanner.scanString("", into: &instruction) {
            
        }
        //
        
       /* scanner.scanUpTo( " ", into: AutoreleasingUnsafeMutablePointer<NSString?>?)
        */
        
        return Attribute.Filter(query: string)
    }

}*/
/*
protocol PropertyNames {
    func propertyNames() -> [String]
}

extension PropertyNames {
    func propertyNames() -> [String] {
        let mirror = Mirror(reflecting: self)
        let children = mirror.children
        return children.flatMap {
            print($0.label ?? "nil")

            return $0.label
        }
    }
}
import CoreData
class ManagegObjectTest: NSManagedObject, PropertyNames {

    public func test() {
        self.description
        self.isDeleted
        self.isFault
        isInserted
        isUpdated
        isDeleted
        hasChanges
        hasPersistentChangedValues
    }

}*/
