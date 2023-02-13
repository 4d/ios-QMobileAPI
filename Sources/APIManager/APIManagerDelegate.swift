//
//  APIManagerDelegate.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/11/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//

import Foundation

/// Delegate protocol for `APIManager`.
public protocol APIManagerDelegate: NSObjectProtocol {
    func didLoginSuccess(_ token: AuthToken)
    func didLoginFailed(_ error: APIError)
    func didLogout()

    func didReplacedAsDefaultInstance(oldValue: APIManager, newValue: APIManager)
}
