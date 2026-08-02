package com.ccdakit.engine

/**
 * Coded clinical value from a CDA element such as `code`, `value`, or `confidentialityCode`.
 *
 * @property code Code value from the source XML.
 * @property codeSystem OID or identifier for the coding system.
 * @property codeSystemName Human-readable coding system name.
 * @property displayName Human-readable display text supplied by the source XML.
 */
data class CCDACodedValue(
    val code: String? = null,
    val codeSystem: String? = null,
    val codeSystemName: String? = null,
    val displayName: String? = null,
)
