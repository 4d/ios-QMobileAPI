//
//  AttributeKind.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 14/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public enum AttributeKind: String {
    case storage
    case relatedEntity
    case relatedEntities
    case calculated
    case alias
}

// MARK: Codable
extension AttributeKind: Codable {}
