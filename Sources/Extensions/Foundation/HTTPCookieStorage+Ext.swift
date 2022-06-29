//
//  HTTPCookieStorage+Ext.swift
//  QMobileAPI
//
//  Created by emarchand on 24/06/2022.
//  Copyright © 2022 Eric Marchand. All rights reserved.
//

import Foundation

extension HTTPCookieStorage {

    open func deleteCookies() {
        for cookie in self.cookies ?? [] {
            deleteCookie(cookie)
        }
    }
}
