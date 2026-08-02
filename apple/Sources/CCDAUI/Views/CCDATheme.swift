import SwiftUI

#if os(macOS)
import AppKit
#endif

/// Default visual tokens used by CCDAUI views.
public enum CCDATheme {
    /// Main clinical accent color.
    public static let primary = Color(red: 0.10, green: 0.43, blue: 0.48)
    /// Secondary accent color used for entry metadata.
    public static let secondary = Color(red: 0.28, green: 0.31, blue: 0.62)
    /// Warm accent color used for attachments.
    public static let attachment = Color(red: 0.74, green: 0.37, blue: 0.12)
    /// Soft page background.
    public static var pageBackground: Color {
        #if os(iOS)
        Color(.systemGroupedBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.gray.opacity(0.08)
        #endif
    }
    /// Primary panel background.
    public static var panelBackground: Color {
        #if os(iOS)
        Color(.secondarySystemGroupedBackground)
        #elseif os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color.white
        #endif
    }
    /// Nested row background.
    public static var rowBackground: Color {
        #if os(iOS)
        Color(.tertiarySystemGroupedBackground)
        #elseif os(macOS)
        Color(nsColor: .textBackgroundColor).opacity(0.72)
        #else
        Color.gray.opacity(0.08)
        #endif
    }
    /// Card corner radius.
    public static let cornerRadius: CGFloat = 8
}
