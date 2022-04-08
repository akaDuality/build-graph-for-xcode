//
//  DateFormatter+8601.swift
//  
//
//  Created by Mikhail Rubanov on 08.04.2022.
//

import Foundation

extension DateFormatter {
    public static let iso8601Full_Z: DateFormatter = {
        dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ")
    }()
    
    static func dateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
