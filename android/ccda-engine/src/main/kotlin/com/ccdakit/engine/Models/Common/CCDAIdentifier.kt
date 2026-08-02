package com.ccdakit.engine

/**
 * CDA identifier with optional root and extension components.
 *
 * @property root Identifier root, usually an OID.
 * @property extensionValue Identifier extension value.
 */
data class CCDAIdentifier(
    val root: String? = null,
    val extensionValue: String? = null,
) {
    /** Root and extension combined for lightweight display and stable comparisons. */
    val stringValue: String
        get() = listOfNotNull(root, extensionValue).joinToString(" / ")
}
