package com.ccdakit.engine

/**
 * Structured section from a C-CDA document body.
 *
 * @property id Stable identity for list rendering.
 * @property templateIds Section template identifiers.
 * @property code Section code.
 * @property kind Normalized section kind derived from the section code.
 * @property title Section title.
 * @property narrativeText Human-readable narrative text.
 * @property entries Structured clinical entries.
 * @property media Media attachments contained by the section.
 */
data class CCDASection(
    val id: String,
    val templateIds: List<CCDATemplateId> = emptyList(),
    val code: CCDACodedValue? = null,
    val kind: CCDASectionKind = CCDASectionKind.fromCode(code?.code),
    val title: String? = null,
    val narrativeText: String = "",
    val entries: List<CCDAEntry> = emptyList(),
    val media: List<CCDAMedia> = emptyList(),
)
