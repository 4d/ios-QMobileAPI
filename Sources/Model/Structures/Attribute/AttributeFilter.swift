//
//  AttributeFilter.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/05/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

extension Attribute {
    public class Filter {
        private var _query: String
        init() {
            _query = ""
        }
        public init(query: String) {
            _query = query
        }
        public var query: String {
            return _query
        }

        public var isEmpty: Bool {
            return query.isEmpty
        }
    }

    public enum Comparator: String {
        case equalTo = "="
        case notEqualTo = "!="
        case greaterThan = ">"
        case lessThan = "<"
        case greaterThanOrEqualTo = ">="
        case lessThanOrEqualTo = "<="
        case begin = "begin"

        var query: String { return rawValue }
    }

    public class ComparisonFilter: Filter {
        let left: Filter.Expression
        let right: Filter.Expression
        let comparator: Comparator

        public init(left: Filter.Expression, right: Filter.Expression, comparator: Comparator) {
            self.left = left
            self.right = right
            self.comparator = comparator
            super.init()
        }

        override public var query: String {
            return "\(left.query) \(comparator.query) \(right.query)"
        }
    }

    public enum Conjunction: String {
        case and = "AND"
        case or = "OR"
        case except = "EXCEPT"

        var query: String { return rawValue }
    }

    public class CompoundFilter: Filter {
        let filters: [Filter]
        let conjunction: Conjunction

        public init(filters: [Filter], conjunction: Conjunction) {
            self.filters = filters
            self.conjunction = conjunction
            super.init()
        }

        override public var query: String {
            if filters.count == 1, let first = filters.first, case .except = conjunction {
                return "\(self.conjunction.query) \(first.query)"
            }
            return filters.map { $0.query }.joined(separator: " \(self.conjunction.query) ")
        }
    }
}

// MARK: Expression

extension Attribute.Filter {
    public class Expression {
        var query: String
        init(forValue: Attribute.ValueType) {
            query = "\(forValue)"
        }
        init(forKeyPath name: String) {
            query = name
        }
    }
}

extension Attribute {
    public typealias ValueType = Any

    func expression(for value: Attribute.ValueType?) -> Attribute.Filter.Expression {
        if let value = value {
            return Attribute.Filter.Expression(forValue: value)
        }
        return Attribute.Filter.Expression(forValue: NSNull())
    }

    public var expression: Attribute.Filter.Expression {
        return Attribute.Filter.Expression(forKeyPath: name)
    }
}

extension String {
    public var expression: Attribute.Filter.Expression {
        return Attribute.Filter.Expression(forKeyPath: self)
    }
}

// MARK: operators

public func == (left: Attribute, right: Attribute.ValueType) -> Attribute.Filter {
    return left.expression == left.expression(for: right)
}

public func != (left: Attribute, right: Attribute.ValueType) -> Attribute.Filter {
    return left.expression != left.expression(for: right)
}

public func > (left: Attribute, right: Attribute.ValueType) -> Attribute.Filter {
    return left.expression > left.expression(for: right)
}

public func >= (left: Attribute, right: Attribute.ValueType) -> Attribute.Filter {
    return left.expression >= left.expression(for: right)
}

public func < (left: Attribute, right: Attribute.ValueType) -> Attribute.Filter {
    return left.expression < left.expression(for: right)
}

public func <= (left: Attribute, right: Attribute.ValueType) -> Attribute.Filter {
    return left.expression <= left.expression(for: right)
}

public func == (left: Attribute.Filter.Expression, right: Attribute.ValueType) -> Attribute.Filter {
    return left == Attribute.Filter.Expression(forValue: right)
}

public func != (left: Attribute.Filter.Expression, right: Attribute.ValueType) -> Attribute.Filter {
    return left != Attribute.Filter.Expression(forValue: right)
}

public func > (left: Attribute.Filter.Expression, right: Attribute.ValueType) -> Attribute.Filter {
    return left > Attribute.Filter.Expression(forValue: right)
}

public func >= (left: Attribute.Filter.Expression, right: Attribute.ValueType) -> Attribute.Filter {
    return left >= Attribute.Filter.Expression(forValue: right)
}

public func < (left: Attribute.Filter.Expression, right: Attribute.ValueType) -> Attribute.Filter {
    return left < Attribute.Filter.Expression(forValue: right)
}

public func <= (left: Attribute.Filter.Expression, right: Attribute.ValueType) -> Attribute.Filter {
    return left <= Attribute.Filter.Expression(forValue: right)
}

/*
 public func ~= (left: Attribute, right: AttributeType) -> Attribute.Filter {
 return left.expression ~= left.expression(for: right)
 }
 */

public func == (left: Attribute.Filter.Expression, right: Attribute.Filter.Expression) -> Attribute.Filter {
    return Attribute.ComparisonFilter(left: left, right: right, comparator: .equalTo)
}

public func != (left: Attribute.Filter.Expression, right: Attribute.Filter.Expression) -> Attribute.Filter {
    return Attribute.ComparisonFilter(left: left, right: right, comparator: .notEqualTo)
}

public func > (left: Attribute.Filter.Expression, right: Attribute.Filter.Expression) -> Attribute.Filter {
    return Attribute.ComparisonFilter(left: left, right: right, comparator: .greaterThan)
}

public func >= (left: Attribute.Filter.Expression, right: Attribute.Filter.Expression) -> Attribute.Filter {
    return Attribute.ComparisonFilter(left: left, right: right, comparator: .greaterThanOrEqualTo)
}

public func < (left: Attribute.Filter.Expression, right: Attribute.Filter.Expression) -> Attribute.Filter {
    return Attribute.ComparisonFilter(left: left, right: right, comparator: .lessThan)
}

public func <= (left: Attribute.Filter.Expression, right: Attribute.Filter.Expression) -> Attribute.Filter {
    return Attribute.ComparisonFilter(left: left, right: right, comparator: .lessThanOrEqualTo)
}

/*
 // Manage instead @
 public func ~= (left: Attribute.Filter.Expression, right: Attribute.Filter.Expression) -> Attribute.Filter {
 return Attribute.ComparisonFilter(left: left, right: right, comparator: .like)
 }
 
 public func << (left: Attribute.Filter.Expression, right: Attribute.Filter.Expression) -> Attribute.Filter {
 return Attribute.ComparisonFilter(left: left, right: right, comparator: .in)
 }
 */

public func && (left: Attribute.Filter, right: Attribute.Filter) -> Attribute.Filter {
    return Attribute.CompoundFilter(filters: [left, right], conjunction: .and)
}

public func || (left: Attribute.Filter, right: Attribute.Filter) -> Attribute.Filter {
    return Attribute.CompoundFilter(filters: [left, right], conjunction: .or)
}

prefix public func ! (predicate: Attribute.Filter) -> Attribute.Filter {
    return Attribute.CompoundFilter(filters: [predicate], conjunction: .except)
}
