//
//  RemoteDeleteRecordsTests.swift
//  QMobileAPI
//
//  Created by anass talii on 16/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI
import Moya

class RemoteDeleteRecordsTests: XCTestCase {

    let requestTimeout: TimeInterval = 5
    let instance = APIManager.instance
    let tablePrimaryKeyValue = 5

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    /*
    func testDeleteRecords() {
        //TODO
        let expectation = self.expectation()
        let target = self.instance.deleteRecordJSON(table: RemoteConfig.tableName, key: self.tablePrimaryKeyValue, completionHandler: <#APIManager.CompletionRecordJSONHandler#>)
        target.method = .delete
        target.parameters = ["__KEY": self.tablePrimaryKeyValue, "__STAMP": 1]
        target.parameterEncoding = JSONEncoding.default
        
        let cancellable = instance.request(target) { result  in
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
    }*/

}
