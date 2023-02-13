//
//  RemoteUploadTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 29/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

import XCTest
@testable import QMobileAPI
import Moya
import Result

class RemoteUploadTests: XCTestCase {
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

    func testUpload() {
        let expectation = self.expectation()

        guard let url = Bundle(for: RemoteUploadTests.self).url(forResource: "image", withExtension: "jpg") else {
            XCTFail("No file to test upload")
            return
        }
        let cancellable = instance.upload(url: url) { result  in
            switch result {
            case .success(let data):
                print("\(data)")
                expectation.fulfill()
                //data.update(on: "10", stamp: "")
                //instance.request()

            case .failure(let error):
                XCTFail("\(error)")
            }
        }

        XCTAssertFalse(cancellable.isCancelled)

        wait(timeout: requestTimeout)
    }

    func testUploadData() {
        let expectation = self.expectation()
        
        guard let url = Bundle(for: RemoteUploadTests.self).url(forResource: "image", withExtension: "jpg") else {
            XCTFail("No file to test upload")
            return
        }

        guard let data = try? Data(contentsOf: url, options: []) else {
            XCTFail("Failed to read data for all table at url \(url)")
            return
        }
        
        let cancellable = instance.upload(data: data, image: true, mimeType: "image/jpg") { result  in
            switch result {
            case .success(let data):
                print("\(data)")
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        
        XCTAssertFalse(cancellable.isCancelled)
        
        wait(timeout: requestTimeout)
    }

}
