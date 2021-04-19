//
//  Bundle+Stub.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 14/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

extension Bundle {
    /// Bundle used to stub file
    @nonobjc public static var qMobileApiStub = Bundle(for: APIManager.self)
    @nonobjc public static var qMobileApiStubURL = URL(fileURLWithPath: #file)
}
