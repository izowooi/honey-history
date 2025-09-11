# CLAUDE_ko.md

이 파일은 Claude Code (claude.ai/code)가 이 저장소에서 작업할 때 참조할 가이드를 제공합니다.

## 프로젝트 개요

일별 역사적 사건을 제공하는 "꿀 역사" Flutter 애플리케이션입니다. 현재 날짜에 따라 다른 역사적 사건을 표시하며, 오디오 재생, 유튜브 동영상 통합, Firebase 푸시 알림 기능을 포함합니다.

## 핵심 아키텍처 구성요소

### 데이터베이스 레이어 (Drift/SQLite)
- **데이터베이스**: `lib/db/app_database.dart` - SQLite 백엔드와 함께 Drift ORM 사용
- **테이블 스키마**: `HistoryEvents` 테이블, 필드: id (MM-dd 형식), title, year, simple, detail, youtube_url
- **초기화**: 첫 실행 시 `assets/data/history_events.sqlite`에서 사전 구축된 SQLite 데이터베이스 복사
- **데이터 제공자**: `lib/providers/historical_event_provider.dart`가 날짜 기반 이벤트 쿼리 관리

### 상태 관리 (Riverpod)
- **프로바이더 패턴**: 상태 관리를 위해 flutter_riverpod 사용
- **주요 프로바이더들**:
  - `selectedDateProvider`: 현재 날짜 선택
  - `driftDbProvider`: 데이터베이스 싱글톤 인스턴스
  - `historicalEventProvider`: 날짜별 이벤트 가져오기
  - `audioProvider`: 오디오 재생 상태 관리
  - `settingsProvider`: 앱 구성 설정

### 오디오 시스템
- **스트리밍 아키텍처**: 원격 URL에서 오디오 파일 스트리밍 (패턴: `https://honeyhistory.zowoo.uk/audio/{MMDD}.mp3`)
- **캐싱**: 첫 다운로드 후 임시 디렉터리에 파일 캐시
- **프로바이더**: `lib/providers/audio_provider.dart`가 재생 및 캐싱 처리
- **일괄 다운로드**: WiFi 기반 배치 다운로드를 위한 `lib/providers/bulk_audio_download_provider.dart`

### Firebase 통합
- **푸시 알림**: Firebase Messaging을 통한 토픽 기반 알림
- **원격 구성**: 기능 플래그 및 구성 관리
- **서비스**: `lib/services/push_notification_service.dart`

## 일반적인 개발 명령어

### 의존성 및 설정
```bash
# 의존성 설치
flutter pub get

# 코드 생성 (Drift 데이터베이스 변경 시)
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run

# 특정 기기에서 실행
flutter run -d <device_id>
```

### 빌드 명령어
```bash
# Android 릴리스 빌드 (Play Store용 AAB)
flutter build appbundle --release

# iOS 릴리스 빌드
flutter build ios --release

# 빌드 파일 정리
flutter clean
```

### iOS 전용 명령어
```bash
# CocoaPods 정리 및 재설치 (iOS 빌드 문제 시)
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
flutter clean
flutter pub get
```

### 앱 아이콘 생성
```bash
# 앱 아이콘 생성 (pubspec.yaml에 구성됨)
dart run flutter_launcher_icons
```

### 린팅 및 분석
```bash
# 정적 분석 실행
flutter analyze

# 테스트 실행
flutter test
```

## 개발 가이드라인

### 데이터베이스 스키마 변경
1. `lib/db/app_database.dart`에서 테이블 정의 수정
2. 코드 생성 실행: `dart run build_runner build --delete-conflicting-outputs`
3. 필요시 스키마 버전 및 마이그레이션 전략 업데이트
4. 새로운 데이터베이스 설치로 테스트

### 오디오 파일 관리
- 원격 서버에서 요청 시 오디오 파일 가져오기
- 형식: `https://honeyhistory.zowoo.uk/audio/{MMDD}.mp3` (MMDD는 월-일 앞자리 0 포함, 예: 8월 15일은 0815)
- 임시 디렉터리의 로컬 캐싱으로 재다운로드 방지
- WiFi 연결 시 일괄 다운로드 기능 제공

### 날짜 기반 콘텐츠
- MM-dd 형식으로 이벤트 식별 (예: 7월 15일은 "07-15")
- 이미지 위치: `assets/illustration/{MMDD}.webp`
- intl 패키지의 `DateFormat('MM-dd')`로 날짜 형식 처리

### Firebase 구성
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`의 구성
- 푸시 알림 토픽: 일일 알림을 위해 "history" 토픽 구독

### 에셋 관리
- `assets/data/history_events.sqlite`에서 역사적 사건 데이터 시드
- `assets/illustration/`에 {MMDD}.webp 명명 방식의 삽화
- `lib/historical_events.json`의 JSON 폴백 데이터

## 프로젝트 구조 참고사항

### 주요 디렉터리
- `lib/db/`: 데이터베이스 레이어 및 모델
- `lib/providers/`: Riverpod 상태 관리
- `lib/widgets/`: 재사용 가능한 UI 구성요소
- `lib/services/`: 플랫폼 서비스 (알림 등)
- `assets/data/`: 정적 데이터 파일 및 사전 구축 데이터베이스
- `assets/illustration/`: 역사적 사건 삽화

### 중요한 파일들
- `lib/main.dart`: 데이터베이스 초기화가 포함된 앱 진입점
- `lib/widget/daily_calendar_widget.dart`: 메인 UI 화면
- `pubspec.yaml`: Drift, Firebase, 오디오 패키지 포함 의존성
- `analysis_options.yaml`: 린트 규칙 (flutter_lints 표준 사용)

### 데이터 흐름
1. 앱 실행 → 첫 실행인 경우 사전 구축된 SQLite DB 복사
2. 사용자 날짜 선택/조회 → MM-dd ID로 HistoryEvents 테이블 쿼리
3. UI가 이벤트 데이터 표시, 삽화 로드, 오디오 재생 활성화
4. 로컬 캐싱과 함께 원격 URL에서 오디오 스트리밍
5. youtube_player_flutter 위젯을 통해 유튜브 동영상 표시

## 빌드 구성

### 버전 관리
- 현재 버전: 1.0.1+20 (의미적 버전관리 + 빌드 번호)
- iOS 배포 대상: iOS 12.0+
- Android minSdkVersion: 21 (Android 5.0+)

### 플랫폼별 참고사항
- iOS: 앱 아이콘 자동 생성, 적절한 프로비저닝 프로필 필요
- Android: 적응형 아이콘 사용, 릴리스 서명을 위한 키스토어 필요
- 푸시 알림은 플랫폼별 설정 및 권한 필요

## 개발 팁

### Drift DB 시드 과정
- 앱은 기본적으로 `assets/data/history_events.sqlite`에서 사전 구축된 데이터베이스를 복사
- 첫 실행 시에만 복사되며, 이후에는 로컬 데이터베이스 사용
- 데이터 갱신 시 에셋 파일 교체 후 앱 재설치 또는 DB 초기화 필요

### 오디오 재생 정책
- 앱에 오디오 파일을 내장하지 않음
- 재생 버튼 클릭 시 날짜 기반 URL에서 스트리밍 + 캐싱 후 재생
- 파일이 없거나 네트워크 오류 시 스낵바로 안내

### 날짜 형식 주의사항
- 이벤트 ID는 MM-dd 형식 (예: "07-01")
- 삽화 파일명은 MMDD 형식 (예: "0701.webp")
- 오디오 URL은 MMDD 형식 (예: "0701.mp3")