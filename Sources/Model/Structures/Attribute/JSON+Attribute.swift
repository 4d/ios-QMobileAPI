//
//  JSON+Attribute.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 14/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

extension JSON {
    //Optional AttributeStorageType
    var attributeStorageType: AttributeStorageType? {
        get {
            switch self.type {
            case .string:
                if let string = self.object as? String {
                    return AttributeStorageType(rawValue: string)
                }
                return nil

            default:
                return nil
            }
        }
        set {
            if let newValue = newValue?.rawValue {
                self.object = NSString(string: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }

    //Optional AttributeRelativeType
    var attributeRelativeType: AttributeRelativeType? {
        get {
            switch self.type {
            case .string:
                if let string = self.object as? String {
                    return AttributeRelativeType(rawValue: string)
                }
                return nil

            default:
                return nil
            }
        }
        set {
            if let newValue = newValue?.rawValue {
                self.object = NSString(string: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }

    //Optional AttributeKind
    var attributeKind: AttributeKind? {
        get {
            switch self.type {
            case .string:
                if let string = self.object as? String {
                    return AttributeKind(rawValue: string)
                }
                return nil

            default:
                return nil
            }
        }
        set {
            if let newValue = newValue?.rawValue {
                self.object = NSString(string: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }

    //Optional AttributeScope
    var attributeScope: AttributeScope? {
        get {
            switch self.type {
            case .string:
                if let string = self.object as? String {
                    return AttributeScope(rawValue: string)
                }
                return nil

            default:
                return nil
            }
        }
        set {
            if let newValue = newValue?.rawValue {
                self.object = NSString(string: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }
}
