package com.ccdakit.engine

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class CCDATimestampTest {
    @Test
    fun parsesTimestampComponentsByPosition() {
        val timestamp = requireNotNull(CCDATimestamp.parse("20260719093045.123-0500"))

        assertEquals("20260719093045.123-0500", timestamp.rawValue)
        assertEquals(2026, timestamp.year)
        assertEquals(7, timestamp.month)
        assertEquals(19, timestamp.day)
        assertEquals(9, timestamp.hour)
        assertEquals(30, timestamp.minute)
        assertEquals(45, timestamp.second)
        assertEquals("123", timestamp.fractionalSecond)
        assertEquals("-0500", timestamp.timeZoneOffset)
        assertTrue(timestamp.hasTime)
    }

    @Test
    fun parsesDateOnlyWithoutInventingTime() {
        val timestamp = requireNotNull(CCDATimestamp.parse("19800515"))

        assertEquals(1980, timestamp.year)
        assertEquals(5, timestamp.month)
        assertEquals(15, timestamp.day)
        assertNull(timestamp.hour)
        assertFalse(timestamp.hasTime)
    }

    @Test
    fun returnsNullWhenYearCannotBeParsed() {
        assertNull(CCDATimestamp.parse("bad-date"))
        assertNull(CCDATimestamp.parse("123"))
        assertNull(CCDATimestamp.parse("00000515"))
    }
}
