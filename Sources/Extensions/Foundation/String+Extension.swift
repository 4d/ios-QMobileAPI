//
//  String+Extension.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

extension String {
    var first: String {
        return String(self.prefix(1))
    }

    var last: String {
        return String(self.suffix(1))
    }

    func uppercasedFirstCharacter() -> String {
        let first = self.first.uppercased()
        let other = String(self.dropFirst())
        return first + other
    }

    func lowercasedFirstCharacter() -> String {
        let first = self.first.lowercased()
        let other = String(self.dropFirst())
        return first + other
    }

    var isFirstCharacterUppercased: Bool {
        let first = self.first
        if first.isEmpty {
            return false
        }
        return first.uppercased() == first
    }

    var isFirstCharacterLowercased: Bool {
        let first = self.first
        if first.isEmpty {
            return false
        }
        return first.lowercased() == first
    }

    var isFirstCharacterLetter: Bool {
        guard let first = unicodeScalars.first else {
            return false
        }
        return CharacterSet.letters.contains(first)
    }

    public init(unwrappedDescrib object: Any?) {
        if let object = object {
            self.init(describing: object)
        } else {
            self.init(describing: object)
        }
    }

    var localized: String {
        return NSLocalizedString(self, bundle: Bundle(for: APIManager.self), comment: "")
    }

    func localized(with comment: String = "", bundle: Bundle = Bundle(for: APIManager.self)) -> String {
        return NSLocalizedString(self, bundle: bundle, comment: comment)
    }

    var base64Encoded: String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }

    var base64Decoded: String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    var base64DecodedData: Data? {
        return Data(base64Encoded: self)
    }

    var urlEncodedString: String {
        let customAllowedSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        return escapedString!
    }
    var urlQueryEncoded: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
