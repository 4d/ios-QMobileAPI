//
//  APIManager+Notification.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/11/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//

import Foundation

extension Notification.Name {
    /// Notify about log in success
    @available(*, deprecated, message: "Now use `APIManager.loginSuccess`")
    public static let apiManagerLoginSuccess = APIManager.loginSuccess
    /// Notify about log in failure
    @available(*, deprecated, message: "Now use `APIManager.loginFailed`")
    public static let apiManagerLoginFailed = APIManager.loginFailed
    /// Notify about log out
    @available(*, deprecated, message: "Now use `APIManager.logout`")
    public static let apiManagerLogout = APIManager.logout

    /// Notify default instance change.
    @available(*, deprecated, message: "Now use `APIManager.didChangeDefaultInstance`")
    public static let apiManagerDidChangeDefaultInstance = APIManager.didChangeDefaultInstance
}

extension APIManager {
    /// Notify about log in success
    public static let loginSuccess = Notification.Name("apiManager.login.success")
    /// Notify about log in failure
    public static let loginFailed = Notification.Name("apiManager.login.failed")
    /// Notify about log out
    public static let logout = Notification.Name("apiManager.logout")

    /// Notify default instance change.
    public static let didChangeDefaultInstance = Notification.Name("apiManager.instance")
}

extension NotificationCenter {
    /// Specific center for api. By default `default`.
    static var apiManager: NotificationCenter = .default
}

extension Notification {
    /// Post this notification using the `.apiManager` center.
    func post(_ center: NotificationCenter = .apiManager) {
        center.post(self)
    }
}

extension APIManager {
    /// Observe `APIManager` on specific event usung closure.
    public func observe(_ name: Notification.Name, queue: OperationQueue? = nil, using: @escaping (Notification) -> Void) -> NSObjectProtocol {
        /// /!\ Could not observer on self because APIManager instance change. (maybe make url changeable instead of changing the singleton instance)
        return NotificationCenter.apiManager.addObserver(forName: name, object: nil/*listen to all instead of self*/, queue: queue, using: using)
    }

    /// Unobserve `APIManager` by passing the handle returned by `oberve` function.
    public func unobserve(_ observer: NSObjectProtocol) {
        NotificationCenter.apiManager.removeObserver(observer)
    }

    /// Unobserve `APIManager` by passing the handle returned by `oberve` function.
    public func unobserve(_ observers: [NSObjectProtocol]) {
        for observer in observers {
            unobserve(observer)
        }
    }
}
