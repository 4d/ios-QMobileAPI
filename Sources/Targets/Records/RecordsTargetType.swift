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
    /// https://developer.4d.com/docs/en/REST/orderby.html
    @discardableResult public func order(by value: String) -> Self {
        if value.isOrderByValid {
            setParameter(.orderby, value)
        } else {
            assertionFailure("Order by sequence not valid \(value)")
        }
        return self
    }
    /// https://developer.4d.com/docs/en/REST/orderby.html
    @discardableResult public func order(by: [String: OrderBy]) -> Self {
        let orderBy = by.compactMap { key, orderBy -> String? in
            "\(key) \(orderBy.rawValue)"
        }.joined(separator: ",")

        setParameter(.orderby, orderBy)
        return self
    }

    /// https://developer.4d.com/docs/en/REST/skip.html
    @discardableResult public func skip(_ value: Int) -> Self {
        setParameter(.skip, value)
        return self
    }
    /// https://developer.4d.com/docs/en/REST/top_$limit.html
    @discardableResult public func limit(_ value: Int) -> Self {
        setParameter(.limit, value)
        return self
    }

    /// https://developer.4d.com/docs/en/REST/distinct.html
    @discardableResult public func distinct() -> Self {
        return distinct(true)
    }
    /// https://developer.4d.com/docs/en/REST/distinct.html
    @discardableResult public func distinct(_ value: Bool = true) -> Self {
        setParameter(.distinct, value)
        return self
    }

    /// https://developer.4d.com/docs/en/REST/filter.html
    @discardableResult public func filter(_ query: String) -> Self {
        if query.isDoubleQuoted { // TODO make an escape method
            setParameter(.filter, query)
        } else {
            setParameter(.filter, "\"\(query)\"")
        }
        return self
    }

    /// Define $params for filters.
    @discardableResult public func params(_ params: JSONEncodable) -> Self {
        setParameter(.params, "'\(params.json)'")
        return self
    }

    /// https://developer.4d.com/docs/en/REST/attributes.html
    @discardableResult public func attributes(_ attributes: [String]) -> Self {
        setParameter(.attributes, "\(attributes.joined(separator: ","))") // XXX maybe encode or espace?
        return self
    }

    /// https://developer.4d.com/docs/en/REST/querypath.html
    @discardableResult public func querypath() -> Self {
        return querypath(true)
    }
    /// https://developer.4d.com/docs/en/REST/querypath.html
    @discardableResult public func querypath(_ value: Bool = true) -> Self {
        setParameter(.querypath, value)
        return self
    }

    /// https://developer.4d.com/docs/en/REST/queryplan.html
    @discardableResult public func queryplan() -> Self {
        return queryplan(true)
    }
    /// https://developer.4d.com/docs/en/REST/queryplan.html
    @discardableResult public func queryplan(_ value: Bool = true) -> Self { // check XXX if accessible in 4d server
        setParameter(.queryplan, value)
        return self
    }

    /// Defines the number of seconds to save an entity set in 4D Server's cache (e.g., $timeout=1800)
    @discardableResult public func _timeout(_ value: Int) -> Self { // check XXX exist in 4d server
        setParameter(.timeout, value)
        return self
    }

    /// Expands the relational attribute record $expand=staff relation
    @discardableResult public func expand(_ relation: String) -> Self {
        setParameter(.expand, relation)
        return self
    }

    /// https://developer.4d.com/docs/en/REST/atomic_$atonce.html
    @discardableResult public func imageformat(_ format: ImageFormat) -> Self {
        setParameter(.imageformat, format.rawValue)
        return self
    }

    /// https://developer.4d.com/docs/en/REST/method.html
    @discardableResult public func restMethod(_ method: Method) -> Self {
        self.setParameter(.method, method.rawValue)
        self.setHTTPMethod(method.method)
        // XXX maybe also change parameters encoding, add body or parameters (post  update etc...)
        // TODO check if moya authorize query parameters and post json data...
        return self
    }

    /// https://developer.4d.com/docs/en/REST/atomic_$atonce.html
    @discardableResult public func atomic() -> Self {
        return atomic(true)
    }

    /// https://developer.4d.com/docs/en/REST/atomic_$atonce.html
    @discardableResult public func atomic(_ value: Bool = true) -> Self {
        setParameter(.atomic, value)
        return self
    }

    /// https://developer.4d.com/docs/en/REST/distinct.html
    public var isDistinct: Bool { return getParameter(.distinct) as? Bool ?? false }
    /// https://developer.4d.com/docs/en/REST/orderby.html
    public var isAtomic: Bool { return getParameter(.atomic) as? Bool ?? false }
    /// https://developer.4d.com/docs/en/REST/top_$limit.html
    public var limit: Int { return getParameter(.limit) as? Int ?? 0 }

    /// https://developer.4d.com/docs/en/REST/skip.html
    public var skip: Int { return getParameter(.skip) as? Int ?? 0 }
    /// https://developer.4d.com/docs/en/REST/method.html
    public var restMethod: Method? {
        guard let string = getParameter(.method) as? String else {
            return nil
        }
        return Method(rawValue: string)
    }
    /// https://developer.4d.com/docs/en/REST/filter.html
    public var filter: String? { return getParameter(.filter) as? String }
    /// https://developer.4d.com/docs/en/REST/expand.html
    public var expand: String? { return getParameter(.expand) as? String }
}

extension String {
    /// Check if string is a valid "order" string ie. use good syntax.
    var isOrderByValid: Bool {
        // TODO check order by string validity, ie. split by token, check keywords..
        return true
    }
}
