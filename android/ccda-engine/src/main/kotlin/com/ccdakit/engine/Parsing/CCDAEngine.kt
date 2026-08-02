package com.ccdakit.engine

import org.xmlpull.v1.XmlPullParserException
import org.xmlpull.v1.XmlPullParserFactory
import java.io.File
import java.io.InputStream

/** Parses C-CDA XML into normalized engine models. */
class CCDAEngine(
    private val configuration: CCDAEngineConfiguration = CCDAEngineConfiguration(),
) {
    /** Parses a C-CDA document from XML bytes. */
    fun parse(data: ByteArray): CCDADocument {
        val file = File.createTempFile("ccda-kit-", ".xml")
        return try {
            file.writeBytes(data)
            parse(file, sourceDescription = null)
        } finally {
            file.delete()
        }
    }

    /** Parses a C-CDA document from an XML file. */
    fun parse(file: File): CCDADocument =
        parse(file, sourceDescription = file.path)

    /** Parses a C-CDA document from an XML input stream. */
    fun parse(inputStream: InputStream): CCDADocument =
        parse(inputStream, null)

    private fun parse(file: File, sourceDescription: String?): CCDADocument =
        file.inputStream().use { parse(it, sourceDescription) }

    private fun parse(inputStream: InputStream, sourceDescription: String?): CCDADocument {
        val parser = XmlPullParserFactory.newInstance().apply {
            isNamespaceAware = true
        }.newPullParser()
        val mapper = CCDADocumentMapper(configuration)
        val builder = XMLStreamingDocumentBuilder { sectionNode, sectionIndex ->
            mapper.mapSection(sectionNode, sectionIndex)
        }

        return try {
            parser.setInput(inputStream, null)
            val streamedDocument = builder.build(parser)
            val root = streamedDocument.root
                ?: throw CCDAEngineException.InvalidXml(
                    CCDAXmlParsingFailure(
                        message = "No root XML element was found.",
                        sourceDescription = sourceDescription,
                    ),
                )
            mapper.map(root, streamedDocument.sections)
        } catch (error: CCDAEngineException) {
            throw error
        } catch (error: XmlPullParserException) {
            throw invalidXml(error, sourceDescription, parser.lineNumber, parser.columnNumber)
        } catch (error: Exception) {
            throw invalidXml(error, sourceDescription, parser.lineNumber, parser.columnNumber)
        }
    }

    private fun invalidXml(
        error: Exception,
        sourceDescription: String?,
        lineNumber: Int,
        columnNumber: Int,
    ): CCDAEngineException.InvalidXml =
        CCDAEngineException.InvalidXml(
            CCDAXmlParsingFailure(
                message = error.message ?: "XML parser failed.",
                lineNumber = lineNumber.takeIf { it > 0 },
                columnNumber = columnNumber.takeIf { it > 0 },
                sourceDescription = sourceDescription,
                underlyingErrorDescription = error.message,
            ),
        )
}
