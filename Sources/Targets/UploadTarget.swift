//
//  UploadTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/05/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

// http://doc.wakanda.org/home2.en.html?&_ga=1.241951170.1945468140.1488380770#/HTTP-REST/Interacting-with-the-Server/upload.303-1158401.en.html

public class UploadTarget: ChildTargetType {
    let parentTarget: TargetType
    init(parentTarget: BaseTarget,
         provider: MultipartFormData.FormDataProvider,
         name: String = "name",
         fileName: String = "fileName",
         mimeType: String = MimeTypes.default
        ) {
        self.parentTarget = parentTarget
        self.provider = provider
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }

    let provider: MultipartFormData.FormDataProvider
    private let multipart = false // seems to be not supported
    public let name: String
    public let fileName: String
    public let mimeType: String
    public var timeout: Int? // default 120s on server

    var contentType: String?
    var rawPict: Any?

    let childPath = "$upload"

    public let method = Moya.Method.post

    public var parameters: [String: String]? {
        var parameters: [String: String] = [:]
        if rawPict != nil {
            parameters ["$rawPict"] = "true" // XXX maybe allow set rawpicy format if strings
        } // else  binary = true?
        if let timeout = timeout {
            parameters ["$timeout"] = "\(timeout)"
        }
        return parameters.isEmpty ? nil: parameters
    }

    public var task: Task {
        if multipart {
            if let parameters = parameters {
                return .uploadCompositeMultipart(multipartBody, urlParameters: parameters) // seems to be not supported
            }
            return .uploadMultipart(multipartBody)
        } else if let bodyData = bodyData {
            if let parameters = parameters {
                return .requestCompositeData(bodyData: bodyData, urlParameters: parameters)
            }
            return .requestData(bodyData)
        } else { // no data
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            }
            return .requestPlain
        }
    }

    public var sampleData: Data {
        return stubbedData("restupload")
    }

    public var bodyData: Data? {
        switch provider {
        case .data(let data):
            return data
        case .file(let url):
            return try? Data(contentsOf: url)
        default:
            return nil // not implemented
        }
    }

    public var multipartBody: [MultipartFormData] {
        return [
            MultipartFormData(provider: provider, name: name, fileName: fileName, mimeType: mimeType)
        ]
    }

    // The headers to used in the request.
    public var headers: [String: String]? {
        if let contentType = contentType {
            return ["Content-Type": contentType]
        } else if !mimeType.isEmpty {
            return ["Content-Type": mimeType]
        }
        return nil
    }
}
extension UploadTarget: DecodableTargetType {
    public typealias ResultType = UploadResult
}

extension BaseTarget {
    public func upload(data: Data, image: Bool = false, mimeType: String?) -> UploadTarget {
        let target = UploadTarget(parentTarget: self, provider: .data(data), mimeType: mimeType ?? MimeTypes.default)
        if image {
            target.rawPict = "true"
        }
        return target
    }

    public func upload(url: URL) -> UploadTarget {
        assert(url.isFileURL)
        let mimeType = url.mimeType()
        let target = UploadTarget(parentTarget: self, provider: .file(url), mimeType: mimeType)
        if MimeTypes.isCategory(.image, mimeType) {
            target.rawPict = mimeType
        }
        return target
    }
}

struct MimeTypes {
   enum Category: String {
        case text
        case image
        case application
        case audio
    }

    static let `default` = "application/octet-stream"

    static let extensionMapping = [
        "html": "text/html",
        "htm": "text/html",
        "shtml": "text/html",
        "css": "text/css",
        "xml": "text/xml",
        "gif": "image/gif",
        "jpeg": "image/jpeg",
        "jpg": "image/jpeg",
        "heif": "image/heif",
        "heic": "image/heic",
        "js": "application/javascript",
        "atom": "application/atom+xml",
        "rss": "application/rss+xml",
        "mml": "text/mathml",
        "txt": "text/plain",
        "jad": "text/vnd.sun.j2me.app-descriptor",
        "wml": "text/vnd.wap.wml",
        "htc": "text/x-component",
        "png": "image/png",
        "tif": "image/tiff",
        "tiff": "image/tiff",
        "wbmp": "image/vnd.wap.wbmp",
        "ico": "image/x-icon",
        "jng": "image/x-jng",
        "bmp": "image/x-ms-bmp",
        "svg": "image/svg+xml",
        "svgz": "image/svg+xml",
        "webp": "image/webp",
        "woff": "application/font-woff",
        "jar": "application/java-archive",
        "war": "application/java-archive",
        "ear": "application/java-archive",
        "json": "application/json",
        "hqx": "application/mac-binhex40",
        "doc": "application/msword",
        "pdf": "application/pdf",
        "ps": "application/postscript",
        "eps": "application/postscript",
        "ai": "application/postscript",
        "rtf": "application/rtf",
        "m3u8": "application/vnd.apple.mpegurl",
        "xls": "application/vnd.ms-excel",
        "eot": "application/vnd.ms-fontobject",
        "ppt": "application/vnd.ms-powerpoint",
        "wmlc": "application/vnd.wap.wmlc",
        "kml": "application/vnd.google-earth.kml+xml",
        "kmz": "application/vnd.google-earth.kmz",
        "7z": "application/x-7z-compressed",
        "cco": "application/x-cocoa",
        "jardiff": "application/x-java-archive-diff",
        "jnlp": "application/x-java-jnlp-file",
        "run": "application/x-makeself",
        "pl": "application/x-perl",
        "pm": "application/x-perl",
        "prc": "application/x-pilot",
        "pdb": "application/x-pilot",
        "rar": "application/x-rar-compressed",
        "rpm": "application/x-redhat-package-manager",
        "sea": "application/x-sea",
        "swf": "application/x-shockwave-flash",
        "sit": "application/x-stuffit",
        "tcl": "application/x-tcl",
        "tk": "application/x-tcl",
        "der": "application/x-x509-ca-cert",
        "pem": "application/x-x509-ca-cert",
        "crt": "application/x-x509-ca-cert",
        "xpi": "application/x-xpinstall",
        "xhtml": "application/xhtml+xml",
        "xspf": "application/xspf+xml",
        "zip": "application/zip",
        "bin": "application/octet-stream",
        "exe": "application/octet-stream",
        "dll": "application/octet-stream",
        "deb": "application/octet-stream",
        "dmg": "application/octet-stream",
        "iso": "application/octet-stream",
        "img": "application/octet-stream",
        "msi": "application/octet-stream",
        "msp": "application/octet-stream",
        "msm": "application/octet-stream",
        "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        "mid": "audio/midi",
        "midi": "audio/midi",
        "kar": "audio/midi",
        "mp3": "audio/mpeg",
        "ogg": "audio/ogg",
        "m4a": "audio/x-m4a",
        "ra": "audio/x-realaudio",
        "3gpp": "video/3gpp",
        "3gp": "video/3gpp",
        "ts": "video/mp2t",
        "mp4": "video/mp4",
        "mpeg": "video/mpeg",
        "mpg": "video/mpeg",
        "mov": "video/quicktime",
        "webm": "video/webm",
        "flv": "video/x-flv",
        "m4v": "video/x-m4v",
        "mng": "video/x-mng",
        "asx": "video/x-ms-asf",
        "asf": "video/x-ms-asf",
        "wmv": "video/x-ms-wmv",
        "avi": "video/x-msvideo"
    ]

    static func mimeType(for ext: String) -> String {
        return extensionMapping[ext.lowercased()] ?? MimeTypes.default
    }

    static func isCategory(_ category: MimeTypes.Category, _ mimeType: String) -> Bool {
        return mimeType.hasPrefix("\(category.rawValue)/")
    }
}

extension URL {
    func mimeType() -> String {
        return MimeTypes.mimeType(for: self.pathExtension)
    }
}
