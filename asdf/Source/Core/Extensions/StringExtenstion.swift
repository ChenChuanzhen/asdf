//
//  StringExtenstion.swift
//  asdf
//
//  Created by 咸鱼悠游 on 2026/4/17.
//

import Foundation

extension String {
    
    func dateFormat(format: String = "d MMM yyyy HH:mm") -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = isoFormatter.date(from: self) else {
            return self
        }
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        displayFormatter.dateFormat = format
        return displayFormatter.string(from: date)
    }
    
}
