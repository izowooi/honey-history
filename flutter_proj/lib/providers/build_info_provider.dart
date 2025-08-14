import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_proj/providers/remote_config_provider.dart';

// 앱의 빌드/배포 관련 정보 제공 (Single Responsibility)

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

// Android: versionCode, iOS: CFBundleVersion (문자열)
final versionCodeProvider = FutureProvider<String>((ref) async {
  final info = await ref.watch(packageInfoProvider.future);
  return info.buildNumber; // Android에서 versionCode
});

// 리뷰 빌드 여부: 현재 versionCode == RemoteConfig.review_version
final isReviewBuildProvider = FutureProvider<bool>((ref) async {
  final currentVersionCode = await ref.watch(versionCodeProvider.future);
  final reviewVersion = await ref.watch(reviewVersionProvider.future);
  return reviewVersion.isNotEmpty && currentVersionCode == reviewVersion;
});


