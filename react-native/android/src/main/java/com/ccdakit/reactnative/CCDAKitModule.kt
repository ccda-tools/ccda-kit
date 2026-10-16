package com.ccdakit.reactnative

import com.ccdakit.engine.CCDAAddress
import com.ccdakit.engine.CCDACodedValue
import com.ccdakit.engine.CCDADocument
import com.ccdakit.engine.CCDAEngine
import com.ccdakit.engine.CCDAEngineConfiguration
import com.ccdakit.engine.CCDAEngineException
import com.ccdakit.engine.CCDAEntry
import com.ccdakit.engine.CCDAHeader
import com.ccdakit.engine.CCDAHumanName
import com.ccdakit.engine.CCDAIdentifier
import com.ccdakit.engine.CCDAMedia
import com.ccdakit.engine.CCDAMediaPayload
import com.ccdakit.engine.CCDAMediaRepresentation
import com.ccdakit.engine.CCDAMediaStoragePolicy
import com.ccdakit.engine.CCDAMediaType
import com.ccdakit.engine.CCDAPatient
import com.ccdakit.engine.CCDASection
import com.ccdakit.engine.CCDASectionKind
import com.ccdakit.engine.CCDATemplateId
import com.ccdakit.engine.CCDATimestamp
import com.ccdakit.engine.CCDAValue
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import java.io.File
import java.net.URI

class CCDAKitModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext), LifecycleEventListener {
    init {
        reactContext.addLifecycleEventListener(this)
    }

    override fun getName(): String = "CCDAKit"

    private var mediaPreview: CCDAMediaPreview? = null

    @ReactMethod
    fun openMedia(media: ReadableMap, promise: Promise) {
        try {
            val activity = currentActivity ?: error("No active screen is available.")
            val preview = CCDAMediaPreview.prepare(reactContext, media)
            activity.runOnUiThread {
                try {
                    mediaPreview?.dismiss()
                    mediaPreview = preview
                    preview.show(activity)
                    promise.resolve(null)
                } catch (error: Exception) {
                    preview.dismiss()
                    promise.reject("CCDA_PREVIEW_FAILED", error.message, error)
                }
            }
        } catch (error: Exception) {
            promise.reject("CCDA_PREVIEW_FAILED", error.message, error)
        }
    }

    override fun invalidate() {
        reactContext.removeLifecycleEventListener(this)
        onHostDestroy()
        super.invalidate()
    }

    override fun onHostResume() = Unit

    override fun onHostPause() = Unit

    override fun onHostDestroy() {
        reactContext.runOnUiQueueThread {
            mediaPreview?.dismiss()
            mediaPreview = null
        }
    }

    @ReactMethod
    fun parseXml(xml: String, options: ReadableMap?, promise: Promise) {
        try {
            val document = engine(options).parse(xml.toByteArray(Charsets.UTF_8))
            promise.resolve(document.toWritableMap())
        } catch (error: Exception) {
            reject(error, promise)
        }
    }

    @ReactMethod
    fun parseFile(path: String, options: ReadableMap?, promise: Promise) {
        try {
            val file = fileFromPath(path)
            val document = engine(options).parse(file)
            promise.resolve(document.toWritableMap())
        } catch (error: Exception) {
            reject(error, promise)
        }
    }

    private fun engine(options: ReadableMap?): CCDAEngine {
        val storagePolicy = when (options?.string("mediaStoragePolicy")) {
            "inline" -> CCDAMediaStoragePolicy.Inline
            else -> CCDAMediaStoragePolicy.CacheToDisk
        }
        val cacheDirectory = options?.string("mediaCacheDirectory")?.let(::File)
            ?: File(reactContext.cacheDir, "ccda-kit-media-cache")

        return CCDAEngine(
            CCDAEngineConfiguration(
                mediaStoragePolicy = storagePolicy,
                mediaCacheDirectory = cacheDirectory,
            ),
        )
    }

    private fun fileFromPath(path: String): File =
        if (path.startsWith("file://")) {
            File(URI(path))
        } else {
            File(path)
        }

    private fun reject(error: Exception, promise: Promise) {
        if (error is CCDAEngineException.InvalidXml) {
            promise.reject("CCDA_INVALID_XML", error.message, error)
        } else {
            promise.reject("CCDA_PARSE_FAILED", error.message, error)
        }
    }
}

private fun ReadableMap.string(key: String): String? =
    if (hasKey(key) && !isNull(key)) getString(key) else null

private fun CCDADocument.toWritableMap(): WritableMap = mapOf(
    "id" to id,
    "header" to header.toWritableMap(),
    "patient" to patient?.toWritableMap(),
    "sections" to sections.toWritableArray { it.toWritableMap() },
)

private fun CCDAHeader.toWritableMap(): WritableMap = mapOf(
    "realmCode" to realmCode,
    "typeId" to typeId?.toWritableMap(),
    "templateIds" to templateIds.toWritableArray { it.toWritableMap() },
    "documentId" to documentId.toWritableMap(),
    "code" to code?.toWritableMap(),
    "title" to title,
    "effectiveTime" to effectiveTime?.toWritableMap(),
    "confidentialityCode" to confidentialityCode?.toWritableMap(),
    "languageCode" to languageCode,
)

private fun CCDAPatient.toWritableMap(): WritableMap = mapOf(
    "ids" to ids.toWritableArray { it.toWritableMap() },
    "name" to name?.toWritableMap(),
    "gender" to gender?.toWritableMap(),
    "birthTime" to birthTime?.toWritableMap(),
    "maritalStatus" to maritalStatus?.toWritableMap(),
    "race" to race?.toWritableMap(),
    "ethnicity" to ethnicity?.toWritableMap(),
    "addresses" to addresses.toWritableArray { it.toWritableMap() },
    "telecoms" to telecoms.toWritableArray { it },
)

private fun CCDASection.toWritableMap(): WritableMap = mapOf(
    "id" to id,
    "templateIds" to templateIds.toWritableArray { it.toWritableMap() },
    "code" to code?.toWritableMap(),
    "kind" to kind.serializedName(),
    "title" to title,
    "narrativeText" to narrativeText,
    "entries" to entries.toWritableArray { it.toWritableMap() },
    "media" to media.toWritableArray { it.toWritableMap() },
)

private fun CCDAEntry.toWritableMap(): WritableMap = mapOf(
    "id" to id,
    "type" to type.rawValue,
    "templateIds" to templateIds.toWritableArray { it.toWritableMap() },
    "identifiers" to identifiers.toWritableArray { it.toWritableMap() },
    "code" to code?.toWritableMap(),
    "status" to status?.rawValue,
    "effectiveTime" to effectiveTime?.toWritableMap(),
    "value" to value?.toWritableMap(),
    "textReference" to textReference,
    "children" to children.toWritableArray { it.toWritableMap() },
)

internal fun CCDAMedia.toWritableMap(): WritableMap = mapOf(
    "id" to id,
    "mediaType" to mediaType.toWritableMap(),
    "representation" to representation.toWritableMap(),
    "payload" to payload.toWritableMap(),
    "isImage" to isImage,
    "isCached" to isCached,
)

private fun CCDAMediaType.toWritableMap(): WritableMap = mapOf(
    "kind" to serializedName(),
    "mimeType" to mimeType,
)

private fun CCDAMediaRepresentation.toWritableMap(): WritableMap = mapOf(
    "kind" to serializedName(),
    "rawValue" to rawValue,
)

private fun CCDAMediaPayload.toWritableMap(): WritableMap = when (this) {
    is CCDAMediaPayload.CachedFile -> mapOf(
        "kind" to "cachedFile",
        "filePath" to file.path,
        "fileUri" to file.toURI().toString(),
        "byteCount" to byteCount,
    )
    is CCDAMediaPayload.InlineBase64 -> mapOf(
        "kind" to "inlineBase64",
        "value" to value,
    )
    CCDAMediaPayload.Unavailable -> mapOf("kind" to "unavailable")
}

private fun CCDAIdentifier.toWritableMap(): WritableMap = mapOf(
    "root" to root,
    "extensionValue" to extensionValue,
    "stringValue" to stringValue,
)

private fun CCDATemplateId.toWritableMap(): WritableMap = mapOf(
    "root" to root,
    "extensionValue" to extensionValue,
)

private fun CCDACodedValue.toWritableMap(): WritableMap = mapOf(
    "code" to code,
    "codeSystem" to codeSystem,
    "codeSystemName" to codeSystemName,
    "displayName" to displayName,
)

private fun CCDATimestamp.toWritableMap(): WritableMap = mapOf(
    "rawValue" to rawValue,
    "year" to year,
    "month" to month,
    "day" to day,
    "hour" to hour,
    "minute" to minute,
    "second" to second,
    "fractionalSecond" to fractionalSecond,
    "timeZoneOffset" to timeZoneOffset,
    "hasTime" to hasTime,
)

private fun CCDAValue.toWritableMap(): WritableMap = mapOf(
    "type" to type,
    "code" to code,
    "displayName" to displayName,
    "value" to value,
    "unit" to unit,
)

private fun CCDAHumanName.toWritableMap(): WritableMap = mapOf(
    "prefix" to prefix,
    "given" to given.toWritableArray { it },
    "family" to family,
)

private fun CCDAAddress.toWritableMap(): WritableMap = mapOf(
    "use" to (use.rawValue ?: "unknown"),
    "streetLines" to streetLines.toWritableArray { it },
    "city" to city,
    "state" to state,
    "postalCode" to postalCode,
    "country" to country,
)

private fun CCDASectionKind.serializedName(): String = when (this) {
    CCDASectionKind.Allergies -> "allergies"
    CCDASectionKind.Assessment -> "assessment"
    CCDASectionKind.PlanOfCare -> "planOfCare"
    CCDASectionKind.Encounters -> "encounters"
    CCDASectionKind.FunctionalStatus -> "functionalStatus"
    CCDASectionKind.Immunizations -> "immunizations"
    CCDASectionKind.MedicalEquipment -> "medicalEquipment"
    CCDASectionKind.Medications -> "medications"
    CCDASectionKind.Payers -> "payers"
    CCDASectionKind.Problems -> "problems"
    CCDASectionKind.Procedures -> "procedures"
    CCDASectionKind.ReasonForReferral -> "reasonForReferral"
    CCDASectionKind.Results -> "results"
    CCDASectionKind.SocialHistory -> "socialHistory"
    CCDASectionKind.VitalSigns -> "vitalSigns"
    is CCDASectionKind.Unknown -> "unknown"
}

private fun CCDAMediaType.serializedName(): String = when (this) {
    CCDAMediaType.ImagePNG -> "imagePNG"
    CCDAMediaType.ImageJPEG -> "imageJPEG"
    CCDAMediaType.ImageGIF -> "imageGIF"
    CCDAMediaType.ApplicationPDF -> "applicationPDF"
    CCDAMediaType.TextPlain -> "textPlain"
    CCDAMediaType.TextHTML -> "textHTML"
    is CCDAMediaType.Unsupported -> "unsupported"
    CCDAMediaType.Unknown -> "unknown"
}

private fun CCDAMediaRepresentation.serializedName(): String = when (this) {
    CCDAMediaRepresentation.Base64 -> "base64"
    CCDAMediaRepresentation.Text -> "text"
    is CCDAMediaRepresentation.Unsupported -> "unsupported"
    CCDAMediaRepresentation.Unknown -> "unknown"
}

private fun mapOf(vararg pairs: Pair<String, Any?>): WritableMap =
    Arguments.createMap().apply {
        pairs.forEach { (key, value) -> putAny(key, value) }
    }

private fun WritableMap.putAny(key: String, value: Any?) {
    when (value) {
        null -> putNull(key)
        is Boolean -> putBoolean(key, value)
        is Int -> putInt(key, value)
        is Long -> putDouble(key, value.toDouble())
        is Double -> putDouble(key, value)
        is Float -> putDouble(key, value.toDouble())
        is String -> putString(key, value)
        is WritableMap -> putMap(key, value)
        is WritableArray -> putArray(key, value)
        else -> putString(key, value.toString())
    }
}

private fun <T> Iterable<T>.toWritableArray(transform: (T) -> Any?): WritableArray =
    Arguments.createArray().apply {
        forEach { value -> pushAny(transform(value)) }
    }

private fun WritableArray.pushAny(value: Any?) {
    when (value) {
        null -> pushNull()
        is Boolean -> pushBoolean(value)
        is Int -> pushInt(value)
        is Long -> pushDouble(value.toDouble())
        is Double -> pushDouble(value)
        is Float -> pushDouble(value.toDouble())
        is String -> pushString(value)
        is WritableMap -> pushMap(value)
        is WritableArray -> pushArray(value)
        else -> pushString(value.toString())
    }
}
