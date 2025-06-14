git push
flutter build apk --split-per-abi
adb push build\app\outputs\flutter-apk\app-arm64-v8a-release.apk /sdcard/
msg * Build finished.