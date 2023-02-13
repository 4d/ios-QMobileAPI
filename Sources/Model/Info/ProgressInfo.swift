//
//  ProgressInfo.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct ProgressInfo {
    public var userInfo: String
    public var sessionCount: Int
    public var title: String
    public var canInterrupt: Bool
}

// MARK: Codable
extension ProgressInfo: Codable {}

// MARK: JSON
extension ProgressInfo: JSONDecodable {
    public init?(json: JSON) {
        guard let myUserInfo = json["UserInfo"].string else {
            return nil
        }
        userInfo = myUserInfo
        sessionCount = json["SessionCount"].intValue
        title = json["Title"].stringValue
        canInterrupt = json["CanInterrupt"].boolValue
    }

    public static func array(json: JSON) -> [ProgressInfo]? {
        guard let arrayJSON = json["ProgressInfo"].array else {
            return nil
        }
        var sessions = [ProgressInfo]()
        for sessionJSON in arrayJSON {
            if let session = ProgressInfo(json: sessionJSON) {
                sessions.append(session)
            }
        }
        return sessions
    }
}

// MARK: DictionaryConvertible
extension ProgressInfo: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["UserInfo"] = self.userInfo
        dictionary["SessionCount"] = self.sessionCount
        dictionary["Title"] = self.title
        dictionary["CanInterrupt"] = self.canInterrupt
        return dictionary
    }
}

// MARK: Equatable
extension ProgressInfo: Equatable {
    public static func == (lhf: ProgressInfo, rhf: ProgressInfo) -> Bool {
        return lhf.userInfo == rhf.userInfo &&
            lhf.sessionCount == rhf.sessionCount &&
            lhf.title == rhf.title &&
            lhf.canInterrupt == rhf.canInterrupt
    }
}
