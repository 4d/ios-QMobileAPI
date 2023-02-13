//
//  BaseTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 24/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import protocol Alamofire.URLConvertible

/// Returns the server status.
public class BaseTarget: SimpleTarget, AccessTokenAuthorizable {
    /// Initialize target with base `URL`.
    init(baseURL url: URL, path: String) {
        super.init(baseURL: url, path: path)
    }
    /// Initilize target with base `URL` using `URLConvertible` type.
    convenience init(baseURL url: URLConvertible, path: String) throws {
        try self.init(baseURL: url.asURL(), path: path)
    }

    /// `sampleData` for Moya's `TargetType`.
    override public var sampleData: Data {
        return stubbedData("status")
    }

    public var authorizationType: AuthorizationType  = .bearer
}
