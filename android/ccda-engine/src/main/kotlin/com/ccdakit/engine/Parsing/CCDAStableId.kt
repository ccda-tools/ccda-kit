package com.ccdakit.engine

import java.util.Base64

internal object CCDAStableId {
    fun section(index: Int, code: String?, title: String?): String =
        encoded(prefix = "s", parts = listOf(index.toString(), code.orEmpty(), title.orEmpty()))

    fun entry(path: List<String>, sourceId: String?): String =
        encoded(prefix = "e", parts = path + sourceId.orEmpty())

    fun media(sectionIndex: Int, mediaIndex: Int, sourceId: String?): String =
        encoded(prefix = "m", parts = listOf(sectionIndex.toString(), mediaIndex.toString(), sourceId.orEmpty()))

    private fun encoded(prefix: String, parts: List<String>): String {
        val raw = parts.joinToString(separator = "|")
        val encoded = Base64.getUrlEncoder()
            .withoutPadding()
            .encodeToString(raw.toByteArray(Charsets.UTF_8))

        return "$prefix:$encoded"
    }
}
