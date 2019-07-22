//
//  TargetType+Stub.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 14/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Result

// MARK: TargetType stubbed
extension TargetType {
    /// Provides stub data for use in testing.
    public func stubbedData(_ filename: String, ofType type: String = "json") -> Data {
        let bundles: [Bundle] = [.qMobileApiStub, .main]
        for bundle in bundles {
            if let path = bundle.path(forResource: filename, ofType: type),
                let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                return data
            }
        }
        var url = URL(fileURLWithPath: "Tests/Resources/Stubbed Responses/\(filename).\(type)")
        if let data = try? Data(contentsOf: url) {
            return data
        }
        url = URL(fileURLWithPath: "Tests/Resources/JSON/\(filename).\(type)")
        if let data = try? Data(contentsOf: url) {
            return data
        }
        assertionFailure("No stub with name \(filename)")
        return Data()
    }
}
