//
//  AttributeMapper.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 29/03/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Allow to map swift(data store) and json type
open class AttributeValueMapper { // XX rename to AttributeValueMapper

    public static var `default` = AttributeValueMapper()

    open func map(_ value: Any?, with attribute: Attribute) -> Any? {
        guard let type = attribute.storageType else {
            return nil
        }
        switch type {
        /*case .string:
            if let string = value as? String {
                return string
            }
            return "" // XXX do optional case or not, or default value*/
        case .date:
            if let string = value as? String, !string.isEmpty {
                if attribute.simpleDate {
                    return string.simpleDate ?? string.dateFromISO8601 // could remove dateFromISO8601
                }
                return string.dateFromISO8601
            }
            return nil
        /*case .bool:
            if let bool = value as? Bool {
                return bool
            } else if let string = value as? String {
                return Bool(string) ?? false
            } else if let integer = value as? Int {
                return integer == 1
            }
            return false*/
        /* case .image:
             maybe already parse json value to get only uri
             
             */
        default:
            return nullToNil(value)
        }
    }

    func nullToNil(_ value: Any?) -> Any? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }

    open func unmap(_ value: Any?, with attribute: Attribute) -> Any? {
        guard let type = attribute.storageType else {
            return nil
        }
        switch type {
        /*case .string:
            if let string = value as? String {
                return string
            }
            return "" // XXX do optional case or not, or default value*/
        case .date:
            // XXX maybe get info from attribute, like 'simpleDate'
            if let date = value as? Date {
                return date.iso8601
            }
            return nil

        default:
            return value
        }
    }
}
