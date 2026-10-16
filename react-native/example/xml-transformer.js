const transformer = require('@react-native/metro-babel-transformer');

module.exports.transform = ({src, filename, ...options}) =>
  transformer.transform({
    ...options,
    filename,
    src: filename.endsWith('.xml')
      ? `module.exports = ${JSON.stringify(src)};`
      : src,
  });

// Jest uses the same XML representation as the bundled application.
module.exports.process = src => ({
  code: `module.exports = ${JSON.stringify(src)};`,
});
