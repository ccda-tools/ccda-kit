package com.ccdakit.engine

import java.util.Base64

/** Internal mapper that converts captured C-CDA XML nodes into public engine models. */
internal class CCDADocumentMapper(
    private val configuration: CCDAEngineConfiguration,
) {
    /** Maps document-level XML and already mapped sections into a public C-CDA document model. */
    fun map(root: CCDAXmlNode, sections: List<CCDASection>): CCDADocument {
        val header = CCDAHeader(
            realmCode = root.first(CCDAXmlName.REALM_CODE)?.attribute(CCDAXmlAttribute.CODE),
            typeId = root.first(CCDAXmlName.TYPE_ID)?.let(::identifier),
            templateIds = root.direct(CCDAXmlName.TEMPLATE_ID).map(::templateId),
            documentId = root.first(CCDAXmlName.ID)?.let(::identifier) ?: CCDAIdentifier(),
            code = root.first(CCDAXmlName.CODE)?.let(::codedValue),
            title = root.first(CCDAXmlName.TITLE)?.cleanText,
            effectiveTime = timestamp(root.first(CCDAXmlName.EFFECTIVE_TIME)?.attribute(CCDAXmlAttribute.VALUE)),
            confidentialityCode = root.first(CCDAXmlName.CONFIDENTIALITY_CODE)?.let(::codedValue),
            languageCode = root.first(CCDAXmlName.LANGUAGE_CODE)?.attribute(CCDAXmlAttribute.CODE),
        )

        return CCDADocument(
            header = header,
            patient = mapPatient(root),
            sections = sections,
        )
    }

    /** Maps a completed C-CDA section subtree. */
    fun mapSection(section: CCDAXmlNode, sectionIndex: Int): CCDASection {
        val code = section.first(CCDAXmlName.CODE)?.let(::codedValue)
        val title = section.first(CCDAXmlName.TITLE)?.cleanText
        val entries = section.direct(CCDAXmlName.ENTRY).flatMapIndexed { entryIndex, entry ->
            entry.children
                .filterNot { it.name == CCDAXmlName.OBSERVATION_MEDIA }
                .mapIndexed { childIndex, child ->
                    mapEntry(child, path = listOf(sectionIndex.toString(), entryIndex.toString(), childIndex.toString()))
                }
        }
        val mediaNodes = section.direct(CCDAXmlName.ENTRY).flatMap { entry ->
            entry.children.filter { it.name == CCDAXmlName.OBSERVATION_MEDIA }
        }
        val media = mediaNodes.mapIndexedNotNull { mediaIndex, mediaNode ->
            mapMedia(mediaNode, sectionIndex = sectionIndex, mediaIndex = mediaIndex)
        }

        return CCDASection(
            id = CCDAStableId.section(sectionIndex, code?.code, title),
            templateIds = section.direct(CCDAXmlName.TEMPLATE_ID).map(::templateId),
            code = code,
            title = title,
            narrativeText = section.first(CCDAXmlName.TEXT)?.cleanText.orEmpty(),
            entries = entries,
            media = media,
        )
    }

    private fun mapPatient(root: CCDAXmlNode): CCDAPatient? {
        val patientRole = root.first(CCDAXmlName.RECORD_TARGET)
            ?.first(CCDAXmlName.PATIENT_ROLE)
            ?: return null
        val patient = patientRole.first(CCDAXmlName.PATIENT)

        return CCDAPatient(
            ids = patientRole.direct(CCDAXmlName.ID).map(::identifier),
            name = patient?.first(CCDAXmlName.NAME)?.let(::humanName),
            gender = patient?.first(CCDAXmlName.ADMINISTRATIVE_GENDER_CODE)?.let(::codedValue),
            birthTime = timestamp(patient?.first(CCDAXmlName.BIRTH_TIME)?.attribute(CCDAXmlAttribute.VALUE)),
            maritalStatus = patient?.first(CCDAXmlName.MARITAL_STATUS_CODE)?.let(::codedValue),
            race = patient?.first(CCDAXmlName.RACE_CODE)?.let(::codedValue),
            ethnicity = patient?.first(CCDAXmlName.ETHNIC_GROUP_CODE)?.let(::codedValue),
            addresses = patientRole.direct(CCDAXmlName.ADDR).map(::address),
            telecoms = patientRole.direct(CCDAXmlName.TELECOM).mapNotNull {
                it.attribute(CCDAXmlAttribute.VALUE)
            },
        )
    }

    private fun mapEntry(node: CCDAXmlNode, path: List<String>): CCDAEntry {
        val directValue = node.first(CCDAXmlName.VALUE)
        val identifiers = node.direct(CCDAXmlName.ID).map(::identifier)

        return CCDAEntry(
            id = CCDAStableId.entry(path, identifiers.firstOrNull()?.stringValue),
            type = CCDAEntryType.fromElementName(node.name),
            templateIds = node.direct(CCDAXmlName.TEMPLATE_ID).map(::templateId),
            identifiers = identifiers,
            code = node.first(CCDAXmlName.CODE)?.let(::codedValue),
            status = node.first(CCDAXmlName.STATUS_CODE)
                ?.attribute(CCDAXmlAttribute.CODE)
                ?.let(CCDAEntryStatus::fromCode),
            effectiveTime = effectiveTimeValue(node.first(CCDAXmlName.EFFECTIVE_TIME)),
            value = directValue?.let(::ccdaValue),
            textReference = node.first(CCDAXmlName.TEXT)
                ?.first(CCDAXmlName.REFERENCE)
                ?.attribute(CCDAXmlAttribute.VALUE),
            children = node.direct(CCDAXmlName.ENTRY_RELATIONSHIP).flatMapIndexed { relationshipIndex, relationship ->
                relationship.children.mapIndexed { childIndex, child ->
                    mapEntry(child, path = path + listOf("r", relationshipIndex.toString(), childIndex.toString()))
                }
            } + node.direct(CCDAXmlName.COMPONENT).flatMapIndexed { componentIndex, component ->
                component.children.mapIndexed { childIndex, child ->
                    mapEntry(child, path = path + listOf("c", componentIndex.toString(), childIndex.toString()))
                }
            },
        )
    }

    private fun mapMedia(node: CCDAXmlNode, sectionIndex: Int, mediaIndex: Int): CCDAMedia? {
        val value = node.first(CCDAXmlName.VALUE) ?: return null
        val sourceId = node.attribute(CCDAXmlAttribute.ID)
            ?: node.first(CCDAXmlName.ID)?.attribute(CCDAXmlAttribute.ROOT)
        val id = CCDAStableId.media(sectionIndex, mediaIndex, sourceId)
        val mediaType = CCDAMediaType.fromMimeType(value.attribute(CCDAXmlAttribute.MEDIA_TYPE))
        val representation = CCDAMediaRepresentation.fromRawValue(
            value.attribute(CCDAXmlAttribute.REPRESENTATION),
        )
        val base64Value = value.cleanText

        val payload = if (configuration.mediaStoragePolicy is CCDAMediaStoragePolicy.CacheToDisk) {
            cacheMediaIfPossible(id, mediaType, base64Value)
                ?: if (base64Value.isEmpty()) CCDAMediaPayload.Unavailable else CCDAMediaPayload.InlineBase64(base64Value)
        } else {
            if (base64Value.isEmpty()) CCDAMediaPayload.Unavailable else CCDAMediaPayload.InlineBase64(base64Value)
        }

        return CCDAMedia(
            id = id,
            mediaType = mediaType,
            representation = representation,
            payload = payload,
        )
    }

    private fun cacheMediaIfPossible(
        id: String,
        mediaType: CCDAMediaType,
        base64Value: String,
    ): CCDAMediaPayload.CachedFile? {
        val directory = configuration.mediaCacheDirectory ?: return null
        val data = runCatching {
            Base64.getDecoder().decode(base64Value.filterNot { it.isWhitespace() })
        }.getOrNull() ?: return null

        return try {
            val file = CCDAMediaCache(directory).store(data, id, mediaType)
            CCDAMediaPayload.CachedFile(file, data.size)
        } catch (error: Exception) {
            throw CCDAEngineException.MediaCacheWriteFailed(directory, error)
        }
    }

    private fun templateId(node: CCDAXmlNode): CCDATemplateId =
        CCDATemplateId(
            root = node.attribute(CCDAXmlAttribute.ROOT).orEmpty(),
            extensionValue = node.attribute(CCDAXmlAttribute.EXTENSION),
        )

    private fun identifier(node: CCDAXmlNode): CCDAIdentifier =
        CCDAIdentifier(
            root = node.attribute(CCDAXmlAttribute.ROOT),
            extensionValue = node.attribute(CCDAXmlAttribute.EXTENSION),
        )

    private fun codedValue(node: CCDAXmlNode): CCDACodedValue =
        CCDACodedValue(
            code = node.attribute(CCDAXmlAttribute.CODE),
            codeSystem = node.attribute(CCDAXmlAttribute.CODE_SYSTEM),
            codeSystemName = node.attribute(CCDAXmlAttribute.CODE_SYSTEM_NAME),
            displayName = node.attribute(CCDAXmlAttribute.DISPLAY_NAME),
        )

    private fun ccdaValue(node: CCDAXmlNode): CCDAValue =
        CCDAValue(
            type = node.attribute(CCDAXmlAttribute.TYPE) ?: node.attribute(CCDAXmlAttribute.XSI_TYPE),
            code = node.attribute(CCDAXmlAttribute.CODE),
            displayName = node.attribute(CCDAXmlAttribute.DISPLAY_NAME),
            value = node.attribute(CCDAXmlAttribute.VALUE),
            unit = node.attribute(CCDAXmlAttribute.UNIT),
        )

    private fun humanName(node: CCDAXmlNode): CCDAHumanName =
        CCDAHumanName(
            prefix = node.first(CCDAXmlName.PREFIX)?.cleanText,
            given = node.direct(CCDAXmlName.GIVEN).map { it.cleanText },
            family = node.first(CCDAXmlName.FAMILY)?.cleanText,
        )

    private fun address(node: CCDAXmlNode): CCDAAddress =
        CCDAAddress(
            use = CCDAAddressUse.fromCode(node.attribute(CCDAXmlAttribute.USE)),
            streetLines = node.direct(CCDAXmlName.STREET_ADDRESS_LINE).map { it.cleanText },
            city = node.first(CCDAXmlName.CITY)?.cleanText,
            state = node.first(CCDAXmlName.STATE)?.cleanText,
            postalCode = node.first(CCDAXmlName.POSTAL_CODE)?.cleanText,
            country = node.first(CCDAXmlName.COUNTRY)?.cleanText,
        )

    private fun effectiveTimeValue(node: CCDAXmlNode?): CCDATimestamp? {
        if (node == null) return null
        return timestamp(
            node.attribute(CCDAXmlAttribute.VALUE)
                ?: node.first(CCDAXmlName.LOW)?.attribute(CCDAXmlAttribute.VALUE)
                ?: node.first(CCDAXmlName.HIGH)?.attribute(CCDAXmlAttribute.VALUE),
        )
    }

    private fun timestamp(rawValue: String?): CCDATimestamp? = CCDATimestamp.parse(rawValue)
}
