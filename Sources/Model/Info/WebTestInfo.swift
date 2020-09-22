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

public struct ServerVersion {

    public var version: SemVersion
    public var submit: String?
    public var commercialVersion: String?

    public init?(_ string: String?) {
        guard let versionString = string?.replacingOccurrences(of: "4D/", with: "") else {
            return nil
        }

        guard let pos = versionString.firstIndex(of: " ") else {
            logger.warning("Cannot decode server semVersion \(versionString). No space")
            return nil
        }
        let semVer = String(versionString[versionString.startIndex..<pos])
        self.version =  SemVersion(semVer)

        let build = String(versionString[pos..<versionString.endIndex]).replacingOccurrences(of: "(Build ", with: "").replacingOccurrences(of: ")", with: "")
        let builds = build.split(separator: ".")

        if builds.count > 1 {
            self.commercialVersion = String(builds[0])
            self.submit =  String(builds[1])
        } else if !builds.isEmpty {
            self.commercialVersion =  String(builds[0])
        }
    }
}

public struct SemVersion {

    public private(set) var max: Int = 0
    public private(set) var min: Int = 0
    public private(set) var patch: Int = 0

    public static let V18R5 = SemVersion(max: 18, min: 5, patch: 0)

    public init(max: Int, min: Int, patch: Int) {
        self.max = max
        self.min = min
        self.patch = patch
    }
    public init(_ string: String) {
        let splitted = string.split(separator: ".")
        if splitted.count > 2 {
            self.max = Int(splitted[0]) ?? 0
            self.min = Int(splitted[1]) ?? 0
            self.patch = Int(splitted[2]) ?? 0
        } else if splitted.count > 1 {
            self.max = Int(splitted[0]) ?? 0
            self.min = Int(splitted[1]) ?? 0
        } else if !splitted.isEmpty {
            self.max = Int(splitted[0]) ?? 0
        }
    }

}
extension SemVersion: Equatable {
    public static func == (left: SemVersion, right: SemVersion) -> Bool {
        return left.max == right.max && left.min == right.min && left.patch == right.patch
    }
}

extension SemVersion: Comparable {
    static public func < (left: SemVersion, right: SemVersion) -> Bool {
        if left.max < right.max {
            return true
        }
        if left.min < right.min {
            return true
        }
        if left.patch < right.patch {
            return true
        }
        return false
    }
}

// MARK: shortcut
extension WebTestInfo {
    /// Return server information
    public var server: String? {
      return info["Server"] // 4D/18.5.0 (Build 0.255457)
    }

    public var version: ServerVersion? {
        return ServerVersion(server)
    }

    /// Return true if it's a 4D web server
    public var is4D: Bool {
      guard let server = server else {
        return false
      }
      return server.hasPrefix("")
    }
}
