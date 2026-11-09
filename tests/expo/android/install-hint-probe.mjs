// Adds an isolated test Activity to an already generated disposable Expo fixture.
import {readFileSync, writeFileSync, copyFileSync} from 'node:fs';
import {resolve, dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const root = resolve(process.argv[2]);
const here = dirname(fileURLToPath(import.meta.url));
const manifest = resolve(root, 'android/app/src/main/AndroidManifest.xml');
let xml = readFileSync(manifest, 'utf8');
if (!xml.includes('HintLifecycleProbeActivity')) {
  xml = xml.replace('</application>', '<activity android:name=".HintLifecycleProbeActivity" android:exported="true" android:theme="@style/AppTheme" />\n  </application>');
  writeFileSync(manifest, xml);
}
copyFileSync(resolve(here, 'HintLifecycleProbeActivity.kt'), resolve(root, 'android/app/src/main/java/com/skyvist/asbexpoandroid/HintLifecycleProbeActivity.kt'));
