package com.ccdakit.engine

/** Internal XML node used by the DOM-based parser. */
internal data class CCDAXmlNode(
    val name: String,
    val attributes: Map<String, String> = emptyMap(),
    val children: MutableList<CCDAXmlNode> = mutableListOf(),
    val textParts: MutableList<String> = mutableListOf(),
) {
    /** Text from this node and descendants with whitespace normalized. */
    val cleanText: String
        get() = collectText()
            .joinToString(" ")
            .replace(Regex("[\\s\\u00A0]+"), " ")
            .trim()

    /** Returns an attribute value by XML attribute name. */
    fun attribute(name: String): String? = attributes[name]

    /** Returns direct child elements with the supplied XML element name. */
    fun direct(name: String): List<CCDAXmlNode> = children.filter { it.name == name }

    /** Returns the first descendant matching the supplied XML element name. */
    fun first(name: String): CCDAXmlNode? {
        children.firstOrNull { it.name == name }?.let { return it }
        return children.firstNotNullOfOrNull { it.first(name) }
    }

    private fun collectText(): List<String> =
        textParts + children.flatMap { it.collectText() }
}

internal object CCDAXmlName {
    const val ADMINISTRATIVE_GENDER_CODE = "administrativeGenderCode"
    const val ADDR = "addr"
    const val BIRTH_TIME = "birthTime"
    const val CITY = "city"
    const val CODE = "code"
    const val COMPONENT = "component"
    const val CONFIDENTIALITY_CODE = "confidentialityCode"
    const val COUNTRY = "country"
    const val EFFECTIVE_TIME = "effectiveTime"
    const val ENTRY = "entry"
    const val ENTRY_RELATIONSHIP = "entryRelationship"
    const val ETHNIC_GROUP_CODE = "ethnicGroupCode"
    const val FAMILY = "family"
    const val GIVEN = "given"
    const val HIGH = "high"
    const val ID = "id"
    const val LANGUAGE_CODE = "languageCode"
    const val LOW = "low"
    const val MARITAL_STATUS_CODE = "maritalStatusCode"
    const val NAME = "name"
    const val OBSERVATION_MEDIA = "observationMedia"
    const val PATIENT = "patient"
    const val PATIENT_ROLE = "patientRole"
    const val POSTAL_CODE = "postalCode"
    const val PREFIX = "prefix"
    const val RACE_CODE = "raceCode"
    const val REALM_CODE = "realmCode"
    const val RECORD_TARGET = "recordTarget"
    const val REFERENCE = "reference"
    const val SECTION = "section"
    const val STATE = "state"
    const val STATUS_CODE = "statusCode"
    const val STREET_ADDRESS_LINE = "streetAddressLine"
    const val STRUCTURED_BODY = "structuredBody"
    const val TELECOM = "telecom"
    const val TEMPLATE_ID = "templateId"
    const val TEXT = "text"
    const val TITLE = "title"
    const val TYPE_ID = "typeId"
    const val VALUE = "value"
}

internal object CCDAXmlAttribute {
    const val CODE = "code"
    const val CODE_SYSTEM = "codeSystem"
    const val CODE_SYSTEM_NAME = "codeSystemName"
    const val DISPLAY_NAME = "displayName"
    const val EXTENSION = "extension"
    const val ID = "ID"
    const val MEDIA_TYPE = "mediaType"
    const val REPRESENTATION = "representation"
    const val ROOT = "root"
    const val TYPE = "type"
    const val XSI_TYPE = "xsi:type"
    const val UNIT = "unit"
    const val USE = "use"
    const val VALUE = "value"
}

internal object CCDAXmlNamespace {
    const val XML_SCHEMA_INSTANCE = "http://www.w3.org/2001/XMLSchema-instance"
}
