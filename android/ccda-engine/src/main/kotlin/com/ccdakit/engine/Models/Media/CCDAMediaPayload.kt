package com.ccdakit.engine

import java.io.File

/** Media payload storage. */
sealed class CCDAMediaPayload {
    /** Payload decoded and written to disk. */
    data class CachedFile(val file: File, val byteCount: Int) : CCDAMediaPayload()
    /** Payload kept as base64 text, usually when caching is disabled or decoding fails. */
    data class InlineBase64(val value: String) : CCDAMediaPayload()
    /** Payload was not available or could not be represented. */
    data object Unavailable : CCDAMediaPayload()
}
