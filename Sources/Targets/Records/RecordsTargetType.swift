//
//  RecordsTargetType.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

/// Common protocol for RecordsTarget and RecordSetTarget
/// allowing common configurations
public protocol RecordsTargetType: TargetType, RecordsRequest {
    func setHTTPMethod(_ method: Moya.Method)
    func setParameter(_ key: RecordsRequestKey, _ value: Any)
    func getParameter(_ key: RecordsRequestKey) -> Any?
}

// MARK: Configure request
let kRecordsRequestKey = "$"

extension RecordsTargetType {
    @discardableResult public func order(by value: String) -> Self {
        if value.isOrderByValid {
            setParameter(.orderby, value)
        } else {
            assertionFailure("Order by sequence not valid \(value)")
        }
        return self
    }
    @discardableResult public func order(by: [String: OrderBy]) -> Self {
        let orderBy = by.compactMap { key, orderBy -> String? in
            "\(key) \(orderBy.rawValue)"
        }.joined(separator: ",")

        setParameter(.orderby, orderBy)
        return self
    }

    @discardableResult public func skip(_ value: Int) -> Self {
        setParameter(.skip, value)
        return self
    }
    @discardableResult public func limit(_ value: Int) -> Self {
        setParameter(.limit, value)
        return self
    }

    @discardableResult public func distinct() -> Self {
        return distinct(true)
    }
    @discardableResult public func distinct(_ value: Bool = true) -> Self {
        setParameter(.distinct, value)
        return self
    }

    @discardableResult public func filter(_ query: String) -> Self {
        if query.isDoubleQuoted { // TODO make an escape method
            setParameter(.filter, query)
        } else {
            setParameter(.filter, "\"\(query)\"")
        }
        return self
    }

    @discardableResult public func params(_ params: JSONEncodable) -> Self {
        setParameter(.params, "'\(params.json)'")
        return self
    }

    @discardableResult public func attributes(_ attributes: [String]) -> Self {
        setParameter(.attributes, "\(attributes.joined(separator: ","))") // XXX maybe encode or espace?
        return self
    }

    @discardableResult public func querypath() -> Self {
        return querypath(true)
    }
    @discardableResult public func querypath(_ value: Bool = true) -> Self {
        setParameter(.querypath, value)
        return self
    }

    @discardableResult public func queryplan() -> Self {
        return queryplan(true)
    }
    @discardableResult public func queryplan(_ value: Bool = true) -> Self { // check XXX if accessible in 4d server
        setParameter(.queryplan, value)
        return self
    }

    @discardableResult public func _timeout(_ value: Int) -> Self { // check XXX exist in 4d server
        setParameter(.timeout, value)
        return self
    }

    /// Expands the relational attribute
    // record $expand=staff relation
    @discardableResult public func expand(_ relation: String) -> Self {
        setParameter(.expand, relation)
        return self
    }

    @discardableResult public func imageformat(_ format: ImageFormat) -> Self {
        setParameter(.imageformat, format.rawValue)
        return self
    }

    // MARK: record $method
    @discardableResult public func restMethod(_ method: Method) -> Self {
        self.setParameter(.method, method.rawValue)
        self.setHTTPMethod(method.method)
        // XXX maybe also change parameters encoding, add body or parameters (post  update etc...)
        // TODO check if moya authorize query parameters and post json data...
        return self
    }

    @discardableResult public func atomic() -> Self {
        return atomic(true)
    }

    @discardableResult public func atomic(_ value: Bool = true) -> Self {
        setParameter(.atomic, value)
        return self
    }

    public var isDistinct: Bool { return getParameter(.distinct) as? Bool ?? false }
    public var isAtomic: Bool { return getParameter(.atomic) as? Bool ?? false }
    public var limit: Int { return getParameter(.limit) as? Int ?? 0 }
    public var skip: Int { return getParameter(.skip) as? Int ?? 0 }
    public var restMethod: Method? {
        guard let string = getParameter(.method) as? String else {
            return nil
        }
        return Method(rawValue: string)
    }
    public var filter: String? { return getParameter(.filter) as? String }
    public var expand: String? { return getParameter(.expand) as? String }
}

extension String {
    /// Check if string is a valid "order" string ie. use good syntax.
    var isOrderByValid: Bool {
        // TODO check order by string validity, ie. split by token, check keywords..
        return true
    }
}
