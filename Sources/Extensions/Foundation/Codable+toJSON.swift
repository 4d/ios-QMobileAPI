//
//  Codable+toJSON.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 06/03/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import Foundation

extension Encodable {
    /// Encode object to json.
    public func toJSON(encoder: JSONEncoder = JSONEncoder()) -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension Decodable {
    /// Decode an object from json string.
    public static func decode(fromJSON string: String, decoder: JSONDecoder = JSONDecoder()) -> Self? {
        if string.isEmpty { return nil }
        guard let data = string.data(using: .utf8) else { return nil }
        do {
            return try decoder.decode(self, from: data)
        } catch {
            logger.warning("Cannot decode to \(self): \n \(string)\n \(error)")
            return nil
        }
    }
}

/// // Encode a model with properties of type [String : Any]
struct DynamicKey: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    var intValue: Int? { return nil }
    init?(intValue: Int) { return nil }
}

extension KeyedEncodingContainer where Key == DynamicKey {
    mutating func encodeDynamicKeyValues(withDictionary dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let dynamicKey = DynamicKey(stringValue: key)!
            switch value {
            case let v as String: try encode(v, forKey: dynamicKey)
            case let v as Int: try encode(v, forKey: dynamicKey)
            case let v as Double: try encode(v, forKey: dynamicKey)
            case let v as Float: try encode(v, forKey: dynamicKey)
            case let v as Bool: try encode(v, forKey: dynamicKey)
            default: logger.warning("Type \(type(of: value)) not supported")
            }
        }
    }
}

extension KeyedDecodingContainer where Key == DynamicKey {

    func decodeDynamicKeyValues() -> [String: Any] {
        var dict = [String: Any]()
        for key in allKeys {
            // Once again, following decode doesn't work, therefore requires explicitly decoding each supported type.
            // propertiesContainer.decode(?, forKey: key)
            if let v = try? decode(String.self, forKey: key) {
                dict[key.stringValue] = v
            } else if let v = try? decode(Bool.self, forKey: key) {
                dict[key.stringValue] = v
            } else if let v = try? decode(Int.self, forKey: key) {
                dict[key.stringValue] = v
            } else if let v = try? decode(Double.self, forKey: key) {
                dict[key.stringValue] = v
            } else if let v = try? decode(Float.self, forKey: key) {
                dict[key.stringValue] = v
            } else {
                logger.warning("Key \(key.stringValue) type not supported")
            }
        }
        return dict
    }

}
