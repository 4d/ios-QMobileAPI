//
//  CodableTests.swift
//  Tests
//
//  Created by Eric Marchand on 04/12/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//

import XCTest
import Alamofire

@testable import QMobileAPI

class CodableTests: XCTestCase {
    
    let jsonPath = "Tests/Resources/JSON"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStatus() {
        let value = Status(ok: true)

        do {
            let data = try JSONEncoder().encode(value)
            let newValue = try JSONDecoder().decode(Status.self, from: data)
            XCTAssertEqual(value, newValue)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testInfoJSON() {
        let url = "\(jsonPath)/info.json".testBundleUrl
        if let value = Info(fileURL: url) {

            do {
                let data = try JSONEncoder().encode(value)
                let newValue = try JSONDecoder().decode(Info.self, from: data)
                XCTAssertEqual(value, newValue)
            } catch {
                XCTFail("\(error)")
            }
        } else {
            XCTFail("Failed to read data for file")
        }
    }

    func testCatalogJson() {
        let url = "\(jsonPath)/catalog.json".testBundleUrl
        if let value = Catalog(fileURL: url) {
            do {
                let data = try JSONEncoder().encode(value)
                let newValue = try JSONDecoder().decode(Catalog.self, from: data)
                XCTAssertEqual(value, newValue)
            } catch {
                XCTFail("\(error)")
            }
        } else {
            XCTFail("Failed to read data for file")
        }
    }


    func testDataStoreClass() {
        let url = "\(jsonPath)/cat.json".testBundleUrl
        if let value = Table(fileURL: url) {
            
            do {
                let data = try JSONEncoder().encode(value)
                let newValue = try JSONDecoder().decode(Table.self, from: data)
                XCTAssertEqual(value, newValue)
            } catch {
                XCTFail("\(error)")
            }
        } else {
            XCTFail("Failed to read data for file")
        }
    }

    func testError() {
        let url = "\(jsonPath)/erreur.json".testBundleUrl
        if let value = RestErrors(fileURL: url) {
            
            do {
                let data = try JSONEncoder().encode(value)
                let newValue = try JSONDecoder().decode(RestErrors.self, from: data)
                XCTAssertEqual(value, newValue)
            } catch {
                XCTFail("\(error)")
            }
        } else {
            XCTFail("Failed to read data for file")
        }
    }
}
