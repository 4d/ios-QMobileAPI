//
//  WebTestTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 12/12/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Alamofire
import Foundation
import Moya

/// Returns the server test.
public class WebTestTarget: SimpleTarget {
    init(baseURL url: URL) {
        super.init(baseURL: url, path: "4dwebtest")
    }
    convenience init(baseURL url: URLConvertible) throws {
        try self.init(baseURL: url.asURL())
    }
    override public var sampleData: Data {
        return stubbedData("webtest")
    }
}

extension WebTestTarget {
    /// Define decoded type as `WebTestInfo`.
    public typealias ResultType = WebTestInfo
}
