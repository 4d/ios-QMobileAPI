//
//  APIError.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 24/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

/// An error from data store
public enum APIError: Swift.Error {
    /// Indicates that JSON data for one page is not decodable.
    case jsonMappingFailed(JSON, Any.Type)

    /// Indicates that JSON data have incoherence and records could not be decoded.
    case recordsDecodingFailed(JSON, ImportableParser.Error)

    /// Indicates a response failed due to an underlying `Error`.
    case request(Swift.Error)

    /// Indicates a json decoding process due to an underlying `Error` .
    case jsonDecodingFailed(Swift.Error)

    /// Indicates a string decoding process due to an underlying `Error` .
    case stringDecodingFailed(Swift.Error)
}

// extension APIError: Codable {}

extension APIError {
    ///  Return true if error correspond to the pass HTTP code.
    public func isHTTPResponseWith(code: HTTPCode) -> Bool {
        guard let response = self.response else {
            return false
        }
        return response.statusCode == code.rawValue
    }

    /// Return true if error correospond to one of passed HTTP codes.
    public func isHTTPResponseWith(codes: [HTTPCode]) -> Bool {
        guard let response = self.response else {
            return false
        }
        guard let code = HTTPCode(rawValue: response.statusCode) else {
            return false
        }
        return codes.contains(code)
    }
}

extension APIError {

    /// Return `true` if one of underlying error is an `URLError`.
    public var isUrlError: Bool {
        if self.underlyingError is URLError {
            return true
        }
        if case .request(let error) = self {
            if error is URLError {
                return true
            } else if let moyaError = error as? MoyaError {
                if case .underlying(let underlyingError, _) = moyaError {
                    if underlyingError is URLError {
                        return true
                    }
                }
            }
        }
        return false
    }

    /// Return the underlying error if its an `URLError`.
    public var urlError: URLError? {
        if let urlError = self.underlyingError as? URLError {
            return urlError
        }
        if case .request(let error) = self {
            if let urlError = error as? URLError {
                return urlError
            } else if let moyaError = error as? MoyaError {
                if case .underlying(let underlyingError, _) = moyaError {
                    if let urlError = underlyingError as? URLError {
                        return urlError
                    }
                }
            }
        }
        return nil
    }

    /// Check if contains the specifyed error code.
    /// - Parameter code: the code
    /// - Returns: `true` if this error contains the code.
    public func isUrlError(with code: URLError.Code) -> Bool {
        return isUrlError(with: [code])
    }

    /// Check if contains the specifyed one the specifyed error code.
    /// - Parameter codes: the codes to check
    /// - Returns: `true` if this error contains one of the codes.
    public func isUrlError(with codes: [URLError.Code]) -> Bool {
        if let urlError = self.urlError {
            return codes.contains(urlError.code)
        }
        return false
    }

    /// Is `.timedOut` error.
    public var isTimedOut: Bool {
        return isUrlError(with: .timedOut)
    }

    /// Is `.cannotConnectToHost` error.
    public var isCannotConnectToHost: Bool {
        return isUrlError(with: .cannotConnectToHost)
    }

    /// Is `.notConnectedToInternet` error.
    public var isNotConnectedToInternet: Bool {
        return isUrlError(with: .notConnectedToInternet)
    }

    /// Is `.cancelled` error.
    public var isCancelled: Bool {
        return isUrlError(with: .cancelled) // XXX could add other case
    }

    /// Is `.userAuthenticationRequired` error.
    public var isUserAuthenticationRequired: Bool {
        return isUrlError(with: .userAuthenticationRequired)
    }
}

extension APIError {
    public enum RequestCase: String {
        case notConnectedToInternet
        case serverNotReachable
        case internationalRoamingOff
        case connectionLost
        case ssl
        case cancelled

        var codes: [URLError.Code] {
            switch self {
            case .serverNotReachable:
                return [.timedOut, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed]

            case .connectionLost:
                return [.networkConnectionLost]

            case .notConnectedToInternet:
                return [.notConnectedToInternet]

            case .internationalRoamingOff:
                return [.internationalRoamingOff]

            case .ssl:
                return [.clientCertificateRequired, .clientCertificateRejected, .serverCertificateNotYetValid,
                        .serverCertificateHasUnknownRoot, .serverCertificateUntrusted, .serverCertificateHasBadDate,
                        .secureConnectionFailed]

            case .cancelled:
                return [.cancelled]
            }
        }

        public init?(_ urlError: URLError) {
            self.init(code: urlError.code)
        }

        public init?(code: URLError.Code) {
            switch code {
            case .timedOut, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                self = .serverNotReachable

            case .networkConnectionLost:
                self = .connectionLost

            case .notConnectedToInternet:
                self = .notConnectedToInternet

            case .internationalRoamingOff:
                self = .internationalRoamingOff
            case .clientCertificateRequired, .clientCertificateRejected, .serverCertificateNotYetValid,
                 .serverCertificateHasUnknownRoot, .serverCertificateUntrusted, .serverCertificateHasBadDate,
                 .secureConnectionFailed:
                self = .ssl

            case .cancelled:
                self = .cancelled

            default:
                return nil
            }
        }
    }
}

extension APIError {

    /// Check if this error match the request case.
    /// - Parameter case: the request case to check
    /// - Returns: `true` if error match the request case
    public func isRequestCase(_ case: RequestCase) -> Bool {
        let codes = `case`.codes
        return isUrlError(with: codes)
    }

    /// the underlying request case if any.
    public var requestCase: RequestCase? {
        if case .request(let error) = self {
            if let urlError = error as? URLError {
                return RequestCase(urlError)
            }
        }
        return nil
    }
}

extension APIError: LocalizedError {

    /// The localized error description.
    public var errorDescription: String? {
        switch self {
        case .jsonMappingFailed:
            return "api.jsonMappingFailed".localized

        case .recordsDecodingFailed:
            return "api.recordsDecodingFailed".localized

        case .request:
            return "api.request".localized

        case .jsonDecodingFailed:
            return "api.jsonDecodingFailed".localized

        case .stringDecodingFailed:
            return "api.stringDecodingFailed".localized
        }
    }

    public var failureReason: String? {
        guard let error = self.error else {
            return nil
        }
        if let moyaError = error as? MoyaError,
            // work only if alamofire validation is activated
            let afError = moyaError.error as? AFError,
            case .responseValidationFailed(let reason) = afError,
            case .unacceptableStatusCode(let code) = reason,
            let httpCode = HTTPCode(rawValue: code) {
            if let failureReason = httpCode.reason {
                return failureReason
            }
            // http error code is cryptic.
            return httpCode.message + " (\(code))"
        } else if let error = error as? LocalizedError {
            return error.errorDescription
        }
        return error.localizedDescription
    }

    public var recoverySuggestion: String? {
        if let error = self.error as? LocalizedError {
            if let recoverySuggestion = error.recoverySuggestion {
                return recoverySuggestion
            }
        }
        switch self {
        case .jsonDecodingFailed, .jsonMappingFailed, .recordsDecodingFailed, .stringDecodingFailed:
            return nil

        case .request:
            return nil
        }
    }

    public var helpAnchor: String? {
        return nil
    }
}

extension APIError: ErrorConvertible, ErrorWithCause {
    public static func error(from underlying: Swift.Error) -> APIError {
        if let apiError = underlying as? APIError {
            return apiError
        } else if let moyaError = underlying as? MoyaError {
            return APIError.moya(moyaError)
        } else {
           return.request(underlying)
        }
    }

    /// The underlying error if any.
    public var error: Swift.Error? {
        switch self {
        case .jsonDecodingFailed(let error):
            return error

        case .stringDecodingFailed(let error):
            return error

        case .request(let error):
            /*if let moyaError = error as? Moya.MoyaError {
                return moyaError.error
            }*/
            return error

        default:
            return nil
        }
    }
}

extension APIError {
    /// The underlying response if any.
    public var response: Response? {
        if let error = self.error as? MoyaError {
            return error.response
        }
        return nil
    }

    /// The underlying `MoyaError` from Moya api if any.
    public var moyaError: MoyaError? {
        if let moyaError = self.error as? MoyaError {
            return moyaError
        }
        return nil
    }

    /// The underlying `AFError`from Alamofire  if any.
    public var afError: AFError? {
        if let moyaError = self.error as? MoyaError {
            if let afError = moyaError.error as? AFError {
                return afError
            }
        }
        /*if let afError = self.error as? AFError {
            return afError
        }*/
        return nil
    }

    /// The underlying url if any.
    public var url: URL? {
        if let url = afError?.url {
            return url
        }
        return response?.request?.url
    }

    /// The underlying url as url convertible if any.
    public var urlConvertible: URLConvertible? {
        return afError?.urlConvertible
    }

    /// The server response as string if any.
    public var responseString: String? {
        return moyaError?.responseString
    }
}

public extension MoyaError {
    /// The server response as string if any.
    var responseString: String? {
        guard let response = response else {
            return nil
        }
        return String(data: response.data, encoding: .utf8)
    }
}

extension APIError {
    /// Create `APIError` from `MoyaError`
    public static func moya(_ moyaError: MoyaError) -> APIError {
        /*if let error = moyaError.error {
            return .request(error) // deencapsulate
        }*/
        return .request(moyaError)
    }
}

// MARK: Moya
extension MoyaError: ErrorWithCause {
    /// Depending on error type, returns an `Error` object.
    public var error: Swift.Error? {
        switch self {
        case .underlying(let error, _):
            return error

        case .jsonMapping, .stringMapping:
            if let restErrors = self.restErrors {
                return restErrors
            }
            return nil

        default:
            return nil
        }
    }
}

// MARK: RestError
extension MoyaError {
    /// Get `RestErrors` from this error data.
    public var restErrors: RestErrors? {
        if let data = self.response?.data,
           let restErrors = RestErrors(data: data),
           !restErrors.errors.isEmpty {
            return restErrors
        }
        return nil
    }

    /// `true` if there is rest errors. If you need to know that and use `restErrors`, prefer use `restErrors` directly.
    public var isRestError: Bool {
        // XXX could optimize by not creating objects
        return restErrors != nil
    }
}

extension APIError {
    /// `true` if there is rest errors. If you need to know that and use `restErrors`, prefer use `restErrors` directly.
    public var isRestError: Bool {
        if let moyaError = self.error as? MoyaError {
            return moyaError.isRestError
        }
        return false
    }

    /// Get `RestErrors` from this error data.
    public var restErrors: RestErrors? {
        if let moyaError = self.error as? MoyaError {
            return moyaError.restErrors
        }
        return nil
    }

    /// Check if match rest error code.
    /// - Parameter code: the code to chec;
    /// - Returns: `true` if match
    public func match(_ code: RestErrorCode) -> Bool {
        return restErrors?.match(code) ?? false
    }
}

// MARK: Alamofire
import Alamofire

extension AFError: ErrorWithCause {
    public var error: Swift.Error? {
        return self.underlyingError
    }
}
