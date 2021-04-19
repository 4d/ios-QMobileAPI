//
//  MethodTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 24/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

// MARK: method
/// Returns a record collection based on a table method
public class TableMethodTarget: ChildTargetType {
    let parentTarget: TargetType
    public let name: String
    init(parentTarget: RecordsTarget, name: String) { // XXX maybe see with TableMethod
        self.parentTarget = parentTarget
        self.name = name
    }

    var childPath: String {
        return name
    }
    public var method = Moya.Method.get

    public var task: Task {
        if parameters.isEmpty {
            return .requestPlain
        }
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    public var parameters: [String: Any] = [:]

    public var sampleData: Data {
        return stubbedData("resttablemethod")
    }
}

extension RecordsTarget {
    /// Create a `TableMethodTarget` from this records target.
    public func method(name: String) -> TableMethodTarget { return TableMethodTarget(parentTarget: self, name: name) }
}

// METHOD not fully implemented yet
// http://doc.wakanda.org/home2.en.html?&_ga=1.241951170.1945468140.1488380770#/HTTP-REST/Manipulating-Data/datastoreClassmethod.303-814342.en.html
