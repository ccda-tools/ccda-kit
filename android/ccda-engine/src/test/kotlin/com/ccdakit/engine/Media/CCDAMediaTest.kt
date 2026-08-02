package com.ccdakit.engine

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.io.path.createTempDirectory

class CCDAMediaTest {
    @Test
    fun mapsKnownAndUnsupportedMimeTypes() {
        assertEquals(CCDAMediaType.ImagePNG, CCDAMediaType.fromMimeType("image/png"))
        assertEquals(CCDAMediaType.ImageJPEG, CCDAMediaType.fromMimeType("image/jpg"))
        assertEquals(CCDAMediaType.ApplicationPDF, CCDAMediaType.fromMimeType("application/pdf"))
        assertEquals(CCDAMediaType.Unknown, CCDAMediaType.fromMimeType(null))
        assertEquals(CCDAMediaType.Unsupported("application/dicom"), CCDAMediaType.fromMimeType("application/dicom"))
    }

    @Test
    fun inlinePayloadLoadsDecodedData() {
        val media = CCDAMedia(
            id = "media-1",
            mediaType = CCDAMediaType.TextPlain,
            representation = CCDAMediaRepresentation.Base64,
            payload = CCDAMediaPayload.InlineBase64("SGVsbG8="),
        )

        assertArrayEquals("Hello".toByteArray(), media.loadData())
    }

    @Test
    fun defaultEngineCachesMediaToDisk() {
        val cacheDirectory = createTempDirectory(prefix = "ccda-media-test").toFile()
        val engine = CCDAEngine(
            CCDAEngineConfiguration(
                mediaStoragePolicy = CCDAMediaStoragePolicy.CacheToDisk,
                mediaCacheDirectory = cacheDirectory,
            ),
        )

        val document = engine.parse(mediaXml().toByteArray())
        val media = document.sections.single().media.single()
        val payload = media.payload as CCDAMediaPayload.CachedFile

        assertTrue(payload.file.exists())
        assertEquals(5, payload.byteCount)
        assertArrayEquals("Hello".toByteArray(), payload.file.readBytes())
    }

    private fun mediaXml(): String = """
        <ClinicalDocument xmlns="urn:hl7-org:v3">
          <id root="1.2.3" extension="doc-1"/>
          <component>
            <structuredBody>
              <component>
                <section>
                  <title>Media</title>
                  <entry>
                    <observationMedia ID="media:1">
                      <value mediaType="text/plain" representation="B64">SGVsbG8=</value>
                    </observationMedia>
                  </entry>
                </section>
              </component>
            </structuredBody>
          </component>
        </ClinicalDocument>
    """.trimIndent()
}
