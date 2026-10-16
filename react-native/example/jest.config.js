module.exports = {
  preset: 'react-native',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  transformIgnorePatterns: [
    'node_modules/(?!(@react-native|react-native|@react-navigation)(/|-))',
  ],
  transform: {
    '^.+\\.xml$': '<rootDir>/xml-transformer.js',
    '^.+\\.[jt]sx?$': 'babel-jest',
  },
};
