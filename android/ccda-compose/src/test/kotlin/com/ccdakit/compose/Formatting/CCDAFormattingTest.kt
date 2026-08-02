package com.ccdakit.compose

import com.ccdakit.engine.CCDAAddress
import com.ccdakit.engine.CCDAHumanName
import com.ccdakit.engine.CCDATimestamp
import com.ccdakit.engine.CCDAValue
import org.junit.Assert.assertEquals
import org.junit.Test

class CCDAFormattingTest {
    @Test
    fun formatsNameAddressTimestampAndValue() {
        assertEquals(
            "Dr. Jane Public",
            CCDAHumanName(prefix = "Dr.", given = listOf("Jane"), family = "Public").formattedName(),
        )

        assertEquals(
            "123 Main St\nBoston\nMA\n02118\nUS",
            CCDAAddress(
                streetLines = listOf("123 Main St"),
                city = "Boston",
                state = "MA",
                postalCode = "02118",
                country = "US",
            ).formattedPostalAddress(),
        )

        assertEquals(
            "Jul 19, 2026 at 9:30:45 AM UTC-05:00",
            requireNotNull(CCDATimestamp.parse("20260719093045-0500")).formattedDateTime(),
        )

        assertEquals(
            "120 mm[Hg]",
            CCDAValue(value = "120", unit = "mm[Hg]").formattedValue(),
        )
    }
}
