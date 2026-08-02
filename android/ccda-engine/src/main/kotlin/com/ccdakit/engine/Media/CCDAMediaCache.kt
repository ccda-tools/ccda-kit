package com.ccdakit.engine

import java.io.File

/** Writes decoded C-CDA media payloads to a cache directory. */
internal class CCDAMediaCache(private val directory: File) {
    /** Stores media bytes using a safe filename and an extension based on MIME type. */
    fun store(data: ByteArray, id: String, mediaType: CCDAMediaType): File {
        directory.mkdirs()
        val file = File(directory, "${safeFileName(id)}${extension(mediaType)}")
        file.writeBytes(data)
        return file
    }

    private fun safeFileName(value: String): String =
        value.map { if (it.isLetterOrDigit() || it == '-' || it == '_') it else '_' }
            .joinToString("")
            .ifBlank { "media" }

    private fun extension(mediaType: CCDAMediaType): String = when (mediaType) {
        CCDAMediaType.ImagePNG -> ".png"
        CCDAMediaType.ImageJPEG -> ".jpg"
        CCDAMediaType.ImageGIF -> ".gif"
        CCDAMediaType.ApplicationPDF -> ".pdf"
        CCDAMediaType.TextPlain -> ".txt"
        CCDAMediaType.TextHTML -> ".html"
        is CCDAMediaType.Unsupported, CCDAMediaType.Unknown -> ".bin"
    }
}
