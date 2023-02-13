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
    /// Id of the action
    public let name: String

    /// Localized name to display
    public let label: String?

    /// Short localized name to display
    public let shortLabel: String?

    /// Information about icon
    public let icon: String?

    /// Action style.
    public let style: ActionStyle?

    /// Action style.
    public let parameters: [ActionParameter]?

    public init(name: String, label: String? = nil, shortLabel: String? = nil, icon: String? = nil, style: ActionStyle? = nil, parameters: [ActionParameter] = []) {
        self.name = name
        self.label = label
        self.shortLabel = shortLabel
        self.icon = icon
        self.style = style
        self.parameters = parameters
    }
}

extension Action {
    public var preferredLongLabel: String {
        return self.label ??? self.shortLabel ??? self.name
    }

    public var preferredShortLabel: String {
        return self.shortLabel ??? self.label ??? self.name
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
        self.style = ActionStyle(json: json["style"])
        self.label = json["label"].string ?? name
        self.shortLabel = json["shortLabel"].string ?? name
        self.parameters = json["parameters"].array(of: ActionParameter.self) ?? []
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
        if let parameters = parameters {
            dico["parameters"] = parameters.map { $0.dictionary } // XXX not a pure json
        }
        if let style = style {
            dico["style"] = style.dictionary // XXX not a pure json
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
