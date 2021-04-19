//
//  CancellableComposite.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 27/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

public class CancellableComposite {
    /// all mode possible to manage list of cancellable
    public enum Mode {
        case all, one, requested
    }

    /// Init a cancellable composite.
    public init( mode: Mode = .all) {
        self.mode = mode
    }

    fileprivate var list: [Moya.Cancellable] = []
    fileprivate var hasRequestedCancel: Bool = false
    /// The current mode.
    public var mode: Mode = .all

    /// A semaphore to manage asynchronous code.
    public var semaphore = DispatchSemaphore(value: 1)
}

extension CancellableComposite: Moya.Cancellable {
    @discardableResult
    public func append(_ cancellable: Moya.Cancellable) -> Bool {
        if lock() {
            defer {
                _ = unlock()
            }
            appendUnlocked(cancellable)
            return true
        }
        return false
    }

    public func appendUnlocked(_ cancellable: Moya.Cancellable) {
        if hasRequestedCancel {
            cancellable.cancel()
        }
        list.append(cancellable)
    }

    public var isCancelled: Bool {
        _ = lock()
        defer {
            _ = unlock()
        }
        return isCancelledUnlocked
    }

    public var isCancelledUnlocked: Bool {
        switch mode {
        case .all:
            // all must be cancelled to be cancelled
            for item in list where !item.isCancelled {
                return false
            }
            if list.isEmpty {
                return hasRequestedCancel
            }
            return true

        case .one:
            // all must be cancelled to be cancelled
            for item in list where item.isCancelled {
                return true
            }
            return false

        case .requested:
            return hasRequestedCancel
        }
    }

    public func cancel() {
        _ = lock()
        defer {
            _ = unlock()
        }
        unlockedCancel()
    }

    public func unlockedCancel() {
        // Must be done into cancel lock
        hasRequestedCancel = true
        for item in list where !item.isCancelled {
            item.cancel()
        }
    }
}

extension CancellableComposite: CustomStringConvertible {
    public var description: String {
        return "Cancellable[\(mode): \(list)]"
    }
}

extension CancellableComposite: LockableBySemaphore {}

extension DispatchWorkItem: Moya.Cancellable {}
/*
import Combine

extension AnyCancellable {

    /// Stores this type-erasing cancellable instance in the specified set.
    ///
    /// - Parameter set: The set in which to store this ``AnyCancellable``.
    final public func store(in composite: CancellableComposite) {
        self.store(in: &composite.list)
    }
}
*/
