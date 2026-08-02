package com.ccdakit.engine

/**
 * Structured clinical entry inside a C-CDA section.
 *
 * @property id Stable identity for list and tree rendering.
 * @property type XML element type for the entry, such as `observation` or `substanceAdministration`.
 * @property templateIds Template identifiers attached to this entry.
 * @property identifiers Entry identifiers.
 * @property code Primary coded concept for the entry.
 * @property status Entry status code when present.
 * @property effectiveTime Effective time value or low/high fallback parsed from the XML timestamp.
 * @property value Entry value parsed from the direct `value` element.
 * @property textReference Narrative text reference, usually an anchor such as `#problem-1`.
 * @property children Nested entries from `entryRelationship` or `component` children.
 */
data class CCDAEntry(
    val id: String,
    val type: CCDAEntryType,
    val templateIds: List<CCDATemplateId> = emptyList(),
    val identifiers: List<CCDAIdentifier> = emptyList(),
    val code: CCDACodedValue? = null,
    val status: CCDAEntryStatus? = null,
    val effectiveTime: CCDATimestamp? = null,
    val value: CCDAValue? = null,
    val textReference: String? = null,
    val children: List<CCDAEntry> = emptyList(),
)
