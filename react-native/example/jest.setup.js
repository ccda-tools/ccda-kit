/* eslint-env jest */
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');
jest.mock(
  'react-native-safe-area-context',
  () => require('react-native-safe-area-context/jest/mock').default,
);
