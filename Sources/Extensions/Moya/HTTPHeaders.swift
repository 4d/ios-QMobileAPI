//
//  HTTPHeaders.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 31/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public enum HTTPRequestHeader: String {
    case accept = "Accept"
    case acceptCharset = "Accept-Charset"
    case acceptEncoding = "Accept-Encoding"
    case acceptLanguage = "Accept-Language"
    case acceptDatetime = "Accept-Datetime"
    case authorization = "Authorization"
    case cacheControl = "Cache-Control"
    case connection = "Connection"
    case cookie = "Cookie"
    case contentLength = "Content-Length"
    case contentMD5 = "Content-MD5"
    case contentType = "Content-Type"
    case date = "Date"
    case expect = "Expect"
    case forwarded = "Forwarded"
    case from = "From"
    case host = "Host"
    case ifMatch = "If-Match"
    case ifModifiedSince = "If-Modified-Since"
    case ifNoneMatch = "If-None-Match"
    case ifRange = "If-Range"
    case ifUnmodifiedSince = "If-Unmodified-Since"
    case maxForwards = "Max-Forwards"
    case origin = "Origin"
    case pragma = "Pragma"
    case proxyAuthorization = "Proxy-Authorization"
    case range = "Range"
    case referer  = "Referer"
    case tE = "TE"
    case userAgent = "User-Agent"
    case upgrade = "Upgrade"
    case via = "Via"
    case warning = "Warning"
}

extension URLRequest {
    mutating func setValue(_ value: String?, forHTTPHeaderField header: HTTPRequestHeader) {
        self.setValue(value, forHTTPHeaderField: header.rawValue)
    }
}

public enum HTTPResponseHeader: String {
    case accessControlAllowOrigin = "Access-Control-Allow-Origin"
    case acceptPatc = "Accept-Patc"
    case acceptRanges = "Accept-Ranges"
    case age = "Age"
    case allow = "Allow"
    case altSv = "Alt-Sv"
    case cacheControl = "Cache-Control"
    case connection = "Connection"
    case contentDisposition = "Content-Disposition"
    case contentEncoding = "Content-Encoding"
    case contentLanguage = "Content-Language"
    case contentLength = "Content-Length"
    case contentLocation = "Content-Location"
    case contentMD5 = "Content-MD5"
    case contentRange = "Content-Range"
    case contentType = "Content-Type"
    case date = "Date"
    case eTag = "ETag"
    case expires = "Expires"
    case lastModified = "Last-Modified"
    case link = "Link"
    case location = "Location"
    case p3P = "P3P"
    case pragma = "Pragma"
    case proxyAuthenticate = "Proxy-Authenticate"
    case publicKeyPin = "Public-Key-Pin"
    case refresh = "Refresh"
    case retryAfter = "Retry-After"
    case server = "Server"
    case setCookie = "Set-Cookie"
    case status = "Status"
    case strictTransportSecurity = "Strict-Transport-Security"
    case trailer = "Trailer"
    case transferEncoding = "Transfer-Encoding"
    case tSV = "TSV"
    case upgrade = "Upgrade"
    case vary = "Vary"
    case via = "Via"
    case warning = "Warning"
    case wWWAuthenticate = "WWW-Authenticate"

    case restInfo = "4drest-Info"
}
