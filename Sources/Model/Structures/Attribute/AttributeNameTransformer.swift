//
//  AttributeNameTransformer.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 14/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Defines rules to transform name from JSON to CoreData
public struct AttributeNameTransformer {
    /// An info name
    public var name: String
    /// Map to the wanted field
    public var decode: (String) -> String = { $0 }
    /// Encode for network
    public var encode: (String) -> String = { $0 }
    /// Transformer could manage this case
    public var couldManage: (String) -> Bool = { _ in false }

    @nonobjc public static var suffixForReserved = "_"
    @nonobjc public static var reservedSwiftVars = [
        "entity", "objectID", "description", "shortDescription",
        "isDeleted", "isUpdated", "isInserted", "isFault",
        "hasChanges", "hasPersistentChangedValues",
        "public", "private", "init"
    ]

    @nonobjc public static var suffixForServerReserved = "qmobile"

    /// Init a transformer passing closures.
    public init(name: String, decode: @escaping (String) -> String, encode: @escaping (String) -> String, couldManage: @escaping (String) -> Bool = { _ in true }) {
        self.name = name
        self.decode = decode
        self.encode = encode
        self.couldManage = couldManage
    }

    public init(encoded: String, decoded: String, name: String? = nil) {
        self.init(name: name ?? encoded,
        decode: { _ -> String in
        decoded
        }, encode: { _ -> String in
        encoded
        })
    }

    /// Do not transform anything
    public static var none = AttributeNameTransformer(
        name: "none",
        decode: { key -> String in
            key
        }, encode: { key -> String in
        key
        }, couldManage: { key in
        key.isValidSwiftVar
        })

    /// Set first letter as lower case
    public static var firstLetterLowerCased = AttributeNameTransformer(
        name: "firstLetterLowerCased",
        decode: { key -> String in
            key.lowercasedFirstCharacter()
        }, encode: { key -> String in
        key.uppercasedFirstCharacter()
        }, couldManage: { key in
        if key.isFirstCharacterUppercased {
            let newKey = key.lowercasedFirstCharacter()
            return newKey.isValidSwiftVar
        }
        return false // let next manage
        })

    /// Apply some transformation to reserved language variable
    public static var runtimeReservedVariable = AttributeNameTransformer(
        name: "reservedVariable",
        decode: { key -> String in
            "\(key)\(suffixForReserved)"
        }, encode: { key -> String in
        key.removeSuffix(suffixForReserved)
        }, couldManage: { key in
        if AttributeNameTransformer.reservedSwiftVars.contains(key) {
            let newKey = "\(key)\(suffixForReserved)"
            return newKey.isValidSwiftVar
        }
        return false
        })
    /// A transformer to capitalize.
    public static var capitalizedRuntimeReservedVariable = AttributeNameTransformer(
        name: "capitalizedReservedVariable",
        decode: { key -> String in
            "\(key.lowercasedFirstCharacter())\(suffixForReserved)"
        }, encode: { key -> String in
        key.removeSuffix(suffixForReserved).uppercasedFirstCharacter()
        }, couldManage: { key in
        if AttributeNameTransformer.reservedSwiftVars.contains(key.lowercasedFirstCharacter()) {
            let newKey = "\(key.lowercasedFirstCharacter())\(suffixForReserved)"
            return newKey.isValidSwiftVar
        }
        return false
        })

/// A transformer to remove some reserved keyword.
    public static var serverReservedVariable = AttributeNameTransformer(
        name: "serverReservedVariable",
        decode: { key -> String in
            "\(suffixForServerReserved)\(key)"
    }, encode: { key -> String in
        key.removePrefix(suffixForServerReserved)
    }, couldManage: { key in
        return key.hasPrefix(RestKey.reserved)
    })

    /// List of all transfomers with specific orders, see find
    static let all: [AttributeNameTransformer] = [
        runtimeReservedVariable,
        capitalizedRuntimeReservedVariable,
        serverReservedVariable,
        firstLetterLowerCased,
        none]

    // Look the best transformer for var name
    static func find(for string: String) -> AttributeNameTransformer? {
        if string.contains(" ") {
            let temp = string.replacingOccurrences(of: " ", with: "")

            if let transformer = find(for: temp) {
                if transformer == .none {
                    let name = string+"space" // could add position of space
                    return AttributeNameTransformer(encoded: string, decoded: temp, name: name)
                } else {
                    return AttributeNameTransformer(
                        name: string,
                        decode: { _ -> String in
                            transformer.decode(temp)
                        }, encode: { _ -> String in
                        string
                        })
                }
            } else {
                return nil
            }
        }
        for transformer in AttributeNameTransformer.all {
            if transformer.couldManage(string) {
                return transformer
            }
        }
        return nil
    }
}

extension AttributeNameTransformer: Equatable {
    public static func == (lhs: AttributeNameTransformer, rhs: AttributeNameTransformer) -> Bool {
        return lhs.name == rhs.name // More solid impl could base on UUID
    }
}

extension Attribute {
    /// Encode attribute name to be safe for iOS.
    public var safeName: String {
        return nameTransformer.decode(name)
    }
}

// XXX remove Codable
extension AttributeNameTransformer: Codable {
    enum CodingKeys: String, CodingKey {
        case name
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
    }
}

// MARK: String

extension String {
    /// Check if a swift var
    var isValidSwiftVar: Bool {
        // Name must only contain letters, digits, or underscore with no spaces
        if !CharacterSet.alphanumericsUndescore.isSuperset(ofCharactersIn: self) {
            return false
        }
        // Name must begin with lower case letter  // Name must begin with a letter
        return self.isFirstCharacterLowercased && self.isFirstCharacterLetter
    }
}

extension String {
    func replacePrefix(_ prefix: String, replacement: String) -> String {
        if hasPrefix(prefix) {
            return replacement + self[prefix.endIndex...]
        } else {
            return self
        }
    }

    func removePrefix(_ prefix: String) -> String {
        if hasPrefix(prefix) {
            return String(self[prefix.endIndex...])
        } else {
            return self
        }
    }

    func removeSuffix(_ suffix: String) -> String {
        if hasSuffix(suffix) {
            return String(self[..<self.index(self.endIndex, offsetBy: -suffix.count)])
        } else {
            return self
        }
    }
}
