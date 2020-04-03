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
        
        let cancellable = self.instance.userInfo([:], deviceToken: "abc", completionHandler: { result in
            
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
        
        let cancellable = self.instance.userInfo(["failure":true], deviceToken: "abc", completionHandler: { result in
            
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
    
    func testUserInfoNoParameter() {
        let expectation = self.expectation()
        
        let cancellable = self.instance.userInfo(completionHandler: { result in
            
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
    
    func testUserInfoNoUserInfo() {
        let expectation = self.expectation()
        
        let cancellable = self.instance.userInfo(deviceToken: "", completionHandler: { result in
            
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
    
    func testUserInfoNoDeviceToken() {
        let expectation = self.expectation()
        
        let userInfo: [String: Any] = ["userInfo": ["email": "roger@4d.com", "name": "roger"]]
        
        let cancellable = self.instance.userInfo(userInfo, completionHandler: { result in
            
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
}
