export type CCDAMediaStoragePolicy = 'cacheToDisk' | 'inline';

export interface CCDAParseOptions {
  mediaStoragePolicy?: CCDAMediaStoragePolicy;
  mediaCacheDirectory?: string;
}

export interface CCDADocument {
  id: string;
  header: CCDAHeader;
  patient?: CCDAPatient | null;
  sections: CCDASection[];
}

export interface CCDAHeader {
  realmCode?: string | null;
  typeId?: CCDAIdentifier | null;
  templateIds: CCDATemplateId[];
  documentId: CCDAIdentifier;
  code?: CCDACodedValue | null;
  title?: string | null;
  effectiveTime?: CCDATimestamp | null;
  confidentialityCode?: CCDACodedValue | null;
  languageCode?: string | null;
}

export interface CCDAPatient {
  ids: CCDAIdentifier[];
  name?: CCDAHumanName | null;
  gender?: CCDACodedValue | null;
  birthTime?: CCDATimestamp | null;
  maritalStatus?: CCDACodedValue | null;
  race?: CCDACodedValue | null;
  ethnicity?: CCDACodedValue | null;
  addresses: CCDAAddress[];
  telecoms: string[];
}

export interface CCDASection {
  id: string;
  templateIds: CCDATemplateId[];
  code?: CCDACodedValue | null;
  kind: string;
  title?: string | null;
  narrativeText: string;
  entries: CCDAEntry[];
  media: CCDAMedia[];
}

export interface CCDAEntry {
  id: string;
  type: string;
  templateIds: CCDATemplateId[];
  identifiers: CCDAIdentifier[];
  code?: CCDACodedValue | null;
  status?: string | null;
  effectiveTime?: CCDATimestamp | null;
  value?: CCDAValue | null;
  textReference?: string | null;
  children: CCDAEntry[];
}

export interface CCDAMedia {
  id: string;
  mediaType: CCDAMediaType;
  representation: CCDAMediaRepresentation;
  payload: CCDAMediaPayload;
  isImage: boolean;
  isCached: boolean;
}

export interface CCDAMediaType {
  kind: string;
  mimeType?: string | null;
}

export interface CCDAMediaRepresentation {
  kind: string;
  rawValue?: string | null;
}

export type CCDAMediaPayload =
  | {
      kind: 'cachedFile';
      filePath: string;
      fileUri: string;
      byteCount: number;
    }
  | {
      kind: 'inlineBase64';
      value: string;
    }
  | {
      kind: 'unavailable';
    };

export interface CCDAIdentifier {
  root?: string | null;
  extensionValue?: string | null;
  stringValue: string;
}

export interface CCDATemplateId {
  root: string;
  extensionValue?: string | null;
}

export interface CCDACodedValue {
  code?: string | null;
  codeSystem?: string | null;
  codeSystemName?: string | null;
  displayName?: string | null;
}

export interface CCDATimestamp {
  rawValue: string;
  year: number;
  month?: number | null;
  day?: number | null;
  hour?: number | null;
  minute?: number | null;
  second?: number | null;
  fractionalSecond?: string | null;
  timeZoneOffset?: string | null;
  hasTime: boolean;
}

export interface CCDAValue {
  type?: string | null;
  code?: string | null;
  displayName?: string | null;
  value?: string | null;
  unit?: string | null;
}

export interface CCDAHumanName {
  prefix?: string | null;
  given: string[];
  family?: string | null;
}

export interface CCDAAddress {
  use: string;
  streetLines: string[];
  city?: string | null;
  state?: string | null;
  postalCode?: string | null;
  country?: string | null;
}
