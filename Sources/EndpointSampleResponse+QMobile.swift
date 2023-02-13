//
//  EndpointSampleResponse+QMobile.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 16/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

extension Moya.EndpointSampleResponse {
    /// Create a networkResponse with specified code and data from URL
    public static func url(_ url: URL, _ code: Int = 200) throws -> Moya.EndpointSampleResponse {
        let data = try Data(contentsOf: url)
        return .networkResponse(code, data)
    }

    public static func string(_ code: Int, _ string: String) -> Moya.EndpointSampleResponse {
        return networkResponse(code, string.data(using: .utf8) ?? Data())
    }

    public static func json(_ code: Int, _ json: JSON) -> Moya.EndpointSampleResponse {
        return networkResponse(code, "\(json.object)".data(using: .utf8) ?? Data())
    }
}
