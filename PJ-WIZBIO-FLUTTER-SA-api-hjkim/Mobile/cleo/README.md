# Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# After Flutter install 
## 1. Test requirments with `flutter doctor -v`
Sample result
```txt
[✓] Flutter (Channel stable, 2.10.2, on macOS 11.6.1 20G224 darwin-x64, locale ko-KR)
    • Flutter version 2.10.2 at ~~
    • Upstream repository ~~
    • Framework revision 097d3313d8 (5 weeks ago), 2022-02-18 19:33:08 -0600
    • Engine revision a83ed0e5e3
    • Dart version 2.16.1
    • DevTools version 2.9.2

[✓] Android toolchain - develop for Android devices (Android SDK version 30.0.2)
    • Android SDK at /Users/dong-yublee/Library/Android/sdk
    • Platform android-31, build-tools 30.0.2
    • ANDROID_HOME = /Users/dong-yublee/Library/Android/sdk
    • ANDROID_SDK_ROOT = /Users/dong-yublee/Library/Android/sdk
    • Java binary at: /Applications/Android Studio.app/Contents/jre/Contents/Home/bin/java
    • Java version OpenJDK Runtime Environment (build 11.0.11+0-b60-7590822)
    • All Android licenses accepted.

[✓] Xcode - develop for iOS and macOS (Xcode 13.2.1)
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • CocoaPods version 1.10.1

[✓] Android Studio (version 2021.1)
    • Android Studio at /Applications/Android Studio.app/Contents
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK Runtime Environment (build 11.0.11+0-b60-7590822)
```

## 2. Run debug mode
```bash
:/Mobile/cleo $ flutter run
```

## 3. Build APK for Test
```bash
:/Mobile/cleo $ flutter build apk --release
:/Mobile/cleo $ flutter build apk --debug
```
files located at `Mobile/cleo/build/app/outputs/flutter-apk`

## 4. Build Appbundle for Play Store Upload
```bash
:/Mobile/cleo $ flutter build appbundle
```
a file located at `Mobile/cleo/build/app/outputs/bundle/release/app-release.aab`
    

# project files
- To change video : change files in `Mobile/cleo/assets/video`
- To change report description : change lines in `ResultDescription` @ `/Mobile/cleo/lib/screen/report/report_content.dart`  
- To change device step description : change lines in `_CartridgeProcessScreenState` @ `Mobile/cleo/lib/screen/cartridge/cartridge_process.dart`

