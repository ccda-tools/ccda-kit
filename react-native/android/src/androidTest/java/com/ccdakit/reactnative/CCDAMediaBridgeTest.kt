package com.ccdakit.reactnative

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.ccdakit.engine.CCDAEngine
import com.ccdakit.engine.CCDAEngineConfiguration
import com.ccdakit.engine.CCDAMediaStoragePolicy
import com.facebook.react.bridge.JavaOnlyMap
import com.facebook.react.bridge.ReadableType
import com.facebook.soloader.SoLoader
import java.io.File
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

/** Device tests for the library, independent of the React Native example. */
@RunWith(AndroidJUnit4::class)
class CCDAMediaBridgeTest {
    private val instrumentation = InstrumentationRegistry.getInstrumentation()
    private val context = instrumentation.targetContext
    private lateinit var cache: File

    @Before
    fun setUp() {
        SoLoader.init(context, false)
        cache = File(context.cacheDir, "ccda-tests-${System.nanoTime()}").apply { mkdirs() }
    }

    @After
    fun tearDown() {
        cache.deleteRecursively()
    }

    @Test
    fun cachedAttachmentsKeepNumericByteCountsAndPrepareAllSupportedPreviews() {
        assertSharedAttachments(CCDAMediaStoragePolicy.CacheToDisk, "cachedFile")
    }

    @Test
    fun inlineAttachmentsPrepareAllSupportedPreviews() {
        assertSharedAttachments(CCDAMediaStoragePolicy.Inline, "inlineBase64")
    }

    private fun assertSharedAttachments(policy: CCDAMediaStoragePolicy, payloadKind: String) {
        val xml = instrumentation.context.assets.open("local-media-attachments.xml").use { it.readBytes() }
        val engine = CCDAEngine(CCDAEngineConfiguration(mediaStoragePolicy = policy, mediaCacheDirectory = cache))
        val attachments = engine.parse(xml).sections.flatMap { it.media }
        assertEquals(4, attachments.size)
        val kinds = mutableSetOf<String>()
        for (media in attachments) {
            val bridgeValue = media.toWritableMap()
            kinds += requireNotNull(bridgeValue.getMap("mediaType")?.getString("kind"))
            val payload = requireNotNull(bridgeValue.getMap("payload"))
            assertEquals(payloadKind, payload.getString("kind"))
            if (payloadKind == "cachedFile") {
                assertEquals(ReadableType.Number, payload.getType("byteCount"))
                assertEquals(media.loadData().size.toDouble(), payload.getDouble("byteCount"), 0.0)
                assertTrue(File(requireNotNull(payload.getString("filePath"))).exists())
            }
            val preview = CCDAMediaPreview.prepare(context, bridgeValue)
            preview.dismiss() // Also releases prepared image/PDF bitmaps without an Activity.
        }
        assertEquals(setOf("imagePNG", "applicationPDF", "textPlain", "textHTML"), kinds)
        assertTrue("Temporary PDF copies must be removed", context.cacheDir.listFiles().orEmpty()
            .none { it.name.startsWith("ccda-preview-") })
    }

    @Test
    fun missingCachedFileFailsWithoutCreatingAPreview() {
        expectFailure(media("textPlain", JavaOnlyMap.of(
            "kind", "cachedFile", "filePath", File(cache, "missing.txt").path
        )))
    }

    @Test
    fun malformedImageAndPDFDataFailWithoutLeakingTemporaryFiles() {
        for (kind in listOf("imagePNG", "applicationPDF")) {
            expectFailure(media(kind, JavaOnlyMap.of("kind", "inlineBase64", "value", "bm90LWEtZmlsZQ==")))
        }
        assertTrue(context.cacheDir.listFiles().orEmpty().none { it.name.startsWith("ccda-preview-") })
    }

    @Test
    fun unsupportedAndUnavailablePayloadsFailClearly() {
        expectFailure(media("unsupported", JavaOnlyMap.of("kind", "unavailable")))
        expectFailure(media("textHTML", JavaOnlyMap.of("kind", "unavailable")))
    }

    private fun media(kind: String, payload: JavaOnlyMap) = JavaOnlyMap.of(
        "mediaType", JavaOnlyMap.of("kind", kind), "payload", payload
    )

    private fun expectFailure(value: JavaOnlyMap) {
        try {
            CCDAMediaPreview.prepare(context, value).dismiss()
            fail("Invalid attachment unexpectedly prepared")
        } catch (expected: Exception) {
            assertFalse(expected.message.isNullOrBlank())
        }
    }
}
