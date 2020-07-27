//
//  ActionParameter.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/04/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import Foundation

/// Parameter of `Action`
public struct ActionParameter {

    /// Id of the parameter
    public let name: String

    /// Type of this parameter
    public let type: ActionParameterType

    /// Localized name to display
    public let label: String?

    /// Short localized name to display
    public let shortLabel: String?

    /// Information about icon
    public let icon: String?

    /// Action parameter format.
    public let format: ActionParameterFormat?

    /// Default value
    public let `default`: AnyCodable?
    /// Bind default value to a field.
    public let defaultField: String?

    /// Placeholder
    public let placeholder: String?

    public let choiceList: AnyCodable?
    //public let choiceType: ActionChoiceType?

    public let rules: [ActionParameterRule]?

}
/*
enum ActionChoiceType {
 case push, segmented, popover
}
*/
extension ActionParameter {

    // shortcut to known if there is a .mandatory rule
    public var mandatory: Bool {
        return rules?.contains(where: { rule in
            if case .mandatory = rule {
                return true
            }
            return false
        }) ?? false
    }
}

/// Rules to fill action parameter.
public enum ActionParameterRule {
    public typealias Comparable = Double
    case mandatory
    case min(Comparable)
    case max(Comparable)
    case minLength(Int)
    case maxLength(Int)
    case exactLength(Int)
    case regex(String)
}

extension ActionParameter {
    public var preferredLongLabel: String {
        return self.label ??? self.shortLabel ??? self.name
    }

    public var preferredShortLabel: String {
        return self.shortLabel ??? self.label ??? self.name
    }
}

public enum ActionParameterFormat: String, Equatable {

    case email // , emailAddress
    case url //, link
    case phone // , phoneNumber
    case password
    case zipCode
    case textArea, comment

    /// capitalized text
    case name
    case account

    case integer
    case spellOut
    case scientific
    case percent

    case rating
    case stepper
    case slider

    case check // bool
    case `switch` // bool

    case energy
    case mass

    case duration // time

    case shortDate
    case longDate
    case mediumDate
    case fullDate

}

/// Type of parameters.
public enum ActionParameterType: String, Equatable {
    case string, text
    case number, real
    case integer
    case bool, boolean
    case date
    case time
    case picture, image
    case file, blob
}

// MARK: - Codable
extension ActionParameter: Codable {

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.label = try? values.decode(String.self, forKey: .label)
        self.shortLabel = try? values.decode(String.self, forKey: .shortLabel)
        self.icon = try? values.decode(String.self, forKey: .icon)
        self.type = try values.decode(ActionParameterType.self, forKey: .type)
        self.format = try? values.decode(ActionParameterFormat.self, forKey: .format)
        self.`default` = try? values.decode(AnyCodable.self, forKey: .`default`)
        self.defaultField = try? values.decode(String.self, forKey: .defaultField)
        self.placeholder = try? values.decode(String.self, forKey: .placeholder)
        self.choiceList = try? values.decode(AnyCodable.self, forKey: .choiceList)
        self.rules = try? values.decode([ActionParameterRule].self, forKey: .rules)
    }
}
extension ActionParameterType: Codable {}
extension ActionParameterFormat: Codable {}

extension ActionParameterRule: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            if let rule = ActionParameterRule.from(name: string) {
                self = rule
            } else {
                throw JSONError.wrongType
            }
        } else {
            let container = try decoder.container(keyedBy: DynamicKey.self)
            let properties = container.decodeDynamicKeyValues()
            if let rule = ActionParameterRule.from(dictionary: properties) {
                self = rule
            } else {
                throw JSONError.wrongType
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .mandatory:
            var container = encoder.singleValueContainer()
            try container.encode("mandatory")
        default:
            var container = encoder.container(keyedBy: DynamicKey.self)
            try container.encodeDynamicKeyValues(withDictionary: self.dictionary)
        }
    }

    fileprivate static func from(dictionary: [String: Any]) -> ActionParameterRule? {
        // XXX CLEAN generic code for comparable?
        if let min = dictionary["min"] as? Double {
            return .min(min)
        } else if let max = dictionary["max"] as? Double {
            return .max(max)
        } else  if let min = dictionary["min"] as? Int {
            return .min(Double(min))
        } else if let max = dictionary["max"] as? Int {
            return .max(Double(max))
        } else if let length = dictionary["minLength"] as? Int {
            return .minLength(length)
        } else if let length = dictionary["maxLength"] as? Int {
            return .maxLength(length)
        } else if let length = dictionary["exactLength"] as? Int {
            return .exactLength(length)
        } else if let value = dictionary["mandatory"] as? Bool, value {
            return .mandatory
        } else if let value = dictionary["regex"] as? String, !value.isEmpty {
            return .regex(value)
        } else {
            return nil
        }
    }

    fileprivate static func from(name: String) -> ActionParameterRule? {
        switch name {
        case "mandatory":
            return .mandatory
        default:
            return nil
        }
    }

}

extension ActionParameterRule: JSONDecodable {

    public init?(json: JSON) {
        if let name = json.string, let rule = ActionParameterRule.from(name: name) {
            self = rule
        } else if let dictionary = json.dictionaryObject, let rule = ActionParameterRule.from(dictionary: dictionary) {
            self = rule
        } else {
            return nil
        }
    }
}

// MARK: JSON
extension ActionParameter: JSONDecodable {
    public init?(json: JSON) {
        // mandatory
        guard let name = json["name"].string else {
            logger.warning("No name \(json)")
            return nil
        }
        self.name = name
        guard let type = ActionParameterType(json: json["type"]) else {
            logger.warning("No type in \(json)") // XXX or provide defaut type? string ??
            return nil
        }
        self.type = type
        self.icon = json["icon"].string
        self.format = ActionParameterFormat(json: json["format"])
        self.label = json["label"].string ?? name
        self.shortLabel = json["shortLabel"].string ?? name
        self.placeholder = json["placeholder"].string
        self.default = AnyCodable(json["default"].rawValue)
        self.defaultField = json["placeholder"].string
        self.rules = json["rules"].array(of: ActionParameterRule.self)
        self.choiceList = AnyCodable(json["choiceList"].rawValue)
    }
}

extension ActionParameter: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dico = ["name": name]
        if let label = label {
            dico["label"] = label
        }
        if let shortLabel = shortLabel {
            dico["shortLabel"] = shortLabel
        }
        // XXX complete encodable ActionParameter
        return dico
    }
}

extension ActionParameterType: JSONDecodable {
    public init?(json: JSON) {
        if let string = json.string, let type = ActionParameterType(rawValue: string) {
            self = type
        } else {
            return nil
        }
    }
}

extension ActionParameterFormat: JSONDecodable {
    public init?(json: JSON) {
        if let string = json.string, let type = ActionParameterFormat(rawValue: string) {
            self = type
        } else {
            return nil
        }
    }
}

extension ActionParameterRule: DictionaryConvertible {
    public var dictionary: ActionParameterRule.Dico {
        switch self {
        case .mandatory:
            return ["mandatory": true]
        case .min(let value):
            return ["min": value]
        case .max(let value):
            return ["max": value]
        case .minLength(let value):
            return ["minLength": value]
        case .maxLength(let value):
            return ["maxLength": value]
        case .exactLength(let value):
            return ["exactLength": value]
        case .regex(let value):
            return ["regex": value]
        }
    }

    public var json: JSON {
        switch self {
        case .mandatory:
            return JSON("mandatory")
        default:
            return JSON(self.dictionary)
        }
    }

}
