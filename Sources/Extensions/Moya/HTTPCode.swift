//
//  HttpCode.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 29/09/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Enumeration of HTTP code
/// https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
public enum HTTPCode: Int, CaseIterable, Hashable {
     // 1xx Informational responses
    case `continue` = 100
    case switchingProtocols = 101
    case processing = 102

    // 2xx Success
    case ok = 200
    case created = 201
    case accepted = 202
    case nonAuthoritativeInformation = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206

    // 3xx Redirection
    case multipleChoices = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case notModified = 304
    case useProxy = 305
    case switchProxy = 306
    case temporaryRedirect = 307
    case permanentRedirect = 308

      // 4xx Client errors
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case proxyAuthenticationRequired = 407
    case requestTimeout = 408
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case preconditionFailed = 412
    case requestEntityTooLarge = 413
    case requestURITooLong = 414
    case unsupportedMediaType = 415
    case requestedRangeNotSatisfiable = 416
    case expectationFailed = 417
    case imATeapot = 418
    case authenticationTimeout = 419
    case enhanceYourCalm = 420
    case unprocessableEntity = 422
    case locked = 423
    case failedDependency = 424
    case preconditionRequired = 428
    case tooManyRequests = 429
    case requestHeaderFieldsTooLarge = 431

    // 5xx Server errors
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case httpVersionNotSupported = 505
    case variantAlsoNegotiates = 506
    case insufficientStorage = 507
    case loopDetected = 508
    case notExtended = 510
    case networkAuthenticationRequired = 511
}

extension HTTPCode {

    /// A standard message for HTTP code
    public var message: String {
        switch self {
        case .`continue`: return "Continue"
        case .switchingProtocols: return "Switching Protocols"
        case .processing: return "Processing"

        case .ok: return "OK"
        case .created: return "Created"
        case .accepted: return "Accepted"
        case .nonAuthoritativeInformation: return "Non Authoritative Information"
        case .noContent: return "No Content"
        case .resetContent: return "Reset Content"
        case .partialContent: return "Partial Content"

        case .multipleChoices: return "Multiple Choices"
        case .movedPermanently: return "Moved Permanently"
        case .found: return "Found"
        case .seeOther: return "See Other"
        case .notModified: return "Not Modified"
        case .useProxy: return "Use Proxy"
        case .switchProxy: return "Switch Proxy"
        case .temporaryRedirect: return "Temporary Redirect"
        case .permanentRedirect: return "Permanent Redirect"

        case .badRequest: return "Bad Request"
        case .unauthorized: return "Unauthorized"
        case .paymentRequired: return "Payment Required"
        case .forbidden: return "Forbidden"
        case .notFound: return "Not Found"
        case .methodNotAllowed: return "Method Not Allowed"
        case .notAcceptable: return "Not Acceptable"
        case .proxyAuthenticationRequired: return "Proxy Authentication Required"
        case .requestTimeout: return "Request Timeout"
        case .conflict: return "Conflict"
        case .gone: return "Gone"
        case .lengthRequired: return "Length Required"
        case .preconditionFailed: return "Precondition Failed"
        case .requestEntityTooLarge: return "Request Entity Too Large"
        case .requestURITooLong: return "Request URI Too Long"
        case .unsupportedMediaType: return "Unsupported Media Type"
        case .requestedRangeNotSatisfiable: return "Requested Range Not Satisfiable"
        case .expectationFailed: return "Expectation Failed"
        case .imATeapot: return "I'm A Teapot"
        case .authenticationTimeout: return "Authentication Timeout"
        case .enhanceYourCalm: return "Enhance Your Calm"
        case .unprocessableEntity: return "Unprocessable Entity"
        case .locked: return "Locked"
        case .failedDependency: return "Failed Dependency"
        case .preconditionRequired: return "PreconditionR equired"
        case .tooManyRequests: return "Too Many Requests"
        case .requestHeaderFieldsTooLarge: return "Request Header Fields Too Large"

        case .internalServerError: return "Internal Server Error"
        case .notImplemented: return "Not Implemented"
        case .badGateway: return "Bad Gateway"
        case .serviceUnavailable: return "Service Unavailable"
        case .gatewayTimeout: return "Gateway Timeout"
        case .httpVersionNotSupported: return "HTTP Version Not Supported"
        case .variantAlsoNegotiates: return "Variant Also Negotiates"
        case .insufficientStorage: return "Insufficient Storage"
        case .loopDetected: return "Loop Detected"
        case .notExtended: return "Not Extended"
        case .networkAuthenticationRequired: return "Network Authentication Required"
        }
    }

    /// A standard message for HTTP code
    public var reason: String? {
        switch self {
        case .tooManyRequests: return "Too many requests send to the application server."
        case .serviceUnavailable: return "Service is unavailable currently."
        case .movedPermanently: return "Resource is moved permenantly."
        case .unauthorized: return "You are no more authentified. Please login."
        case .forbidden: return "You are no more allowed to access the resource or make this action."
        case .notFound: return "Some information is missing on application server."
        case .methodNotAllowed: return "You are not a allowed to make this request."
        case .notAcceptable: return "The request is not acceptable."
        case .requestTimeout: return "The server make too much time to respond."
        case .authenticationTimeout: return "You session has expired, please re-login."
        case .locked: return "The resource is locked"
        case .gatewayTimeout: return "Gateway timeout."
        case .notImplemented: return "You request are not available."
        default:
            break
        }
        switch self.rawValue {
        case 500..<600:
            return "The server encountered an error and was unable to complete your request. Please contact the server administrator."
        default:
            return nil
        }
    }
}

/// MARK Error with code
/*
internal protocol HTTPError: Error {
    var httpCode: HTTPCode { get }
}

internal enum ClientError: HTTPError, CaseIterable {
    case badRequest
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case proxyAuthenticationRequired
    case requestTimeout
    case conflict
    case gone
    case lengthRequired
    case preconditionFailed
    case requestEntityTooLarge
    case requestURITooLong
    case unsupportedMediaType
    case requestedRangeNotSatisfiable
    case expectationFailed
    case imATeapot
    case authenticationTimeout
    case enhanceYourCalm
    case unprocessableEntity
    case locked
    case failedDependency
    case preconditionRequired
    case tooManyRequests
    case requestHeaderFieldsTooLarge
}

extension ClientError {
    internal var httpCode: HTTPCode {
        switch self {
        case .badRequest: return .badRequest
        case .unauthorized: return .unauthorized
        case .paymentRequired: return .paymentRequired
        case .forbidden: return .forbidden
        case .notFound: return .notFound
        case .methodNotAllowed: return .methodNotAllowed
        case .notAcceptable: return .notAcceptable
        case .proxyAuthenticationRequired: return .proxyAuthenticationRequired
        case .requestTimeout: return .requestTimeout
        case .conflict: return .conflict
        case .gone: return .gone
        case .lengthRequired: return .lengthRequired
        case .preconditionFailed: return .preconditionFailed
        case .requestEntityTooLarge: return.requestEntityTooLarge
        case .requestURITooLong: return.requestURITooLong
        case .unsupportedMediaType: return.unsupportedMediaType
        case .requestedRangeNotSatisfiable: return .requestedRangeNotSatisfiable
        case .expectationFailed: return.expectationFailed
        case .imATeapot: return.imATeapot
        case .authenticationTimeout: return.authenticationTimeout
        case .enhanceYourCalm: return.enhanceYourCalm
        case .unprocessableEntity: return.unprocessableEntity
        case .locked: return.locked
        case .failedDependency: return.failedDependency
        case .preconditionRequired: return.preconditionRequired
        case .tooManyRequests: return.tooManyRequests
        case .requestHeaderFieldsTooLarge: return.requestHeaderFieldsTooLarge
        }
    }
}

internal enum ServerError: HTTPError, CaseIterable {
    case internalServerError
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported
    case variantAlsoNegotiates
    case insufficientStorage
    case loopDetected
    case notExtended
    case networkAuthenticationRequired
}

extension ServerError {
    internal  var httpCode: HTTPCode {
        switch self {
        case .internalServerError: return.internalServerError
        case .notImplemented: return.notImplemented
        case .badGateway: return.badGateway
        case .serviceUnavailable: return.serviceUnavailable
        case .gatewayTimeout: return.gatewayTimeout
        case .httpVersionNotSupported: return.httpVersionNotSupported
        case .variantAlsoNegotiates: return.variantAlsoNegotiates
        case .insufficientStorage: return.insufficientStorage
        case .loopDetected: return.loopDetected
        case .notExtended: return.notExtended
        case .networkAuthenticationRequired: return .networkAuthenticationRequired
        }
    }
}
*/
