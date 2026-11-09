import { registerRootComponent } from 'expo';
import React, { useEffect, useState } from 'react';
import { View, Text, Pressable, Modal, StatusBar, useWindowDimensions, DevSettings } from 'react-native';
import { AdaptiveStatusBar } from '@skyvist/adaptive-status-bar';
function App() {
  const [dark, setDark] = useState(false);
  const [modal, setModal] = useState(false);
  const [hidden, setHidden] = useState(false);
  const { width, height } = useWindowDimensions();
  const [stats, setStats] = useState({});
  useEffect(() => {
    AdaptiveStatusBar.enable({ strategy: 'automatic', performance: 'responsive', animated: false });
    const timer = setInterval(async () => setStats(await AdaptiveStatusBar.getStats()), 500);
    return () => { clearInterval(timer); AdaptiveStatusBar.disable(); };
  }, []);
  return <View style={{flex: 1, backgroundColor: dark ? '#000' : '#fff', paddingTop: 120, paddingHorizontal: 24}}>
    <Text style={{color: dark ? '#fff' : '#000', fontSize: 20}}>Expo SDK 58 native status bar ({width}x{height})</Text>
    <Pressable accessibilityLabel="Toggle background" onPress={() => setDark(!dark)} style={{backgroundColor: '#888', padding: 20, marginTop: 20}}><Text>Toggle background</Text></Pressable>
    <Pressable accessibilityLabel="Force light icons" onPress={() => AdaptiveStatusBar.setOverride('light')} style={{backgroundColor: '#888', padding: 20, marginTop: 20}}><Text>Force light icons</Text></Pressable>
    <Pressable accessibilityLabel="Automatic icons" onPress={() => AdaptiveStatusBar.clearOverride()} style={{backgroundColor: '#888', padding: 20, marginTop: 20}}><Text>Automatic icons</Text></Pressable>
    <Pressable accessibilityLabel="Toggle hidden status bar" onPress={() => { StatusBar.setHidden(!hidden, 'none'); setHidden(!hidden); }} style={{backgroundColor: '#888', padding: 12, marginTop: 12}}><Text>Hidden: {String(hidden)}</Text></Pressable>
    {__DEV__ && <Pressable accessibilityLabel="Reload development app" onPress={() => DevSettings.reload()} style={{backgroundColor: '#888', padding: 12, marginTop: 12}}><Text>Reload development app</Text></Pressable>}
    <Pressable accessibilityLabel="Open modal" onPress={() => setModal(true)} style={{backgroundColor: '#888', padding: 12, marginTop: 12}}><Text>Open modal</Text></Pressable>
    <Text style={{color: dark ? '#fff' : '#000'}}>Geometry: {width}x{height}</Text>
    <Text style={{color: dark ? '#fff' : '#000', marginTop: 12}}>{JSON.stringify(stats)}</Text>
    <Modal visible={modal} animationType="none" onRequestClose={() => setModal(false)}>
      <View style={{flex: 1, backgroundColor: '#000', paddingTop: 120, paddingHorizontal: 24}}>
        <Text style={{color: '#fff'}}>Dark modal</Text>
        <Pressable accessibilityLabel="Close modal" onPress={() => setModal(false)} style={{backgroundColor: '#888', padding: 20, marginTop: 20}}><Text>Close modal</Text></Pressable>
      </View>
    </Modal>
  </View>;
}
registerRootComponent(App);
