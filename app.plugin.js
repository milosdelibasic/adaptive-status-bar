// Loaded by Expo CLI only; no Expo dependency is needed in bare React Native.
const { withInfoPlist, createRunOncePlugin } = require('expo/config-plugins');
const pkg = require('./package.json');

function withAdaptiveStatusBar(config) {
  const installedVersion = require('expo/package.json').version;
  if (!/^58\./.test(installedVersion)) {
    throw new Error('@skyvist/adaptive-status-bar: install Expo SDK 58 for this integration.');
  }
  if (config.sdkVersion && !/^58\./.test(config.sdkVersion)) {
    throw new Error('@skyvist/adaptive-status-bar: Expo support currently targets SDK 58.');
  }
  return withInfoPlist(config, (mod) => {
    mod.modResults.UIViewControllerBasedStatusBarAppearance = true;
    return mod;
  });
}

module.exports = createRunOncePlugin(withAdaptiveStatusBar, pkg.name, pkg.version);
