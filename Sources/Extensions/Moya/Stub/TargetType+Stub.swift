//
//  TargetType+Stub.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 14/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

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
        let directories = ["Tests/Resources/Stubbed Responses", "Tests/Resources/JSON"]
        for directory in directories {
            var url = URL(fileURLWithPath: "\(directory)/\(filename).\(type)")
            if let data = try? Data(contentsOf: url) {
                return data
            }
            url = Bundle.qMobileApiStubURL.appendingPathComponent("\(directory)/\(filename).\(type)")
            if let data = try? Data(contentsOf: url) {
                return data
            }
        }

        assertionFailure("No stub with name \(filename)")
        return Data()
    }
}

final class Fixture {
    let testTargetPath = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent() // ./Tests/IBLinterKitTests
}
