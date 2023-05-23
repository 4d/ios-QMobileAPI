//
//  ActionTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 01/03/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import Prephirences

/// Define alias for action parameters values.
public typealias ActionParameters = [String: Any]

/// An abstract target to execute actions by its name.
open class ActionAbstractTarget: ChildTargetType, TimeoutTarget {

    let parentTarget: TargetType
    public let name: String

    public init(parentTarget: ActionRootTarget, name: String) {
        self.parentTarget = parentTarget
        self.name = name

        if let timeout = Prephirences.sharedInstance["api.action.timeout"] as? TimeInterval {
            self.timeoutInterval = timeout
        }
    }

    open var childPath: String {
        return name
    }

    public var timeoutInterval: TimeInterval = -1
    open var method = ActionAbstractTarget.defaultMethod
    public static let defaultMethod = Moya.Method.post

    open var task: Task {
        if parameters.isEmpty {
            return .requestPlain
        }
        switch method {
        case .get:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            // TODO Alamofire 5 use JSONParameterEncoder?
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }

    open var parameters: ActionParameters = [:]

    open var sampleData: Data {
        return stubbedData("restactionabstract")
    }
}

/*
import Alamofire
struct JSONEncoderEncoding: ParameterEncoding {
    static let `default` = JSONArrayEncoding()

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()

        guard let json = parameters?["jsonArray"] else {
            return request
        }

        let data = try JSONSerialization.data(withJSONObject: json, options: [])

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        request.httpBody = data

        return request
    }
}*/

/// A concrete target to execute actions by its name and result decoded as `ActionResult`
open class ActionTarget: ActionAbstractTarget {

    open override var sampleData: Data {
        return stubbedData("restaction\(name)")
    }
}

extension ActionTarget: DecodableTargetType {
    public typealias ResultType = ActionResult
}
