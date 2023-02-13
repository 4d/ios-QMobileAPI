//
//  Emptyable.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/09/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public protocol Emptyable {
    var isEmpty: Bool { get }
}
extension String: Emptyable {}
extension Array: Emptyable {}
extension Dictionary: Emptyable {}

infix operator ???: NilCoalescingPrecedence

extension Optional where Wrapped: Emptyable {
    public var isEmpty: Bool {
        switch self {
        case .none:
            return true

        case .some(let wrapped):
            return wrapped.isEmpty
        }
    }

    func orWhenNilOrEmpty(_ defaultValue: Wrapped) -> Wrapped {
        switch self {
        case .none:
            return defaultValue
        case .some(let value) where value.isEmpty:
            return defaultValue
        case .some(let value):
            return value
        }
    }

    static func ??? (left: Wrapped?, right: Wrapped) -> Wrapped {
        return left.orWhenNilOrEmpty(right)
    }
}
