//
//  UploadResult.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

// http://doc.wakanda.org/home2.en.html?&_ga=1.241951170.1945468140.1488380770#/HTTP-REST/Interacting-with-the-Server/upload.303-1158401.en.html
// ex: { "ID": "D507BC03E613487E9B4C2F6A0512FE50" }

public struct UploadResult {
    public let id: String
}

extension UploadResult: Codable {}

extension UploadResult: JSONDecodable {
    public init?(json: JSON) {
        guard let id = json["ID"].string else {
            return nil
        }
        self.id = id
    }
}

// MARK: DictionaryConvertible
extension UploadResult: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["ID"] = id
        return dictionary
    }
}

// MARK: Equatable

extension UploadResult: Equatable {
    public static func == (lhf: UploadResult, rhf: UploadResult) -> Bool {
        return lhf.id == rhf.id
    }
}
