package com.ccdakit.engine

/**
 * Patient human name parsed from CDA name components.
 *
 * @property prefix Name prefix such as title or honorific.
 * @property given Given name components.
 * @property family Family name.
 */
data class CCDAHumanName(
    val prefix: String? = null,
    val given: List<String> = emptyList(),
    val family: String? = null,
)
