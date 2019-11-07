//
//  RemoteCreateRecordsTests.swift
//  QMobileAPI
//
//  Created by anass talii on 11/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI
import Moya

class RemoteCreateRecordsTests: XCTestCase {

    let requestTimeout: TimeInterval = 5
    let instance = APIManager.instance
    let tablePrimaryKeyValue = 1

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    /*
    func testCreateRecords() {
        //TODO
        let expectation = self.expectation()
        let target = self.instance.createRecordJSON(table: RemoteConfig.tableName, key: self.tablePrimaryKeyValue, completionHandler: <#APIManager.CompletionRecordJSONHandler#>)
        target.method = .post
        target.parameters = ["nom": "NomTest", "prenom": "prenomTest","age":34,"cin": "MP457000","datenaissance": "1983-06-05T20:00:00"]
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
