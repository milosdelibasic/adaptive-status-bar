# Android analyzer CPU benchmark

This opt-in benchmark compares the frozen `f3d10de` analyzer against the current
implementation on identical seeded 96×8 ARGB buffers. It alternates measurement
order, warms each path with 160,000 samples, consumes the output and reports all
nine 100,000-sample rounds plus their medians. It verifies exact output parity
before timing. Normal unit tests also exhaust all 16,777,216 RGB inputs and
compare 1,792 randomized whole strips, including narrow/nonstandard dimensions.

```sh
cd android/core-tests
./gradlew test benchmarkLuminance
```

This is analyzer CPU work, **not** PixelCopy latency, total app CPU, frame rate,
battery life or physical-device performance. Desktop HotSpot results do not
predict Android ART results.

To repeat on an already selected Android emulator, first compile `benchmarkClasses`,
package `build/classes/kotlin/main` and `build/classes/kotlin/benchmark` into a jar,
and convert that jar plus the matching Kotlin stdlib with Android SDK `d8`:

```sh
./gradlew benchmarkClasses
jar cf /tmp/asb-benchmark-classes.jar \
  -C build/classes/kotlin/main . -C build/classes/kotlin/benchmark .
# Set KOTLIN_STDLIB to the resolved kotlin-stdlib-2.1.20.jar in Gradle's cache.
"$ANDROID_HOME/build-tools/37.0.0/d8" --release --min-api 26 \
  --lib "$ANDROID_HOME/platforms/android-37.0/android.jar" \
  --output /tmp/asb-benchmark.jar /tmp/asb-benchmark-classes.jar "$KOTLIN_STDLIB"
adb -s "$ANDROID_SERIAL" push /tmp/asb-benchmark.jar /data/local/tmp/asb-benchmark.jar
adb -s "$ANDROID_SERIAL" shell \
  'CLASSPATH=/data/local/tmp/asb-benchmark.jar app_process /system/bin com.skyvist.adaptivestatusbar.core.LuminanceBenchmarkKt'
```

Record runtime/API/ABI, all rounds and the device type. Repeat in fresh processes.
The reference and benchmark are excluded from the npm/native production payload.

## 2026-11-09 result

Android API36 ARM64 emulator, Android ART via `app_process`, three fresh processes:

| Run | Original median | Weighted lookup median | Change |
| --- | --- | --- | --- |
| 1 | 944.890 ns/sample | 565.365 ns/sample | −40.2% |
| 2 | 979.752 ns/sample | 566.670 ns/sample | −42.2% |
| 3 | 950.743 ns/sample | 566.646 ns/sample | −40.4% |

The earlier desktop JVM run was only 359.119 → 339.233 ns/sample (−5.5%),
illustrating why the Android runtime was measured separately. The optimization
uses three preweighted lookup tables, adding 2 KiB of retained table storage,
while preserving the original Float operations/results. These numbers are a
microbenchmark result on the test host, not a guarantee for other devices.
