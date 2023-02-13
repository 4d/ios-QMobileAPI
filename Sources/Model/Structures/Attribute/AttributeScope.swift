//
//  AttributeScope.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 14/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public enum AttributeScope: String {
    case `public`
}

// MARK: Codable
extension AttributeScope: Codable {}
