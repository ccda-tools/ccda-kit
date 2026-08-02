package com.ccdakit.compose

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

/** Default visual tokens used by ccda-compose views. */
object CCDATheme {
    /** Main clinical accent color. */
    val Primary = Color(0xFF1A6D7A)
    /** Secondary accent color used for entry metadata. */
    val Secondary = Color(0xFF474F9E)
    /** Warm accent color used for attachments. */
    val Attachment = Color(0xFFBD5E1F)
    /** Soft page background. */
    val PageBackground = Color(0xFFF3F6F7)
    /** Dark-mode page background. */
    val DarkPageBackground = Color(0xFF101719)
    /** Card corner radius. */
    val CornerRadius = 8.dp
}
