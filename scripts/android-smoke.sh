#!/usr/bin/env bash
set -euo pipefail

export ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$HOME/gradle-8.7/bin:$PATH"

echo "== java =="
java -version 2>&1 | head -3

echo "== gradle =="
gradle --version | head -8

echo "== sdk packages =="
sdkmanager --list_installed

echo "== assembleDebug =="
gradle --no-daemon assembleDebug
APK=app/build/outputs/apk/debug/app-debug.apk
test -f "$APK"
ls -lh "$APK"

echo "== start emulator =="
if ! adb devices | grep -q "emulator-.*device"; then
  nohup emulator -avd devin -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect -no-snapshot > /tmp/emulator.log 2>&1 &
fi
adb wait-for-device
for i in $(seq 1 60); do
  boot=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)
  if [ "$boot" = "1" ]; then
    break
  fi
  sleep 5
done
echo "boot_completed=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
adb shell input keyevent 82

echo "== install =="
adb install -r "$APK"

echo "== launch =="
adb shell am start -n com.example.devinandroid/.MainActivity
sleep 3
adb shell dumpsys activity activities | grep -E "mResumedActivity|topResumedActivity" || true

echo "== screenshot =="
adb exec-out screencap -p > /tmp/android-smoke.png
ls -lh /tmp/android-smoke.png

echo "== unit tests =="
gradle --no-daemon testDebugUnitTest

echo "== instrumented tests =="
gradle --no-daemon connectedDebugAndroidTest

echo "ANDROID_SMOKE_OK"
