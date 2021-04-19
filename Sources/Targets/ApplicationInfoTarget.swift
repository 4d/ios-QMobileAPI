//
//  ApplicationInfoTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/12/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

/// Get information about the application
public class ApplicationInfoTarget: ActionAbstractTarget {

    // Application id
    public var bundleId: String {
        get {
            return parameters["bundleId"] as? String ?? ""
        }
        set {
            parameters["bundleId"] = newValue
        }
    }

    init(parentTarget: ActionRootTarget, actionName: String, bundleId: String) {
        super.init(parentTarget: parentTarget, name: actionName)
        self.bundleId = bundleId
    }

    override public var sampleData: Data {
        return stubbedData("actionapplicationinfo")
    }

}

extension ApplicationInfoTarget: DecodableTargetType {
    public typealias ResultType = ApplicationInfo
}

extension ActionRootTarget {
    /// Create an `ApplicationInfoTarget` from this.
    public func applicationInfo(actionName: String, bundleId: String) -> ApplicationInfoTarget {
        return ApplicationInfoTarget(parentTarget: self, actionName: actionName, bundleId: bundleId)
    }
}
