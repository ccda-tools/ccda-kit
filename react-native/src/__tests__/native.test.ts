import {NativeModules} from 'react-native';
import {openCCDAMedia, parseCCDAFile, parseCCDAXml} from '../native';
import {documentFixture} from './fixtures';

const nativeModule = NativeModules.CCDAKit as {
  parseXml: jest.Mock;
  parseFile: jest.Mock;
  openMedia: jest.Mock;
};

describe('ccda-kit native API', () => {
  beforeEach(() => {
    nativeModule.parseXml.mockReset();
    nativeModule.parseFile.mockReset();
    nativeModule.openMedia.mockReset();
    nativeModule.parseXml.mockResolvedValue(documentFixture);
    nativeModule.parseFile.mockResolvedValue(documentFixture);
  });

  it('forwards XML and parser options to the native implementation', async () => {
    const options = {mediaStoragePolicy: 'inline' as const};
    await expect(parseCCDAXml('<ClinicalDocument />', options)).resolves.toBe(
      documentFixture,
    );

    expect(nativeModule.parseXml).toHaveBeenCalledWith(
      '<ClinicalDocument />',
      options,
    );
  });

  it('forwards file paths and parser options to the native implementation', async () => {
    const options = {
      mediaStoragePolicy: 'cacheToDisk' as const,
      mediaCacheDirectory: '/tmp/ccda-media',
    };
    await expect(
      parseCCDAFile('file:///tmp/document.xml', options),
    ).resolves.toBe(documentFixture);

    expect(nativeModule.parseFile).toHaveBeenCalledWith(
      'file:///tmp/document.xml',
      options,
    );
  });

  it('preserves native parser failures', async () => {
    const error = new Error('Invalid C-CDA XML');
    nativeModule.parseXml.mockRejectedValue(error);

    await expect(parseCCDAXml('<broken>')).rejects.toBe(error);
  });

  it('passes attachment payloads to the native preview and preserves preview errors', async () => {
    const media = documentFixture.sections[0].media[0];
    nativeModule.openMedia.mockResolvedValueOnce(undefined);
    await expect(openCCDAMedia(media)).resolves.toBeUndefined();
    expect(nativeModule.openMedia).toHaveBeenCalledWith(media);
    nativeModule.openMedia.mockRejectedValueOnce(
      new Error('Missing cached attachment'),
    );
    await expect(openCCDAMedia(media)).rejects.toThrow(
      'Missing cached attachment',
    );
  });
});

describe('native installation failures', () => {
  const installedModule = NativeModules.CCDAKit;
  afterEach(() => {
    NativeModules.CCDAKit = installedModule;
  });

  it('explains how to link a missing native module', () => {
    NativeModules.CCDAKit = undefined;
    jest.isolateModules(() => {
      const api = require('../native') as typeof import('../native');
      expect(() => api.parseCCDAXml('<ClinicalDocument />')).toThrow(
        'not linked',
      );
      expect(() => api.parseCCDAFile('/tmp/document.xml')).toThrow(
        'not linked',
      );
      expect(() =>
        api.openCCDAMedia(documentFixture.sections[0].media[0]),
      ).toThrow('not linked');
    });
  });

  it('requests a native rebuild when an older installed bridge lacks previews', async () => {
    NativeModules.CCDAKit = {parseXml: jest.fn(), parseFile: jest.fn()};
    let result: Promise<void>;
    jest.isolateModules(() => {
      const api = require('../native') as typeof import('../native');
      result = api.openCCDAMedia(documentFixture.sections[0].media[0]);
    });
    await expect(result!).rejects.toThrow('rebuilding the app');
  });
});

it('uses default options without rewriting the caller’s XML or plain file path', async () => {
  const xml = '<ClinicalDocument>  synthetic text  </ClinicalDocument>';
  const file = '/tmp/a sample/document.xml';
  await parseCCDAXml(xml);
  await parseCCDAFile(file);
  expect(nativeModule.parseXml).toHaveBeenCalledWith(xml, {});
  expect(nativeModule.parseFile).toHaveBeenCalledWith(file, {});
});

it('preserves native file access failures', async () => {
  const error = new Error('File is not readable');
  nativeModule.parseFile.mockRejectedValueOnce(error);
  await expect(parseCCDAFile('/missing/document.xml')).rejects.toBe(error);
});
