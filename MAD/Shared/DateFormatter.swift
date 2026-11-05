//
//  DateFormatter.swift
//  MAD
//
//  Created by Fabian Gerö on 05.11.26.
//

import Foundation

nonisolated extension DateFormatter {
    static var iso8601Full: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
