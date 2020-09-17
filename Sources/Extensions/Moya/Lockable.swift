//
//  Lockable.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 05/09/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public protocol Lockable {
    func lock() -> Bool
    func unlock() -> Bool
}

public protocol LockableBySync: Lockable {}

extension LockableBySync {
    public func lock() -> Bool {
        logger.verbose({ "will lock \(self)" })
        let result = (objc_sync_enter(self))
        logger.verbose({ "did lock \(self)" })
        return Int(result) == OBJC_SYNC_SUCCESS
    }

    public func unlock() -> Bool {
        logger.verbose({ "will unlock \(self)" })
        let result = objc_sync_exit(self)
        logger.verbose({ "did unlock \(self)" })
        return Int(result) == OBJC_SYNC_SUCCESS
    }
}

public protocol LockableBySemaphore: Lockable {
    var semaphore: DispatchSemaphore { get }
}

extension LockableBySemaphore {
    public func lock() -> Bool {
        return semaphore.wait(timeout: DispatchTime.distantFuture) == .success
    }

    public func unlock() -> Bool {
        return semaphore.signal() != 0
    }
}

extension Lockable {
    public func perform(lockedTask task: () -> Void) -> Bool {
        if lock() {
            defer {
                _ = unlock()
            }
            task()
            return true
        }
        return false
    }
}
