package com.ccdakit.engine

/** XML element type for a structured C-CDA entry. */
sealed class CCDAEntryType(open val rawValue: String) {
    /** CDA act entry. */
    data object Act : CCDAEntryType("act")
    /** CDA encounter entry. */
    data object Encounter : CCDAEntryType("encounter")
    /** CDA observation entry. */
    data object Observation : CCDAEntryType("observation")
    /** CDA organizer entry. */
    data object Organizer : CCDAEntryType("organizer")
    /** CDA procedure entry. */
    data object Procedure : CCDAEntryType("procedure")
    /** CDA substanceAdministration entry. */
    data object SubstanceAdministration : CCDAEntryType("substanceAdministration")
    /** CDA supply entry. */
    data object Supply : CCDAEntryType("supply")
    /** Unsupported entry element name preserved from source XML. */
    data class Unsupported(override val rawValue: String) : CCDAEntryType(rawValue)

    companion object {
        /** Creates an entry type from an XML element name. */
        fun fromElementName(name: String): CCDAEntryType = when (name) {
            "act" -> Act
            "encounter" -> Encounter
            "observation" -> Observation
            "organizer" -> Organizer
            "procedure" -> Procedure
            "substanceAdministration" -> SubstanceAdministration
            "supply" -> Supply
            else -> Unsupported(name)
        }
    }
}
