const path = require('node:path');
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * @type {import('metro-config').MetroConfig}
 */
const packageRoot = path.resolve(__dirname, '..');
const defaultConfig = getDefaultConfig(__dirname);

const config = {
  watchFolders: [
    packageRoot,
    path.resolve(packageRoot, '../test-data/ccda/samples'),
  ],
  transformer: {
    babelTransformerPath: require.resolve('./xml-transformer'),
  },
  resolver: {
    sourceExts: [...defaultConfig.resolver.sourceExts, 'xml'],
    assetExts: defaultConfig.resolver.assetExts.filter(
      extension => extension !== 'xml',
    ),
    // Resolve the local library's peer dependencies from the app as well.
    // Two React copies cause hook failures when the document list mounts.
    disableHierarchicalLookup: true,
    extraNodeModules: {
      '@ccda-kit/react-native': packageRoot,
    },
    nodeModulesPaths: [
      path.resolve(__dirname, 'node_modules'),
      path.resolve(packageRoot, 'node_modules'),
    ],
  },
};

module.exports = mergeConfig(defaultConfig, config);
