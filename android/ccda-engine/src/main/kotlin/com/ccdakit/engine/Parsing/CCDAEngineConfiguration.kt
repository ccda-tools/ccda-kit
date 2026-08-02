package com.ccdakit.engine

import java.io.File

/**
 * Runtime configuration for C-CDA parsing.
 *
 * @property mediaStoragePolicy Storage behavior for embedded media payloads.
 * @property mediaCacheDirectory Directory used when media is cached to disk.
 */
data class CCDAEngineConfiguration(
    val mediaStoragePolicy: CCDAMediaStoragePolicy = CCDAMediaStoragePolicy.CacheToDisk,
    val mediaCacheDirectory: File? = File(System.getProperty("java.io.tmpdir"), "ccda-kit-media-cache"),
)

/** Storage policy for embedded C-CDA media payloads. */
sealed class CCDAMediaStoragePolicy {
    /** Keep base64 media payloads in the parsed model. */
    data object Inline : CCDAMediaStoragePolicy()
    /** Decode supported media payloads and write them to the configured cache directory. */
    data object CacheToDisk : CCDAMediaStoragePolicy()
}

/** Errors raised by the C-CDA engine. */
sealed class CCDAEngineException(message: String, cause: Throwable? = null) : Exception(message, cause) {
    /** XML could not be parsed into a C-CDA document. */
    class InvalidXml(val failure: CCDAXmlParsingFailure) : CCDAEngineException(failure.toString())
    /** Media payload could not be written to the cache directory. */
    class MediaCacheWriteFailed(val directory: File, cause: Throwable) :
        CCDAEngineException("Unable to cache C-CDA media at ${directory.path}: ${cause.message}", cause)
}

/**
 * Detailed XML parsing failure information.
 *
 * @property message Human-readable parser failure.
 * @property lineNumber XML line number when reported by the parser.
 * @property columnNumber XML column number when reported by the parser.
 * @property sourceDescription Optional source path or label.
 * @property underlyingErrorDescription Underlying parser error description.
 */
data class CCDAXmlParsingFailure(
    val message: String,
    val lineNumber: Int? = null,
    val columnNumber: Int? = null,
    val sourceDescription: String? = null,
    val underlyingErrorDescription: String? = null,
) {
    override fun toString(): String = buildList {
        add("Invalid C-CDA XML: $message")
        sourceDescription?.let { add("source: $it") }
        if (lineNumber != null && columnNumber != null) {
            add("line: $lineNumber, column: $columnNumber")
        } else {
            lineNumber?.let { add("line: $it") }
            columnNumber?.let { add("column: $it") }
        }
        underlyingErrorDescription?.let { add("underlying error: $it") }
    }.joinToString("; ")
}
