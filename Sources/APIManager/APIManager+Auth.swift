//
//  APIManager+Auth.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/03/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//

import Foundation

import Moya
import Result

extension APIManager {
    public typealias CompletionAuthTokenHandler = ((Result<AuthToken, APIError>) -> Void)
    /// Authentificate with login and password.
    open func authentificate(login: String,
                             password: String? = nil,
                             send: AuthTarget.Send = .link,
                             parameters: [String: Any]? = nil,
                             callbackQueue: DispatchQueue? = nil,
                             progress: ProgressHandler? = nil,
                             completionHandler: @escaping CompletionAuthTokenHandler) -> Cancellable {
        let target: AuthTarget = base.authentificate(login: login, password: password, send: send, parameters: parameters)
        return self.authentificate(target, callbackQueue: callbackQueue, progress: progress, completionHandler: completionHandler)
    }

    /// Authentificate with token.
    open func authentificate(token: String,
                             callbackQueue: DispatchQueue? = nil,
                             progress: ProgressHandler? = nil,
                             completionHandler: @escaping CompletionAuthTokenHandler) -> Cancellable {
        let target: AuthVerificationTarget = base.authentificate(token: token)
        return self.authentificate(target, callbackQueue: callbackQueue, progress: progress, completionHandler: completionHandler)
    }

    fileprivate func authentificate<T: DecodableTargetType> (_ target: T,
                                                             callbackQueue: DispatchQueue? = nil,
                                                             progress: ProgressHandler? = nil,
                                                             completionHandler: @escaping CompletionAuthTokenHandler) -> Cancellable where T.ResultType == AuthToken {
        let completionHandler: CompletionAuthTokenHandler = { result in
            switch result {
            case .success(let authToken):
                self.authToken = authToken
                Notification(name: APIManager.loginSuccess, object: self, userInfo: ["token": authToken]).post()
                self.delegate?.didLoginSuccess(authToken)

            case .failure(let error):
                Notification(name: APIManager.loginFailed, object: self, userInfo: [NSUnderlyingErrorKey: error]).post()
                self.delegate?.didLoginFailed(error)
            }
            completionHandler(result)
        }
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    /// Logout using token in headers or passed token.
    public typealias CompletionLogOutHandler = ((Result<Status, APIError>) -> Void)
    open func logout(token: String? = nil,
                     callbackQueue: DispatchQueue? = nil,
                     progress: ProgressHandler? = nil,
                     completionHandler: @escaping CompletionLogOutHandler) -> Cancellable {
        let target: LogOutTarget = base.logout(token: token)
        let completionHandler: CompletionLogOutHandler = { result in
            self.authToken = nil
            Notification(name: APIManager.logout, object: self).post()
            self.delegate?.didLogout()
            completionHandler(result)
        }
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }
}
