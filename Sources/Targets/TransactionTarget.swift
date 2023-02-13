//
//  TransactionTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 29/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

enum TransationType: String {
    case start
    case rollback
    case pause
    case resume

    var query: String {
        return "$\(self.rawValue)"
    }
}

class TransationTarget: ChildTargetType {
    let parentTarget: TargetType
    let type: TransationType
    init(parentTarget: BaseTarget, type: TransationType) {
        self.parentTarget = parentTarget
        self.type = type
    }

    var childPath: String {
        return "$transaction/\(self.type.query)"
    }
    let method = Moya.Method.get

    let task = Task.requestPlain
    var sampleData: Data {
        return stubbedData("restransaction\(self.type.rawValue)")
    }
}

extension BaseTarget {
    func transaction(type: TransationType) -> TransationTarget {
        return TransationTarget(parentTarget: self, type: type)
    }
}
