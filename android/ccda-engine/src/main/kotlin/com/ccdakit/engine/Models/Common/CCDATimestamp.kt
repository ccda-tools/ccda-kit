package com.ccdakit.engine

/**
 * Parsed HL7 TS timestamp preserving the original precision instead of forcing every value into a date-time.
 *
 * Supports `yyyy`, `yyyyMM`, `yyyyMMdd`, `yyyyMMddHH`, `yyyyMMddHHmm`,
 * and `yyyyMMddHHmmss`, with optional `.fraction` and `+/-ZZZZ` timezone offset.
 *
 * @property rawValue Original timestamp string.
 * @property year Parsed year.
 * @property month Parsed month when present.
 * @property day Parsed day when present.
 * @property hour Parsed hour when present.
 * @property minute Parsed minute when present.
 * @property second Parsed second when present.
 * @property fractionalSecond Fractional second digits when present.
 * @property timeZoneOffset Timezone offset such as `-0500` when present.
 */
data class CCDATimestamp(
    val rawValue: String,
    val year: Int,
    val month: Int? = null,
    val day: Int? = null,
    val hour: Int? = null,
    val minute: Int? = null,
    val second: Int? = null,
    val fractionalSecond: String? = null,
    val timeZoneOffset: String? = null,
) {
    /** Whether the source timestamp included an hour component. */
    val hasTime: Boolean
        get() = hour != null

    companion object {
        private val supportedDigitCounts = setOf(4, 6, 8, 10, 12, 14)

        /** Parses an HL7 TS timestamp into positional date/time components. */
        fun parse(rawValue: String?): CCDATimestamp? {
            val raw = rawValue?.trim()?.takeIf { it.isNotEmpty() } ?: return null
            val (timestampWithFraction, offset) = splitTimeZone(raw)
            val (digits, fraction) = splitFraction(timestampWithFraction)

            if (digits.length !in supportedDigitCounts || !digits.all { it.isDigit() }) {
                return null
            }

            val year = digits.intAt(0, 4)?.takeIf { it in 1..9999 } ?: return null
            val month = digits.intAt(4, 2)
            val day = digits.intAt(6, 2)
            val hour = digits.intAt(8, 2)
            val minute = digits.intAt(10, 2)
            val second = digits.intAt(12, 2)

            if (!optionalComponentsAreValid(month, day, hour, minute, second)) {
                return null
            }

            return CCDATimestamp(
                rawValue = raw,
                year = year,
                month = month,
                day = day,
                hour = hour,
                minute = minute,
                second = second,
                fractionalSecond = fraction,
                timeZoneOffset = offset,
            )
        }

        private fun splitTimeZone(value: String): Pair<String, String?> {
            val index = value.indexOfLast { it == '+' || it == '-' }
            if (index < 0) return value to null

            val timestamp = value.substring(0, index)
            val offset = value.substring(index)

            return if (offset.length == 5 && offset.drop(1).all { it.isDigit() }) {
                timestamp to offset
            } else {
                value to null
            }
        }

        private fun splitFraction(value: String): Pair<String, String?> {
            val parts = value.split(".", limit = 2)
            if (parts.size != 2 || parts[1].isEmpty() || !parts[1].all { it.isDigit() }) {
                return value to null
            }
            return parts[0] to parts[1]
        }

        private fun String.intAt(start: Int, length: Int): Int? {
            if (this.length < start + length) return null
            return substring(start, start + length).toIntOrNull()
        }

        private fun optionalComponentsAreValid(
            month: Int?,
            day: Int?,
            hour: Int?,
            minute: Int?,
            second: Int?,
        ): Boolean {
            if (month != null && month !in 1..12) return false
            if (day != null && day !in 1..31) return false
            if (hour != null && hour !in 0..23) return false
            if (minute != null && minute !in 0..59) return false
            if (second != null && second !in 0..59) return false
            return true
        }
    }
}
