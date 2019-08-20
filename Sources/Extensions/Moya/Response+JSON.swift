//
//  TargetType+JSON.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 26/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

import SwiftyJSON

extension Response {
    public func map<T: JSONDecodable>(to type: T.Type) throws -> T {
        let jsonObject = try mapJSON()

        guard let mappedObject = T(json: JSON(jsonObject)) else {
            throw MoyaError.jsonMapping(self)
        }

        return mappedObject
    }

    public func map<T: JSONDecodable>(to type: [T.Type]) throws -> [T] {
        let jsonObject = try mapJSON()

        guard let mappedObject = T.array(json: JSON(jsonObject)) else {
            throw MoyaError.jsonMapping(self)
        }

        return mappedObject
    }
}

extension Response {
    public var httpHeader: [String: String]? {
        return self.request?.allHTTPHeaderFields
    }

    public func header(for key: HTTPResponseHeader) -> String? {
        return httpHeader?[key.rawValue]
    }
}

public protocol ErrorConvertible: Swift.Error {
    static func error(from error: Swift.Error) -> Self
}

// MARK: Result

extension Result where Success: Response {
    func map<T: JSONDecodable, E: ErrorConvertible>(to type: T.Type) -> Result<T, E> {
        switch self {
        case .success(let response):
            do {
                let mapped = try response.map(to: type)
                return .success(mapped)
            } catch let error as E {
                return .failure(error)
            } catch {
                return .failure(E.error(from: error))
            }

        case .failure(let error as E):
            return .failure(error)

        case .failure(let error):
            return .failure(E.error(from: error))
        }
    }

    func map<T: JSONDecodable, E: ErrorConvertible>(to type: [T.Type]) -> Result<[T], E> {
        switch self {
        case .success(let response):
            do {
                let mapped = try response.map(to: type)
                return .success(mapped)
            } catch let error as E {
                return .failure(error)
            } catch {
                return .failure(E.error(from: error))
            }

        case .failure(let error as E):
            return .failure(error)

        case .failure(let error):
            return .failure(E.error(from: error))
        }
    }
}
