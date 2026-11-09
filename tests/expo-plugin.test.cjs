const { test, after } = require('node:test');
const assert = require('node:assert/strict');
const Module = require('node:module');
const originalLoad = Module._load;
let expoVersion = '58.0.23';
after(() => { Module._load = originalLoad; });
Module._load = function (name, ...args) {
  if (name === 'expo/package.json') return { version: expoVersion };
  if (name === 'expo/config-plugins') return {
    withInfoPlist: (config, apply) => ({ ...config, ios: { ...config.ios, infoPlist: apply({ modResults: { ...config.ios?.infoPlist } }).modResults } }),
    createRunOncePlugin: (plugin) => plugin,
  };
  return originalLoad.call(this, name, ...args);
};
const plugin = require('../app.plugin');
// Keep the minimal Expo fixture available for lazy version resolution.

test('enables controller appearance without changing other settings', () => {
  const input = { sdkVersion: '58.0.0', ios: { infoPlist: { Custom: 'keep', UIViewControllerBasedStatusBarAppearance: false } }, android: { package: 'example.test' } };
  const result = plugin(input);
  assert.equal(result.ios.infoPlist.UIViewControllerBasedStatusBarAppearance, true);
  assert.equal(result.ios.infoPlist.Custom, 'keep');
  assert.deepEqual(result.android, input.android);
  assert.equal(input.ios.infoPlist.UIViewControllerBasedStatusBarAppearance, false);
});
test('repeated application is idempotent', () => {
  const first = plugin({});
  assert.deepEqual(plugin(first), first);
});
test('explicit unsupported SDK is rejected', () => {
  assert.throws(() => plugin({ sdkVersion: '57.0.0' }), /SDK 58/);
});
test('native adapter preserves Expo lifecycle and only sets style', () => {
  const fs = require('node:fs');
  const native = fs.readFileSync(require('node:path').join(__dirname, '../ios/SkyvistAdaptiveStatusBar.mm'), 'utf8');
  assert.match(native, /__has_include\(<React\/RCTStatusBarAppearance.h>\)/);
  assert.match(native, /\[RCTStatusBarAppearance setStyle:/);
  assert.doesNotMatch(native, /setHidden:|method_exchangeImplementations|setRootViewController:/);
  assert.match(native, /removeObserver:self/);
});

test('rejects unsupported installed Expo even without sdkVersion', () => {
  expoVersion = '57.0.0';
  try { assert.throws(() => plugin({}), /SDK 58/); }
  finally { expoVersion = '58.0.23'; }
});
