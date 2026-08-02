package com.ccdakit.engine

/**
 * Header metadata parsed from the root C-CDA document.
 *
 * @property realmCode Realm code such as `US`.
 * @property typeId CDA type identifier.
 * @property templateIds Document-level template identifiers.
 * @property documentId Document identifier.
 * @property code Document type code.
 * @property title Document title.
 * @property effectiveTime Document effective timestamp.
 * @property confidentialityCode Confidentiality code.
 * @property languageCode Document language code.
 */
data class CCDAHeader(
    val realmCode: String? = null,
    val typeId: CCDAIdentifier? = null,
    val templateIds: List<CCDATemplateId> = emptyList(),
    val documentId: CCDAIdentifier,
    val code: CCDACodedValue? = null,
    val title: String? = null,
    val effectiveTime: CCDATimestamp? = null,
    val confidentialityCode: CCDACodedValue? = null,
    val languageCode: String? = null,
)
