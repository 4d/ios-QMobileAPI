//
//  APIManager+WebTest.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/12/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

extension APIManager {
    public typealias CompletionWebTestInfoHandler = ((Result<WebTestInfo, APIError>) -> Void)
    /// Get server status
    public func loadWebTestInfo(callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionWebTestInfoHandler) -> Cancellable {
        return self.request(webTest, callbackQueue: callbackQueue, progress: progress) { result in
            switch result {
            case .success(let response):
                do {
                    let result = try response.mapString()
                    let info = WebTestInfo(string: result)
                    self.webTestInfo = info
                    completionHandler(.success(info))
                } catch {
                    completionHandler(.failure(.stringDecodingFailed(error)))
                }

            case .failure(let error):
                completionHandler(.failure(APIError.error(from: error)))
            }
        }
    }
}
