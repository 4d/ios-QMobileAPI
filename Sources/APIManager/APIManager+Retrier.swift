//
//  APIManager+Retrier.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 22/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Alamofire
import Foundation

extension APIManager: RequestInterceptor {

    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        completion(.doNotRetry)
    }

    // Implement mecanism to retry request if some errors occurs
    /*public func should(_ manager: Session, retry request: Request, with error: Swift.Error, completion: @escaping RequestRetryCompletion) {
        /*// check info from error or request...
        if let retryable = error as? Retryable, let retry = retryable.retry {
            completion(retry.maxAttempts > request.retryCount, retry.interval)
        } else if let retryable = request as? Retryable, let retry = retryable.retry {
            completion(retry.maxAttempts > request.retryCount, retry.interval)
        } else if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            lock.lock()
            defer { lock.unlock() }
            requestsToRetry.append(completion)

            if !isRefreshing {
                refreshTokens { [weak self] succeeded in
                    guard let strongSelf = self else { return }

                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }

                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
           */ completion(false, 0)
        /*}*/
    }*/

    private typealias RefreshCompletion = (_ succeeded: Bool) -> Void

    /*private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        isRefreshing = true
        // XXX here try to refresh instead of authentificated if there is some expired mecanism
        _ = APIManager.instance.authentificate(login: "") { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success:
                completion(true)
                strongSelf.isRefreshing = false
            case .failure(_):
                completion(false)
                strongSelf.isRefreshing = false
            }
        }
    }*/
}

// MARK: retry

/// Define some info to customize retry behavioue.
public struct Retry {
    /// Time interval before retry.
    public var interval: TimeInterval = 10
    /// The number of max retry attemps.
    public var maxAttempts: UInt = 5
}
/// Protocol to define rety info
public protocol Retryable {
    /// Return the retry parametes info.
    var retry: Retry? { get }
}

// MARK: URLError
/*
 extension NSError: Retryable {
 
 public var retry: Retry? {
 guard self.domain == NSURLErrorDomain else {
 return nil
 }
 }
 }*/

extension URLError: Retryable {
    public static var retryableLookUpErrorCodes: Set<URLError.Code> = [
        .timedOut,
        .cannotFindHost,
        .cannotConnectToHost,
        .dnsLookupFailed,
        .networkConnectionLost]

    public var retry: Retry? {
        if URLError.retryableLookUpErrorCodes.contains(self.code) {
            return Retry(interval: 10, maxAttempts: 5)
        }
        return nil
    }
}
