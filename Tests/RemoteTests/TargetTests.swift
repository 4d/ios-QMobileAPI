//
//  TargetTests.swift
//  Tests
//
//  Created by Eric Marchand on 12/10/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI
import Moya


class TargetTests: XCTestCase {
    
    let instance = APIManager.instance
    let requestTimeout: TimeInterval = 5
    var lastRequest: URLRequest?
    override func setUp() {
        super.setUp()
        
        RemoteConfig.configure(instance)
        instance.plugins += [self]
    }
    
    override func tearDown() {
        super.tearDown()
        var newPlugins = [PluginType]()
        for plugin in instance.plugins {
            if plugin is TargetTests {
                //plugins.remove(self)
            } else {
                newPlugins.append(plugin)
            }
        }
        instance.plugins = newPlugins
    }
    
    func testTarget() {
        let expectation = self.expectation()
        withTable(RemoteConfig.tableName, instance) { table in
            
            let operation: ComputeOperation = .sum
            let attributes = table.attributes
            guard let attribute = attributes.first else {
                XCTFail("No attribute to test in table \(table)")
                return
            }

            let target: ComputeTarget = self.instance.base.records(from: table).compute(operation, for: attribute.key)
            
            let completion: APIManager.Completion = { result in
                
                if let lastRequest =  self.lastRequest {
                    
                  XCTAssertEqual(lastRequest.httpMethod,  target.method.rawValue)
                    
                    if let url = lastRequest.url, let component = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                        
                        // path is /rest/Table/AttributeKey"
                        XCTAssertTrue(component.path.contains(attribute.key), "No attribute in path \(component.path)")
                        XCTAssertTrue(component.path.contains(table.name), "No table in path  \(component.path)")
                        // query contains operation
                        if let query = component.query {
                            XCTAssertTrue(query.contains(operation.rawValue), "No operation in query \(query)")
                        }  else {
                            XCTFail("No query in url \(url) when trying to analyse it")
                        }
                    } else {
                        XCTFail("No url in request \(lastRequest) when trying to analyse it")
                    }
                    
                } else {
                    XCTFail("No request send when trying to analyse it")
                }
                expectation.fulfill()
            }
            _ = self.instance.request(target, completion: completion)
        }
        wait(timeout: requestTimeout)
    }
    
}

extension TargetTests: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return request
    }

    func willSend(_ request: RequestType, target: TargetType) {
        lastRequest = request.request
    }

    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        
    }

    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        return result
    }
}
