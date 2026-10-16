import React from 'react';
import renderer from 'react-test-renderer';
import {FlatList, StyleSheet, Text, useColorScheme} from 'react-native';
import {
  CCDADocumentView,
  CCDAEntryRow,
  CCDAMediaRow,
  CCDASectionView,
} from '../components/CCDADocumentView';
import {documentFixture} from './fixtures';
import {CCDATheme} from '../theme';

jest.mock('react-native/Libraries/Utilities/useColorScheme', () => ({
  __esModule: true,
  default: jest.fn(() => 'light'),
}));

afterEach(() => {
  jest.mocked(useColorScheme).mockReturnValue('light');
});

describe('CCDADocumentView', () => {
  it('replaces header and patient panels with host renderers receiving the parsed models', () => {
    const renderHeader = jest.fn(header => (
      <Text>{`Host header: ${header.title}`}</Text>
    ));
    const renderPatient = jest.fn(patient => (
      <Text>{`Host patient: ${patient.name.family}`}</Text>
    ));
    const tree = renderer.create(
      <CCDADocumentView
        document={documentFixture}
        renderHeader={renderHeader}
        renderPatient={renderPatient}
      />,
    );

    expect(renderHeader).toHaveBeenCalledWith(documentFixture.header);
    expect(renderPatient).toHaveBeenCalledWith(documentFixture.patient);
    const text = tree.root.findAllByType(Text).map(node => node.props.children);
    expect(text).toEqual(
      expect.arrayContaining([
        'Host header: Synthetic Summary of Care',
        'Host patient: Patient',
      ]),
    );
    expect(text).not.toEqual(expect.arrayContaining(['Document ID', 'NAME']));
    expect(
      tree.root
        .findByType(FlatList)
        .props.data.map((row: {kind: string}) => row.kind),
    ).toEqual(['header', 'patient', 'section', 'entry', 'media']);
    expect(tree.root.findAllByType(CCDASectionView)).toHaveLength(1);
  });

  it('keeps the default patient panel when only the header is customized', () => {
    const tree = renderer.create(
      <CCDADocumentView
        document={documentFixture}
        renderHeader={() => <Text>Host header</Text>}
      />,
    );
    const text = tree.root.findAllByType(Text).map(node => node.props.children);
    expect(text).toEqual(
      expect.arrayContaining(['Host header', 'NAME', 'Test Patient']),
    );
    expect(text).not.toContain('Document ID');
  });

  it('allows hosts to hide header and patient panels by returning null', () => {
    const tree = renderer.create(
      <CCDADocumentView
        document={documentFixture}
        renderHeader={() => null}
        renderPatient={() => null}
      />,
    );
    const text = tree.root.findAllByType(Text).map(node => node.props.children);
    expect(text).not.toContain('Document ID');
    expect(text).not.toContain('NAME');
    expect(tree.root.findAllByType(CCDASectionView)).toHaveLength(1);
  });

  it.each([null, undefined])(
    'does not call the patient renderer when the patient is %s',
    patient => {
      const renderPatient = jest.fn(() => <Text>Host patient</Text>);
      const tree = renderer.create(
        <CCDADocumentView
          document={{...documentFixture, patient}}
          renderPatient={renderPatient}
        />,
      );
      expect(renderPatient).not.toHaveBeenCalled();
      expect(
        tree.root
          .findByType(FlatList)
          .props.data.map((row: {kind: string}) => row.kind),
      ).toEqual(['header', 'section', 'entry', 'media']);
      expect(
        tree.root.findAllByType(Text).map(node => node.props.children),
      ).toContain('Document ID');
    },
  );

  it('renders the document through one virtualized FlatList', () => {
    const tree = renderer.create(
      <CCDADocumentView document={documentFixture} />,
    );
    const lists = tree.root.findAllByType(FlatList);

    expect(lists).toHaveLength(1);
    expect(lists[0].props.data).toHaveLength(5);
    expect(lists[0].props.data.map((row: {kind: string}) => row.kind)).toEqual([
      'header',
      'patient',
      'section',
      'entry',
      'media',
    ]);
  });

  it('uses dark backgrounds while keeping header text readable', () => {
    jest.mocked(useColorScheme).mockReturnValue('dark');
    const tree = renderer.create(
      <CCDADocumentView document={documentFixture} />,
    );
    expect(
      StyleSheet.flatten(tree.root.findByType(FlatList).props.style)
        .backgroundColor,
    ).toBe(CCDATheme.dark.pageBackground);
    const title = tree.root
      .findAllByType(Text)
      .find(text => text.props.children === documentFixture.header.title)!;
    expect(StyleSheet.flatten(title.props.style).color).toBe(
      CCDATheme.dark.onHeader,
    );
  });

  it('shows labeled header metadata and patient addresses', () => {
    const document = {
      ...documentFixture,
      header: {...documentFixture.header, languageCode: 'en-US'},
      patient: {
        ...documentFixture.patient!,
        addresses: [
          {use: 'home', streetLines: ['123 Test Street'], city: 'Test City'},
        ],
      },
    };
    const tree = renderer.create(<CCDADocumentView document={document} />);
    const text = tree.root.findAllByType(Text).map(node => node.props.children);
    expect(text).toEqual(
      expect.arrayContaining([
        'Document ID',
        'Effective',
        'Jan 15, 2026',
        'Language',
        'en-US',
        'NAME',
        'GENDER',
        'ADDRESS',
        '123 Test Street\nTest City',
      ]),
    );
    expect(tree.root.findByType(FlatList).props.data[4].endsSection).toBe(true);
  });

  it('keeps nested entry details inside the entry row like native renderers', () => {
    const tree = renderer.create(
      <CCDADocumentView document={documentFixture} />,
    );
    const list = tree.root.findByType(FlatList);
    const entryRow = renderer.create(
      list.props.renderItem({item: list.props.data[3], index: 3}),
    );

    expect(entryRow.root.findAllByType(CCDAEntryRow)).toHaveLength(1);
    expect(
      entryRow.root.findAllByType(Text).map(node => node.props.children),
    ).toEqual(expect.arrayContaining(['Child detail', 'Controlled']));
  });

  it('supports host-owned section, entry, and media renderers', () => {
    const tree = renderer.create(
      <CCDADocumentView
        document={documentFixture}
        renderSection={section => <Text>{`custom-section-${section.id}`}</Text>}
        renderEntry={entry => <Text>{`custom-entry-${entry.id}`}</Text>}
        renderMedia={media => <Text>{`custom-media-${media.id}`}</Text>}
      />,
    );
    const list = tree.root.findByType(FlatList);

    expect(list.props.data.map((row: {kind: string}) => row.kind)).toEqual([
      'header',
      'patient',
      'section',
    ]);
    expect(tree.root.findAllByType(CCDASectionView)).toHaveLength(0);
  });

  it('passes entry and media rows to host renderers when sections stay default', () => {
    const tree = renderer.create(
      <CCDADocumentView
        document={documentFixture}
        renderEntry={entry => <Text>{`custom-entry-${entry.id}`}</Text>}
        renderMedia={media => <Text>{`custom-media-${media.id}`}</Text>}
      />,
    );
    const list = tree.root.findByType(FlatList);

    expect(list.props.data.map((row: {kind: string}) => row.kind)).toEqual([
      'header',
      'patient',
      'section',
      'entry',
      'media',
    ]);
  });
});

describe('document boundaries and large inputs', () => {
  it('renders an empty document without inventing patient or section rows', () => {
    const tree = renderer.create(
      <CCDADocumentView
        document={{
          ...documentFixture,
          patient: null,
          sections: [],
        }}
      />,
    );
    expect(
      tree.root
        .findByType(FlatList)
        .props.data.map((row: {kind: string}) => row.kind),
    ).toEqual(['header']);
  });

  it('keeps repeated entry and media identifiers unique across sections', () => {
    const document = {
      ...documentFixture,
      sections: [
        {...documentFixture.sections[0], id: 'first'},
        {...documentFixture.sections[0], id: 'second'},
      ],
    };
    const tree = renderer.create(<CCDADocumentView document={document} />);
    const list = tree.root.findByType(FlatList);
    const keys = list.props.data.map((row: {key: string}) =>
      list.props.keyExtractor(row),
    );
    expect(new Set(keys).size).toBe(keys.length);
    expect(
      list.props.data.filter((row: {endsSection: boolean}) => row.endsSection),
    ).toHaveLength(2);
  });

  it('does not eagerly mount thousands of entry components', () => {
    const document = {
      ...documentFixture,
      sections: [
        {
          ...documentFixture.sections[0],
          media: [],
          entries: Array.from({length: 10000}, (_, index) => ({
            ...documentFixture.sections[0].entries[0],
            id: `large-${index}`,
            children: [],
          })),
        },
      ],
    };
    const renderEntry = jest.fn(entry => <Text>{entry.id}</Text>);
    const tree = renderer.create(
      <CCDADocumentView document={document} renderEntry={renderEntry} />,
    );
    const list = tree.root.findByType(FlatList);
    expect(list.props.data).toHaveLength(10003);
    expect(renderEntry.mock.calls.length).toBeGreaterThan(0);
    expect(renderEntry.mock.calls.length).toBeLessThan(50);
    const last = renderer.create(
      list.props.renderItem({item: list.props.data[10002], index: 10002}),
    );
    expect(
      last.root
        .findAllByType(Text)
        .some(node => node.props.children === 'large-9999'),
    ).toBe(true);
    last.unmount();
    tree.unmount();
  });

  it('lets a custom section own its subtree without invoking entry or media callbacks', () => {
    const renderEntry = jest.fn(() => null);
    const renderMedia = jest.fn(() => null);
    const tree = renderer.create(
      <CCDADocumentView
        document={documentFixture}
        renderSection={section => <Text>{section.title}</Text>}
        renderEntry={renderEntry}
        renderMedia={renderMedia}
      />,
    );
    expect(renderEntry).not.toHaveBeenCalled();
    expect(renderMedia).not.toHaveBeenCalled();
    expect(tree.root.findAllByType(CCDAMediaRow)).toHaveLength(0);
  });
});

describe('default UI appearance snapshots', () => {
  it.each(['light', 'dark'] as const)(
    'preserves the %s document appearance',
    scheme => {
      jest.mocked(useColorScheme).mockReturnValue(scheme);
      const tree = renderer.create(
        <CCDADocumentView document={documentFixture} />,
      );
      expect(tree.toJSON()).toMatchSnapshot();
      tree.unmount();
    },
  );
});
