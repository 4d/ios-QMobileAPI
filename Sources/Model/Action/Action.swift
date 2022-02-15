//
//  Action.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 01/03/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import Foundation

/// Represent a mobile action sent 4D server.
public struct Action {

    /// An empty action without name and parameters.
    static let empty =  Action(name: "")

    /// Id of the action
    public let name: String

    /// Localized name to display
    public let label: String?

    /// Short localized name to display
    public let shortLabel: String?

    /// Information about icon
    public let icon: String?

    /// Preset data: edit, share, adding, sort
    @OptionalDecodable public var preset: ActionPreset?

    /// Action style.
    public let style: ActionStyle?

    /// Action style.
    public let parameters: [ActionParameter]?

    /// Scope
    public let scope: String?

    /// Table Name if scope need it
    public let tableName: String?

    public init(name: String, label: String? = nil, shortLabel: String? = nil, icon: String? = nil, preset: ActionPreset? = nil, style: ActionStyle? = nil, parameters: [ActionParameter] = [], scope: String? = nil, tableName: String? = nil) {
        self.name = name
        self.label = label
        self.shortLabel = shortLabel
        self.icon = icon
        self.preset = preset
        self.style = style
        self.parameters = parameters
        self.scope = scope
        self.tableName = tableName
    }

    // MARK: computed properties

    /// Return long label if any, then short label and finally name
    public var preferredLongLabel: String {
        return self.label ??? self.shortLabel ??? self.name
    }

    /// Return short label if any, then long label and finally name
    public var preferredShortLabel: String {
        return self.shortLabel ??? self.label ??? self.name
    }

    /// Return `true` if must be online.
    public var isOnlineOnly: Bool {
        return self.preset?.isOnlineOnly ?? self.style?.isOnlineOnly ?? false // we use preset until there maybe a JSON data to force it
    }
}

/// Action preset that could change the default behaviour.
public enum ActionPreset: String, Codable {
    /// Attempt to create a new record/entity
    case add
    /// Edit a record/entity
    case edit
    /// Delete a record/entity
    case delete
    /// Share current entity asking a link from server
    case share
    /// Sort locally the record (no remote request)
    case sort
    /// Display an url
    case url

    var isOnlineOnly: Bool {
        return self == .share
    }

    /// Action executed in local mobile phone, not on remote server
    public var isLocal: Bool {
        return self == .sort
    }
}

/// Description of type of opeation
public enum ActionStyle {
    /// Normal style.
    case normal
    /// Operation which delete/destroy somethings.
    case destructive
    /// Custom style.
    case custom([String: Any])
}

public extension ActionStyle {
    /// If custom style, 
    var properties: [String: Any]? {
        switch self {
        case .custom(let properties):
            return properties
        default:
            return nil
        }
    }

    var isOnlineOnly: Bool {
        switch self {
        case .custom(let properties):
            return properties["onlineOnly"] as? Bool ?? false
        default:
            return false
        }
    }
}

// MARK: - Codable
extension Action: Codable {}
extension ActionStyle: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            if string == "normal" {
                self = .normal
            } else if string ==  "destructive"{
                self = .destructive
            } else {
                self = .normal
            }
        } else {
            let container = try decoder.container(keyedBy: DynamicKey.self)
            let properties = container.decodeDynamicKeyValues()
            self = .custom(properties)
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .destructive:
            var container = encoder.singleValueContainer()
            try container.encode("destructive")
        case .normal:
            var container = encoder.singleValueContainer()
            try container.encode("normal")
        case .custom(let properties):
            var container = encoder.container(keyedBy: DynamicKey.self)
            try container.encodeDynamicKeyValues(withDictionary: properties)
        }
    }
}

// MARK: JSON
extension Action: JSONDecodable {
    public init?(json: JSON) {
        // mandatory
        guard let name = json["name"].string else {
            logger.warning("No name \(json)")
            return nil
        }
        self.name = name
        self.icon = json["icon"].string
        self.preset = ActionPreset(rawValue: json["preset"].stringValue)
        self.style = ActionStyle(json: json["style"])
        self.label = json["label"].string ?? name
        self.shortLabel = json["shortLabel"].string ?? name
        self.parameters = json["parameters"].array(of: ActionParameter.self) ?? []
        self.scope = json["scope"].string
        self.tableName = json["tableName"].string
    }
}

extension ActionStyle: JSONDecodable {
    public init?(json: JSON) {
        if let string = json.string {
            switch string {
            case "normal": self = .normal
            case "destructive": self = .destructive
            default: return nil
            }
        } else if let properties = json.dictionaryObject {
            self = .custom(properties)
        }
        return nil
    }
}

// MARK: Key
extension Action: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dico: DictionaryConvertible.Dico = ["name": name]
        if let label = label {
            dico["label"] = label
        }
        if let shortLabel = shortLabel {
            dico["shortLabel"] = shortLabel
        }
        if let icon = icon {
            dico["icon"] = icon
        }
        if let preset = preset {
            dico["preset"] = preset.rawValue
        }
        if let parameters = parameters {
            dico["parameters"] = parameters.map { $0.dictionary } // XXX not a pure json
        }
        if let style = style {
            dico["style"] = style.dictionary // XXX not a pure json
        }
        if let scope = scope {
            dico["scope"] = scope
        }
        if let tableName = tableName {
            dico["tableName"] = tableName
        }
        return dico
    }
}

extension ActionStyle: DictionaryConvertible {

    public var dictionary: DictionaryConvertible.Dico {
        switch self {
        case .normal:
            return ["normal": true] // CLEAN: not exactly expected json
        case .destructive:
            return ["destructive": true]
        case .custom(let dico):
            return dico
        }
    }

    public var json: JSON {
        switch self {
        case .normal:
            return JSON("normal")
        case .destructive:
            return JSON("destructive")
        case .custom(let dico):
            return JSON(dico)
        }
    }
}

// MARK: Equatable
extension Action: Equatable {
    public static func == (lhf: Action, rhf: Action) -> Bool {
        return lhf.name == rhf.name
    }
}
