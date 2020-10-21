//
//  ActionResult.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 01/03/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import Foundation

/// Authentication token.
public struct ActionResult {

    /// The JSON representation
    public let json: JSON

    /// Operation success or not.
    public var success: Bool

    /// Create an instance from raw data
    public init(success: Bool, json: JSON) {
        self.success = success
        self.json = json
    }

    public static let emptySuccess = ActionResult(success: true, json: JSON())
    public static let emptyFailure = ActionResult(success: false, json: JSON())
}

extension ActionResult {
    /// Will return the raw value for specified key.
    subscript(_ key: String) -> Any? {
        return json[key].rawValue
    }

    /// Optionnal status message
    public var statusText: String? {
        return json["statusText"].string
    }

    ///  Close event if there is errors
    public var close: Bool {
        return json["close"].boolValue
    }

    public var errors: [Any]? {
        return json["errors"].arrayObject
    }
}

// MARK: JSON
extension ActionResult: JSONDecodable {
    public init?(json: JSON) {
        self.json = json
        self.success = json["success"].boolValue
        // XXX decode here known values
    }
}

// MARK: Equatable
extension ActionResult: Equatable {
    public static func == (lhf: ActionResult, rhf: ActionResult) -> Bool {
        return lhf.json == rhf.json
    }
}

extension ActionResult: Codable {

}
