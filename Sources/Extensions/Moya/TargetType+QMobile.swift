//
//  TargetType.swift
//  QAPI
//
//  Created by Eric Marchand on 08/03/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Result
import protocol Alamofire.URLConvertible

// MARK: TargetType stubbed
extension TargetType {
    public var basePath: String {
        return self.baseURL.path
    }
}

// MARK: TargetType parent/child relation
protocol ChildTargetType: TargetType, AccessTokenAuthorizable {
    var parentTarget: TargetType { get }
    var childPath: String { get }
}

extension ChildTargetType {
    public var path: String {
        return parentTarget.path + "/" + self.childPath
    }
    public var baseURL: URL {
        return self.parentTarget.baseURL
    }
    public var validationType: ValidationType {
        return self.parentTarget.validationType
    }
    public var headers: [String: String]? {
        return self.parentTarget.headers
    }
    public var authorizationType: AuthorizationType {
        if let parent = self.parentTarget as? AccessTokenAuthorizable {
            return parent.authorizationType
        }
        return .none
    }
}
// MARK: Simple Target

/// A simple target.
public class SimpleTarget: TargetType {
    public var baseURL: URL {
        didSet {
            assert(!self.baseURL.isFileURL && self.baseURL.isHttpOrHttps)
        }
    }
    public var path: String
    public var task: Task
    public var method: Moya.Method
    public var headers: [String: String]?

    public var validationType: ValidationType  = .successCodes // We want HTTP success codes: 2xx.
    public var sampleData: Data { // Error must set here...
        fatalError("Must be overriden")
    }

    init(baseURL: URL, path: String, method: Moya.Method = .get, task: Task = .requestPlain) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.task = task
        assert(!self.baseURL.isFileURL && self.baseURL.isHttpOrHttps)
    }
    convenience init(baseURL: URLConvertible, path: String, method: Moya.Method = .get, task: Task = .requestPlain) throws {
        self.init(baseURL: try baseURL.asURL(), path: path, method: method, task: task)
    }
}

// MARK: Decodable content
public protocol DecodableTargetType: Moya.TargetType {
    associatedtype ResultType: JSONDecodable
}

extension MoyaError: ErrorConvertible {
    public static func error(from underlying: Swift.Error) -> MoyaError {
        if let error = underlying as? MoyaError {
            return error
        } else {
            return .underlying(underlying, nil)
        }
    }
}

extension MoyaProvider where Target: DecodableTargetType {
    func requestDecoded<E: ErrorConvertible>(_ target: Target, callbackQueue: DispatchQueue? = nil, progress: APIManager.ProgressHandler? = nil, completion: @escaping (Result<[Target.ResultType], E>) -> Void) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress) { result in
            let result: Result<[Target.ResultType], E> = result.map(to: [Target.ResultType.self])
            completion(result)
        }
    }
    func requestDecoded<E: ErrorConvertible>(_ target: Target, callbackQueue: DispatchQueue? = nil, progress: APIManager.ProgressHandler? = nil, completion: @escaping (Result<Target.ResultType, E>) -> Void) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress) { result in
            let result: Result<Target.ResultType, E> = result.map(to: Target.ResultType.self)
            completion(result)
        }
    }
}
