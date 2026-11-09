#!/usr/bin/env python3
"""ADB-only test driver. Requires an explicitly selected emulator/device and an installed fixture."""
import argparse, json, pathlib, subprocess, time, xml.etree.ElementTree as ET
p=argparse.ArgumentParser(); p.add_argument('--serial',required=True); p.add_argument('--output',required=True); a=p.parse_args()
out=pathlib.Path(a.output); out.mkdir(parents=True,exist_ok=True)
package='com.helloworld'
def adb(*args):
    return subprocess.check_output(['adb','-s',a.serial,*args],stderr=subprocess.STDOUT,timeout=30)
def setting(key): return adb('shell','settings','get','system',key).decode().strip()
def setsetting(key,value):
    adb('shell','settings', 'delete' if value=='null' else 'put','system',key,*([] if value=='null' else [value]))
def snapshot():
    try:
        adb('shell','uiautomator','dump','/sdcard/asb-window.xml')
    except subprocess.CalledProcessError as error:
        raise RuntimeError('UIAutomator dump failed. Close other device automation sessions before running this driver. '+error.output.decode(errors='replace')) from error
    return ET.fromstring(adb('shell','cat','/sdcard/asb-window.xml'))
def wait_result(identifier,expected,timeout=150):
    deadline=time.time()+timeout
    while time.time()<deadline:
        root=snapshot()
        texts=[n.get('text','') for n in root.iter('node') if n.get('resource-id','').endswith(identifier)]
        for text in texts:
            if text.startswith(('FAIL','ERROR')): raise AssertionError(text)
            if text.startswith(expected): return text
        time.sleep(1)
    raise TimeoutError(f'{identifier} did not reach {expected}')
def wait_event(name, timeout=30):
    deadline=time.time()+timeout
    while time.time()<deadline:
        root=snapshot()
        for node in root.iter('node'):
            if not node.get('resource-id','').endswith('lifecycle-result'): continue
            text=node.get('text','')
            if text.startswith(('FAIL','ERROR')): raise AssertionError(text)
            if text.startswith('{') and json.loads(text).get(name) is True: return
        time.sleep(.5)
    raise TimeoutError(f'App did not verify {name} orientation and icon style')
def evidence(name):
    (out/(name+'.png')).write_bytes(adb('exec-out','screencap','-p'))
    (out/(name+'.xml')).write_bytes(ET.tostring(snapshot()))
old={k:setting(k) for k in ['accelerometer_rotation','user_rotation']}
try:
    setsetting('accelerometer_rotation','0'); setsetting('user_rotation','0')
    adb('shell','am','force-stop',package)
    adb('shell','am','start','-W','-n',package+'/.MainActivity')
    result=wait_result('integration-result','PASS:')
    api=int(adb('shell','getprop','ro.build.version.sdk').decode().strip())
    expected=16 if api>=26 else 14
    if result != f'PASS:{expected}': raise AssertionError(f'Expected {expected} checks, got {result}')
    evidence('checks-passed')
    setsetting('accelerometer_rotation','0'); setsetting('user_rotation','1'); wait_event('landscape'); evidence('landscape')
    setsetting('accelerometer_rotation','0'); setsetting('user_rotation','0'); wait_event('portrait'); evidence('portrait')
    adb('shell','input','keyevent','KEYCODE_HOME'); time.sleep(2)
    adb('shell','am','start','-W','-n',package+'/.MainActivity')
    lifecycle=wait_result('lifecycle-result','PASS',30); evidence('resumed-portrait')
    report={'serial':a.serial,'api':adb('shell','getprop','ro.build.version.sdk').decode().strip(),'checks':result,'lifecycle':lifecycle}
    (out/'result.json').write_text(json.dumps(report,indent=2)); print(json.dumps(report))
finally:
    try:
        (out/'logcat.txt').write_bytes(adb('logcat','-d','-v','threadtime'))
    finally:
        try:
            setsetting('user_rotation',old['user_rotation'])
        finally:
            setsetting('accelerometer_rotation',old['accelerometer_rotation'])
