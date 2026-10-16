import type {CCDADocument} from '../types';

export const documentFixture: CCDADocument = {
  id: '2.16.840.1.113883.3.72 / doc-1',
  header: {
    documentId: {
      root: '2.16.840.1.113883.3.72',
      extensionValue: 'doc-1',
      stringValue: '2.16.840.1.113883.3.72 / doc-1',
    },
    templateIds: [],
    title: 'Synthetic Summary of Care',
    effectiveTime: {
      rawValue: '20260115',
      year: 2026,
      month: 1,
      day: 15,
      hour: null,
      minute: null,
      second: null,
      fractionalSecond: null,
      timeZoneOffset: null,
      hasTime: false,
    },
  },
  patient: {
    ids: [],
    name: {prefix: null, given: ['Test'], family: 'Patient'},
    gender: {code: 'F', displayName: 'Female'},
    birthTime: null,
    maritalStatus: null,
    race: null,
    ethnicity: null,
    addresses: [],
    telecoms: [],
  },
  sections: [
    {
      id: 'section-1',
      templateIds: [],
      code: {code: '11450-4', displayName: 'Problem List'},
      kind: 'problems',
      title: 'Problems',
      narrativeText: 'Synthetic problem narrative.',
      entries: [
        {
          id: 'entry-1',
          type: 'observation',
          templateIds: [],
          identifiers: [],
          code: {code: '38341003', displayName: 'Hypertension'},
          status: 'active',
          effectiveTime: null,
          value: null,
          textReference: null,
          children: [
            {
              id: 'entry-1-child',
              type: 'observation',
              templateIds: [],
              identifiers: [],
              code: {displayName: 'Child detail'},
              status: null,
              effectiveTime: null,
              value: {type: 'ST', value: 'Controlled'},
              textReference: null,
              children: [],
            },
          ],
        },
      ],
      media: [
        {
          id: 'media-1',
          mediaType: {kind: 'applicationPDF', mimeType: 'application/pdf'},
          representation: {kind: 'base64', rawValue: 'B64'},
          payload: {kind: 'unavailable'},
          isImage: false,
          isCached: false,
        },
      ],
    },
  ],
};
