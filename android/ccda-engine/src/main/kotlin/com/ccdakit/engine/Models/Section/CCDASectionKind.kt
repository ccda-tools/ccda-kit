package com.ccdakit.engine

/** Normalized kind for common C-CDA section LOINC codes. */
sealed class CCDASectionKind {
    /** Allergies and intolerances section. */
    data object Allergies : CCDASectionKind()
    /** Assessment section. */
    data object Assessment : CCDASectionKind()
    /** Plan of care section. */
    data object PlanOfCare : CCDASectionKind()
    /** Encounters section. */
    data object Encounters : CCDASectionKind()
    /** Functional status section. */
    data object FunctionalStatus : CCDASectionKind()
    /** Immunizations section. */
    data object Immunizations : CCDASectionKind()
    /** Medical equipment section. */
    data object MedicalEquipment : CCDASectionKind()
    /** Medications section. */
    data object Medications : CCDASectionKind()
    /** Payers section. */
    data object Payers : CCDASectionKind()
    /** Problems section. */
    data object Problems : CCDASectionKind()
    /** Procedures section. */
    data object Procedures : CCDASectionKind()
    /** Reason for referral section. */
    data object ReasonForReferral : CCDASectionKind()
    /** Results section. */
    data object Results : CCDASectionKind()
    /** Social history section. */
    data object SocialHistory : CCDASectionKind()
    /** Vital signs section. */
    data object VitalSigns : CCDASectionKind()
    /** Unknown section kind with the original section code. */
    data class Unknown(val code: String?) : CCDASectionKind()

    companion object {
        /** Creates a section kind from a C-CDA section LOINC code. */
        fun fromCode(code: String?): CCDASectionKind = when (code) {
            "48765-2" -> Allergies
            "51848-0" -> Assessment
            "18776-5", "61146-7" -> PlanOfCare
            "46240-8" -> Encounters
            "47420-5" -> FunctionalStatus
            "11369-6" -> Immunizations
            "46264-8" -> MedicalEquipment
            "10160-0" -> Medications
            "48768-6" -> Payers
            "11450-4" -> Problems
            "47519-4" -> Procedures
            "42349-1" -> ReasonForReferral
            "30954-2" -> Results
            "29762-2" -> SocialHistory
            "8716-3" -> VitalSigns
            else -> Unknown(code)
        }
    }
}
