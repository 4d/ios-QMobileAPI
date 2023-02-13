//
//  URLTests.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

import XCTest
@testable import QMobileAPI
import Prephirences

class URLTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSumpleHttpURL() {
        let urls = ["http://www.example.com", "http://example.com", "https://example.com"]
        for string in urls {
            let url = URL(string: string)
            XCTAssertNotNil(url)
            XCTAssertTrue(url!.isHttpOrHttps)
        }

        let url = URL(fileURLWithPath: "/")
        XCTAssertNotNil(url)
        XCTAssertFalse(url.isHttpOrHttps)

    }

    func testLocalhost() {
        if URL.defaultScheme == "http" {
            XCTAssertTrue(URL.localIP.isHttpOrHttps)
            XCTAssertTrue(URL.localhost.isHttpOrHttps)

            XCTAssertTrue(URL.localIP.isHttp)
            XCTAssertTrue(URL.localhost.isHttp)

            XCTAssertFalse(URL.localIP.isHttps)
            XCTAssertFalse(URL.localhost.isHttps)
        } else {
            // https
            XCTAssertTrue(URL.localIP.isHttpOrHttps)
            XCTAssertTrue(URL.localhost.isHttpOrHttps)

            XCTAssertFalse(URL.localIP.isHttp)
            XCTAssertFalse(URL.localhost.isHttp)

            XCTAssertTrue(URL.localIP.isHttps)
            XCTAssertTrue(URL.localhost.isHttps)
        }
    }

    func testWithPort() {
        var pref = Prephirences.sharedMutableInstance ?? UserDefaults.standard


        for wantedScheme in [nil, "https", "http"] {
            pref[Prephirences.Key.serverURLScheme] = wantedScheme
            let scheme = URL.defaultScheme
            switch scheme {
            case "http":
                pref[Prephirences.Key.serverURLPort] = nil
                XCTAssertEqual(URL.localIP.withPort, URL.localIP)
                XCTAssertEqual(URL.localhost.withPort, URL.localhost)
                pref[Prephirences.Key.serverURLPort] = 80
                XCTAssertEqual(URL.localIP.withPort, URL.localIP)
                XCTAssertEqual(URL.localhost.withPort, URL.localhost)
                pref[Prephirences.Key.serverURLPort] = 8080
                XCTAssertNotEqual(URL.localIP.withPort, URL.localIP)
                XCTAssertNotEqual(URL.localhost.withPort, URL.localhost)
                pref[Prephirences.Key.serverURLPort] = 443
                XCTAssertNotEqual(URL.localIP.withPort, URL.localIP)
                XCTAssertNotEqual(URL.localhost.withPort, URL.localhost)
            case "https":
                pref[Prephirences.Key.serverURLPort] = nil
                XCTAssertEqual(URL.localIP.withPort, URL.localIP)
                XCTAssertEqual(URL.localhost.withPort, URL.localhost)
                pref[Prephirences.Key.serverURLHTTPSPort] = 80
                XCTAssertNotEqual(URL.localIP.withPort, URL.localIP) // port forced to 80, not https default
                XCTAssertNotEqual(URL.localhost.withPort, URL.localhost)
                pref[Prephirences.Key.serverURLHTTPSPort] = 8080
                XCTAssertNotEqual(URL.localIP.withPort, URL.localIP)
                XCTAssertNotEqual(URL.localhost.withPort, URL.localhost)
                pref[Prephirences.Key.serverURLHTTPSPort] = 443
                XCTAssertEqual(URL.localIP.withPort, URL.localIP) // default port, must be equal
                XCTAssertEqual(URL.localhost.withPort, URL.localhost)
            default:
                XCTFail("wrong scheme \(scheme)")
            }
            pref[Prephirences.Key.serverURLPort] = nil
        }

    }

    func testQMobileURL() {
        Prephirences.sharedInstance = MutableCompositePreferences([UserDefaults.standard, Bundle.test])

        let pref = UserDefaults.standard
        pref[Prephirences.Key.serverURL] = "http://www.example.com"

        XCTAssertTrue(URL.qmobile.isHttpOrHttps)
        var qmobileURLs = URL.qmobileURLs ?? []
        XCTAssertFalse(qmobileURLs.isEmpty)
        for url in qmobileURLs {
            XCTAssertTrue(url.isHttpOrHttps)
        }

        let wantedURLs = ["http://www.example.com", "http://example.com", "https://example.com"]
        pref[Prephirences.Key.serverURLs] = wantedURLs
        qmobileURLs = URL.qmobileURLs ?? []
        XCTAssertFalse(qmobileURLs.isEmpty)
        for url in qmobileURLs {
            XCTAssertTrue(url.isHttpOrHttps)
        }
        XCTAssertTrue(URL.qmobile.isHttpOrHttps)

        pref[Prephirences.Key.serverURLEdited] = true // simulate Prephirences.serverURL =

        pref[Prephirences.Key.serverURL] = nil
        XCTAssertTrue(URL.qmobile.isHttpOrHttps)

        pref[Prephirences.Key.serverURL] = "127.0.0.1"
        var qmobileURL = URL.qmobile
        XCTAssertTrue(qmobileURL.isHttpOrHttps)

        pref[Prephirences.Key.serverURL] = "127.0.0.1:8090"
        qmobileURL = URL.qmobile
        XCTAssertTrue(qmobileURL.isHttpOrHttps)
        XCTAssertEqual(qmobileURL.port, 8090)

        pref[Prephirences.Key.serverURL] = "ht://127.0.0.1"
        qmobileURL = URL.qmobile
        XCTAssertTrue(qmobileURL.isHttpOrHttps)
        XCTAssertFalse(qmobileURL.host?.contains("ht") ?? false) // no http://ht://...

        pref[Prephirences.Key.serverURL] = ""
        qmobileURL = URL.qmobile
        XCTAssertTrue(qmobileURL.isHttpOrHttps)
        if let first = wantedURLs.first {
            XCTAssertEqual(qmobileURL, URL(string: first))
        }

        pref[Prephirences.Key.serverURLs] = nil
        qmobileURL = URL.qmobile
        if let first = wantedURLs.first {
            XCTAssertEqual(qmobileURL, URL(string: first)) // has been copied
        }
        pref[Prephirences.Key.serverURL] = nil
        qmobileURL = URL.qmobile
        XCTAssertNotNil(qmobileURL) // must return the local host
    }
}
