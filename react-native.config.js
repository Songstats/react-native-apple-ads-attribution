module.exports = {
  dependency: {
    platforms: {
      ios: {
        podspecPath: 'react-native-apple-ads-attribution.podspec',
        codegenConfig: {
          name: 'AppleAdsAttributionSpec',
          type: 'modules',
          jsSrcsDir: 'src',
        },
      },
    },
  },
};
