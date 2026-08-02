package com.ccdakit.engine

/**
 * CDA template identifier used to declare document, section, or entry templates.
 *
 * @property root Template OID.
 * @property extensionValue Optional template version or extension.
 */
data class CCDATemplateId(
    val root: String,
    val extensionValue: String? = null,
)
