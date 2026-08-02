package com.ccdakit.engine

/** Status code attached to a structured C-CDA entry. */
sealed class CCDAEntryStatus(open val rawValue: String) {
    /** Entry is currently active. */
    data object Active : CCDAEntryStatus("active")
    /** Entry has been completed. */
    data object Completed : CCDAEntryStatus("completed")
    /** Entry was aborted before completion. */
    data object Aborted : CCDAEntryStatus("aborted")
    /** Entry was cancelled. */
    data object Cancelled : CCDAEntryStatus("cancelled")
    /** Entry is temporarily suspended. */
    data object Suspended : CCDAEntryStatus("suspended")
    /** Entry is temporarily held. */
    data object Held : CCDAEntryStatus("held")
    /** Entry is newly created or pending. */
    data object New : CCDAEntryStatus("new")
    /** Entry status is normal. */
    data object Normal : CCDAEntryStatus("normal")
    /** Entry has been made obsolete. */
    data object Obsolete : CCDAEntryStatus("obsolete")
    /** Entry has been nullified. */
    data object Nullified : CCDAEntryStatus("nullified")
    /** Unsupported status code preserved from source XML. */
    data class Unsupported(override val rawValue: String) : CCDAEntryStatus(rawValue)

    companion object {
        /** Creates an entry status from a C-CDA `statusCode/@code` value. */
        fun fromCode(code: String): CCDAEntryStatus = when (code) {
            "active" -> Active
            "completed" -> Completed
            "aborted" -> Aborted
            "cancelled" -> Cancelled
            "suspended" -> Suspended
            "held" -> Held
            "new" -> New
            "normal" -> Normal
            "obsolete" -> Obsolete
            "nullified" -> Nullified
            else -> Unsupported(code)
        }
    }
}
