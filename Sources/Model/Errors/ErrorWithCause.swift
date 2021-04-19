//
//  ErrorWithCause.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 31/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

// MARK: mapping
public protocol ErrorWithCause: Swift.Error {
    /// Depending on error type, returns an `Error` object, cause of the current error.
    var error: Swift.Error? { get }
}

/*
 extension NSError: ErrorWithCause {
 public var error: Swift.Error? {
 return self.userInfo[NSUnderlyingErrorKey] as? Swift.Error
 }
 }
 */

extension ErrorWithCause {
    /// Get the first error cause
    public var underlyingError: Swift.Error? {
        let error = self.error
        if let error = error as? ErrorWithCause {
            return error.underlyingError
        }
        // CLEAN if all error, match protocol no need to do this code and errorStack will be better
        if let error = error?.userInfoUnderlyingError {
            return error
        }
        return error
    }

    /// Get all error stack
    public var errorStack: [Swift.Error]? {
        guard let error = self.error else {
            return nil
        }
        var stack: [Swift.Error] = [error]
        if let error = error as? ErrorWithCause {
            if let toAppend = error.errorStack {
                stack.append(contentsOf: toAppend)
            }
        } else if let error = error.userInfoUnderlyingError {
            stack.append(error)
        }
        return stack
    }
}

extension Swift.Error {
    /// Return the ns error underlying error if any.
    public var userInfoUnderlyingError: Swift.Error? {
        if let error = self as? CustomNSError {
            return error.errorUserInfo[NSUnderlyingErrorKey] as? Swift.Error
        }
        if let underlyingError = (self as NSError).userInfo[NSUnderlyingErrorKey] as? Swift.Error {
            return underlyingError
        }
        return nil
    }
}
