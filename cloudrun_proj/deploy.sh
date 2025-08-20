#!/bin/bash

# 설정 변수
PROJECT_ID="honey-history"  # GCP 프로젝트 ID로 변경하세요
SERVICE_NAME="honey-history-api"
REGION="asia-northeast3"  # 서울 리전

echo "🚀 Google Cloud Run 배포 시작..."

# 1. 프로젝트 설정
echo "📋 프로젝트 설정: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# 2. Artifact Registry 저장소 생성 (처음 한 번만)
echo "📦 Artifact Registry 확인/생성..."
gcloud artifacts repositories create cloud-run-source-deploy \
    --repository-format=docker \
    --location=$REGION \
    --quiet || echo "저장소가 이미 존재합니다."

# 3. Cloud Run 서비스 배포
echo "🏗️ Cloud Run 서비스 배포 중..."
gcloud run deploy $SERVICE_NAME \
    --source . \
    --region=$REGION \
    --platform=managed \
    --allow-unauthenticated \
    --memory=512Mi \
    --cpu=1 \
    --timeout=60 \
    --concurrency=1000 \
    --max-instances=10 \
    --min-instances=0

# 4. 서비스 URL 가져오기
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')

echo "✅ 배포 완료!"
echo "🌐 서비스 URL: $SERVICE_URL"
echo "📖 API 문서: $SERVICE_URL/docs"
echo "🏓 헬스체크: $SERVICE_URL/ping"