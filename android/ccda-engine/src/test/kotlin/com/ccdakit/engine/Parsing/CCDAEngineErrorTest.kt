package com.ccdakit.engine

import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class CCDAEngineErrorTest {
    @Test
    fun invalidXmlIncludesParserLocationAndSourceDescription() {
        val sample = File.createTempFile("invalid-ccda", ".xml").apply {
            writeText("<ClinicalDocument><component></ClinicalDocument>")
            deleteOnExit()
        }

        try {
            CCDAEngine().parse(sample)
        } catch (error: CCDAEngineException.InvalidXml) {
            assertTrue(error.failure.message.isNotBlank())
            assertNotNull(error.failure.lineNumber)
            assertNotNull(error.failure.columnNumber)
            assertTrue(requireNotNull(error.failure.sourceDescription).endsWith(".xml"))
            return
        }

        error("Expected invalid XML to throw CCDAEngineException.InvalidXml.")
    }
}
