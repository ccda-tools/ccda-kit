import Foundation
import CCDAEngine

public extension CCDATimestamp {
    /// Localized display text built only from timestamp components present in the XML.
    var formattedDateTime: String {
        var text = formattedDate

        if let formattedTime {
            text += " at \(formattedTime)"
        }

        if let timeZoneOffset {
            text += " \(formattedTimeZoneOffset(timeZoneOffset))"
        }

        return text
    }

    private var formattedDate: String {
        guard let month else {
            return String(year)
        }

        let monthName = Self.shortMonthName(for: month)

        guard let day else {
            return "\(monthName) \(year)"
        }

        return "\(monthName) \(day), \(year)"
    }

    private var formattedTime: String? {
        guard let hour else {
            return nil
        }

        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        let meridiem = hour < 12 ? "AM" : "PM"

        guard let minute else {
            return "\(displayHour) \(meridiem)"
        }

        guard let second else {
            return "\(displayHour):\(Self.twoDigit(minute)) \(meridiem)"
        }

        if let fractionalSecond {
            return "\(displayHour):\(Self.twoDigit(minute)):\(Self.twoDigit(second)).\(fractionalSecond) \(meridiem)"
        }

        return "\(displayHour):\(Self.twoDigit(minute)):\(Self.twoDigit(second)) \(meridiem)"
    }

    private static func shortMonthName(for month: Int) -> String {
        let symbols = DateFormatter().shortMonthSymbols ?? []
        guard symbols.indices.contains(month - 1) else {
            return String(month)
        }
        return symbols[month - 1]
    }

    private static func twoDigit(_ value: Int) -> String {
        String(format: "%02d", value)
    }

    private func formattedTimeZoneOffset(_ value: String) -> String {
        guard value.count == 5 else {
            return value
        }

        let hourEndIndex = value.index(value.startIndex, offsetBy: 3)
        return "UTC\(value[..<hourEndIndex]):\(value[hourEndIndex...])"
    }
}
