import {NativeModules, Platform} from 'react-native';
import type {CCDADocument, CCDAMedia, CCDAParseOptions} from './types';

type CCDAKitNativeModule = {
  parseXml(xml: string, options?: CCDAParseOptions): Promise<CCDADocument>;
  parseFile(path: string, options?: CCDAParseOptions): Promise<CCDADocument>;
  openMedia?: (media: CCDAMedia) => Promise<void>;
};

const LINKING_ERROR =
  `The ccda-kit React Native native module is not linked on ${Platform.OS}. ` +
  'Run pod install for iOS, rebuild the app, and confirm Android autolinking found the package.';

const CCDAKitModule = NativeModules.CCDAKit as CCDAKitNativeModule | undefined;

function nativeModule(): CCDAKitNativeModule {
  if (!CCDAKitModule) {
    throw new Error(LINKING_ERROR);
  }
  return CCDAKitModule;
}

export function parseCCDAXml(
  xml: string,
  options: CCDAParseOptions = {},
): Promise<CCDADocument> {
  return nativeModule().parseXml(xml, options);
}

export function parseCCDAFile(
  path: string,
  options: CCDAParseOptions = {},
): Promise<CCDADocument> {
  return nativeModule().parseFile(path, options);
}

/** Presents the platform's in-app attachment preview. */
export function openCCDAMedia(media: CCDAMedia): Promise<void> {
  const module = nativeModule();
  if (!module.openMedia) {
    return Promise.reject(
      new Error(
        'Attachment previews require rebuilding the app with the updated ccda-kit native module.',
      ),
    );
  }
  return module.openMedia(media);
}
