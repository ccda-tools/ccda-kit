export type SampleDocument = {
  title: string;
  filename: string;
  source: string;
  loadXml: () => string;
};

// Keep the selection and order aligned with the native iOS example.
export const samples: SampleDocument[] = [
  {
    title: 'Local Comprehensive Sample',
    filename: 'local-comprehensive-sample',
    source: 'Shared Test Data',
    loadXml: () =>
      require('../../../test-data/ccda/samples/local-comprehensive-sample.xml'),
  },
  {
    title: 'Media Attachments',
    filename: 'local-media-attachments',
    source: 'Shared Test Data',
    loadXml: () =>
      require('../../../test-data/ccda/samples/local-media-attachments.xml'),
  },
  {
    title: 'HL7 CCD',
    filename: 'hl7-ccd',
    source: 'HL7 Samples',
    loadXml: () => require('../../../test-data/ccda/samples/hl7-ccd.xml'),
  },
  {
    title: 'HL7 Discharge Summary',
    filename: 'hl7-discharge-summary',
    source: 'HL7 Samples',
    loadXml: () =>
      require('../../../test-data/ccda/samples/hl7-discharge-summary.xml'),
  },
  {
    title: 'HL7 Progress Note',
    filename: 'hl7-progress-note',
    source: 'HL7 Samples',
    loadXml: () =>
      require('../../../test-data/ccda/samples/hl7-progress-note.xml'),
  },
  {
    title: 'Cerner Problems and Medications',
    filename: 'cerner-problems-medications',
    source: 'Cerner Samples',
    loadXml: () =>
      require('../../../test-data/ccda/samples/cerner-problems-medications.xml'),
  },
  {
    title: 'Transition of Care Full XML',
    filename: 'toc-full',
    source: 'Transitions of Care Samples',
    loadXml: () => require('../../../test-data/ccda/samples/toc-full.xml'),
  },
];
