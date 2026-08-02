package com.ccdakit.engine

/** CDA address use code. */
sealed class CCDAAddressUse(open val rawValue: String?) {
    /** Home address. */
    data object Home : CCDAAddressUse("H")
    /** Primary home address. */
    data object PrimaryHome : CCDAAddressUse("HP")
    /** Workplace address. */
    data object WorkPlace : CCDAAddressUse("WP")
    /** Temporary address. */
    data object Temporary : CCDAAddressUse("TMP")
    /** Old address. */
    data object Old : CCDAAddressUse("OLD")
    /** Bad or unusable address. */
    data object Bad : CCDAAddressUse("BAD")
    /** Unsupported address use preserved from source XML. */
    data class Unsupported(override val rawValue: String) : CCDAAddressUse(rawValue)
    /** Missing or empty address use. */
    data object Unknown : CCDAAddressUse(null)

    companion object {
        /** Creates an address use from a CDA `addr/@use` code. */
        fun fromCode(code: String?): CCDAAddressUse = when (code?.uppercase()) {
            null, "" -> Unknown
            "H" -> Home
            "HP" -> PrimaryHome
            "WP" -> WorkPlace
            "TMP" -> Temporary
            "OLD" -> Old
            "BAD" -> Bad
            else -> Unsupported(code)
        }
    }
}
