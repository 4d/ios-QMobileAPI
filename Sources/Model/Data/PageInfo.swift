//
//  PageInfo.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 27/04/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

/// Information about one page when doing paginate request.
public struct PageInfo {
    public var globalStamp: Int
    /// The number of elementin this page
    public var sent: Int
    /// The first element of this page
    public var first: Int
    /// The total number of element
    public var count: Int

    public init(globalStamp: Int, sent: Int, first: Int, count: Int) {
        self.globalStamp = globalStamp
        self.count = count
        self.sent = sent
        self.first = first
    }
}

extension PageInfo: Codable {}

// MARK: JSON

struct PageKey {
    static let reserved = "__"

    static let globalStamp = "__GlobalStamp"
    static let count = "__COUNT"
    static let sent = "__SENT"
    static let first = "__FIRST"
}

extension PageInfo: JSONDecodable {
    public init?(json: JSON) {
        self.globalStamp = json[PageKey.globalStamp].intValue
        self.count = json[PageKey.count].intValue
        self.sent = json[PageKey.sent].intValue
        self.first = json[PageKey.first].intValue
    }
}

// MARK: DictionaryConvertible

extension PageInfo: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary[PageKey.globalStamp] = self.globalStamp
        dictionary[PageKey.count] = self.count
        dictionary[PageKey.sent] = self.sent
        dictionary[PageKey.first] = self.first
        return dictionary
    }
}

// MARK: Equatable
extension PageInfo: Equatable {
    public static func == (lhf: PageInfo, rhf: PageInfo) -> Bool {
        return lhf.globalStamp == rhf.globalStamp &&
        lhf.count == rhf.count &&
        lhf.sent == rhf.sent &&
        lhf.first == rhf.first
    }
}

// MARK: Utility methods
extension PageInfo {
    public var isEmpty: Bool {
        // swiftlint:disable:next empty_count
        return count == 0
    }

    public var last: Int {
        return next - 1
    }

    public var next: Int {
        return first + sent
    }

    /// true if first is equel to 0
    public var isFirst: Bool {
        return first == 0
    }

    public var isLast: Bool {
        return first + sent == count
    }
}
