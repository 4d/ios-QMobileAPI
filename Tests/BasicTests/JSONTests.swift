//
//  JSONTests.swift
//  QMobileAPI
//
//  Created by anass talii on 21/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
import Alamofire

@testable import QMobileAPI

class JSONTests: XCTestCase {
    
    let jsonPath = "Tests/Resources/JSON"
    let jsonSampleDataPath = "Tests/Resources/Sample/Data"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: status
    
    func testStatusOkJSON() {
        let jsonString = "{ \"ok\": true}"
        let status = Status(string: jsonString)
        // not nil > sucessful read
        XCTAssertNotNil(status)
        // read ok
        XCTAssertTrue(status!.ok)
        
        XCTAssertTrue(status == status)
        XCTAssertFalse(status == Status(ok: false))
    }
    func testStatusNotOkJSON() {
        let jsonString = "{ \"ok\": false}"
        let status = Status(string: jsonString)
        XCTAssertNotNil(status)
        
        // read false in json
        XCTAssertFalse(status!.ok)
    }
    func testStatusEmptyJSON() {
        let jsonString = "{}"
        let status = Status(string: jsonString)
        // on lit quand meme
        XCTAssertNotNil(status)
        
        // et la valeur est faux
        XCTAssertFalse(status!.ok)
    }
    
    // MARK: info
    func testInfoJSON() {
        let url = "\(jsonPath)/info.json".testBundleUrl
        let info = Info(fileURL: url)
        
        XCTAssertNotNil(info)
        XCTAssertTrue(info == info)
        
        XCTAssertNotNil(info?.entitySetCount)
        XCTAssertNotNil(info?.cacheSize)
        
        XCTAssertNotEqual(info?.sessions.count, 0)
        XCTAssertNotEqual(info?.progress.count, 0)
        
        let jsonFromObject = info?.json
        XCTAssertNotNil(jsonFromObject)
    }
    
    func testSessionInfo() {
        let url = "\(jsonPath)/SessionInfo.json".testBundleUrl
        let sessionInfo = SessionInfo(fileURL: url)
        
        XCTAssertNotNil(sessionInfo)
        XCTAssertTrue(sessionInfo == sessionInfo)
        
        let jsonFromObject = sessionInfo?.json
        XCTAssertNotNil(jsonFromObject)
    }
    
    func testSessionInfoIsNil() {
        let url = "\(jsonPath)/SessionInfoNil.json".testBundleUrl
        let sessionInfo = SessionInfo(fileURL: url)
        
        XCTAssertNil(sessionInfo)
    }
    
    func testProgressInfo() {
        let url = "\(jsonPath)/ProgressInfo.json".testBundleUrl
        let progressInfo = ProgressInfo(fileURL: url)
        
        XCTAssertNotNil(progressInfo)
        XCTAssertTrue(progressInfo == progressInfo)
        
        let jsonFromObject = progressInfo?.json
        XCTAssertNotNil(jsonFromObject)
    }
    
    func testProgressInfoIsNil() {
        let url = "\(jsonPath)/ProgressInfoNil.json".testBundleUrl
        let progressInfo = ProgressInfo(fileURL: url)
        
        XCTAssertNil(progressInfo)
    }
    
    func testCacheInfo() {
        let url = "\(jsonPath)/CacheInfo.json".testBundleUrl
        let cacheInfo = CacheInfo(fileURL: url)
        
        XCTAssertNotNil(cacheInfo)
        XCTAssertTrue(cacheInfo == cacheInfo)
        
        XCTAssertEqual(cacheInfo?.cacheObjects.count ?? 0, 1)
        
        if let cacheObject = cacheInfo?.cacheObjects.first {
            XCTAssertEqual(cacheObject.objects.count, 111)
        }
        let jsonFromObject = cacheInfo?.json
        XCTAssertNotNil(jsonFromObject)
    }
    
    // MARK: Entity info
    func testEntityInfo() {
        let url = "\(jsonPath)/EntitySetInfo.json".testBundleUrl
        let entitySet = EntitySetInfo(fileURL: url)
        
        XCTAssertNotNil(entitySet)
        XCTAssertTrue(entitySet == entitySet)
        
        XCTAssertEqual(entitySet?.entitySet.count ?? 0, 3)
        
        let jsonFromObject = entitySet?.json
        XCTAssertNotNil(jsonFromObject)
    }
    
    func testEntityInfoWithData() {
        let url = "\(jsonPath)/EntitySetWithData.json".testBundleUrl
        let entitySet = EntitySetInfo(fileURL: url)
        
        XCTAssertNotNil(entitySet)
        XCTAssertEqual(entitySet?.entitySet.count ?? 0, 3)
        XCTAssertEqual(entitySet?.entitySetCount ?? 0, 3)
        
        let jsonFromObject = entitySet?.json
        XCTAssertNotNil(jsonFromObject)
    }
    
    func testEntityInfoAloneWithData() {
        let url = "\(jsonPath)/EntitySetAloneWithData.json".testBundleUrl
        let entitySet = EntitySet(fileURL: url)
        
        XCTAssertNotNil(entitySet)
        
        let jsonFromObject = entitySet?.json
        XCTAssertNotNil(jsonFromObject)
    }
    
    // MARK: structure
    func testCatalogJson() {
        let url = "\(jsonPath)/catalog.json".testBundleUrl
        let catalog = Catalog(fileURL: url)
        
        XCTAssertNotNil(catalog)
        XCTAssertTrue(catalog == catalog)
        XCTAssertFalse(catalog == Catalog(name: "dummy"))
    }
    
    func testDataStoreClass() {
        let url = "\(jsonPath)/cat.json".testBundleUrl
        let table = Table(fileURL: url)
        
        XCTAssertNotNil(table)
        XCTAssertTrue(table == table)
        XCTAssertFalse(table == Table(name: "dummy"))
        XCTAssertNotNil(table?.name)
        XCTAssertEqual(table?.name, "cat")
        XCTAssertNotNil(table?.className)
        XCTAssertEqual(table?.className, "cat")
        XCTAssertNotNil(table?.collectionName)
        XCTAssertEqual(table?.collectionName, "catCollection")
        XCTAssertNotNil(table?.scope)
        XCTAssertEqual(table?.scope, "public")
        XCTAssertNotNil(table?.dataURI)
        XCTAssertEqual(table?.dataURI, "/mobileapp/cat")
        
        XCTAssertNotEqual(table?.attributes.count, 0)
        XCTAssertNotEqual(table?.keys.count, 0)
        XCTAssertEqual(table?.attributes.count, 14)
        XCTAssertEqual(table?.keys.count, 1)
    }
    
    // MARK: data
    func testPage() {
        let tableName = "CLIENTS"
        let pageInfo = PageInfo(globalStamp: 0, sent: 100, first: 0, count: 200)
        
        let url = "\(jsonSampleDataPath)/\(tableName).json".testBundleUrl
        
        if let page = Page(fileURL: url) {
            XCTAssertEqual(page.tableName, tableName)
            XCTAssertEqual(page.info, pageInfo)
            XCTAssertEqual(page.records.count, pageInfo.sent)
            
            if let record = page.records.first {
                
                XCTAssertNotNil(record.key)
                XCTAssertNotNil(record.stamp)
                // XCTAssertNotNil(record.globalStamp)
                XCTAssertNotNil(record.timestamp)
                
                XCTAssertNotNil(record["id"])
                XCTAssertNotNil(record["Comments"])
                XCTAssertNotNil(record["Lat"] as? NSNumber)
                XCTAssertNotNil(record["Lat"] as? Double)
                XCTAssertNotNil(record["DiscountRate"] as? Int)
                
                XCTAssertNotNil(record["Logo"])
                XCTAssertNotNil(record.deferred("Logo"))
                if let deferred = record.deferred("Logo") {
                    XCTAssertTrue(deferred.image)
                    XCTAssertFalse(deferred.uri.isEmpty)
                }
                
                XCTAssertNotNil(record["Link_4_return"])
                XCTAssertNotNil(record.deferred("Link_4_return"))
                if let deferred = record.deferred("Link_4_return") {
                    XCTAssertFalse(deferred.image)
                    XCTAssertFalse(deferred.uri.isEmpty)
                }
            }
            
        } else {
            XCTFail("Failed to read RestErrors")
        }
    }
    
    func testPageExpanded() {
        let tableName = "Table_Link" // Table_Link/?$expand=Link_1
        let pageInfo = PageInfo(globalStamp: 0, sent: 2, first: 0, count: 2)
        
        let url = "\(jsonSampleDataPath)/\(tableName).json".testBundleUrl
        
        if let page = Page(fileURL: url) {
            XCTAssertEqual(page.tableName, tableName)
            XCTAssertEqual(page.info, pageInfo)
            XCTAssertEqual(page.records.count, pageInfo.sent)
            
            if let record = page.records.first {
                
                XCTAssertNotNil(record.key)
                XCTAssertNotNil(record.stamp)
                XCTAssertNotNil(record.timestamp)
                
                XCTAssertNotNil(record["ID"])
                XCTAssertNotNil(record["link"])
                XCTAssertNotNil(record["Link_1"])
                
                let link = record[json: "Link_1"]
                XCTAssertNotNil(link["ID"])
                XCTAssertNotNil(link["Field_2"])
                XCTAssertNotNil(link["Link_1_return"])
                
                let asDico = record["Link_1"] as? [String: Any?]
                XCTAssertNotNil(asDico)
                XCTAssertNotNil(asDico?["ID"] ?? nil)
                
                if let link = record.record("Link_1") {
                    XCTAssertNotNil(link["ID"])
                    XCTAssertNotNil(link["Field_2"])
                }
            }
            
        } else {
            XCTFail("Failed to read RestErrors")
        }
    }
    
    
    func testPageExpandedReturn() {
        let tableName = "Table_Linked" // Table_Linked/?$expand=Link_1_return
        let pageInfo = PageInfo(globalStamp: 0, sent: 1, first: 0, count: 1)
        
        let url = "\(jsonSampleDataPath)/\(tableName).json".testBundleUrl
        
        if let page = Page(fileURL: url) {
            XCTAssertEqual(page.tableName, tableName)
            XCTAssertEqual(page.info, pageInfo)
            XCTAssertEqual(page.records.count, pageInfo.sent)
            
            if let record = page.records.first {
                
                XCTAssertNotNil(record.key)
                XCTAssertNotNil(record.stamp)
                XCTAssertNotNil(record.timestamp)
                
                XCTAssertNotNil(record["ID"])
                XCTAssertNotNil(record["Field_2"])
                XCTAssertNotNil(record["Link_1_return"])
                if let page = record.page("Link_1_return") {
                    let pageInfoLink = PageInfo(globalStamp: 0, sent: 2, first: 0, count: 2)
                    XCTAssertEqual(page.info, pageInfoLink)
                    XCTAssertEqual(page.records.count, pageInfoLink.sent)
                    
                    if let link = page.records.first {
                        XCTAssertNotNil(link.key)
                        XCTAssertNotNil(link.stamp)
                        XCTAssertNotNil(link.timestamp)
                        XCTAssertNotNil(link["ID"])
                    }
                }
            }
            
        } else {
            XCTFail("Failed to read RestErrors")
        }
    }
    
    // MARK: error
    func testError() {
        let url = "\(jsonPath)/erreur.json".testBundleUrl
        
        if let error = RestErrors(fileURL: url) {
            XCTAssertEqual(error.errors.count, 3)
            let jsonFromObject = error.json
            XCTAssertNotNil(jsonFromObject)
            XCTAssertTrue(error.match(.cannot_build_list_of_attribute))
            XCTAssertFalse(error.match(.unknown_picture_mime_type))
        } else {
            XCTFail("Failed to read RestErrors")
        }
    }
    
    func testDateValidDate() {
        
        let dic = [
            "rfc3339": "1937-01-01T12:00:27.87+00:20",
            "simple": "12!4!2014",
            "simpleDash": "12/4/2014",
            "iso8601": "2013-07-16T19:23:51Z",
            "iso8601WithoutZ": "2019-02-14T12:21:18"]
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(dic) {
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                let dateJSON = JSON.init(parseJSON: jsonString)
                for (_ , value) in dateJSON {
                    if let parsedDate = value.date {
                        XCTAssertNotNil(parsedDate)
                    } else {
                        XCTFail("String date \(value) could not be parsed")
                    }
                }
            }
        }
    }
    
    func testDateInvalidDate() {
        
        let dic = ["abc": "abcdef"]
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(dic) {
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                let dateJSON = JSON.init(parseJSON: jsonString)
                XCTAssertNil(dateJSON["abc"].date)
            }
        }
    }
}
