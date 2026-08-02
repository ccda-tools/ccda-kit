package com.ccdakit.engine

/** Known media types with fallback for vendor-specific MIME values. */
sealed class CCDAMediaType(open val mimeType: String?) {
    /** PNG image. */
    data object ImagePNG : CCDAMediaType("image/png")
    /** JPEG image. */
    data object ImageJPEG : CCDAMediaType("image/jpeg")
    /** GIF image. */
    data object ImageGIF : CCDAMediaType("image/gif")
    /** PDF document. */
    data object ApplicationPDF : CCDAMediaType("application/pdf")
    /** Plain text document. */
    data object TextPlain : CCDAMediaType("text/plain")
    /** HTML document. */
    data object TextHTML : CCDAMediaType("text/html")
    /** Unsupported MIME value preserved from source XML. */
    data class Unsupported(override val mimeType: String) : CCDAMediaType(mimeType)
    /** Missing or empty MIME value. */
    data object Unknown : CCDAMediaType(null)

    companion object {
        /** Creates a media type from a MIME string. */
        fun fromMimeType(mimeType: String?): CCDAMediaType = when (mimeType?.lowercase()) {
            null, "" -> Unknown
            "image/png" -> ImagePNG
            "image/jpeg", "image/jpg" -> ImageJPEG
            "image/gif" -> ImageGIF
            "application/pdf" -> ApplicationPDF
            "text/plain" -> TextPlain
            "text/html" -> TextHTML
            else -> Unsupported(mimeType)
        }
    }
}
