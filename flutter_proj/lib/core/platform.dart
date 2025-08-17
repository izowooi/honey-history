import 'dart:io' show Platform;

enum AppPlatform { android, ios, other }

late final AppPlatform appPlatform;
bool _platformInitialized = false;

void initAppPlatform() {
  if (_platformInitialized) return;
  if (Platform.isAndroid) {
    appPlatform = AppPlatform.android;
  } else if (Platform.isIOS) {
    appPlatform = AppPlatform.ios;
  } else {
    appPlatform = AppPlatform.other;
  }
  _platformInitialized = true;
}

String reviewVersionKeyForPlatform() {
  switch (appPlatform) {
    case AppPlatform.android:
      return 'review_versioncode_aos';
    case AppPlatform.ios:
      return 'review_versioncode_ios';
    case AppPlatform.other:
      return 'review_version';
  }
}


