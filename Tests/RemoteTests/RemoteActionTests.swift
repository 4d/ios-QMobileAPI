//
//  RemoteActionTests.swift
//  Tests
//
//  Created by Quentin Marciset on 17/07/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI
import Moya


class RemoteActionTests: XCTestCase {
    
    let requestTimeout: TimeInterval = 5
    
    let instance = APIManager.instance
    
    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
    }

    func testActionNameSuccessTrue() {
        let expectation = self.expectation()
        
        let cancellable = self.instance.action(name: "successtrue", completionHandler: { result in
            
            switch result {
            case .success(let actionResult):
                print("\(actionResult)")
                XCTAssertTrue(actionResult.success)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        })
        
        XCTAssertFalse(cancellable.isCancelled)
        
        wait(timeout: requestTimeout)
    }
    
    func testActionNameSuccessFalse() {
        let expectation = self.expectation()
        
        let cancellable = self.instance.action(name: "successfalse", completionHandler: { result in
            
            switch result {
            case .success(let actionResult):
                print("\(actionResult)")
                XCTAssertFalse(actionResult.success)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        })
        
        XCTAssertFalse(cancellable.isCancelled)
        
        wait(timeout: requestTimeout)
    }
    
    func testActionNameFailure() {
        let expectation = self.expectation()

        let cancellable = self.instance.action(name: "failure", completionHandler: { result in

            switch result {
            case .success(let actionResult):
                print("\(actionResult)")
                XCTFail("Malformed JSON file should not be a success")
            case .failure(let error):
                print("\(error)")
                if let failureReason = error.failureReason {
                    print("\(failureReason)")
                }
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        })

        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }
    
    func testActionSuccessTrue() {
        let expectation = self.expectation()
        let actionSuccessTrue = Action(name: "successtrue")
        
        let cancellable = self.instance.action(actionSuccessTrue, completionHandler: { result in
            
            switch result {
            case .success(let actionResult):
                print("\(actionResult)")
                XCTAssertTrue(actionResult.success)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        })
        
        XCTAssertFalse(cancellable.isCancelled)
        
        wait(timeout: requestTimeout)
    }
}
