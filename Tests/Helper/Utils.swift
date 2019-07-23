//
//  Utils.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 29/03/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//
import XCTest
@testable import QMobileAPI

import Foundation
import SwiftyJSON
import Prephirences

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

let tablesNames = ["CLIENTS", "INVOICES", "PRODUCTS"]

private class Utils {

    static func initialize() {
        Prephirences.sharedInstance = MutableCompositePreferences([UserDefaults.standard, Bundle.test])
    }
}

extension Bundle {
    static let test = Bundle(for: Utils.self)
}

// MARK: Files

extension String {
    var testBundleUrl: URL {
        let bundle = Bundle(for: Utils.self)
        let url = URL(fileURLWithPath: self)
        return bundle.url(forResource: url.deletingPathExtension().lastPathComponent, withExtension: url.pathExtension) ?? url
    }
}

func table(name: String) -> Table? {
    let bundle = Bundle(for: Utils.self)
    if let json = NSDataAsset(name: "\(name).catalog", bundle: bundle)?.json {
        guard let table = Table(json: json) else {
            XCTFail("Failed to parse table \(name)")
            return nil
        }
        return table
    }

    let url = "Tests/Resources/Sample/Table/\(name).catalog.json".testBundleUrl
    
    guard let data = try? Data(contentsOf: url, options: []) else {
        XCTFail("Failed to read data for table \(name) at url \(url)")
        return nil
    }

    guard let json = try? JSON(data: data), let table = Table(json: json) else {
        XCTFail("Failed to parse table \(name)")
        return nil
    }
    return table
}
extension NSDataAsset {
    var json: JSON? {
        return try? JSON(data: self.data)
    }
}
func json(name: String) -> JSON? {
    let bundle = Bundle(for: Utils.self)
    guard let url = bundle.url(forResource: "\(name)", withExtension: "json") else {
        XCTFail("File not found to test \(name) data")
        return nil
    }
    
    guard let data = try? Data(contentsOf: url, options: []) else {
        XCTFail("Failed to read data for table \(name) at url \(url)")
        return nil
    }
    return try? JSON(data: data)
}

func json(name: String, id: String) -> JSON? {
    let bundle = Bundle(for: Utils.self)
    guard let url = bundle.url(forResource: "\(name)(\(id))", withExtension: "json") else {
        XCTFail("File not found to test \(name) data")
        return nil
    }
    guard let data = try? Data(contentsOf: url, options: []) else {
        XCTFail("Failed to read data for table \(name) at url \(url)")
        return nil
    }
    return try? JSON(data: data)
}

extension XCTestCase {

    open func expectation(function: String = #function) -> XCTestExpectation {
        return self.expectation(description: function)
    }

    open func wait(timeout: TimeInterval) {
        waitForExpectations(timeout: timeout) { e in
            if let error = e {
                XCTFail(error.localizedDescription)
            }
        }
    }

}

extension ProcessInfo {
    
    static var isSwiftRuntime: Bool {
        
        let envVar = ProcessInfo.processInfo.environment["_"]
        if let check = envVar {
            print(check)
            return check == "/usr/bin/swift"
        }
        return false
    }
}

/*
import Alamofire

class RequestManager {
    static let shared = RequestManager()
    fileprivate let liveManager: SessionManager
    fileprivate let mockManager: SessionManager
    
    init(_ state: RequestState = .live) {
        let configuration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [MockingURLProtocol.self]
            return configuration
        }()
        self.liveManager = SessionManager.default
        self.mockManager = SessionManager(configuration: configuration)
    }
}

enum RequestState {
    case live
    case mock
    
    var session: SessionManager {
        switch self {
        case .live: return RequestManager.shared.liveManager
        case .mock: return RequestManager.shared.mockManager
        }
    }
}


class MockingURLProtocol: URLProtocol {
    private let cannedHeaders = ["Content-Type" : "application/json; charset=utf-8"]
    
    // MARK: Properties
    private struct PropertyKeys {
        static let handledByForwarderURLProtocol = "HandledByProxyURLProtocol"
    }
    
    lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
            return configuration
        }()
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    // MARK: Class Request Methods
    override class func canInit(with request: URLRequest) -> Bool {
        return URLProtocol.property(forKey: PropertyKeys.handledByForwarderURLProtocol, in: request) == nil
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        guard let headers = request.allHTTPHeaderFields else { return request }
        do {
            return try URLEncoding.default.encode(request, with: headers)
        } catch {
            return request
        }
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }
    
    // MARK: Loading Methods
    override func startLoading() {
        if let data = get mocked data according to request),
            let url = request.url,
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: cannedHeaders) {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
    }
}

// MARK: NSURLSessionDelegate extension
extension MockingURLProtocol: URLSessionDelegate {
    func URLSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    func URLSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let response = task.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
}*/
