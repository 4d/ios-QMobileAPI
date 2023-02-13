//
//  RemoteMethodTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/05/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI
import Moya
import Result

class RemoteTableMethodTests: XCTestCase {
    let requestTimeout: TimeInterval = 5

    let instance = APIManager.instance

    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetMethod() {
        let expectation = self.expectation()

        let table = RemoteConfig.tableName
        let method = "getmethod"
        
        let target = instance.base.records(from: table).method(name: method)

        let completion: APIManager.Completion = { result  in
            switch result {
            case .success(let data):
                print("\(data)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        let cancellable = instance.request(target, completion: completion)

        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }
    
    func testGetMethodWithTable() {
        let expectation = self.expectation()
        
        let table = Table(name: RemoteConfig.tableName)
        let tableMethod = TableMethod(name: "getmethod")
        
        let cancellable = self.instance.method(table: table, method: tableMethod, completionHandler: { result in
            switch result {
            case .success(let actionResult):
                print("\(actionResult)")
                do {
                    let filteredResponse = try actionResult.filterSuccessfulStatusAndRedirectCodes()
                    XCTAssertNotNil(filteredResponse)
                } catch let error {
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        })
        
        XCTAssertFalse(cancellable.isCancelled)
        
        wait(timeout: requestTimeout)
    }
    
    func testGetMethodWithTableName() {
        let expectation = self.expectation()
        
        let table = RemoteConfig.tableName
        let method = "getmethod"
        
        let cancellable = self.instance.method(table: table, name: method, completionHandler: { result in
            switch result {
            case .success(let actionResult):
                print("\(actionResult)")
                do {
                    let filteredResponse = try actionResult.filterSuccessfulStatusAndRedirectCodes()
                    XCTAssertNotNil(filteredResponse)
                } catch let error {
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        })
        
        XCTAssertFalse(cancellable.isCancelled)
        
        wait(timeout: requestTimeout)
    }

    func testPostMethod() {
        let expectation = self.expectation()

        let table = RemoteConfig.tableName

        let method = "postmethod"
        let target = instance.base.records(from: table).method(name: method)
        target.method = .post
        target.parameters = ["": ["John", "Smith"]]

        let completion: APIManager.Completion = { result  in
            switch result {
            case .success(let data):
                print("\(data)")

                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
           let cancellable = instance.request(target, completion: completion)

        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }
}
