# Python Projects Collection

이 프로젝트는 ComfyUI 워크플로우 처리와 미디어 파일 변환을 위한 다양한 Python 스크립트들을 포함합니다.

## 🚀 주요 기능

### 1. ComfyUI 워크플로우 처리
- ComfyUI 서버와의 WebSocket 통신
- 이미지 업로드 및 워크플로우 실행
- 추상화된 워크플로우 처리기 패턴

### 2. 미디어 파일 변환
- 이미지 포맷 변환 (JPG/PNG/WebP → WebP)
- 오디오 포맷 변환 (WAV/M4A → MP3)
- 용량 최적화 옵션 제공

## 📁 파일 구조

```
python_proj/
├── README.md                      # 이 파일
├── requirements.txt               # 의존성 패키지
├── 
├── # ComfyUI 관련
├── comfy_ui_client.py            # ComfyUI WebSocket 클라이언트
├── workflow_processor.py         # 워크플로우 처리 추상 클래스
├── main.py                       # ComfyUI 메인 실행 스크립트
├── test_workflow_processor.py    # 워크플로우 처리기 테스트
├── 
├── # 미디어 변환 도구
├── image_to_webp.py              # 이미지 → WebP 변환
├── wav_to_mp3_converter.py       # WAV → MP3 변환
├── m4a_to_mp3_converter.py       # M4A → MP3 변환 (용량 최적화)
├── 
├── # 데이터 파일
├── *.json                        # 워크플로우 설정 파일들
├── image_files/                  # 샘플 이미지 파일들
├── m4a_files/                    # M4A 오디오 파일들
├── wav_files/                    # WAV 오디오 파일들
└── mp3_files/                    # 변환된 MP3 파일들
```

## 🛠️ 설치 및 설정

### 1. 의존성 설치

```bash
pip install -r requirements.txt
```

### 2. FFmpeg 설치 (오디오 변환용)

**macOS:**
```bash
brew install ffmpeg
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install ffmpeg
```

**Windows:**
[FFmpeg 공식 사이트](https://ffmpeg.org/download.html)에서 다운로드

## 📖 사용법

### ComfyUI 워크플로우 처리

#### 1. ComfyUI 클라이언트
```python
from comfy_ui_client import ComfyUIClient

client = ComfyUIClient("127.0.0.1:8188")
client.connect_websocket()
# WebSocket 통신으로 ComfyUI와 연결
```

#### 2. 워크플로우 처리기
```python
from workflow_processor import WorkflowProcessorFactory

processor = WorkflowProcessorFactory.create_processor("test_02.json")
result = processor.process_workflow("input_image.png")
```

#### 3. 메인 스크립트 실행
```bash
python main.py
```

### 미디어 파일 변환

#### 1. 이미지 변환 (JPG/PNG → WebP)
```bash
# 기본 사용법
python image_to_webp.py image_files

# 옵션 지정
python image_to_webp.py my_images -q 90 -w 8
```

**옵션:**
- `folder`: 변환할 이미지 폴더 (기본값: `image_files`)
- `-q, --quality`: WebP 품질 1-100 (기본값: 85)
- `-w, --workers`: 동시 처리 작업자 수 (기본값: 4)

#### 2. WAV → MP3 변환
```bash
python wav_to_mp3_converter.py
```
- 입력: `wav_files` 폴더
- 출력: `mp3_files` 폴더
- 기존 MP3 파일은 건너뜀

#### 3. M4A → MP3 변환 (용량 최적화)
```bash
# 기본 사용법 (모노, 96k, 24kHz)
python m4a_to_mp3_converter.py m4a_files

# 스테레오 유지
python m4a_to_mp3_converter.py m4a_files --stereo

# 최소 용량 설정
python m4a_to_mp3_converter.py m4a_files --very-small

# 세부 옵션
python m4a_to_mp3_converter.py m4a_files -o output_mp3 --vbr 6 --lowpass 8000
```

**옵션:**
- `folder`: 변환할 M4A 폴더 (기본값: `m4a_files`)
- `-o, --output`: 출력 폴더 (기본값: `mp3_files`)
- `-b, --bitrate`: CBR 비트레이트 (기본값: `96k`)
- `--stereo`: 스테레오 유지 (기본값: 모노)
- `--sample-rate`: 샘플레이트 (기본값: `24000`)
- `--vbr`: VBR 품질 0-9 (0=최고음질, 9=최소용량)
- `--lowpass`: 저역통과 필터 컷오프 Hz
- `--very-small`: 최소 용량 프리셋 (모노/16kHz/VBR7/lowpass 8kHz)

## 🔧 개발 정보

### 테스트 실행
```bash
python -m unittest test_workflow_processor.py
```

### 주요 클래스

#### WorkflowProcessor (추상 클래스)
- 워크플로우 파일 로드
- 이미지 업로드
- 결과 다운로드
- 구체적인 처리 로직은 하위 클래스에서 구현

#### ComfyUIClient
- WebSocket 연결 관리
- 메시지 처리
- 프롬프트 실행 상태 모니터링

## 📋 요구사항

### Python 패키지
- `websocket-client==1.8.0` - WebSocket 통신
- `pydub==0.25.1` - 오디오 처리
- `requests==2.32.3` - HTTP 요청
- `pillow==11.2.1` - 이미지 처리
- `tqdm==4.67.1` - 진행률 표시

### 외부 도구
- **FFmpeg** - 오디오 변환 (pydub 백엔드)
- **ComfyUI** - AI 이미지 생성 (워크플로우 처리용)

## 🎯 사용 사례

### 1. 대용량 이미지 일괄 변환
여러 포맷의 이미지를 WebP로 변환하여 웹 최적화:
```bash
python image_to_webp.py photos -q 80 -w 8
```

### 2. 음성 파일 용량 최적화
팟캐스트나 강의 음성을 최소 용량으로 변환:
```bash
python m4a_to_mp3_converter.py lectures --very-small
```

### 3. AI 이미지 생성 자동화
ComfyUI 워크플로우를 통한 배치 이미지 생성:
```bash
python main.py
```

## 📄 라이선스

이 프로젝트는 개인 사용 목적으로 제작되었습니다.

## 🤝 기여

버그 리포트나 개선 제안은 이슈를 통해 제출해 주세요.

---

**참고:** ComfyUI 서버 주소는 `main.py`와 `workflow_processor.py`에서 환경에 맞게 수정해야 합니다.
