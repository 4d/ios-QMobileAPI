//
//  RemoteConfig.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
@testable import QMobileAPI
import Moya

struct RemoteConfig {

    static let stub: Bool = true // XXX configure with external properties

    static var tableName: String {
        Bundle.qMobileApiStub = Bundle(for: TestTargetStubDelegate.self)
        return RemoteConfig.stub ? "Event"/*stub files*/ : "CLIENTS"/* test on my invoice database*/
    }

    static func configure(_ instance: APIManager) {
        Bundle.qMobileApiStub = Bundle(for: TestTargetStubDelegate.self)
        instance.stub = stub
        // instance.stubDelegate = TestTargetStubDelegate()
    }

}

class TestTargetStubDelegate: StubDelegate {

    func sampleResponse(_ target: TargetType) -> Moya.EndpointSampleResponse? {
        // Could simulate errors, etc...
        return .networkResponse(200, target.sampleData)
    }

}
