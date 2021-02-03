//
//  AppUpdateChecker.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 27/11/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

#if DEBUG // not used

import Foundation
import Moya
import Prephirences

public class ItunesAPI {
    // Lookup application in itunes store.
    public static func lookup(bundleId: String, completion: @escaping (Result<ItunesLookup, APIError>) -> Void) -> Cancellable? {
        let provider = MoyaProvider<ItunesTarget>()
        return provider.requestDecoded(.lookup(bundleId: bundleId), completion: completion)
    }
}

public enum ItunesTarget {
    /// http://itunes.apple.com/lookup?bundleId=<bundleID>
    case lookup(bundleId: String)
}

extension ItunesTarget: TargetType {
    public var baseURL: URL {
        return URL(string: "https://itunes.apple.com")!
    }

    public var method: Moya.Method {
        return .get
    }

    public var sampleData: Data {
        return stubbedData("ituneslookup")
    }

    public var task: Task {
        switch self {
        case let .lookup(bundleId):
            return .requestParameters(parameters: ["bundleId": bundleId], encoding: URLEncoding.queryString)
        }
    }

    public var headers: [String: String]? {
        return nil
    }

   public var path: String {
        switch self {
        case .lookup:
            return "lookup"
        }
    }
}

extension ItunesTarget: DecodableTargetType {
    public typealias ResultType = ItunesLookup
}

/// One result of itunes lookup request.
public struct ItunesLookupItem {
    public var bundleId: String?
    public var trackViewUrl: String?
    public var version: String?
    public var kind: String?
    public var description: String?
    public var artistName: String?
    public var trackId: Int?
    public var trackName: String?
    public var releaseDate: Date?
    public var releaseNote: String?
    public var currentVersionReleaseDate: Date?
    public var minimumOsVersion: String?
    public var supportedDevices: [String]?
    public var screenshotUrls: [URL]?
}

/// Results of itunes lookup request.
public struct ItunesLookup {
    public var resultCount: Int
    public var results: [ItunesLookupItem]
}

extension ItunesLookup: JSONDecodable {
    public init?(json: JSON) {
        resultCount = json["resultCount"].intValue
        results = json["results"].arrayValue.compactMap { ItunesLookupItem(json: $0) }
    }
}

extension ItunesLookup: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["resultCount"] = self.resultCount
        dictionary["results"] = self.results.map { $0.dictionary }
        return dictionary
    }
}

extension ItunesLookupItem: JSONDecodable {
    public init?(json: JSON) {
        bundleId = json["bundleId"].stringValue
        trackViewUrl = json["trackViewUrl"].stringValue
        version = json["version"].stringValue
        kind = json["kind"].stringValue
        artistName = json["artistName"].stringValue
        description = json["description"].stringValue
        trackId = json["trackId"].intValue
        trackName = json["trackName"].stringValue
        trackViewUrl = json["trackViewUrl"].stringValue
        releaseDate = json["releaseDate"].stringValue.dateFromRFC3339
        releaseNote = json["releaseNote"].stringValue
        currentVersionReleaseDate = json["currentVersionReleaseDate"].stringValue.dateFromRFC3339
        minimumOsVersion = json["minimumOsVersion"].stringValue
        supportedDevices = json["supportedDevices"].map { $0.1.stringValue }
        screenshotUrls = json["screenshotUrls"].compactMap { $0.1.url }
    }
}

extension ItunesLookupItem: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["trackViewUrl"] = self.trackViewUrl
        dictionary["version"] = self.version
        dictionary["kind"] = self.kind
        dictionary["minimumOsVersion"] = self.minimumOsVersion
        dictionary["supportedDevices"] = self.supportedDevices
        dictionary["currentVersionReleaseDate"] = self.currentVersionReleaseDate
        // TO DO
        return dictionary
    }
}

extension ItunesLookupItem {
    public var applicationInfo: ApplicationInfo {
        return ApplicationInfo(
            bundleId: self.bundleId,
            name: self.trackName,
            id: self.trackId,
            description: self.description,
            viewUrl: self.trackViewUrl,
            minimumOsVersion: self.minimumOsVersion,
            supportedDevices: self.supportedDevices ?? [],
            version: self.version,
            currentVersionReleaseDate: self.currentVersionReleaseDate,
            releaseNote: self.releaseNote)
    }
}
#endif
