# UI Theme Guide

Default UI components should make C-CDA documents feel readable, calm, and clinically useful without pretending to be a full host app design system.

This guide applies to `CCDAUI` on Apple and `ccda-compose` on Android.

## Design Goals

- Keep parser models and UI styling separate.
- Make default views useful for inspection, demos, and early app integrations.
- Let host apps replace header, patient, section, entry, and media renderers.
- Keep Apple and Android visually related while still feeling native on each platform.
- Favor clear clinical hierarchy over decorative layout.

## Visual Language

Use a quiet clinical palette:

- Primary teal for document and section identity.
- Secondary indigo for entry metadata and clinical rows.
- Warm amber/brown for media and attachments.
- Soft grouped backgrounds behind panels.
- 8dp/8pt corner radius for cards, rows, media previews, and pills.

Avoid:

- Heavy gradients.
- Decorative blobs or abstract background art.
- Oversized marketing-style hero layouts.
- One-color-only interfaces.
- Nested cards inside cards unless the nested item is a real repeated row.

## Component Patterns

Document views should start with a strong header panel that includes:

- Document title or document type.
- Document identifier.
- Effective date/time when present.
- Language or other compact metadata when useful.

Patient views should use compact labeled values:

- Name.
- DOB.
- Gender.
- Address.
- Other demographic fields as they become supported.

Section views should use full-width panels:

- Section title with an icon.
- Narrative text before structured entries.
- Entries as repeated rows.
- Media as attachment rows or previews.

Entry rows should be compact and scannable:

- Primary label from display name, code, or entry type.
- Status and time as subdued metadata.
- Value as readable clinical text.
- Nested entries indented, not visually over-decorated.

Media views should use clear attachment affordances:

- Images render inline when possible.
- PDF, text, and HTML open in a preview view.
- Unsupported media still displays as an attachment with preserved MIME text.

## Platform Tokens

Apple tokens live in `CCDATheme`:

- `primary`
- `secondary`
- `attachment`
- `pageBackground`
- `panelBackground`
- `rowBackground`
- `cornerRadius`

Android tokens live in `CCDATheme`:

- `Primary`
- `Secondary`
- `Attachment`
- `PageBackground`
- `DarkPageBackground`
- `CornerRadius`

When adding new default components, use these tokens first. Add new tokens only when the component has a repeated need across multiple views.

## Native Feel

Apple:

- Use SwiftUI-native layout, SF Symbols, and platform colors.
- Keep macOS compatibility when using platform colors.
- Prefer `Label`, `NavigationLink`, `ScrollView`, and `LazyVStack` where appropriate.

Android:

- Use Jetpack Compose and Material 3.
- Use Material icons for action buttons and section identity.
- Keep layouts compatible with light and dark Material color schemes.

## Boundaries

Do not move formatting or display-only behavior into `CCDAEngine`.

Do not make default UI required for parsing.

Do not remove composable/custom renderer APIs when improving the default design.

Do not use real PHI in previews, snapshots, docs, or sample data.
