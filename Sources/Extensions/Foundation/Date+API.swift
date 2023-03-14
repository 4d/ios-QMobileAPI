//
//  Date+API.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 29/03/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

extension TimeZone {
    static let greenwichMeanTime  = TimeZone(secondsFromGMT: 0)!
}

extension DateFormatter {
    public static let iso8601: DateFormatter = {
        // XX use ISO8601DateFormatter
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .greenwichMeanTime
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()

    static let iso8601WithoutZ: DateFormatter = {
        // XX use ISO8601DateFormatter
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .greenwichMeanTime
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()

    // public var refreshed: Date //"2011-11-18T10:30:30Z",

    /// a simple date format with / "dd/MM/yyyy"
    public static let simpleDateSlash: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .greenwichMeanTime
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    /// a date formatter to match with 4d one "dd!MM!yyyy"
    public static let simpleDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .greenwichMeanTime
        formatter.dateFormat = "dd!MM!yyyy"
        return formatter
    }()

    public static let simpleDateDash: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .greenwichMeanTime
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()

    static let rfc3339: [DateFormatter] = {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
            "yyyy-MM-dd HH:mm:ss.SSSZZZZZ",
            "yyyy-MM-dd HH:mm:ssZZZZZ"
        ]
        return formats.map { createRFC3339(dateFormat: $0) }
    }()
    static func createRFC3339(dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .greenwichMeanTime
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = dateFormat
        return formatter
    }

    // could add here date formatter with local and timezone as argument

}

extension Date {
    /// A string representation of this date using ISO 8601 format.
    public var iso8601: String {
        return DateFormatter.iso8601.string(from: self)
    }

    /// Return the tomorrow date
    public static var tomorrow: Date {
        var dateComponents = DateComponents()
        dateComponents.setValue(1, for: .day) // +1 day

        let now = Date() // Current date
        let tomorrow = Calendar.current.date(byAdding: dateComponents, to: now)  // Add the DateComponents

        return tomorrow! // swiftlint:disable:this
    }

    /// Return yesterday date.
    public static var yesterday: Date {
        var dateComponents = DateComponents()
        dateComponents.setValue(-1, for: .day) // -1 day

        let now = Date() // Current date
        let yesterday = Calendar.current.date(byAdding: dateComponents, to: now) // Add the DateComponents

        return yesterday! // swiftlint:disable:this
    }

    /// Return two day ago date.
    public static var twoDaysAgo: Date {
        var dateComponents = DateComponents()
        dateComponents.setValue(-2, for: .day) // -2 day

        let now = Date() // Current date
        let yesterday = Calendar.current.date(byAdding: dateComponents, to: now) // Add the DateComponents

        return yesterday! // swiftlint:disable:this
    }

    /// Return the first day of this month.
    public static var firstDayOfMonth: Date {
        let now = Date() // Current date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: now))
        let firstMonthDay = Calendar.current.date(from: components)

        return firstMonthDay! // swiftlint:disable:this
    }
}

extension String {
    /// A date of this string si a date in ISO 8601 format.
    public var dateFromISO8601: Date? {
        return DateFormatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
    /// A date of this string si a date in ISO 8601 format.
    public var dateFromISO8601WithoutZ: Date? {
        return DateFormatter.iso8601WithoutZ.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }

    /// A date of this string si a date in simple date format.
    /// ex: 12!4!2014 or 12/4/2014
    public var simpleDate: Date? {
        if let date = DateFormatter.simpleDate.date(from: self) { // 12!4!2014
            return date
        }
        return DateFormatter.simpleDateSlash.date(from: self)   // 12/4/2014
    }

    /// A date of this string si a date in one of the format defined by RFC 3339.
    public var dateFromRFC3339: Date? {
        return DateFormatter.rfc3339.lazy.compactMap { $0.date(from: self) }.first
    }
}
