# Python 3.11 슬림 이미지 사용
FROM python:3.11-slim

# 작업 디렉토리 설정
WORKDIR /app

# 파이썬 런타임 환경
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# requirements.txt 먼저 복사 (캐싱 최적화)
COPY requirements.txt .

# 빌드 의존성 설치 → 패키지 설치 → 의존성 제거를 단일 레이어로 처리
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get purge -y --auto-remove gcc \
    && rm -rf /var/lib/apt/lists/*

# 애플리케이션 코드 복사
COPY . .

# 비루트 사용자로 실행 (보안)
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Cloud Run은 PORT 환경변수를 자동 설정
EXPOSE 8080

# 애플리케이션 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]