package com.ccdakit.engine

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class CCDAEngineMappingTest {
    @Test
    fun mapsHeaderPatientSectionsEntriesAndMedia() {
        val engine = CCDAEngine(
            CCDAEngineConfiguration(mediaStoragePolicy = CCDAMediaStoragePolicy.Inline),
        )

        val document = engine.parse(comprehensiveXml.toByteArray())
        val reparsedDocument = engine.parse(comprehensiveXml.toByteArray())

        assertEquals("US", document.header.realmCode)
        assertEquals("2.16.840.1.113883.1.3", document.header.typeId?.root)
        assertEquals("POCD_HD000040", document.header.typeId?.extensionValue)
        assertEquals("1.2.3 / doc-1", document.header.documentId.stringValue)
        assertEquals("Continuity of Care Document", document.header.title)
        assertEquals(2026, document.header.effectiveTime?.year)
        assertEquals(7, document.header.effectiveTime?.month)
        assertEquals("-0500", document.header.effectiveTime?.timeZoneOffset)

        val patient = requireNotNull(document.patient)
        assertEquals(listOf("John", "Quincy"), patient.name?.given)
        assertEquals("Public", patient.name?.family)
        assertEquals(1980, patient.birthTime?.year)
        assertNull(patient.birthTime?.hour)
        val address = patient.addresses.single()
        assertEquals(CCDAAddressUse.PrimaryHome, address.use)
        assertEquals("Boston", address.city)

        assertEquals(2, document.sections.size)
        val problems = document.sections[0]
        assertEquals(true, problems.id.startsWith("s:"))
        assertEquals("Problems", problems.title)
        assertEquals(CCDASectionKind.Problems, problems.kind)
        assertEquals("Hypertension Active", problems.narrativeText)
        assertEquals(1, problems.entries.size)
        assertEquals(1, problems.media.size)

        val problemEntry = problems.entries[0]
        assertEquals(true, problemEntry.id.startsWith("e:"))
        assertEquals(CCDAEntryType.Act, problemEntry.type)
        assertEquals(CCDAEntryStatus.Active, problemEntry.status)
        assertEquals("20200101", problemEntry.effectiveTime?.rawValue)
        assertEquals("#problem-1", problemEntry.textReference)
        assertEquals(1, problemEntry.children.size)
        assertEquals(true, problemEntry.children[0].id.startsWith("e:"))
        assertEquals("Hypertensive disorder", problemEntry.children[0].value?.displayName)

        val media = problems.media.single()
        assertEquals(true, media.id.startsWith("m:"))
        assertEquals(CCDAMediaType.TextHTML, media.mediaType)
        assertArrayEquals("<p>note</p>".toByteArray(), media.loadData())
        assertEquals(reparsedDocument.sections[0].id, problems.id)
        assertEquals(reparsedDocument.sections[0].entries[0].id, problemEntry.id)
        assertEquals(reparsedDocument.sections[0].entries[0].children[0].id, problemEntry.children[0].id)
        assertEquals(reparsedDocument.sections[0].media[0].id, media.id)

        val vitals = document.sections[1]
        assertEquals(CCDASectionKind.VitalSigns, vitals.kind)
        assertEquals("120", vitals.entries[0].children[0].value?.value)
    }

    private val comprehensiveXml = """
        <ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <realmCode code="US"/>
          <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
          <templateId root="2.16.840.1.113883.10.20.22.1.1"/>
          <id root="1.2.3" extension="doc-1"/>
          <code code="34133-9" codeSystem="2.16.840.1.113883.6.1" displayName="Summarization of Episode Note"/>
          <title>Continuity of Care Document</title>
          <effectiveTime value="20260719090000-0500"/>
          <recordTarget>
            <patientRole>
              <id root="patient-1"/>
              <addr use="HP">
                <streetAddressLine>123 Main St</streetAddressLine>
                <city>Boston</city>
                <state>MA</state>
                <postalCode>02118</postalCode>
                <country>US</country>
              </addr>
              <patient>
                <name><given>John</given><given>Quincy</given><family>Public</family></name>
                <birthTime value="19800515"/>
              </patient>
            </patientRole>
          </recordTarget>
          <component>
            <structuredBody>
              <component>
                <section>
                  <templateId root="2.16.840.1.113883.10.20.22.2.5.1"/>
                  <code code="11450-4" displayName="Problem List"/>
                  <title>Problems</title>
                  <text><table><tbody><tr><td>Hypertension</td><td>Active</td></tr></tbody></table></text>
                  <entry>
                    <act>
                      <id root="problem-act-1"/>
                      <code code="CONC" displayName="Concern"/>
                      <text><reference value="#problem-1"/></text>
                      <statusCode code="active"/>
                      <effectiveTime><low value="20200101"/></effectiveTime>
                      <entryRelationship>
                        <observation>
                          <code code="55607006" displayName="Problem Observation"/>
                          <effectiveTime><high value="20200115"/></effectiveTime>
                          <value xsi:type="CD" code="38341003" displayName="Hypertensive disorder"/>
                        </observation>
                      </entryRelationship>
                    </act>
                  </entry>
                  <entry>
                    <observationMedia ID="media-1">
                      <value mediaType="text/html" representation="B64">PHA+bm90ZTwvcD4=</value>
                    </observationMedia>
                  </entry>
                </section>
              </component>
              <component>
                <section>
                  <code code="8716-3" displayName="Vital Signs"/>
                  <title>Vital Signs</title>
                  <entry>
                    <organizer>
                      <component>
                        <observation>
                          <value xsi:type="PQ" value="120" unit="mm[Hg]"/>
                        </observation>
                      </component>
                    </organizer>
                  </entry>
                </section>
              </component>
            </structuredBody>
          </component>
        </ClinicalDocument>
    """.trimIndent()
}
