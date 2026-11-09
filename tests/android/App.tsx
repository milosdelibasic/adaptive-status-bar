import React, {useEffect, useRef, useState} from 'react';
import {Appearance, AppState, FlatList, Image, Modal, Platform, Text, View, useWindowDimensions} from 'react-native';
import {AdaptiveStatusBar} from '@skyvist/adaptive-status-bar';

// Embedded SVG-free PNGs remove networking/image-loader dependencies from the consumer.
const dark = {uri: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGNgYGAAAAAEAAH2FzhVAAAAAElFTkSuQmCC'};
const light = {uri: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4//8/AAX+Av4N70a4AAAAAElFTkSuQmCC'};
const wait = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));
const options = {strategy: 'automatic', performance: 'responsive', idleInterval: 0} as const;
export default function App() {
  const [white, setWhite] = useState(false);
  const [modal, setModal] = useState(false);
  const [result, setResult] = useState('RUNNING');
  const [lifecycle, setLifecycle] = useState('WAITING');
  const list = useRef<FlatList<boolean>>(null);
  const alive = useRef(true);
  const done = useRef(false);
  const checking = useRef(false);
  const {width, height} = useWindowDimensions();
  const geometry = useRef({width, height});
  geometry.current = {width, height};
  const initial = useRef({width, height});
  const events = useRef({landscape: false, portrait: false, background: false, resumed: false});
  const supported = Number(Platform.Version) >= 26;
  const failures = useRef<string[]>([]);
  const results = useRef<object[]>([]);
  const check = async (name: string, expected: 'light' | 'dark', source = 'sample') => {
    let stats;
    const deadline = Date.now() + 5000;
    do {
      await wait(100);
      stats = await AdaptiveStatusBar.getStats();
      if (stats.style === expected && stats.observedStyle === expected && stats.source === source &&
          (supported ? stats.samples > 0 && stats.failures === 0 : stats.samples === 0 && !stats.supported && !stats.sampling)) break;
    } while (alive.current && Date.now() < deadline);
    const pass = stats?.style === expected && stats?.observedStyle === expected && stats?.source === source &&
      (supported ? stats.samples > 0 && stats.failures === 0 : stats.samples === 0 && !stats.supported && !stats.sampling);
    if (!pass) failures.current.push(name);
    results.current.push({name, pass, stats});
    console.info('ASB_CHECK', JSON.stringify(results.current.at(-1)));
  };
  const verifyLifecycle = async () => {
    if (!done.current || checking.current) return;
    checking.current = true;
    try {
      await check('lifecycle-contrast', 'light', supported ? 'sample' : 'fallback');
      setLifecycle(failures.current.length ? 'FAIL' :
        Object.values(events.current).every(Boolean) ? 'PASS' : JSON.stringify(events.current));
    } finally { checking.current = false; }
  };
  useEffect(() => {
    if (width > height) events.current.landscape = true;
    if (events.current.landscape && height > width) events.current.portrait = true;
    void verifyLifecycle();
  }, [width, height]);
  useEffect(() => {
    alive.current = true;
    AdaptiveStatusBar.enable(options);
    const sub = AppState.addEventListener('change', state => {
      if (state === 'background') events.current.background = true;
      if (state === 'active' && events.current.background) {
        events.current.resumed = true;
        void verifyLifecycle();
      }
    });
    const run = async () => {
      try {
        await wait(500);
        AdaptiveStatusBar.resetStats();
        if (supported) {
          await check('dark-image', 'light');
          setWhite(true); await check('changed-to-light-image', 'dark');
          setWhite(false); await check('changed-to-dark-image', 'light');
          list.current?.scrollToOffset({offset: initial.current.height, animated: true});
          await check('scroll-to-light-image', 'dark');
          list.current?.scrollToOffset({offset: initial.current.height * 2, animated: true});
          await check('scroll-to-dark-image', 'light');
          list.current?.scrollToOffset({offset: 0, animated: false});
          for (let i = 0; i < 6; i++) {
            setWhite(i % 2 === 0); await check(`image-cycle-${i}`, i % 2 === 0 ? 'dark' : 'light');
          }
          AdaptiveStatusBar.setOverride('dark'); await wait(100);
          AdaptiveStatusBar.clearOverride(); await check('automatic-after-override', 'light');
          setModal(true); await check('modal-dark-image', 'light');
          setWhite(true); await check('modal-light-image', 'dark');
          list.current?.scrollToOffset({offset: initial.current.height * 2, animated: true});
          await check('modal-scroll-to-dark', 'light');
          setModal(false); setWhite(false); await check('automatic-after-modal', 'light');
        } else {
          await check('fallback-system-theme', Appearance.getColorScheme() === 'dark' ? 'light' : 'dark', 'fallback');
          // Explicit fallback is independent of emulator theme; no pixels are sampled.
          AdaptiveStatusBar.configure({fallbackStyle: 'dark'}); await check('fallback-dark', 'dark', 'fallback');
          AdaptiveStatusBar.configure({fallbackStyle: 'light'}); await check('fallback-light', 'light', 'fallback');
          AdaptiveStatusBar.setOverride('dark'); await check('fallback-override', 'dark', 'override');
          AdaptiveStatusBar.clearOverride(); await check('fallback-after-override', 'light', 'fallback');
          AdaptiveStatusBar.disable(); AdaptiveStatusBar.enable({...options, fallbackStyle: 'light'});
          await check('fallback-reenabled', 'light', 'fallback');
          setModal(true); await check('fallback-modal-light', 'light', 'fallback');
          AdaptiveStatusBar.configure({fallbackStyle: 'dark'}); await check('fallback-modal-dark', 'dark', 'fallback');
          setModal(false); AdaptiveStatusBar.configure({fallbackStyle: 'light'});
          await check('fallback-after-modal', 'light', 'fallback');
          AdaptiveStatusBar.configure({strategy: 'hybrid'}); AdaptiveStatusBar.setHint('dark');
          await check('fallback-hybrid-hint', 'dark', 'hint');
          AdaptiveStatusBar.setHint(null); await check('fallback-after-hybrid-hint', 'light', 'fallback');
          AdaptiveStatusBar.configure({strategy: 'manual'}); AdaptiveStatusBar.setHint('dark');
          await check('fallback-manual-hint', 'dark', 'hint');
          AdaptiveStatusBar.setHint(null); await check('fallback-after-manual-hint', 'light', 'fallback');
          AdaptiveStatusBar.configure({strategy: 'automatic'}); AdaptiveStatusBar.setHint('dark');
          await check('fallback-automatic-ignores-hint', 'light', 'fallback'); AdaptiveStatusBar.setHint(null);

        }
        done.current = true;
        setResult(failures.current.length ? `FAIL:${failures.current.join(',')}` : `PASS:${results.current.length}`);
        void verifyLifecycle();
      } catch (error) { setResult(`ERROR:${String(error)}`); }
    };
    void run();
    return () => {alive.current = false; sub.remove(); AdaptiveStatusBar.disable();};
  }, []);
  const content = <View style={{flex: 1}}>
    <FlatList ref={list} data={[false, true, false, true]} extraData={white}
      keyExtractor={(_, i) => String(i)}
      renderItem={({item, index}) => <Image resizeMode="stretch" source={(index === 0 ? white : item) ? light : dark}
        style={{width, height}} />} />
    <View style={{position: 'absolute', top: '40%', left: 20, right: 20, padding: 12, backgroundColor: '#888'}}>
      <Text testID="integration-result">{result}</Text>
      <Text testID="lifecycle-result">{lifecycle}</Text>
    </View>
  </View>;
  return <View style={{flex: 1}}>{!modal && content}<Modal visible={modal} transparent statusBarTranslucent animationType="none">{modal && content}</Modal></View>;
}
