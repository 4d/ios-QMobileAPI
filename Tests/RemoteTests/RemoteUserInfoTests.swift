//
//  RemoteUserInfoTests.swift
//  Tests
//
//  Created by Quentin Marciset on 01/04/2020.
//  Copyright © 2020 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI
import Moya

class RemoteUserInfoTests: XCTestCase {
    
    let requestTimeout: TimeInterval = 5
    
    let instance = APIManager.instance
    
    override func setUp() {
        super.setUp()
        RemoteConfig.configure(instance)
    }
    
    func testUserInfoSuccessTrue() {
        let expectation = self.expectation()
        
        let cancellable = self.instance.userInfo(name: "success", parameters: [:], completionHandler: { result in
            
            switch result {
            case .success(let userInfoResult):
                print("\(userInfoResult)")
                XCTAssertTrue(userInfoResult.success)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        })
        
        XCTAssertFalse(cancellable.isCancelled)
        
        wait(timeout: requestTimeout)
    }
    
    func testUserInfoSuccessFalse() {
        let expectation = self.expectation()
        
        let cancellable = self.instance.userInfo(name: "failure", parameters: [:], completionHandler: { result in
            
            switch result {
            case .success(let userInfoResult):
                print("\(userInfoResult)")
                XCTAssertFalse(userInfoResult.success)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        })
        
        XCTAssertFalse(cancellable.isCancelled)
        
        wait(timeout: requestTimeout)
    }
}
