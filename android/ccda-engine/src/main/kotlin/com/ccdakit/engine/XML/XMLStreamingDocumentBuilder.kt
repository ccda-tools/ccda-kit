package com.ccdakit.engine

import org.xmlpull.v1.XmlPullParser

/** Pull-parser helper that captures document metadata and maps section subtrees as they close. */
internal class XMLStreamingDocumentBuilder(
    private val sectionHandler: (CCDAXmlNode, Int) -> CCDASection,
) {
    /** Builds a streamed document from the current parser input. */
    fun build(parser: XmlPullParser): StreamedDocument {
        val headerStack = mutableListOf<CCDAXmlNode>()
        val sectionStack = mutableListOf<CCDAXmlNode>()
        val path = mutableListOf<String>()
        val sections = mutableListOf<CCDASection>()
        var root: CCDAXmlNode? = null
        var skippedBodyDepth = 0

        while (parser.nextToken() != XmlPullParser.END_DOCUMENT) {
            when (parser.eventType) {
                XmlPullParser.START_TAG -> {
                    val node = xmlNode(parser)
                    when {
                        sectionStack.isNotEmpty() -> {
                            sectionStack.last().children.add(node)
                            sectionStack.add(node)
                        }
                        isStructuredBodySectionStart(parser.name, path) -> {
                            sectionStack.add(node)
                        }
                        skippedBodyDepth > 0 -> {
                            skippedBodyDepth += 1
                        }
                        isRootBodyComponent(parser.name, path) -> {
                            skippedBodyDepth = 1
                        }
                        headerStack.isNotEmpty() -> {
                            headerStack.last().children.add(node)
                            headerStack.add(node)
                        }
                        else -> {
                            root = node
                            headerStack.add(node)
                        }
                    }
                    path.add(parser.name)
                }
                XmlPullParser.TEXT, XmlPullParser.CDSECT, XmlPullParser.ENTITY_REF -> {
                    when {
                        sectionStack.isNotEmpty() -> sectionStack.last().textParts.add(parser.text ?: "")
                        skippedBodyDepth == 0 -> headerStack.lastOrNull()?.textParts?.add(parser.text ?: "")
                    }
                }
                XmlPullParser.END_TAG -> {
                    when {
                        sectionStack.isNotEmpty() -> {
                            if (parser.name == CCDAXmlName.SECTION && sectionStack.size == 1) {
                                sections.add(sectionHandler(sectionStack.removeAt(sectionStack.lastIndex), sections.size))
                            } else {
                                sectionStack.removeAt(sectionStack.lastIndex)
                            }
                        }
                        skippedBodyDepth > 0 -> {
                            skippedBodyDepth -= 1
                        }
                        headerStack.isNotEmpty() -> {
                            headerStack.removeAt(headerStack.lastIndex)
                        }
                    }
                    if (path.isNotEmpty()) path.removeAt(path.lastIndex)
                }
            }
        }

        return StreamedDocument(root = root, sections = sections)
    }

    private fun xmlNode(parser: XmlPullParser): CCDAXmlNode =
        CCDAXmlNode(
            name = parser.name,
            attributes = (0 until parser.attributeCount).associate { index ->
                val name = parser.getAttributeName(index)
                val namespace = parser.getAttributeNamespace(index)
                val key = if (
                    namespace == CCDAXmlNamespace.XML_SCHEMA_INSTANCE &&
                    name == CCDAXmlAttribute.TYPE
                ) {
                    CCDAXmlAttribute.XSI_TYPE
                } else {
                    name
                }
                key to parser.getAttributeValue(index)
            },
        )

    private fun isStructuredBodySectionStart(name: String, path: List<String>): Boolean =
        name == CCDAXmlName.SECTION &&
            path.lastOrNull() == CCDAXmlName.COMPONENT &&
            path.dropLast(1).lastOrNull() == CCDAXmlName.STRUCTURED_BODY

    private fun isRootBodyComponent(name: String, path: List<String>): Boolean =
        name == CCDAXmlName.COMPONENT &&
            path.size == 1 &&
            path.firstOrNull() == "ClinicalDocument"
}

/** Stream parse result containing header XML and mapped sections. */
internal data class StreamedDocument(
    val root: CCDAXmlNode?,
    val sections: List<CCDASection>,
)
