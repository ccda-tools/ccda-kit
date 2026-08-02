package com.ccdakit.engine

/**
 * Embedded or referenced media parsed from C-CDA `observationMedia` entries.
 *
 * @property id Stable media identity.
 * @property mediaType Typed media/MIME value.
 * @property representation C-CDA representation metadata.
 * @property payload Payload storage for the media.
 */
data class CCDAMedia(
    val id: String,
    val mediaType: CCDAMediaType,
    val representation: CCDAMediaRepresentation,
    val payload: CCDAMediaPayload,
) {
    /** Whether the media type represents an image. */
    val isImage: Boolean
        get() = mediaType.mimeType?.startsWith("image/") == true

    /** Whether this media payload is stored outside the model. */
    val isCached: Boolean
        get() = payload is CCDAMediaPayload.CachedFile

    /** Loads decoded media bytes from the payload. */
    fun loadData(): ByteArray = when (payload) {
        is CCDAMediaPayload.CachedFile -> payload.file.readBytes()
        is CCDAMediaPayload.InlineBase64 -> java.util.Base64.getDecoder()
            .decode(payload.value.filterNot { it.isWhitespace() })
        CCDAMediaPayload.Unavailable -> throw CCDAMediaPayloadException.Unavailable
    }
}
