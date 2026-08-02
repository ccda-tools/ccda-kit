package com.ccdakit.compose

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.Article
import androidx.compose.material.icons.outlined.Attachment
import androidx.compose.material.icons.outlined.CalendarMonth
import androidx.compose.material.icons.outlined.Description
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material.icons.outlined.Image
import androidx.compose.material.icons.outlined.Language
import androidx.compose.material.icons.outlined.MonitorHeart
import androidx.compose.material.icons.outlined.Numbers
import androidx.compose.material.icons.outlined.PersonSearch
import androidx.compose.material.icons.outlined.PictureAsPdf
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import com.ccdakit.engine.CCDADocument
import com.ccdakit.engine.CCDAEntry
import com.ccdakit.engine.CCDAHeader
import com.ccdakit.engine.CCDAMedia
import com.ccdakit.engine.CCDAMediaType
import com.ccdakit.engine.CCDAPatient
import com.ccdakit.engine.CCDASection

/** Default SwiftUI-style Compose renderer for a parsed C-CDA document. */
@Composable
fun CCDADocumentView(
    document: CCDADocument,
    modifier: Modifier = Modifier,
    onOpenMedia: ((CCDAMedia) -> Unit)? = null,
) {
    Surface(
        modifier = modifier,
        color = MaterialTheme.colorScheme.surfaceContainerLowest,
    ) {
        CCDAComposableDocumentView(
            document = document,
            modifier = Modifier.background(MaterialTheme.colorScheme.surfaceContainerLowest),
            header = { CCDAHeaderView(it) },
            patient = { CCDAPatientView(it) },
            section = { section, entry, media ->
                CCDASectionView(section = section, entry = entry, media = media)
            },
            entry = { CCDAEntryRow(it) },
            media = { CCDAMediaView(media = it, onOpen = onOpenMedia) },
        )
    }
}

/** Composable document renderer that lets callers provide host-owned renderers for each document part. */
@Composable
fun CCDAComposableDocumentView(
    document: CCDADocument,
    modifier: Modifier = Modifier,
    header: @Composable (CCDAHeader) -> Unit,
    patient: @Composable (CCDAPatient) -> Unit,
    section: @Composable (
        CCDASection,
        @Composable (CCDAEntry) -> Unit,
        @Composable (CCDAMedia) -> Unit,
    ) -> Unit,
    entry: @Composable (CCDAEntry) -> Unit,
    media: @Composable (CCDAMedia) -> Unit,
) {
    LazyColumn(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(14.dp),
        contentPadding = androidx.compose.foundation.layout.PaddingValues(16.dp),
    ) {
        item { header(document.header) }
        document.patient?.let { item { patient(it) } }
        items(document.sections, key = { it.id }) { section ->
            section(section, entry, media)
        }
    }
}

/** Default renderer for C-CDA header metadata. */
@Composable
fun CCDAHeaderView(header: CCDAHeader, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = androidx.compose.foundation.shape.RoundedCornerShape(CCDATheme.CornerRadius),
        colors = CardDefaults.cardColors(containerColor = CCDATheme.Primary),
    ) {
        Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                Icon(
                    imageVector = Icons.Outlined.Description,
                    contentDescription = null,
                    tint = androidx.compose.ui.graphics.Color.White,
                )
                Text(
                    text = header.title ?: header.code?.displayName ?: "C-CDA Document",
                    style = MaterialTheme.typography.titleLarge,
                    color = androidx.compose.ui.graphics.Color.White,
                )
            }

            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                CCDASummaryPill("Document ID", header.documentId.stringValue, Icons.Outlined.Numbers)
                header.effectiveTime?.let {
                    CCDASummaryPill("Effective", it.formattedDateTime(), Icons.Outlined.CalendarMonth)
                }
                header.languageCode?.let {
                    CCDASummaryPill("Language", it, Icons.Outlined.Language)
                }
            }
        }
    }
}

/** Default renderer for C-CDA patient demographics. */
@Composable
fun CCDAPatientView(patient: CCDAPatient, modifier: Modifier = Modifier) {
    CCDACard(title = "Patient", icon = Icons.Outlined.PersonSearch, accent = CCDATheme.Secondary, modifier = modifier) {
        patient.name?.formattedName()?.takeIf { it.isNotBlank() }?.let {
            CCDALabeledText("Name", it)
        }
        patient.birthTime?.let { CCDALabeledText("DOB", it.formattedDateTime()) }
        (patient.gender?.displayName ?: patient.gender?.code)?.let { CCDALabeledText("Gender", it) }
        patient.addresses.forEach { address ->
            CCDALabeledText("Address", address.formattedPostalAddress())
        }
    }
}

/** Default renderer for a C-CDA section. */
@Composable
fun CCDASectionView(
    section: CCDASection,
    modifier: Modifier = Modifier,
    entry: @Composable (CCDAEntry) -> Unit = { CCDAEntryRow(it) },
    media: @Composable (CCDAMedia) -> Unit = { CCDAMediaView(it) },
) {
    CCDACard(
        title = section.title ?: section.code?.displayName ?: "Section",
        icon = Icons.Outlined.Folder,
        accent = CCDATheme.Primary,
        modifier = modifier,
    ) {
        if (section.narrativeText.isNotBlank()) {
            Text(section.narrativeText, style = MaterialTheme.typography.bodyMedium)
            Spacer(Modifier.height(8.dp))
        }
        for (entryItem in section.entries) {
            entry(entryItem)
        }
        for (mediaItem in section.media) {
            media(mediaItem)
        }
    }
}

/** Default row renderer for a structured C-CDA entry. */
@Composable
fun CCDAEntryRow(entry: CCDAEntry, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(
                color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.52f),
                shape = androidx.compose.foundation.shape.RoundedCornerShape(CCDATheme.CornerRadius),
            )
            .padding(10.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Icon(
                imageVector = Icons.Outlined.MonitorHeart,
                contentDescription = null,
                tint = CCDATheme.Secondary,
            )
            Text(
                text = entry.code?.displayName ?: entry.code?.code ?: entry.type.rawValue,
                style = MaterialTheme.typography.titleSmall,
            )
        }
        entry.status?.let { Text("Status: ${it.rawValue}", style = MaterialTheme.typography.bodySmall) }
        entry.effectiveTime?.let {
            Text("Time: ${it.formattedDateTime()}", style = MaterialTheme.typography.bodySmall)
        }
        entry.value?.let { Text(it.formattedValue(), style = MaterialTheme.typography.bodySmall) }
        for (child in entry.children) {
            CCDAEntryRow(child, Modifier.padding(start = 12.dp))
        }
    }
}

/** Default media renderer using built-in preview behavior. */
@Composable
fun CCDAMediaView(media: CCDAMedia, modifier: Modifier = Modifier) {
    CCDAMediaView(media = media, modifier = modifier, onOpen = null)
}

/** Default media renderer with optional host-owned open behavior. */
@Composable
fun CCDAMediaView(
    media: CCDAMedia,
    modifier: Modifier = Modifier,
    onOpen: ((CCDAMedia) -> Unit)?,
) {
    var isPreviewOpen by remember(media) { mutableStateOf(false) }
    val openMedia = {
        if (onOpen == null) {
            isPreviewOpen = true
        } else {
            onOpen(media)
        }
    }

    when (media.mediaType) {
        CCDAMediaType.ImagePNG, CCDAMediaType.ImageJPEG, CCDAMediaType.ImageGIF -> {
            val image = remember(media) {
                runCatching {
                    val data = media.loadData()
                    android.graphics.BitmapFactory.decodeByteArray(data, 0, data.size)
                }.getOrNull()
            }

            if (image != null) {
                Image(
                    bitmap = image.asImageBitmap(),
                    contentDescription = "Image attachment",
                    modifier = modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp)
                        .border(
                            width = 1.dp,
                            color = MaterialTheme.colorScheme.outlineVariant,
                            shape = androidx.compose.foundation.shape.RoundedCornerShape(CCDATheme.CornerRadius),
                        ),
                    contentScale = ContentScale.FillWidth,
                )
            } else {
                OutlinedButton(onClick = openMedia, modifier = modifier.padding(vertical = 4.dp)) {
                    Icon(Icons.Outlined.Image, contentDescription = null)
                    Text("Image")
                }
            }
        }
        CCDAMediaType.ApplicationPDF,
        CCDAMediaType.TextPlain,
        CCDAMediaType.TextHTML,
        -> {
            Button(onClick = openMedia, modifier = modifier.padding(vertical = 4.dp)) {
                Icon(media.actionIcon(), contentDescription = null)
                Text(media.openActionLabel())
            }
        }
        is CCDAMediaType.Unsupported, CCDAMediaType.Unknown -> {
            OutlinedButton(onClick = openMedia, modifier = modifier.padding(vertical = 4.dp)) {
                Icon(Icons.Outlined.Attachment, contentDescription = null)
                Text(media.openActionLabel())
            }
        }
    }

    if (isPreviewOpen) {
        CCDAMediaPreview(media = media, onDismiss = { isPreviewOpen = false })
    }
}

@Composable
private fun CCDACard(
    title: String,
    icon: ImageVector,
    accent: androidx.compose.ui.graphics.Color,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit,
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = androidx.compose.foundation.shape.RoundedCornerShape(CCDATheme.CornerRadius),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
    ) {
        Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Icon(imageVector = icon, contentDescription = null, tint = accent)
                Text(title, style = MaterialTheme.typography.titleMedium, color = accent)
            }
            HorizontalDivider(Modifier.padding(vertical = 8.dp))
            content()
        }
    }
}

@Composable
private fun CCDALabeledText(label: String, value: String) {
    Column(Modifier.fillMaxWidth().padding(vertical = 2.dp)) {
        Text(label.uppercase(), style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Text(value, style = MaterialTheme.typography.bodyMedium)
    }
}

@Composable
private fun RowScope.CCDASummaryPill(title: String, value: String, icon: ImageVector) {
    Row(
        modifier = Modifier
            .weight(1f)
            .background(
                color = androidx.compose.ui.graphics.Color.White.copy(alpha = 0.14f),
                shape = androidx.compose.foundation.shape.RoundedCornerShape(CCDATheme.CornerRadius),
            )
            .padding(10.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = androidx.compose.ui.graphics.Color.White)
        Column {
            Text(title, style = MaterialTheme.typography.labelSmall, color = androidx.compose.ui.graphics.Color.White.copy(alpha = 0.78f))
            Text(value, style = MaterialTheme.typography.bodySmall, color = androidx.compose.ui.graphics.Color.White)
        }
    }
}

private fun CCDAMedia.openActionLabel(): String = when (val type = mediaType) {
    CCDAMediaType.ImagePNG, CCDAMediaType.ImageJPEG, CCDAMediaType.ImageGIF -> "Open image"
    CCDAMediaType.ApplicationPDF -> "Open PDF"
    CCDAMediaType.TextPlain -> "Open text"
    CCDAMediaType.TextHTML -> "Open HTML"
    is CCDAMediaType.Unsupported -> "Open ${type.mimeType}"
    CCDAMediaType.Unknown -> "Open attachment"
}

private fun CCDAMedia.actionIcon(): ImageVector = when (mediaType) {
    CCDAMediaType.ImagePNG, CCDAMediaType.ImageJPEG, CCDAMediaType.ImageGIF -> Icons.Outlined.Image
    CCDAMediaType.ApplicationPDF -> Icons.Outlined.PictureAsPdf
    CCDAMediaType.TextPlain -> Icons.AutoMirrored.Outlined.Article
    CCDAMediaType.TextHTML -> Icons.Outlined.Language
    is CCDAMediaType.Unsupported, CCDAMediaType.Unknown -> Icons.Outlined.Attachment
}
