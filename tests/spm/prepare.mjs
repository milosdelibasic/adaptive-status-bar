import { cpSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const root = process.argv[2];
const template = join(root, 'node_modules/@react-native-community/template/template');
cpSync(join(template, 'ios'), join(root, 'ios'), { recursive: true });
for (const name of ['index.js', 'babel.config.js', 'metro.config.js']) {
  cpSync(join(template, name), join(root, name));
}
const scene = join(root, 'ios/HelloWorld/SceneDelegate.swift');
writeFileSync(scene, readFileSync(scene, 'utf8')
  .replace('import UIKit', 'import UIKit\nimport SkyvistAdaptiveStatusBar')
  .replace('  override func bundleURL()', `  override func createRootViewController() -> UIViewController {
    AdaptiveStatusBarViewController()
  }

  override func bundleURL()`));
writeFileSync(join(root, 'app.json'), JSON.stringify({ name: 'HelloWorld', displayName: 'SPM Consumer' }));
writeFileSync(join(root, 'App.tsx'), `import { View } from 'react-native';
import React from 'react';
import { AdaptiveStatusBar } from '@skyvist/adaptive-status-bar';
AdaptiveStatusBar.enable({ strategy: 'automatic' });
export default () => <View />;
`);
