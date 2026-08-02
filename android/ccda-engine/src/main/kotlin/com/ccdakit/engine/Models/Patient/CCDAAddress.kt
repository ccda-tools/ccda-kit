package com.ccdakit.engine

/**
 * Patient postal address parsed from `patientRole/addr`.
 *
 * @property use Typed address use code.
 * @property streetLines Street address lines.
 * @property city City name.
 * @property state State, province, or region.
 * @property postalCode Postal code.
 * @property country Country name or code.
 */
data class CCDAAddress(
    val use: CCDAAddressUse = CCDAAddressUse.Unknown,
    val streetLines: List<String> = emptyList(),
    val city: String? = null,
    val state: String? = null,
    val postalCode: String? = null,
    val country: String? = null,
)
