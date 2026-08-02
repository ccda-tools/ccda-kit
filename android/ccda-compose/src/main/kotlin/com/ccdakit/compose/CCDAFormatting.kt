package com.ccdakit.compose

import com.ccdakit.engine.CCDAAddress
import com.ccdakit.engine.CCDAHumanName
import com.ccdakit.engine.CCDATimestamp
import com.ccdakit.engine.CCDAValue
import java.text.DateFormatSymbols

/** Formats a C-CDA human name for display. */
fun CCDAHumanName.formattedName(): String =
    (listOfNotNull(prefix) + given + listOfNotNull(family))
        .joinToString(" ")

/** Formats a C-CDA postal address for display. */
fun CCDAAddress.formattedPostalAddress(): String =
    (streetLines + listOfNotNull(city, state, postalCode, country))
        .filter { it.isNotBlank() }
        .joinToString("\n")

/** Formats a C-CDA value for display, preferring display name over scalar value and unit. */
fun CCDAValue.formattedValue(): String {
    displayName?.let { return it }
    return listOfNotNull(value, unit).joinToString(" ")
}

/** Formats a parsed C-CDA timestamp while preserving source precision. */
fun CCDATimestamp.formattedDateTime(): String {
    val monthValue = month
    val dayValue = day
    val date = when {
        monthValue == null -> year.toString()
        dayValue == null -> "${shortMonthName(monthValue)} $year"
        else -> "${shortMonthName(monthValue)} $dayValue, $year"
    }
    val time = formattedTime()
    val zone = timeZoneOffset?.let(::formattedTimeZoneOffset)

    return listOfNotNull(date, time?.let { "at $it" }, zone).joinToString(" ")
}

private fun CCDATimestamp.formattedTime(): String? {
    val hourValue = hour ?: return null
    val displayHour = if (hourValue % 12 == 0) 12 else hourValue % 12
    val meridiem = if (hourValue < 12) "AM" else "PM"
    val minuteValue = minute ?: return "$displayHour $meridiem"
    val secondValue = second ?: return "$displayHour:${minuteValue.twoDigit()} $meridiem"
    return if (fractionalSecond != null) {
        "$displayHour:${minuteValue.twoDigit()}:${secondValue.twoDigit()}.$fractionalSecond $meridiem"
    } else {
        "$displayHour:${minuteValue.twoDigit()}:${secondValue.twoDigit()} $meridiem"
    }
}

private fun shortMonthName(month: Int): String =
    DateFormatSymbols().shortMonths.getOrNull(month - 1)?.takeIf { it.isNotBlank() }
        ?: month.toString()

private fun formattedTimeZoneOffset(value: String): String =
    if (value.length == 5) "UTC${value.substring(0, 3)}:${value.substring(3)}" else value

private fun Int.twoDigit(): String = toString().padStart(2, '0')
