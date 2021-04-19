//
//  AuthToken.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/03/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//

import Foundation

/// Authentication token.
public struct AuthToken {
    /// Session id
    public let id: String
    /// Optionnal status message
    public let statusText: String?
    /// Token
    public let token: String?
    /// Additional information
    public let userInfo: [String: Any]?

    /// Create a token with known attributes
    public init(id: String, statusText: String?, token: String?, userInfo: [String: Any]? = nil) {
        self.id = id
        self.token = token
        self.userInfo = userInfo
        self.statusText = statusText
    }
}

extension CodingKey {
    static func container(decoder: Decoder) throws -> KeyedDecodingContainer<Self> {
        return try decoder.container(keyedBy: Self.self)
    }

    static func container(encoder: Encoder) -> KeyedEncodingContainer<Self> {
        return encoder.container(keyedBy: Self.self)
    }
}

// MARK: UserInfo
extension AuthToken {
    /// Return the origin email of token if any
    public var email: String? {
        return userInfo?["email"] as? String
    }
}

// MARK: JSON
extension AuthToken: Codable {
    enum CodingKeys: String, CodingKey {
        case id, token, statusText, userInfo
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.token = try container.decode(String.self, forKey: .token)
        self.statusText = try container.decode(String.self, forKey: .statusText)
        self.userInfo = try container.decode(JSON.self, forKey: .userInfo).dictionaryObject
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(token, forKey: .token)
        try container.encode(statusText, forKey: .statusText)
        try container.encode(self.userInfo?.json, forKey: .userInfo)
    }
}

// MARK: JSON
extension AuthToken: JSONDecodable {
    /// Create a token with information stored in JSON format.
    public init?(json: JSON) {
        guard let id = json["id"].string else {
            return nil // invalid token
        }
        self.id = id
        self.statusText = json["statusText"].string
        self.token = json["token"].string
        self.userInfo = json["userInfo"].dictionaryObject
    }
}

// MARK: DictionaryConvertible
extension AuthToken: DictionaryConvertible {
    /// Return a dictionary with all information inside token
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["id"] = self.id
        if let statusText = self.statusText {
            dictionary["statusText"] = statusText
        }
        if let token = self.token {
            dictionary["token"] = token
        }
        if let userInfo = self.userInfo {
            dictionary["userInfo"] = userInfo
        }

        return dictionary
    }
}

// MARK: Equatable
extension AuthToken: Equatable {
    public static func == (lhf: AuthToken, rhf: AuthToken) -> Bool {
        return lhf.token == rhf.token && lhf.id == rhf.id
    }
}

// MARK: JWTToken

extension AuthToken {
    /// `true` if there is a valid token.
    public var isValidToken: Bool {
        guard let token = self.token else {
            return false
        }
        if token.isEmpty {
            return false
        }
        return true // self.token?.components(separatedBy: ".").count == 3
    }

    /// Is expired token. (for know we will check only if valid.
    public var isExpiredToken: Bool {
        return isValidToken // TODO : if token contains expiration information, implement isExpiredToken
    }

    /*public var header: [String: JSON]? {
        guard let token = self.token else {
            return nil
        }
        let part = token.components(separatedBy: ".")
        guard part.count == 3 else {
            return nil
        }
        guard let base64Decoded = part.first?.base64DecodedData else {
            return nil
        }
        do {
            return try JSON(data: base64Decoded).dictionaryValue
        } catch {
            return nil
        }
    }

    public var payload: [String: JSON]? {
        guard let token = self.token else {
            return nil
        }
        let part = token.components(separatedBy: ".")
        guard part.count == 3 else {
            return nil
        }
        guard let base64Decoded = part.second?.base64DecodedData else {
            return nil
        }
        do {
            return try JSON(data: base64Decoded).dictionaryValue
        } catch {
            return nil
        }
    }

    public var signature: String? {
        guard let token = self.token else {
            return nil
        }
        let part = token.components(separatedBy: ".")
        guard part.count == 3 else {
            return nil
        }
        return part[2]
    }*/
}
