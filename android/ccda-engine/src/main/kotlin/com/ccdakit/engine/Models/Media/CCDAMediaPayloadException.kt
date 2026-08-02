package com.ccdakit.engine

/** Errors raised while loading media payload data. */
sealed class CCDAMediaPayloadException(message: String) : Exception(message) {
    /** No payload is available. */
    data object Unavailable : CCDAMediaPayloadException("No media payload is available.")
}
