//
//  FormDataProvider+JSON.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 27/07/2018.
//  Copyright © 2018 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

extension MultipartFormData.FormDataProvider {
    public static func json(_ json: JSON, options: JSONSerialization.WritingOptions = []) throws -> MultipartFormData.FormDataProvider {
        return .data(try json.rawData(options: options))
    }

    public static func dictionaryConvertible<D: DictionaryConvertible>(_ jsonable: D, options: JSONSerialization.WritingOptions = []) throws -> MultipartFormData.FormDataProvider {
        return try json(jsonable.json, options: options)
    }

    public static func dictionary(_ dictionary: [String: Any], options: JSONSerialization.WritingOptions = []) throws -> MultipartFormData.FormDataProvider {
         return try json(JSON(dictionary), options: options)
    }

    public static func encodable<E: Encodable>(_ encodable: E, jsonEncoder: JSONEncoder = JSONEncoder()) throws -> MultipartFormData.FormDataProvider {
        return .data(try jsonEncoder.encode(encodable))
    }

    public static func encodable<E: Encodable>(_ encodable: E, propertyListEncoder: PropertyListEncoder) throws -> MultipartFormData.FormDataProvider {
        return .data(try propertyListEncoder.encode(encodable))
    }
}
