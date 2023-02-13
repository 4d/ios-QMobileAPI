//
//  APIManager+Route.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 27/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

public typealias URLPath = String
extension APIManager {
    /// Find a target from an URL path. path could come from /rest api json data.
    public func target(for path: URLPath) -> TargetType? {
        var components = ArraySlice(path.components(separatedBy: "/"))
        if path.hasPrefix("/") {
            _ = components.popFirst()
        }

        guard let first = components.popFirst() else {
            return nil
        }
        if first == self.base.path {
            return self.base.target(for: components)
        }
        return nil
    }

    public func target(for deffered: Deferred) -> TargetType? {
        return target(for: deffered.uri)
    }

    public func target(for url: URL) -> TargetType? {
        var urlString = url.absoluteString
        urlString = urlString.replacingOccurrences(of: self.base.baseURL.absoluteString, with: "")
        return target(for: urlString)
    }
}

extension BaseTarget {
    func target(for components: ArraySlice<String>) -> TargetType? {
        var components = components
        guard let first = components.popFirst() else {
            return self // /rest
        }
        if first.isEmpty {
            return self.status // /rest/
        }

        switch first {
        case self.info.childPath:
            return self.info.target(for: components)

        case self.catalog.childPath:
            return self.catalog.target(for: components)

        default:
            let matches = first.matches(for: "(.*)\\((\\d)+\\)")
            if let table = matches.first, let key = matches.second {
                return self.record(from: table, key: key)
            }
            var table = first.removingPercentEncoding ?? first

            if let range = table.range(of: "?") { // there is query string
                table = String(table[..<table.index(range.upperBound, offsetBy: -1)])
                // XXX could also extract filter info and set it to parameters of target
            }
            let recordsTarget = self.records(from: table)

            let finalTarget = recordsTarget.target(for: components)

            return finalTarget
        }
    }
}

extension ChildTargetType {
    func target(for components: ArraySlice<String>) -> TargetType? {
        return self
    }
}

extension CatalogTarget {
    func target(for components: ArraySlice<String>) -> TargetType? {
        var components = components
        guard let first = components.popFirst() else {
            return self
        }
        if first == TableTarget.allPath {
            return self.all.target(for: components)
        } else {
            return self.table(first).target(for: components)
        }
    }
}

extension RecordsTarget {
    func target(for components: ArraySlice<String>) -> TargetType? {
        var components = components
        guard let first = components.popFirst() else {
            return self
        }
        if first == RecordSetTarget.keyPath {
            if let key = components.popFirst() {
                return self.set(key).target(for: components)
            }
        }
        return self
    }
}
