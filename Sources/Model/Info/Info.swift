//
//  Info.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 24/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct Info {
    public var cacheSize: Double
    public var usedCache: Double
    public var entitySetCount: Int

    public var sessions: [SessionInfo] = []
    public var progress: [ProgressInfo] = []
    public var entitySet: [EntitySet] = []
}

// MARK: Codable
extension Info: Codable {}

// MARK: JSONable
extension Info: JSONDecodable {
    public init?(json: JSON) {
        cacheSize = json["cacheSize"].doubleValue
        usedCache = json["usedCache"].doubleValue
        entitySetCount = json["entitySetCount"].intValue

        sessions = json["sessionInfo"].arrayValue.map { SessionInfo(json: $0)! }
        progress = json["ProgressInfo"].arrayValue.map { ProgressInfo(json: $0)! }
        entitySet = json["entitySet"].arrayValue.map { EntitySet(json: $0)! }
    }
}

// MARK: DictionaryConvertible
extension Info: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["cacheSize"] = self.cacheSize
        dictionary["usedCache"] = self.usedCache
        dictionary["entitySetCount"] = self.entitySetCount
        dictionary["sessionInfo"] = self.sessions.map { $0.dictionary }
        dictionary["ProgressInfo"] = self.progress.map { $0.dictionary }
        dictionary["entitySet"] = self.entitySet.map { $0.dictionary }
        return dictionary
    }
}

// MARK: Equatable
extension Info: Equatable {
    public static func == (lhf: Info, rhf: Info) -> Bool {
        return lhf.cacheSize == rhf.cacheSize &&
            lhf.usedCache == rhf.usedCache &&
            lhf.entitySetCount == rhf.entitySetCount &&
            lhf.sessions == rhf.sessions  &&
            lhf.progress == rhf.progress &&
            lhf.entitySet == rhf.entitySet
    }
}
