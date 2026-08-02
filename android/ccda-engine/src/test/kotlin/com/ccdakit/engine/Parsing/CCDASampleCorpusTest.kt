package com.ccdakit.engine

import org.json.JSONArray
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class CCDASampleCorpusTest {
    @Test
    fun sharedSamplesMatchExpectedSummaries() {
        val samples = sampleDirectory().listFiles { file -> file.extension == "xml" }
            ?.sortedBy { it.name }
            .orEmpty()

        assertTrue("Expected shared C-CDA samples.", samples.isNotEmpty())

        val engine = CCDAEngine()
        samples.forEach { sample ->
            val document = engine.parse(sample)
            val actual = summary(document, sample.name)
            val expectedFile = expectedDirectory().resolve(sample.nameWithoutExtension + ".json")

            assertTrue("Missing expected output for ${sample.name}", expectedFile.exists())
            assertJsonEquals(expectedFile.readText(), actual.toString(), sample.name)
        }
    }

    private fun summary(document: CCDADocument, fileName: String): JSONObject =
        JSONObject()
            .putJson("documentCode", document.header.code?.let(::codedSummary))
            .put("documentId", document.header.documentId.stringValue)
            .put("fileName", fileName)
            .putJson("patientBirthTime", document.patient?.birthTime?.rawValue)
            .putJson("patientName", document.patient?.name?.let(::patientName))
            .put("sectionCount", document.sections.size)
            .put("sections", JSONArray(document.sections.map(::sectionSummary)))
            .putJson("title", document.header.title)

    private fun sectionSummary(section: CCDASection): JSONObject =
        JSONObject()
            .putOptional("code", section.code?.let(::codedSummary))
            .put("entryCount", section.entries.size)
            .put("mediaCount", section.media.size)
            .put("templateIds", JSONArray(section.templateIds.map { it.root }.sorted()))
            .putOptional("title", section.title)

    private fun codedSummary(value: CCDACodedValue): JSONObject =
        JSONObject()
            .putOptional("code", value.code)
            .putOptional("codeSystem", value.codeSystem)
            .putOptional("displayName", value.displayName)

    private fun patientName(name: CCDAHumanName): String =
        (listOfNotNull(name.prefix) + name.given + listOfNotNull(name.family))
            .joinToString(" ")

    private fun assertJsonEquals(expected: String, actual: String, fileName: String) {
        assertJsonValueEquals(JSONObject(expected), JSONObject(actual), "$fileName")
    }

    private fun assertJsonValueEquals(expected: Any?, actual: Any?, path: String) {
        when {
            expected == JSONObject.NULL -> assertEquals(path, JSONObject.NULL, actual)
            expected is JSONObject && actual is JSONObject -> {
                assertEquals("$path key count", expected.length(), actual.length())
                expected.keys().forEach { key ->
                    assertTrue("$path.$key missing", actual.has(key))
                    assertJsonValueEquals(expected.get(key), actual.get(key), "$path.$key")
                }
            }
            expected is JSONArray && actual is JSONArray -> {
                assertEquals("$path length", expected.length(), actual.length())
                for (index in 0 until expected.length()) {
                    assertJsonValueEquals(expected.get(index), actual.get(index), "$path[$index]")
                }
            }
            else -> assertEquals(path, expected, actual)
        }
    }

    private fun JSONObject.putJson(name: String, value: Any?): JSONObject =
        put(name, value ?: JSONObject.NULL)

    private fun JSONObject.putOptional(name: String, value: Any?): JSONObject =
        if (value == null) this else put(name, value)

    private fun sampleDirectory(): File =
        repoRoot().resolve("test-data/ccda/samples")

    private fun expectedDirectory(): File =
        repoRoot().resolve("test-data/ccda/expected-output")

    private fun repoRoot(): File {
        val userDirectory = System.getProperty("user.dir") ?: error("Missing user.dir system property.")
        var current = File(userDirectory).absoluteFile
        while (true) {
            if (current.resolve("test-data/ccda").exists()) {
                return current
            }
            current = current.parentFile ?: break
        }
        error("Unable to locate repository root from $userDirectory.")
    }
}
