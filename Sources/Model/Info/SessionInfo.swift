//
//  SessionInfo.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct SessionInfo {
    var sessionID: String
    var lifeTime: Int
    var expiration: Date?
    var userName: String
}

// MARK: Codable
extension SessionInfo: Codable {}

// MARK: JSON
extension SessionInfo: JSONDecodable {
    public init?(json: JSON) {
        guard let id = json["sessionID"].string else {
            return nil
        }
        sessionID = id
        lifeTime = json["lifeTime"].intValue
        expiration = json["expiration"].date
        userName = json["userName"].stringValue
    }

    public static func array(json: JSON) -> [SessionInfo]? {
        guard let arrayJSON = json["sessionInfo"].array else {
            return nil
        }
        var sessions = [SessionInfo]()
        for sessionJSON in arrayJSON {
            if let session = SessionInfo(json: sessionJSON) {
                sessions.append(session)
            }
        }
        return sessions
    }
}

// MARK: DictionaryConvertible
extension SessionInfo: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["sessionID"] = self.sessionID
        dictionary["lifeTime"] = self.lifeTime
        dictionary["expiration"] = self.expiration
        dictionary["userName"] = self.userName
        return dictionary
    }
}

// MARK: Equatable
extension SessionInfo: Equatable {
    public static func == (lhf: SessionInfo, rhf: SessionInfo) -> Bool {
        return lhf.sessionID == rhf.sessionID &&
            lhf.lifeTime == rhf.lifeTime &&
            lhf.expiration == rhf.expiration &&
            lhf.userName == rhf.userName
    }
}
