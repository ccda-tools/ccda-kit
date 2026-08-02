package com.ccdakit.engine

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class CCDAModelConstructionTest {
    @Test
    fun addressUseMapsKnownUnknownAndUnsupportedCodes() {
        assertEquals(CCDAAddressUse.PrimaryHome, CCDAAddressUse.fromCode("HP"))
        assertEquals(CCDAAddressUse.WorkPlace, CCDAAddressUse.fromCode("wp"))
        assertEquals(CCDAAddressUse.Unknown, CCDAAddressUse.fromCode(null))
        assertEquals(CCDAAddressUse.Unsupported("VACATION"), CCDAAddressUse.fromCode("VACATION"))
    }

    @Test
    fun entryTypeMapsKnownAndUnsupportedElementNames() {
        assertEquals(CCDAEntryType.Act, CCDAEntryType.fromElementName("act"))
        assertEquals(CCDAEntryType.Observation, CCDAEntryType.fromElementName("observation"))
        assertEquals(CCDAEntryType.SubstanceAdministration, CCDAEntryType.fromElementName("substanceAdministration"))
        assertEquals(CCDAEntryType.Unsupported("customEntry"), CCDAEntryType.fromElementName("customEntry"))
    }

    @Test
    fun entryStatusMapsKnownAndUnsupportedCodes() {
        assertEquals(CCDAEntryStatus.Active, CCDAEntryStatus.fromCode("active"))
        assertEquals(CCDAEntryStatus.Completed, CCDAEntryStatus.fromCode("completed"))
        assertEquals(CCDAEntryStatus.Unsupported("custom-status"), CCDAEntryStatus.fromCode("custom-status"))
        assertEquals("completed", CCDAEntryStatus.Completed.rawValue)
    }

    @Test
    fun publicModelsCanBeConstructedByLibraryUsers() {
        val document = CCDADocument(
            header = CCDAHeader(
                documentId = CCDAIdentifier(root = "1.2.3", extensionValue = "doc-1"),
                title = "Continuity of Care Document",
                effectiveTime = CCDATimestamp.parse("20260719090000-0500"),
            ),
            patient = CCDAPatient(
                name = CCDAHumanName(given = listOf("Jane"), family = "Public"),
                addresses = listOf(CCDAAddress(city = "Boston", state = "MA")),
            ),
            sections = listOf(
                CCDASection(
                    id = "section-problems",
                    code = CCDACodedValue(code = "11450-4", displayName = "Problem List"),
                    title = "Problems",
                    entries = listOf(
                        CCDAEntry(
                            id = "entry-hypertension",
                            type = CCDAEntryType.Observation,
                            value = CCDAValue(displayName = "Hypertensive disorder"),
                        ),
                    ),
                ),
            ),
        )

        assertEquals("1.2.3 / doc-1", document.id)
        assertEquals(2026, document.header.effectiveTime?.year)
        assertEquals("Jane", document.patient?.name?.given?.single())
        assertEquals(CCDASectionKind.Problems, document.sections.single().kind)
        assertTrue(document.sections.single().entries.single().value?.displayName?.isNotBlank() == true)
    }
}
