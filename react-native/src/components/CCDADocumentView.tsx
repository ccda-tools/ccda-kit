import React, {useMemo} from 'react';
import {FlatList, StyleSheet, Text, View} from 'react-native';
import {useCCDATheme, type CCDAThemeColors} from '../theme';
import {formatAddress, formatTimestamp, formatValue} from '../formatting';
import {CCDAMediaRow} from './CCDAMediaRow';
export {CCDAMediaRow} from './CCDAMediaRow';
import type {
  CCDADocument,
  CCDAEntry,
  CCDAHeader,
  CCDAHumanName,
  CCDAMedia,
  CCDAPatient,
  CCDASection,
} from '../types';

export interface CCDADocumentViewProps {
  document: CCDADocument;
  /** Replaces the default header; return null to hide it. */
  renderHeader?: (header: CCDAHeader) => React.ReactNode;
  /** Replaces the default patient panel when a patient is present. */
  renderPatient?: (patient: CCDAPatient) => React.ReactNode;
  renderSection?: (section: CCDASection) => React.ReactNode;
  renderEntry?: (entry: CCDAEntry) => React.ReactNode;
  renderMedia?: (media: CCDAMedia) => React.ReactNode;
  /** Overrides attachment taps; omitted callbacks use the built-in native preview. */
  onOpenMedia?: (media: CCDAMedia) => void | Promise<void>;
}

export function CCDADocumentView({
  document,
  renderHeader,
  renderPatient,
  renderSection,
  renderEntry,
  renderMedia,
  onOpenMedia,
}: CCDADocumentViewProps): React.ReactElement {
  const styles = useStyles();
  const rows = makeRows(document, Boolean(renderSection));

  return (
    <FlatList
      data={rows}
      keyExtractor={row => row.key}
      renderItem={({item}) => (
        <CCDAListRow
          row={item}
          renderHeader={renderHeader}
          renderPatient={renderPatient}
          renderSection={renderSection}
          renderEntry={renderEntry}
          renderMedia={renderMedia}
          onOpenMedia={onOpenMedia}
        />
      )}
      style={styles.page}
      contentContainerStyle={styles.content}
      initialNumToRender={8}
      maxToRenderPerBatch={8}
      windowSize={7}
      removeClippedSubviews
    />
  );
}

type CCDAListRow = (
  | {key: string; kind: 'header'; document: CCDADocument}
  | {key: string; kind: 'patient'; patient: CCDAPatient}
  | {key: string; kind: 'section'; section: CCDASection}
  | {key: string; kind: 'entry'; entry: CCDAEntry}
  | {key: string; kind: 'media'; media: CCDAMedia}
) & {endsSection?: boolean};

function makeRows(
  document: CCDADocument,
  customSections: boolean,
): CCDAListRow[] {
  const rows: CCDAListRow[] = [{key: 'header', kind: 'header', document}];

  if (document.patient) {
    rows.push({key: 'patient', kind: 'patient', patient: document.patient});
  }

  document.sections.forEach(section => {
    rows.push({key: `section-${section.id}`, kind: 'section', section});

    // A custom section renderer owns the section subtree, matching the native
    // composable APIs and avoiding duplicate entry/media rows.
    if (customSections) {
      return;
    }

    section.entries.forEach(entry => {
      rows.push({key: `entry-${section.id}-${entry.id}`, kind: 'entry', entry});
    });
    section.media.forEach(media => {
      rows.push({key: `media-${section.id}-${media.id}`, kind: 'media', media});
    });
    rows[rows.length - 1].endsSection = true;
  });

  return rows;
}

function CCDAListRow({
  row,
  renderHeader,
  renderPatient,
  renderSection,
  renderEntry,
  renderMedia,
  onOpenMedia,
}: {row: CCDAListRow} & Pick<
  CCDADocumentViewProps,
  | 'renderHeader'
  | 'renderPatient'
  | 'renderSection'
  | 'renderEntry'
  | 'renderMedia'
  | 'onOpenMedia'
>): React.ReactElement {
  const styles = useStyles();
  switch (row.kind) {
    case 'header':
      return renderHeader ? (
        <>{renderHeader(row.document.header)}</>
      ) : (
        <CCDADocumentHeader document={row.document} />
      );
    case 'patient':
      return renderPatient ? (
        <>{renderPatient(row.patient)}</>
      ) : (
        <CCDAPatientPanel patient={row.patient} />
      );
    case 'section':
      return renderSection ? (
        <>{renderSection(row.section)}</>
      ) : (
        <CCDASectionView section={row.section} continues={!row.endsSection} />
      );
    case 'entry':
      return (
        <View
          style={[styles.sectionPart, row.endsSection && styles.sectionEnd]}>
          {renderEntry ? (
            renderEntry(row.entry)
          ) : (
            <CCDAEntryRow entry={row.entry} />
          )}
        </View>
      );
    case 'media':
      return (
        <View
          style={[styles.sectionPart, row.endsSection && styles.sectionEnd]}>
          {renderMedia ? (
            renderMedia(row.media)
          ) : (
            <CCDAMediaRow media={row.media} onOpen={onOpenMedia} />
          )}
        </View>
      );
  }
}

function PanelTitle({
  icon,
  children,
  secondary = false,
}: {
  icon: string;
  children: React.ReactNode;
  secondary?: boolean;
}): React.ReactElement {
  const styles = useStyles();
  return (
    <View style={styles.heading}>
      <Text
        accessible={false}
        style={[styles.icon, secondary && styles.secondary]}>
        {icon}
      </Text>
      <Text
        accessibilityRole="header"
        style={[styles.panelTitle, secondary && styles.secondary]}>
        {children}
      </Text>
    </View>
  );
}

function SummaryPill({
  label,
  value,
}: {
  label: string;
  value: string;
}): React.ReactElement {
  const styles = useStyles();
  return (
    <View style={styles.pill}>
      <Text style={styles.pillLabel}>{label}</Text>
      <Text selectable style={styles.pillValue}>
        {value}
      </Text>
    </View>
  );
}

function LabeledValue({
  label,
  value,
}: {
  label: string;
  value: string;
}): React.ReactElement {
  const styles = useStyles();
  return (
    <View style={styles.field}>
      <Text style={styles.fieldLabel}>{label.toUpperCase()}</Text>
      <Text selectable style={styles.body}>
        {value}
      </Text>
    </View>
  );
}

function CCDADocumentHeader({
  document,
}: {
  document: CCDADocument;
}): React.ReactElement {
  const styles = useStyles();
  const {header} = document;
  return (
    <View style={styles.headerPanel}>
      <View style={styles.heading}>
        <Text accessible={false} style={styles.headerIcon}>
          ▤
        </Text>
        <Text accessibilityRole="header" style={styles.title}>
          {header.title ?? header.code?.displayName ?? 'C-CDA Document'}
        </Text>
      </View>
      <SummaryPill label="Document ID" value={header.documentId.stringValue} />
      {header.effectiveTime ? (
        <SummaryPill
          label="Effective"
          value={formatTimestamp(header.effectiveTime)}
        />
      ) : null}
      {header.languageCode ? (
        <SummaryPill label="Language" value={header.languageCode} />
      ) : null}
    </View>
  );
}

function CCDAPatientPanel({
  patient,
}: {
  patient: CCDAPatient;
}): React.ReactElement {
  const styles = useStyles();
  return (
    <View style={styles.patientPanel}>
      <PanelTitle icon="▣" secondary>
        Patient
      </PanelTitle>
      <LabeledValue
        label="Name"
        value={formatPatientName(patient?.name) || 'Unknown patient'}
      />
      {patient?.birthTime ? (
        <LabeledValue label="DOB" value={formatTimestamp(patient.birthTime)} />
      ) : null}
      {patient?.gender?.displayName || patient?.gender?.code ? (
        <LabeledValue
          label="Gender"
          value={patient.gender.displayName ?? patient.gender.code ?? ''}
        />
      ) : null}
      {patient?.addresses.map((address, index) => {
        const value = formatAddress(address);
        return value ? (
          <LabeledValue key={index} label="Address" value={value} />
        ) : null;
      })}
    </View>
  );
}

export interface CCDASectionViewProps {
  section: CCDASection;
  /** Used by the virtualized document list to join the section's rows. */
  continues?: boolean;
}

export function CCDASectionView({
  section,
  continues = false,
}: CCDASectionViewProps): React.ReactElement {
  const styles = useStyles();
  return (
    <View
      style={[
        styles.panel,
        styles.sectionStart,
        continues && styles.continuedSection,
      ]}>
      <PanelTitle icon="≡">
        {section.title ?? section.code?.displayName ?? 'Section'}
      </PanelTitle>
      {section.narrativeText ? (
        <Text selectable style={styles.body}>
          {section.narrativeText}
        </Text>
      ) : null}
    </View>
  );
}

export function CCDAEntryRow({entry}: {entry: CCDAEntry}): React.ReactElement {
  const styles = useStyles();
  const label = entry.code?.displayName ?? entry.code?.code ?? entry.type;
  return (
    <View style={styles.row}>
      <View style={styles.heading}>
        <Text accessible={false} style={[styles.icon, styles.secondary]}>
          ⌁
        </Text>
        <Text selectable style={styles.primaryText}>
          {label}
        </Text>
      </View>
      <View style={styles.entryDetails}>
        {entry.status ? (
          <Text style={styles.meta}>Status: {entry.status}</Text>
        ) : null}
        {entry.effectiveTime ? (
          <Text style={styles.meta}>
            Time: {formatTimestamp(entry.effectiveTime)}
          </Text>
        ) : null}
        {entry.value ? (
          <Text selectable style={styles.body}>
            {formatValue(entry.value)}
          </Text>
        ) : null}
        <CCDAEntryDetails entries={entry.children} />
      </View>
    </View>
  );
}

function flattenDetails(entries: CCDAEntry[]): CCDAEntry[] {
  return entries.flatMap(entry => [entry, ...flattenDetails(entry.children)]);
}

function CCDAEntryDetails({
  entries,
}: {
  entries: CCDAEntry[];
}): React.ReactElement {
  const styles = useStyles();
  return (
    <>
      {flattenDetails(entries).map(detail => (
        <View key={detail.id} style={styles.childEntry}>
          <Text selectable style={styles.detailTitle}>
            {detail.code?.displayName ?? detail.code?.code ?? detail.type}
          </Text>
          {detail.value ? (
            <Text selectable style={styles.meta}>
              {formatValue(detail.value)}
            </Text>
          ) : null}
          {detail.status ? (
            <Text style={styles.meta}>Status: {detail.status}</Text>
          ) : null}
          {detail.effectiveTime ? (
            <Text style={styles.meta}>
              Time: {formatTimestamp(detail.effectiveTime)}
            </Text>
          ) : null}
        </View>
      ))}
    </>
  );
}

function formatPatientName(name: CCDAHumanName | null | undefined): string {
  return name
    ? [name.prefix, ...name.given, name.family].filter(Boolean).join(' ')
    : '';
}

function useStyles() {
  const theme = useCCDATheme();
  return useMemo(() => createStyles(theme), [theme]);
}

function createStyles(theme: CCDAThemeColors) {
  return StyleSheet.create({
    page: {flex: 1, backgroundColor: theme.pageBackground},
    content: {padding: 16},
    headerPanel: {
      backgroundColor: theme.headerBackground,
      borderRadius: theme.cornerRadius,
      padding: 16,
      gap: 12,
      marginBottom: 14,
    },
    heading: {flexDirection: 'row', alignItems: 'flex-start', gap: 8},
    icon: {color: theme.primary, fontSize: 18, width: 18},
    headerIcon: {color: theme.onHeader, fontSize: 24},
    title: {color: theme.onHeader, fontSize: 22, fontWeight: '600', flex: 1},
    pill: {
      backgroundColor: theme.headerPill,
      borderRadius: theme.cornerRadius,
      padding: 10,
      gap: 2,
    },
    pillLabel: {color: theme.headerMuted, fontSize: 11, fontWeight: '600'},
    pillValue: {color: theme.onHeader, fontSize: 13, lineHeight: 19},
    patientPanel: {
      backgroundColor: theme.panelBackground,
      borderRadius: theme.cornerRadius,
      padding: 14,
      gap: 12,
    },
    panel: {
      backgroundColor: theme.panelBackground,
      borderRadius: theme.cornerRadius,
      padding: 14,
      gap: 12,
    },
    sectionStart: {marginTop: 14},
    continuedSection: {borderBottomLeftRadius: 0, borderBottomRightRadius: 0},
    sectionPart: {
      backgroundColor: theme.panelBackground,
      paddingHorizontal: 14,
      paddingBottom: 10,
    },
    sectionEnd: {
      borderBottomLeftRadius: theme.cornerRadius,
      borderBottomRightRadius: theme.cornerRadius,
      paddingBottom: 14,
    },
    panelTitle: {
      color: theme.primary,
      fontSize: 17,
      fontWeight: '600',
      flex: 1,
    },
    secondary: {color: theme.secondary},
    field: {gap: 2},
    fieldLabel: {color: theme.muted, fontSize: 11, fontWeight: '600'},
    primaryText: {
      color: theme.text,
      fontSize: 15,
      fontWeight: '600',
      flexShrink: 1,
    },
    body: {color: theme.text, fontSize: 14, lineHeight: 21},
    meta: {color: theme.muted, fontSize: 12, lineHeight: 18},
    row: {
      backgroundColor: theme.rowBackground,
      borderRadius: theme.cornerRadius,
      padding: 10,
      gap: 8,
    },
    entryDetails: {paddingLeft: 26, gap: 4},
    detailTitle: {color: theme.text, fontSize: 12, fontWeight: '600'},
    childEntry: {
      borderLeftColor: theme.secondary,
      borderLeftWidth: 2,
      marginTop: 4,
      paddingLeft: 8,
    },
  });
}
