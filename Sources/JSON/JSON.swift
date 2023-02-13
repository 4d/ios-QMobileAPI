//
//  JSON.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 28/03/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import SwiftyJSON

public typealias JSON = SwiftyJSON.JSON
public typealias JSONError = SwiftyJSON.SwiftyJSONError

extension JSON {
    /// Init JSON object using content of file URL
    public init(fileURL: URL, options opt: JSONSerialization.ReadingOptions = .allowFragments) throws {
        guard fileURL.isFileURL else {
            self.init(NSNull())
            return
        }

        let data = try Data(contentsOf: fileURL)
        do {
            try self.init(data: data, options: opt)
        } catch {
            /*let originError = error
            do {*/
            let string = try String(contentsOf: fileURL, encoding: .macOSRoman)
            self.init(string)
            /*} catch {
             throw originError
             }*/
        }
    }
}

extension JSON {
    /// Try to get date value.
    public var date: Date? {
        guard let string = self.string else {
            return nil
        }
        if let date = string.dateFromRFC3339 {
            return date
        }
        if let date = string.simpleDate {
            return date
        }
        if let date = ISO8601DateFormatter().date(from: string) {
            return date
        }
        if let date = string.dateFromISO8601WithoutZ {
            return date
        }
        return nil
    }
}

extension Array where Element == SwiftyJSON.JSON {
    func array<T: JSONDecodable>(of atype: T.Type) -> [T] {
        return self.compactMap { atype.init(json: $0) }
    }
}
extension JSON {

    func array<T: JSONDecodable>(of atype: T.Type) -> [T]? {
        return self.array?.array(of: atype)
    }
}
