import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

// Remote Config 인스턴스 provider
final remoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  final remoteConfig = FirebaseRemoteConfig.instance;
  
  // 기본값 설정
  remoteConfig.setDefaults({
    'review_version': '0.0.0', // 기본값
  });
  
  print('Remote Config Provider 초기화됨');
  return remoteConfig;
});

// Remote Config 값들을 관리하는 provider
final remoteConfigValuesProvider = FutureProvider<Map<String, String>>((ref) async {
  final remoteConfig = ref.read(remoteConfigProvider);
  
  try {
    print('Remote Config 설정 시작...');
    
    // Remote Config 초기화 및 활성화
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(seconds: 0), // 개발 중에는 0으로 설정
    ));
    
    print('Remote Config 설정 완료');
    print('Fetch 타임아웃: ${remoteConfig.settings.fetchTimeout}');
    print('최소 가져오기 간격: ${remoteConfig.settings.minimumFetchInterval}');
    
    // 설정 가져오기
    print('Remote Config fetchAndActivate 시작...');
    final activated = await remoteConfig.fetchAndActivate();
    print('Remote Config fetchAndActivate 완료: $activated');
    
    // 현재 설정된 모든 키 확인
    final allKeys = remoteConfig.getAll();
    print('Remote Config 모든 키: ${allKeys.keys.toList()}');
    
    // review_version 값 확인
    final reviewVersion = remoteConfig.getString('review_version');
    print('review_version 값: "$reviewVersion"');
    
    // 모든 설정값 반환
    final result = {
      'review_version': reviewVersion,
      'fetch_time': DateTime.now().toIso8601String(),
      'activated': activated.toString(),
      'last_fetch_time': remoteConfig.lastFetchTime?.toIso8601String() ?? '없음',
      'last_fetch_status': remoteConfig.lastFetchStatus.toString(),
    };
    
    print('Remote Config 결과: $result');
    return result;
    
  } catch (e, stackTrace) {
    print('Remote Config 에러: $e');
    print('스택 트레이스: $stackTrace');
    // 에러 시 기본값 반환
    return {
      'review_version': '0.0.0',
      'fetch_time': DateTime.now().toIso8601String(),
      'error': e.toString(),
      'stack_trace': stackTrace.toString(),
    };
  }
});

// 특정 키의 값만 가져오는 provider
final reviewVersionProvider = FutureProvider<String>((ref) async {
  final values = await ref.watch(remoteConfigValuesProvider.future);
  final version = values['review_version'] ?? '0.0.0';
  print('reviewVersionProvider에서 반환하는 값: "$version"');
  return version;
});

// Remote Config 상태를 확인하는 provider
final remoteConfigStatusProvider = FutureProvider<RemoteConfigStatus>((ref) async {
  final remoteConfig = ref.read(remoteConfigProvider);
  
  return RemoteConfigStatus(
    lastFetchTime: remoteConfig.lastFetchTime,
    lastFetchStatus: remoteConfig.lastFetchStatus,
    settings: remoteConfig.settings,
  );
});

// Remote Config 상태를 위한 클래스
class RemoteConfigStatus {
  final DateTime? lastFetchTime;
  final RemoteConfigFetchStatus lastFetchStatus;
  final RemoteConfigSettings settings;
  
  RemoteConfigStatus({
    required this.lastFetchTime,
    required this.lastFetchStatus,
    required this.settings,
  });
} 