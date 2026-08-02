import Foundation

/// HL7 timestamp value parsed into date and time components.
///
/// Supports C-CDA/HL7 TS literals in these forms:
///
/// ```text
/// YYYY
/// YYYYMM
/// YYYYMMDD
/// YYYYMMDDHH
/// YYYYMMDDHHMM
/// YYYYMMDDHHMMSS
/// YYYYMMDDHHMMSS.fraction
/// YYYYMMDDHHMMSS+ZZZZ
/// YYYYMMDDHHMMSS-ZZZZ
/// YYYYMMDDHHMMSS.fraction+ZZZZ
/// YYYYMMDDHHMMSS.fraction-ZZZZ
/// ```
///
/// Missing components remain `nil`, so a date-only value such as `19800515`
/// does not invent an hour, minute, or second.
public struct CCDATimestamp: Hashable, Sendable {
    /// Original timestamp value exactly as provided by the XML.
    public let rawValue: String
    /// Four-digit year component.
    public let year: Int
    /// Month component from 1 through 12.
    public let month: Int?
    /// Day component from 1 through 31, validated when month and year are available.
    public let day: Int?
    /// Hour component from 0 through 23.
    public let hour: Int?
    /// Minute component from 0 through 59.
    public let minute: Int?
    /// Second component from 0 through 59.
    public let second: Int?
    /// Fractional second text without the leading decimal point.
    public let fractionalSecond: String?
    /// Time zone offset text such as `-0500`, when provided.
    public let timeZoneOffset: String?

    /// Whether the timestamp includes any time-of-day component.
    public var hasTime: Bool { hour != nil }

    /// Creates a timestamp by parsing an HL7 TS literal.
    public init?(rawValue: String) {
        self.rawValue = rawValue

        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let splitValue = Self.splitTimeZone(from: trimmedValue)
        let splitFraction = Self.splitFraction(from: splitValue.timestamp)
        let digits = splitFraction.timestamp

        guard Self.isSupportedDigitCount(digits.count),
              digits.allSatisfy(\.isNumber),
              let parsedYear = Self.integer(from: digits, start: 0, length: 4),
              (1...9999).contains(parsedYear) else {
            return nil
        }

        let parsedMonth = Self.integer(from: digits, start: 4, length: 2)
        let parsedDay = Self.integer(from: digits, start: 6, length: 2)
        let parsedHour = Self.integer(from: digits, start: 8, length: 2)
        let parsedMinute = Self.integer(from: digits, start: 10, length: 2)
        let parsedSecond = Self.integer(from: digits, start: 12, length: 2)

        guard Self.optionalComponentsAreValid(
            month: parsedMonth,
            day: parsedDay,
            hour: parsedHour,
            minute: parsedMinute,
            second: parsedSecond
        ) else {
            return nil
        }

        self.year = parsedYear
        self.month = parsedMonth
        self.day = parsedDay
        self.hour = parsedHour
        self.minute = parsedMinute
        self.second = parsedSecond
        self.fractionalSecond = splitFraction.fractionalSecond
        self.timeZoneOffset = splitValue.timeZoneOffset
    }

    private static func splitTimeZone(from value: String) -> (timestamp: String, timeZoneOffset: String?) {
        let splitIndex = value.lastIndex { $0 == "+" || $0 == "-" }
        guard let splitIndex else { return (value, nil) }

        let timestamp = String(value[..<splitIndex])
        let offset = String(value[splitIndex...])

        guard offset.count == 5,
              offset.dropFirst().allSatisfy(\.isNumber) else {
            return (value, nil)
        }

        return (timestamp, offset)
    }

    private static func splitFraction(from value: String) -> (timestamp: String, fractionalSecond: String?) {
        let parts = value.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)

        guard parts.count == 2,
              !parts[1].isEmpty,
              parts[1].allSatisfy(\.isNumber) else {
            return (value, nil)
        }

        return (String(parts[0]), String(parts[1]))
    }

    private static func isSupportedDigitCount(_ count: Int) -> Bool {
        [4, 6, 8, 10, 12, 14].contains(count)
    }

    private static func integer(from value: String, start: Int, length: Int) -> Int? {
        guard value.count >= start + length else {
            return nil
        }

        let startIndex = value.index(value.startIndex, offsetBy: start)
        let endIndex = value.index(startIndex, offsetBy: length)
        return Int(value[startIndex..<endIndex])
    }

    private static func optionalComponentsAreValid(
        month: Int?,
        day: Int?,
        hour: Int?,
        minute: Int?,
        second: Int?
    ) -> Bool {
        if let month, !(1...12).contains(month) {
            return false
        }

        if let day, !(1...31).contains(day) {
            return false
        }

        if let hour, !(0...23).contains(hour) {
            return false
        }

        if let minute, !(0...59).contains(minute) {
            return false
        }

        if let second, !(0...59).contains(second) {
            return false
        }
        return true
    }
}
