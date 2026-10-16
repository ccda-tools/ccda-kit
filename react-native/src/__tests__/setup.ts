import {NativeModules} from 'react-native';

jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');

NativeModules.CCDAKit = {
  parseXml: jest.fn(),
  parseFile: jest.fn(),
  openMedia: jest.fn(),
};
