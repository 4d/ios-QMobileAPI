//
//  DateFormatterTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 18/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import XCTest
@testable import QMobileAPI

class DateFormatterTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSimpleDate() {

        let formatter = DateFormatter.simpleDate

        let dateString = "12!10!2016"
        let date = formatter.date(from: dateString)
        XCTAssertNotNil(date)
        XCTAssertEqual(dateString.simpleDate, date)

        let string = formatter.string(from: date!)
        XCTAssertEqual(string, dateString)
    }

    func testSimpleDateSlash() {

        let formatter = DateFormatter.simpleDateSlash

        let dateString = "12/10/2016"
        let date = formatter.date(from: dateString)
        XCTAssertNotNil(date)
        XCTAssertEqual(dateString.simpleDate, date)

        let string = formatter.string(from: date!)
        XCTAssertEqual(string, dateString)
    }

    func testDateIso8601() {
        let formatter = DateFormatter.iso8601

        let dateString = "2016-10-12T12:38:41.447Z" //  "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let date = formatter.date(from: dateString)
        XCTAssertNotNil(date)
        XCTAssertEqual(dateString.dateFromISO8601, date)

        let string = formatter.string(from: date!)
        XCTAssertEqual(string, dateString)

        XCTAssertEqual(date!.iso8601, dateString)
    }
    
    func testSimpleDateDash() {
        let formatter = DateFormatter.simpleDateDash
        
        let dateString = "16-07-2019"
        let date = formatter.date(from: dateString)
        XCTAssertNotNil(date)
        XCTAssertEqual(dateString.simpleDate, date)
        
        let string = formatter.string(from: date!)
        XCTAssertEqual(string, dateString)
    }
    
    func testTomorrow() {
        var dateComponents = DateComponents()
        dateComponents.setValue(-1, for: .day) // -1 day
        
        if let yesterdayOfTomorrow = Calendar.current.date(byAdding: dateComponents, to: Date.tomorrow) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy"
            let nowString = formatter.string(from: Date())
            let yesterdayOfTomorrowString = formatter.string(from: yesterdayOfTomorrow)
            XCTAssertEqual(nowString, yesterdayOfTomorrowString)
        } else {
            XCTFail("Failed to get yesterday of Date.tomorrow date")
        }
    }
    
    func testYesterday() {
        var dateComponents = DateComponents()
        dateComponents.setValue(1, for: .day) // +1 day
        
        if let tomorrowOfYesterday = Calendar.current.date(byAdding: dateComponents, to: Date.yesterday) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy"
            let nowString = formatter.string(from: Date())
            let tomorrowOfYesterdayString = formatter.string(from: tomorrowOfYesterday)
            XCTAssertEqual(nowString, tomorrowOfYesterdayString)
        } else {
            XCTFail("Failed to get tomorrow of Date.yesterday date")
        }
    }
    
    func testTwoDaysAgo() {
        var dateComponents = DateComponents()
        dateComponents.setValue(2, for: .day) // +2 day
        
        if let twoDaysLaterTwoDaysAgo = Calendar.current.date(byAdding: dateComponents, to: Date.twoDaysAgo) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy"
            let nowString = formatter.string(from: Date())
            let twoDaysLaterTwoDaysAgoString = formatter.string(from: twoDaysLaterTwoDaysAgo)
            XCTAssertEqual(nowString, twoDaysLaterTwoDaysAgoString)
        } else {
            XCTFail("Failed to get two days later of Date.twoDaysAgo date")
        }
    }
    
    func testFirstDayOfMonth() {
        let now = getEpochDate(date: Date())
        let currentDay = Calendar.current.component(.day, from: now)
        
        let firstDayOfMonth = getEpochDate(date: Date.firstDayOfMonth)
        var dateComponents = DateComponents()
        dateComponents.setValue(currentDay - 1, for: .day) // +(today's number - first day) day
        
        if let shouldBeToday = Calendar.current.date(byAdding: dateComponents, to: firstDayOfMonth) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy"
            let nowString = formatter.string(from: Date())
            let shouldBeTodayString = formatter.string(from: shouldBeToday)
            XCTAssertEqual(nowString, shouldBeTodayString)
        } else {
            XCTFail("Failed to retrieve today's date from Date.firstDayOfMonth")
        }
    }
    
    /*
     * Get a date with Epoch Calculation to avoid any Timezone inconsistency
     */
    func getEpochDate(date: Date) -> Date {
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = date.timeIntervalSince1970
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        return Date(timeIntervalSince1970: timezoneEpochOffset)
    }
}
