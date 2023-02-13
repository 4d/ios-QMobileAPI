//
//  CatalogTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 24/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

// MARK: catalog
// rest/$catalog/
/// Returns a list of the table in your project along with two URIs:
/// one to access the information about its structure and one to retrieve the data.
public class CatalogTarget: ChildTargetType {
    let parentTarget: TargetType
    init(parentTarget: BaseTarget) { self.parentTarget = parentTarget }

    let childPath = "$catalog"
    public let method = Moya.Method.get

    public let task = Task.requestPlain
    public var sampleData: Data {
        return stubbedData("restcatalog")
    }
}
extension CatalogTarget: DecodableTargetType {
    public typealias ResultType = Catalog
}

extension BaseTarget {
    /// Returns a list of the table in your project along with two URIs:
    /// one to access the information about its structure and one to retrieve the data.
    var catalog: CatalogTarget { return CatalogTarget(parentTarget: self) }
}
