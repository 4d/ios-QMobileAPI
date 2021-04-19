//
//  RecordsRequest.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 27/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

/// The key for record request query.
public enum RecordsRequestKey: String {
    case orderby
    case skip
    case limit
    case distinct
    case filter
    case querypath
    case queryplan
    case timeout
    case expand
    case imageformat
    case method
    case atomic
    case params
    case attributes
    case extendedAttributes
}

/// The records request.
public protocol RecordsRequest {

    /// Is distinct.
    var isDistinct: Bool { get }
    /// Is atomic.
    var isAtomic: Bool { get }
    /// Current limit.
    var limit: Int { get }
    /// Current skip value.
    var skip: Int { get }
    /// Current 4D rest method.
    var restMethod: Method? { get }
    /// Current filter.
    var filter: String? { get }
    /// Current expand fields.
    var expand: String? { get }

    // MARK: Configure
    /// Order by.
    @discardableResult func order(by: String) -> Self
    @discardableResult func order(by: [String: OrderBy]) -> Self

    /// Skip some records.
    @discardableResult func skip(_ value: Int) -> Self
    /// Limit the number of records returned.
    @discardableResult func limit(_ value: Int) -> Self

    /// https://developer.4d.com/docs/en/REST/distinct.html
    @discardableResult func distinct() -> Self
    /// https://developer.4d.com/docs/en/REST/distinct.html
    @discardableResult func distinct(_ value: Bool) -> Self

    /// Filter the records. (orda notation)
    @discardableResult func filter(_ query: String) -> Self
    /// Add some parameters for filter.
    @discardableResult func params(_ params: JSONEncodable) -> Self
    /// List the wanted record fields/attributes.
    @discardableResult func attributes(_ attributes: [String]) -> Self

    /// Activate query path.
    @discardableResult func querypath() -> Self
    /// Activate query path.
    @discardableResult func querypath(_ value: Bool) -> Self

    /// Activate query plan.
    @discardableResult func queryplan() -> Self
    /// Activate query plan.
    @discardableResult func queryplan(_ value: Bool) -> Self

    /// Expand specific relations (separated by comma).
    @discardableResult func expand(_ relation: String) -> Self

    /// The image format wanted.
    @discardableResult func imageformat(_ format: ImageFormat) -> Self

    /// https://developer.4d.com/docs/en/REST/method.html
    @discardableResult func restMethod(_ method: Method) -> Self
    /// https://developer.4d.com/docs/en/REST/atomic_$atonce.html
    @discardableResult func atomic() -> Self
    /// https://developer.4d.com/docs/en/REST/atomic_$atonce.html
    @discardableResult func atomic(_ value: Bool) -> Self

}

///  To defined if should be sorted in ascending or descending order.
public enum OrderBy: String {
    /// Ascending order
    case asc
    /// Descending order
    case desc
}

/// Supported image format.
public enum ImageFormat: String {
    case gif
    case pmh
    case jpeg
    case tiff
    case best
    case pdf // macOS server only
}

/// 4D rest method.
public enum Method: String {
    case delete
    /// Create an entity set when doing the record request
    case entityset
    case release
    case subentityset
    case validate
    case update
}

extension Method {
    /// Get Specific HTTP method according to 4D rest method.
    var method: Moya.Method {
        switch self {
        case .entityset, .subentityset, .release:
            return .get

        case .delete, .validate, .update:
            return .post
        }
    }
}

extension RecordsRequest {
    public func appendToFilter(_ query: String) {
        if let currentFilter = self.filter, !currentFilter.isEmpty {
            assert(!query.isDoubleQuoted) // expect query not double quoted
            self.filter(currentFilter.appendingInDoubleQuote(" AND \(query)"))
        } else {
            self.filter(query)
        }
    }
}

extension String {

    var isDoubleQuoted: Bool {
        return self.first == "\"" && self.last == "\""
    }

    var doubleQuoted: String {
        return "\"\(self)\""
    }

    var trimDoubleQuote: String {
        return self.trimmingCharacters(in: .doubleQuote)
    }

    func appendingInDoubleQuote(_ string: String) -> String {
        guard self.isDoubleQuoted else {
            return self.appending(string)
        }
        return self.trimDoubleQuote.appending(string).doubleQuoted
    }
}

extension CharacterSet {
    static let doubleQuote = CharacterSet(charactersIn: "\"")
}
