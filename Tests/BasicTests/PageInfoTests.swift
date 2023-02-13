//
//  PageInfoTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import XCTest
@testable import QMobileAPI

import SwiftyJSON

class PageInfoTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()

    }

    func testPageInfoAttribute() {
        let globalStamp = 10
        let sent = 11
        let first = 0
        let count = 20
        let info = PageInfo(globalStamp: globalStamp, sent: sent, first: first, count: count)
        XCTAssertEqual(info.globalStamp, globalStamp)
        XCTAssertEqual(info.sent, sent)
        XCTAssertEqual(info.first, first)
        XCTAssertEqual(info.count, count)
    }

    func testPageInfoJSON() {
        let globalStamp = 10
        let sent = 11
        let first = 0
        let count = 20
        let info = PageInfo(globalStamp: globalStamp, sent: sent, first: first, count: count)

        let json = info.json

        let newInfo = PageInfo(json: json)
        XCTAssertEqual(newInfo, info)

        XCTAssertEqual(newInfo?.globalStamp, globalStamp)
        XCTAssertEqual(newInfo?.sent, sent)
        XCTAssertEqual(newInfo?.first, first)
        XCTAssertEqual(newInfo?.count, count)
    }

}
