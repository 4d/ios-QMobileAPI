//
//  WebServerInfo.swift
//  Tests
//
//  Created by Eric Marchand on 12/12/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Request basic information about web server.
public struct WebTestInfo {
    /// Headers information.
    public var info: [String: String]

    public init(string: String) {
        let lines = string.split(separator: "\n")
        var result: [String: String] = [:]
        for line in lines {
            if let index = line.firstIndex(of: ":") {
                result[String(line[..<index])] = String(line[line.index(index, offsetBy: 1)...]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        self.info = result
    }
}

// MARK: Codable
extension WebTestInfo: Codable {}

// MARK: shortcut
extension WebTestInfo {
    /// Return server information
    public var server: String? {
      return info["Server"]
    }

    /// Return true if it's a 4D web server
    public var is4D: Bool {
      guard let server = server else {
        return false
      }
      return server.hasPrefix("")
    }
}
