package com.ccdakit.engine

/**
 * Value parsed from an entry `value` element.
 *
 * @property type XML or `xsi:type` value such as `CD` or `PQ`.
 * @property code Coded value when the value is coded.
 * @property displayName Human-readable coded display.
 * @property value Scalar value when the value is numeric or textual.
 * @property unit Unit for scalar values.
 */
data class CCDAValue(
    val type: String? = null,
    val code: String? = null,
    val displayName: String? = null,
    val value: String? = null,
    val unit: String? = null,
)
