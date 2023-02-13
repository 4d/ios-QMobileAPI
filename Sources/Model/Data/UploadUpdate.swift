//
//  UploadUpdate.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

// http://doc.wakanda.org/home2.en.html?&_ga=1.241951170.1945468140.1488380770#/HTTP-REST/Interacting-with-the-Server/upload.303-1158401.en.html
// ex: { "ID": "D507BC03E613487E9B4C2F6A0512FE50" }

public struct UploadUpdate {
    public let key: String
    public let stamp: String
    public let photo: UploadResult

    public init(key: String, stamp: String, photo: UploadResult) {
        self.key = key
        self.stamp = stamp
        self.photo = photo
    }
}

extension UploadUpdate: Codable {}

extension UploadUpdate: JSONDecodable {
    public init?(json: JSON) {
        self.key = json["__KEY"].stringValue
        self.stamp = json["__STAMP"].stringValue
        guard let photo = UploadResult(json: json["photo"]) else {
            return nil
        }
        self.photo = photo
    }
}

// MARK: DictionaryConvertible
extension UploadUpdate: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["__KEY"] = key
        dictionary["__STAMP"] = stamp
        dictionary["photo"] = photo.dictionary
        return dictionary
    }
}

// MARK: Equatable

extension UploadUpdate: Equatable {
    public static func == (lhf: UploadUpdate, rhf: UploadUpdate) -> Bool {
        return lhf.key == rhf.key && lhf.stamp == rhf.stamp && lhf.photo == rhf.photo
    }
}

// MARK: Builder
extension UploadResult {
    public func update(on key: String, stamp: String) -> UploadUpdate {
        return UploadUpdate(key: key, stamp: stamp, photo: self)
    }
}
