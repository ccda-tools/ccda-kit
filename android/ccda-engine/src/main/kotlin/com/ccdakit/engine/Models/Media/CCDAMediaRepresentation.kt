package com.ccdakit.engine

/** C-CDA media representation metadata. */
sealed class CCDAMediaRepresentation(open val rawValue: String?) {
    /** Base64-encoded payload representation. */
    data object Base64 : CCDAMediaRepresentation("B64")
    /** Text payload representation. */
    data object Text : CCDAMediaRepresentation("TXT")
    /** Unsupported representation preserved from source XML. */
    data class Unsupported(override val rawValue: String) : CCDAMediaRepresentation(rawValue)
    /** Missing or empty representation. */
    data object Unknown : CCDAMediaRepresentation(null)

    companion object {
        /** Creates a representation from the XML value. */
        fun fromRawValue(rawValue: String?): CCDAMediaRepresentation = when (rawValue?.uppercase()) {
            null, "" -> Unknown
            "B64" -> Base64
            "TXT" -> Text
            else -> Unsupported(rawValue)
        }
    }
}
