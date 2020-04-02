//
//  UserInfo.swift
//  QMobileAPI
//
//  Created by Quentin Marciset on 01/04/2020.
//  Copyright © 2020 Eric Marchand. All rights reserved.
//

import Foundation

/// Authentication token.
public struct UserInfoResult {

    /// The JSON representation
    public let json: JSON

    /// Operation success or not.
    public var success: Bool

}

extension UserInfoResult {
    /// Will return the raw value for specified key.
    subscript(_ key: String) -> Any? {
        return json[key].rawValue
    }

    public var errors: [Any]? {
        return json["__ERROR"].arrayObject
    }
}

// MARK: JSON
extension UserInfoResult: JSONDecodable {
    public init?(json: JSON) {
        self.json = json
        self.success = json["success"].boolValue
        // XXX decode here known values
    }
}

// MARK: Equatable
extension UserInfoResult: Equatable {
    public static func == (lhf: UserInfoResult, rhf: UserInfoResult) -> Bool {
        return lhf.json == rhf.json
    }
}
