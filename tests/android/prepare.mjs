import { cpSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
const root = process.argv[2];
if (!root) throw new Error('Usage: node prepare.mjs CONSUMER_DIRECTORY');
const here = dirname(fileURLToPath(import.meta.url));
const template = join(root, 'node_modules/@react-native-community/template/template');
cpSync(join(template, 'android'), join(root, 'android'), { recursive: true });
for (const name of ['index.js', 'babel.config.js', 'metro.config.js']) {
  cpSync(join(template, name), join(root, name));
}
cpSync(join(here, 'App.tsx'), join(root, 'App.tsx'));
writeFileSync(join(root, 'app.json'), JSON.stringify({ name: 'HelloWorld', displayName: 'Adaptive Status Bar Tests' }));
const gradle = join(root, 'android/app/build.gradle');
// Bundle both variants: neither needs Metro and both run the identical assertions.
writeFileSync(gradle, readFileSync(gradle, 'utf8').replace('react {', 'react {\n    debuggableVariants = []'));
const application = join(root, 'android/app/src/main/java/com/helloworld/MainApplication.kt');
writeFileSync(application, readFileSync(application, 'utf8').replace('context = applicationContext,', 'context = applicationContext,\n      useDevSupport = false,'));
