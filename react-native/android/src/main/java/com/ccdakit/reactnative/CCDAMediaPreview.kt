package com.ccdakit.reactnative

import android.app.Activity
import android.app.Dialog
import android.content.Context
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import android.os.Build
import android.util.Base64
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.webkit.WebView
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import com.facebook.react.bridge.ReadableMap
import java.io.File

/** In-app previews matching ccda-compose's supported media and first-page PDF behavior. */
internal class CCDAMediaPreview private constructor(
    private val title: String,
    private val kind: String,
    private val data: ByteArray,
    private val bitmap: Bitmap?,
) {
    private var dialog: Dialog? = null

    fun show(activity: Activity) {
        check(!activity.isFinishing && !activity.isDestroyed) { "No active screen is available." }
        val preview = Dialog(activity)
        dialog = preview
        preview.requestWindowFeature(Window.FEATURE_NO_TITLE)
        val dp = activity.resources.displayMetrics.density
        val padding = (16 * dp).toInt()
        val layout = LinearLayout(activity).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(padding, padding, padding, padding)
        }
        val toolbar = LinearLayout(activity).apply { orientation = LinearLayout.HORIZONTAL }
        toolbar.addView(TextView(activity).apply {
            text = title
            textSize = 20f
            if (Build.VERSION.SDK_INT >= 28) setAccessibilityHeading(true)
        }, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
        toolbar.addView(Button(activity).apply {
            text = "Close"
            val dark = resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
            setTextColor(Color.parseColor(if (dark) "#80CCD6" else "#1A6D7A"))
            setOnClickListener { dismiss() }
        })
        layout.addView(toolbar)

        var webView: WebView? = null
        val content: View = when (kind) {
            "imagePNG", "imageJPEG", "imageGIF", "applicationPDF" -> ImageView(activity).apply {
                setImageBitmap(bitmap)
                scaleType = ImageView.ScaleType.FIT_CENTER
                contentDescription = if (kind == "applicationPDF") "PDF preview, first page" else "Image attachment"
            }
            "textHTML" -> WebView(activity).apply {
                webView = this
                settings.javaScriptEnabled = false
                settings.allowFileAccess = false
                loadDataWithBaseURL(null, data.toString(Charsets.UTF_8), "text/html", "UTF-8", null)
            }
            else -> ScrollView(activity).apply {
                addView(TextView(activity).apply {
                    text = data.toString(Charsets.UTF_8)
                    textSize = 16f
                    setTextIsSelectable(true)
                })
            }
        }
        layout.addView(content, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        preview.setContentView(layout)
        preview.setOnDismissListener {
            webView?.destroy()
            bitmap?.recycle()
            dialog = null
        }
        preview.show()
        preview.window?.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
    }

    fun dismiss() {
        if (dialog?.isShowing == true) {
            dialog?.dismiss()
        } else {
            bitmap?.let { if (!it.isRecycled) it.recycle() }
            dialog = null
        }
    }

    companion object {
        fun prepare(context: Context, media: ReadableMap): CCDAMediaPreview {
            val kind = media.getMap("mediaType")?.getString("kind") ?: "unknown"
            val title = when (kind) {
                "imagePNG", "imageJPEG", "imageGIF" -> "Image"
                "applicationPDF" -> "PDF (first page)"
                "textPlain" -> "Text"
                "textHTML" -> "HTML"
                else -> error("This attachment type cannot be previewed.")
            }
            val payload = requireNotNull(media.getMap("payload")) { "Attachment payload is unavailable." }
            val data = when (payload.getString("kind")) {
                "cachedFile" -> File(requireNotNull(payload.getString("filePath"))).readBytes()
                "inlineBase64" -> Base64.decode(requireNotNull(payload.getString("value")), Base64.DEFAULT)
                else -> error("Attachment payload is unavailable.")
            }
            val bitmap = when (kind) {
                "imagePNG", "imageJPEG", "imageGIF" -> requireNotNull(BitmapFactory.decodeByteArray(data, 0, data.size)) {
                    "Unable to decode image attachment."
                }
                "applicationPDF" -> renderPDF(context, data)
                else -> null
            }
            return CCDAMediaPreview(title, kind, data, bitmap)
        }

        private fun renderPDF(context: Context, data: ByteArray): Bitmap {
            val file = File.createTempFile("ccda-preview-", ".pdf", context.cacheDir)
            try {
                file.writeBytes(data)
                ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
                    PdfRenderer(descriptor).use { renderer ->
                        renderer.openPage(0).use { page ->
                            val scale = minOf(2f, 2048f / maxOf(page.width, page.height))
                            val bitmap = Bitmap.createBitmap(
                                (page.width * scale).toInt().coerceAtLeast(1),
                                (page.height * scale).toInt().coerceAtLeast(1),
                                Bitmap.Config.ARGB_8888,
                            )
                            Canvas(bitmap).drawColor(Color.WHITE)
                            page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                            return bitmap
                        }
                    }
                }
            } finally {
                file.delete()
            }
        }
    }
}
