package com.ccdakit.compose

import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import android.webkit.WebView
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.ccdakit.engine.CCDAMedia
import com.ccdakit.engine.CCDAMediaPayload
import com.ccdakit.engine.CCDAMediaType
import java.io.File

/** Full-screen media preview for supported C-CDA media attachments. */
@Composable
fun CCDAMediaPreview(media: CCDAMedia, onDismiss: () -> Unit) {
    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false),
    ) {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colorScheme.surface,
        ) {
            Column(Modifier.fillMaxSize()) {
                Row(Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 12.dp)) {
                    Text(
                        text = media.previewTitle(),
                        modifier = Modifier.weight(1f),
                        style = MaterialTheme.typography.titleLarge,
                    )
                    Button(onClick = onDismiss) {
                        Text("Close")
                    }
                }
                HorizontalDivider()
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(MaterialTheme.colorScheme.surface)
                        .padding(16.dp),
                ) {
                    when (media.mediaType) {
                        CCDAMediaType.TextHTML -> CCDAHtmlPreview(media)
                        CCDAMediaType.TextPlain -> CCDATextPreview(media)
                        CCDAMediaType.ApplicationPDF -> CCDAPDFPreview(media)
                        CCDAMediaType.ImagePNG,
                        CCDAMediaType.ImageJPEG,
                        CCDAMediaType.ImageGIF,
                        -> CCDAImagePreview(media)
                        is CCDAMediaType.Unsupported, CCDAMediaType.Unknown -> CCDAMediaDetailsPreview(media)
                    }
                }
            }
        }
    }
}

@Composable
private fun CCDAHtmlPreview(media: CCDAMedia) {
    val html = remember(media) {
        runCatching { media.loadData().toString(Charsets.UTF_8) }.getOrDefault("")
    }

    AndroidView(
        factory = { context ->
            WebView(context).apply {
                loadDataWithBaseURL(null, html, "text/html", "UTF-8", null)
            }
        },
        modifier = Modifier.fillMaxSize(),
    )
}

@Composable
private fun CCDATextPreview(media: CCDAMedia) {
    val text = remember(media) {
        runCatching { media.loadData().toString(Charsets.UTF_8) }
            .getOrDefault("Unable to load text attachment.")
    }

    Text(
        text = text,
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()),
        style = MaterialTheme.typography.bodyMedium,
    )
}

@Composable
private fun CCDAPDFPreview(media: CCDAMedia) {
    val context = LocalContext.current
    val pageBitmap = remember(media) {
        runCatching {
            val file = media.fileForPreview(context.cacheDir)
            renderFirstPDFPage(file)
        }.getOrNull()
    }

    if (pageBitmap == null) {
        CCDAMediaDetailsPreview(media)
    } else {
        Image(
            bitmap = pageBitmap.asImageBitmap(),
            contentDescription = "PDF preview",
            modifier = Modifier.fillMaxWidth().heightIn(max = 720.dp),
            contentScale = ContentScale.FillWidth,
        )
    }
}

@Composable
private fun CCDAImagePreview(media: CCDAMedia) {
    val image = remember(media) {
        runCatching {
            val data = media.loadData()
            android.graphics.BitmapFactory.decodeByteArray(data, 0, data.size)
        }.getOrNull()
    }

    if (image == null) {
        CCDAMediaDetailsPreview(media)
    } else {
        Image(
            bitmap = image.asImageBitmap(),
            contentDescription = "Image attachment",
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Fit,
        )
    }
}

@Composable
private fun CCDAMediaDetailsPreview(media: CCDAMedia) {
    Column(Modifier.padding(top = 4.dp)) {
        Text(media.mediaType.mimeType ?: "Unknown media type")
        Text(media.payloadDescription(), style = MaterialTheme.typography.bodySmall)
    }
}

private fun CCDAMedia.previewTitle(): String = when (val type = mediaType) {
    CCDAMediaType.ImagePNG, CCDAMediaType.ImageJPEG, CCDAMediaType.ImageGIF -> "Image"
    CCDAMediaType.ApplicationPDF -> "PDF"
    CCDAMediaType.TextPlain -> "Text"
    CCDAMediaType.TextHTML -> "HTML"
    is CCDAMediaType.Unsupported -> type.mimeType
    CCDAMediaType.Unknown -> "Attachment"
}

private fun CCDAMedia.payloadDescription(): String =
    runCatching { "${loadData().size} bytes" }.getOrElse { "Payload unavailable" }

private fun CCDAMedia.fileForPreview(cacheDirectory: File): File = when (val mediaPayload = payload) {
    is CCDAMediaPayload.CachedFile -> mediaPayload.file
    is CCDAMediaPayload.InlineBase64 -> {
        val file = File(cacheDirectory, "ccda-preview-$id.pdf".safePreviewFileName())
        if (!file.exists()) {
            file.writeBytes(loadData())
        }
        file
    }
    CCDAMediaPayload.Unavailable -> error("No media payload available.")
}

private fun renderFirstPDFPage(file: File): Bitmap {
    ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
        PdfRenderer(descriptor).use { renderer ->
            val page = renderer.openPage(0)
            try {
                val bitmap = Bitmap.createBitmap(page.width, page.height, Bitmap.Config.ARGB_8888)
                page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                return bitmap
            } finally {
                page.close()
            }
        }
    }
}

private fun String.safePreviewFileName(): String =
    replace(Regex("[^A-Za-z0-9._-]"), "_")
