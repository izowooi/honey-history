import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proj/providers/remote_config_provider.dart';

class RemoteConfigTestWidget extends ConsumerWidget {
  const RemoteConfigTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewVersionAsync = ref.watch(reviewVersionProvider);
    final remoteConfigStatusAsync = ref.watch(remoteConfigStatusProvider);
    final remoteConfigValuesAsync = ref.watch(remoteConfigValuesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Config 테스트'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Review Version',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      reviewVersionAsync.when(
                        data: (version) => Text(
                          '현재 값: $version',
                          style: const TextStyle(fontSize: 16),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Text(
                          '에러: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remote Config 상세 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      remoteConfigValuesAsync.when(
                        data: (values) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('활성화됨: ${values['activated'] ?? '알 수 없음'}'),
                            const SizedBox(height: 4),
                            Text('마지막 가져오기 시간: ${values['last_fetch_time'] ?? '알 수 없음'}'),
                            const SizedBox(height: 4),
                            Text('마지막 가져오기 상태: ${values['last_fetch_status'] ?? '알 수 없음'}'),
                            const SizedBox(height: 4),
                            Text('가져오기 시간: ${values['fetch_time'] ?? '알 수 없음'}'),
                            if (values['error'] != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '에러: ${values['error']}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ],
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Text(
                          '에러: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remote Config 상태',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      remoteConfigStatusAsync.when(
                        data: (status) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('마지막 가져오기 시간: ${status.lastFetchTime ?? '없음'}'),
                            const SizedBox(height: 4),
                            Text('마지막 가져오기 상태: ${status.lastFetchStatus}'),
                            const SizedBox(height: 4),
                            Text('Fetch 타임아웃: ${status.settings.fetchTimeout}'),
                            const SizedBox(height: 4),
                            Text('최소 가져오기 간격: ${status.settings.minimumFetchInterval}'),
                          ],
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Text(
                          '에러: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Remote Config 새로고침
                        ref.invalidate(remoteConfigValuesProvider);
                        ref.invalidate(reviewVersionProvider);
                        ref.invalidate(remoteConfigStatusProvider);
                      },
                      child: const Text('Remote Config 새로고침'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 콘솔 로그 확인을 위한 버튼
                        print('=== Remote Config 수동 테스트 ===');
                        final remoteConfig = ref.read(remoteConfigProvider);
                        print('현재 review_version: ${remoteConfig.getString('review_version')}');
                        print('모든 키: ${remoteConfig.getAll().keys.toList()}');
                      },
                      child: const Text('콘솔 로그 확인'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Firebase Console 설정 확인사항',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('1. Firebase Console → Remote Config 접속'),
                      Text('2. review_version 키가 있는지 확인'),
                      Text('3. 값이 "1.0.0"으로 설정되어 있는지 확인'),
                      Text('4. "게시" 버튼을 눌러 변경사항 적용'),
                      Text('5. 앱을 완전히 종료 후 다시 실행'),
                      Text('6. 위의 "새로고침" 버튼 클릭'),
                      SizedBox(height: 8),
                      Text(
                        '주의사항',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('• 네트워크 연결이 필요함'),
                      Text('• 변경사항이 즉시 반영되지 않을 수 있음'),
                      Text('• 개발 중에는 minimumFetchInterval을 0으로 설정'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 