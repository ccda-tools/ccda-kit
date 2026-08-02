package com.ccdakit.engine

/**
 * Patient demographics parsed from `recordTarget/patientRole`.
 *
 * @property ids Patient identifiers.
 * @property name Patient name.
 * @property gender Administrative gender code.
 * @property birthTime Birth timestamp.
 * @property maritalStatus Marital status code.
 * @property race Race code.
 * @property ethnicity Ethnicity code.
 * @property addresses Postal addresses.
 * @property telecoms Telecom values such as phone or email URIs.
 */
data class CCDAPatient(
    val ids: List<CCDAIdentifier> = emptyList(),
    val name: CCDAHumanName? = null,
    val gender: CCDACodedValue? = null,
    val birthTime: CCDATimestamp? = null,
    val maritalStatus: CCDACodedValue? = null,
    val race: CCDACodedValue? = null,
    val ethnicity: CCDACodedValue? = null,
    val addresses: List<CCDAAddress> = emptyList(),
    val telecoms: List<String> = emptyList(),
)
