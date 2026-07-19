import Foundation
import XCTest
@testable import CCDAEngine

final class CCDAEngineDetailedMappingTests: XCTestCase {
    func testMapsHeaderPatientSectionsEntriesAndMedia() throws {
        let engine = CCDAEngine(
            configuration: CCDAEngineConfiguration(
                mediaStoragePolicy: .inline,
                mediaCacheDirectory: nil
            )
        )

        let document = try engine.parse(data: Data(Self.comprehensiveXML.utf8))

        XCTAssertEqual(document.header.realmCode, "US")
        XCTAssertEqual(document.header.typeId?.root, "2.16.840.1.113883.1.3")
        XCTAssertEqual(document.header.typeId?.extensionValue, "POCD_HD000040")
        XCTAssertEqual(document.header.templateIds.map(\.root), [
            "2.16.840.1.113883.10.20.22.1.1",
            "2.16.840.1.113883.10.20.22.1.2"
        ])
        XCTAssertEqual(document.header.documentId.root, "1.2.3")
        XCTAssertEqual(document.header.documentId.extensionValue, "doc-1")
        XCTAssertEqual(document.header.code?.code, "34133-9")
        XCTAssertEqual(document.header.code?.codeSystem, "2.16.840.1.113883.6.1")
        XCTAssertEqual(document.header.code?.codeSystemName, "LOINC")
        XCTAssertEqual(document.header.code?.displayName, "Summarization of Episode Note")
        XCTAssertEqual(document.header.title, "Continuity of Care Document")
        XCTAssertEqual(document.header.effectiveTime?.rawValue, "20260719090000-0500")
        XCTAssertEqual(document.header.effectiveTime?.year, 2026)
        XCTAssertEqual(document.header.effectiveTime?.month, 7)
        XCTAssertEqual(document.header.effectiveTime?.day, 19)
        XCTAssertEqual(document.header.effectiveTime?.hour, 9)
        XCTAssertEqual(document.header.effectiveTime?.minute, 0)
        XCTAssertEqual(document.header.effectiveTime?.second, 0)
        XCTAssertEqual(document.header.effectiveTime?.timeZoneOffset, "-0500")
        XCTAssertEqual(document.header.confidentialityCode?.code, "N")
        XCTAssertEqual(document.header.languageCode, "en-US")

        let patient = try XCTUnwrap(document.patient)
        XCTAssertEqual(patient.ids, [
            CCDAIdentifier(root: "2.16.840.1.113883.19.5", extensionValue: "patient-1"),
            CCDAIdentifier(root: "2.16.840.1.113883.19.6", extensionValue: nil)
        ])
        XCTAssertEqual(patient.name?.prefix, "Mr.")
        XCTAssertEqual(patient.name?.given, ["John", "Quincy"])
        XCTAssertEqual(patient.name?.family, "Public")
        XCTAssertEqual(patient.gender?.code, "M")
        XCTAssertEqual(patient.birthTime?.rawValue, "19800515")
        XCTAssertEqual(patient.birthTime?.year, 1980)
        XCTAssertEqual(patient.birthTime?.month, 5)
        XCTAssertEqual(patient.birthTime?.day, 15)
        XCTAssertNil(patient.birthTime?.hour)
        XCTAssertEqual(patient.maritalStatus?.displayName, "Married")
        XCTAssertEqual(patient.race?.displayName, "White")
        XCTAssertEqual(patient.ethnicity?.displayName, "Not Hispanic or Latino")
        XCTAssertEqual(patient.telecoms, ["tel:+1-555-0100", "mailto:john@example.com"])

        let address = try XCTUnwrap(patient.addresses.first)
        XCTAssertEqual(address.use, "HP")
        XCTAssertEqual(address.streetLines, ["123 Main St", "Apt 4B"])
        XCTAssertEqual(address.city, "Boston")
        XCTAssertEqual(address.state, "MA")
        XCTAssertEqual(address.postalCode, "02118")
        XCTAssertEqual(address.country, "US")

        XCTAssertEqual(document.sections.count, 2)

        let problems = document.sections[0]
        XCTAssertEqual(problems.templateIds.first?.root, "2.16.840.1.113883.10.20.22.2.5.1")
        XCTAssertEqual(problems.code?.code, "11450-4")
        XCTAssertEqual(problems.kind, .problems)
        XCTAssertEqual(problems.code?.displayName, "Problem List")
        XCTAssertEqual(problems.title, "Problems")
        XCTAssertEqual(problems.narrativeText, "Hypertension Active")
        XCTAssertEqual(problems.entries.count, 1)
        XCTAssertEqual(problems.media.count, 1)

        let problemEntry = problems.entries[0]
        XCTAssertEqual(problemEntry.type, "act")
        XCTAssertEqual(problemEntry.templateIds.first?.root, "2.16.840.1.113883.10.20.22.4.3")
        XCTAssertEqual(problemEntry.identifiers.first?.root, "problem-act-1")
        XCTAssertEqual(problemEntry.code?.code, "CONC")
        XCTAssertEqual(problemEntry.status, "active")
        XCTAssertEqual(problemEntry.effectiveTime?.rawValue, "20200101")
        XCTAssertEqual(problemEntry.textReference, "#problem-1")
        XCTAssertEqual(problemEntry.children.count, 1)

        let nestedObservation = problemEntry.children[0]
        XCTAssertEqual(nestedObservation.type, "observation")
        XCTAssertEqual(nestedObservation.code?.displayName, "Problem Observation")
        XCTAssertEqual(nestedObservation.status, "completed")
        XCTAssertEqual(nestedObservation.effectiveTime?.rawValue, "20200115")
        XCTAssertEqual(nestedObservation.value?.type, "CD")
        XCTAssertEqual(nestedObservation.value?.code, "38341003")
        XCTAssertEqual(nestedObservation.value?.displayName, "Hypertensive disorder")

        let media = try XCTUnwrap(problems.media.first)
        XCTAssertEqual(media.id, "media-1")
        XCTAssertEqual(media.mediaType, .textHTML)
        XCTAssertEqual(media.representation, .base64)
        XCTAssertEqual(try media.loadData(), Data("<p>note</p>".utf8))

        let vitals = document.sections[1]
        XCTAssertEqual(vitals.title, "Vital Signs")
        XCTAssertEqual(vitals.kind, .vitalSigns)
        XCTAssertEqual(vitals.entries.count, 1)

        let organizer = vitals.entries[0]
        XCTAssertEqual(organizer.type, "organizer")
        XCTAssertEqual(organizer.effectiveTime?.rawValue, "20260701")
        XCTAssertEqual(organizer.children.count, 1)

        let componentObservation = organizer.children[0]
        XCTAssertEqual(componentObservation.type, "observation")
        XCTAssertEqual(componentObservation.effectiveTime?.rawValue, "20260702")
        XCTAssertEqual(componentObservation.value?.type, "PQ")
        XCTAssertEqual(componentObservation.value?.value, "120")
        XCTAssertEqual(componentObservation.value?.unit, "mm[Hg]")
    }

    func testReturnsEmptySectionsWhenStructuredBodyIsMissing() throws {
        let xml = """
        <ClinicalDocument xmlns="urn:hl7-org:v3">
            <id root="1.2.3" extension="doc-1"/>
            <title>No Body</title>
        </ClinicalDocument>
        """

        let document = try CCDAEngine().parse(data: Data(xml.utf8))

        XCTAssertEqual(document.header.title, "No Body")
        XCTAssertNil(document.patient)
        XCTAssertTrue(document.sections.isEmpty)
    }

    func testMissingDocumentIdFallsBackToEmptyIdentifier() throws {
        let xml = """
        <ClinicalDocument xmlns="urn:hl7-org:v3">
            <title>No Document Id</title>
        </ClinicalDocument>
        """

        let document = try CCDAEngine().parse(data: Data(xml.utf8))

        XCTAssertEqual(document.header.documentId, CCDAIdentifier(root: nil, extensionValue: nil))
        XCTAssertEqual(document.id, "")
    }

    private static let comprehensiveXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <realmCode code="US"/>
        <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
        <templateId root="2.16.840.1.113883.10.20.22.1.1"/>
        <templateId root="2.16.840.1.113883.10.20.22.1.2"/>
        <id root="1.2.3" extension="doc-1"/>
        <code code="34133-9" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Summarization of Episode Note"/>
        <title>Continuity of Care Document</title>
        <effectiveTime value="20260719090000-0500"/>
        <confidentialityCode code="N" codeSystem="2.16.840.1.113883.5.25" displayName="Normal"/>
        <languageCode code="en-US"/>
        <recordTarget>
            <patientRole>
                <id root="2.16.840.1.113883.19.5" extension="patient-1"/>
                <id root="2.16.840.1.113883.19.6"/>
                <addr use="HP">
                    <streetAddressLine>123 Main St</streetAddressLine>
                    <streetAddressLine>Apt 4B</streetAddressLine>
                    <city>Boston</city>
                    <state>MA</state>
                    <postalCode>02118</postalCode>
                    <country>US</country>
                </addr>
                <telecom value="tel:+1-555-0100"/>
                <telecom value="mailto:john@example.com"/>
                <patient>
                    <name>
                        <prefix>Mr.</prefix>
                        <given>John</given>
                        <given>Quincy</given>
                        <family>Public</family>
                    </name>
                    <administrativeGenderCode code="M" displayName="Male"/>
                    <birthTime value="19800515"/>
                    <maritalStatusCode code="M" displayName="Married"/>
                    <raceCode code="2106-3" displayName="White"/>
                    <ethnicGroupCode code="2186-5" displayName="Not Hispanic or Latino"/>
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
                        <text>
                            <table>
                                <tbody>
                                    <tr><td>Hypertension</td><td>Active</td></tr>
                                </tbody>
                            </table>
                        </text>
                        <entry>
                            <act>
                                <templateId root="2.16.840.1.113883.10.20.22.4.3"/>
                                <id root="problem-act-1"/>
                                <code code="CONC" displayName="Concern"/>
                                <text><reference value="#problem-1"/></text>
                                <statusCode code="active"/>
                                <effectiveTime><low value="20200101"/></effectiveTime>
                                <entryRelationship>
                                    <observation>
                                        <code code="55607006" displayName="Problem Observation"/>
                                        <statusCode code="completed"/>
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
                        <text>Blood pressure 120 mmHg</text>
                        <entry>
                            <organizer>
                                <code code="46680005" displayName="Vital signs"/>
                                <effectiveTime value="20260701"/>
                                <component>
                                    <observation>
                                        <code code="8480-6" displayName="Systolic blood pressure"/>
                                        <effectiveTime value="20260702"/>
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
    """
}
