# devin-android-smoke

Minimal Android app used to verify Devin Cloud Android build/test capability.

## What it contains

- Single `MainActivity` showing one `TextView`.
- One JVM unit test (`SmokeUnitTest`).
- One Espresso instrumented test (`MainActivityTest`).
- `.devin/environment.yaml` blueprint that installs JDK 17, Android SDK, emulator, and Gradle 8.7.

## Build

```bash
gradle --no-daemon assembleDebug
```

Output: `app/build/outputs/apk/debug/app-debug.apk`

## Test

```bash
gradle --no-daemon testDebugUnitTest
```

Instrumented tests require a running emulator:

```bash
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$HOME/gradle-8.7/bin:$PATH"
nohup emulator -avd devin -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect -no-snapshot > /tmp/emulator.log 2>&1 &
adb wait-for-device
until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do sleep 5; done
gradle --no-daemon connectedDebugAndroidTest
```
