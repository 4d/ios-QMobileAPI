//
//  JSONCodable.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 03/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Object that could be initialized from JSON object
public protocol JSONDecodable {
    init?(json: JSON)
    static func array(json: JSON) -> [Self]?
}

extension JSONDecodable {
    /// Init object with Data
    public init?(data: Data) {
        guard let json = try? JSON(data: data) else { // XXX do not use ?, throw instead
            return nil
        }
        self.init(json: json)
    }

    /// Init object with string
    public init?(string: String, using: String.Encoding = .utf8) {
        guard let data = string.data(using: using) else {
            return nil
        }
        self.init(data: data)
    }

    /// Init using content of file
    public init?(fileURL: URL) {
        if fileURL.isFileURL {
            guard let json = try? JSON(fileURL: fileURL) else {
                return nil
            }
            self.init(json: json)
        } else {
            return nil
        }
    }

    /// Try to get one object into an array with size equal to one.
    /// otherwise return nil
    public static func array(json: JSON) -> [Self]? {
        guard let instance = Self(json: json) else {
            return nil
        }
        return [instance]
    }
}

/// Object that could produce JSON
public protocol JSONEncodable {
    var json: JSON { get }
}

extension Dictionary: JSONEncodable {
    public var json: JSON {
        return JSON(self)
    }
}

extension Array: JSONEncodable {
    public var json: JSON {
        return JSON(self)
    }
}

/// Alias for object decodable and encodable
public typealias JSONCodable = JSONEncodable & JSONDecodable
