//
//  URL+Localhost.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

extension URL {
    static var localIP: URL { return URL(string: "\(URL.defaultScheme)://127.0.0.1")! }
    static var localhost: URL { return URL(string: "\(URL.defaultScheme)://localhost")! }
}
