package com.ccdakit.engine

/**
 * Parsed C-CDA document containing header metadata, patient demographics, and structured sections.
 *
 * @property header Document header metadata.
 * @property patient Patient demographics when present.
 * @property sections Structured document sections.
 */
data class CCDADocument(
    val header: CCDAHeader,
    val patient: CCDAPatient? = null,
    val sections: List<CCDASection> = emptyList(),
) {
    /** Lightweight document identity derived from the header document identifier. */
    val id: String
        get() = header.documentId.stringValue
}
