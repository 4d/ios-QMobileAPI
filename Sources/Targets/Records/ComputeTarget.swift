//
//  ComputeTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 02/05/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Alamofire

// http://doc.wakanda.org/home2.en.html?&_ga=1.241951170.1945468140.1488380770#/HTTP-REST/Manipulating-Data/compute.303-982894.en.html
public class ComputeTarget: ChildTargetType {
    let parentTarget: TargetType
    public let attribute: String
    public let operation: ComputeOperation
    init(parentTarget: RecordsTarget, attribute: String, operation: ComputeOperation) {
        self.parentTarget = parentTarget
        self.attribute = attribute
        self.operation = operation
    }
    init(parentTarget: RecordSetTarget, attribute: String, operation: ComputeOperation) {
        self.parentTarget = parentTarget
        self.attribute = attribute
        self.operation = operation
    }

    var childPath: String {
        return attribute
    }
    public let method = Moya.Method.get

    public var task: Task {
        return .requestParameters(parameters: ["$compute": operation.query], encoding: URLEncoding.default)
    }
    public var sampleData: Data {
        if operation == .all {
            return stubbedData("restcompute")
        } else {
            return "445".data(using: .utf8)!
        }
    }
}
extension ComputeTarget: DecodableTargetType {
    public typealias ResultType = Compute
}

extension RecordsTarget {
    func compute(_ operation: ComputeOperation, for attribute: String) -> ComputeTarget {
        return ComputeTarget(parentTarget: self, attribute: attribute, operation: operation)
    }
}

extension RecordSetTarget {
    func compute(_ operation: ComputeOperation, for attribute: String) -> ComputeTarget {
        return ComputeTarget(parentTarget: self, attribute: attribute, operation: operation)
    }
}
