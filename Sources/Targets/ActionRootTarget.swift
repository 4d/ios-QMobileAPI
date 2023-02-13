//
//  ActionRootTarget.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/12/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Alamofire
import Foundation
import Moya

/// Te server target to execute actions.
public class ActionRootTarget: ChildTargetType {
    let parentTarget: TargetType
    init(parentTarget: BaseTarget) { self.parentTarget = parentTarget }

    let childPath = "$action"

    public let method = Moya.Method.get
    public let task = Task.requestPlain

    public var headers: [String: String]?

    public  var sampleData: Data {
        return stubbedData("404notfound")
    }

    public var validate: Bool = true
}

extension ActionRootTarget {
    /// Create a target to execute the action.
    public func action(_ action: Action) -> ActionTarget { return self.action(name: action.name) }
    /// Create a target to execute the action using its name.
    public func action(name: String, parameters: [String: Any] =  [:]) -> ActionTarget { return ActionTarget(parentTarget: self, name: name) }
}

extension BaseTarget {
    /// Root target for actions.
    var actionTarget: ActionRootTarget { return ActionRootTarget(parentTarget: self) }
}
