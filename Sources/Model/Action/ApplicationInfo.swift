//
//  ApplicationInfo.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/12/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Application information
public struct ApplicationInfo {
    public let bundleId: String?
    public let name: String?
    public let id: Int?
    public let description: String?
    public let viewUrl: String?

    /// Application requierement
    public let minimumOsVersion: String?
    public let supportedDevices: [String]

    /// Current version information
    public let version: String?
    public let currentVersionReleaseDate: Date?
    public let releaseNote: String?
}

extension ApplicationInfo: Codable {}

extension ApplicationInfo: JSONDecodable {
    public init?(json: JSON) {
        bundleId = json["bundleId"].stringValue
        name = json["name"].stringValue
        id = json["id"].intValue
        description = json["description"].stringValue
        viewUrl = json["viewUrl"].stringValue

        minimumOsVersion = json["minimumOsVersion"].stringValue
        supportedDevices = json["supportedDevices"].arrayValue.compactMap { $0.string }

        version = json["version"].stringValue
        currentVersionReleaseDate = json["currentVersionReleaseDate"].stringValue.dateFromRFC3339
        releaseNote = json["releaseNote"].stringValue

        /*if version.isEmpty || bundleId.isEmpty { // commented: let caller see how to manage this
            return nil
        }*/
    }
}

// MARK: DictionaryConvertible
extension ApplicationInfo: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["bundleId"] = self.bundleId
        dictionary["name"] = self.name
        dictionary["id"] = self.id
        dictionary["description"] = self.description
        dictionary["viewUrl"] = self.viewUrl

        dictionary["minimumOsVersion"] = self.minimumOsVersion
        dictionary["supportedDevices"] = self.supportedDevices

        dictionary["version"] = self.version
        dictionary["currentVersionReleaseDate"] = self.currentVersionReleaseDate
        dictionary["releaseNote"] = self.releaseNote
        return dictionary
    }
}

// MARK: Equatable
extension ApplicationInfo: Equatable {
    public static func == (lhf: ApplicationInfo, rhf: ApplicationInfo) -> Bool {
        return lhf.bundleId == rhf.bundleId && lhf.version == rhf.version
    }
}
