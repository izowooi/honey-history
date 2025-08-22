from fastapi import FastAPI, Query, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict, Optional
import random
from datetime import datetime, timedelta
import os
from supabase import create_client, Client
import logging
import firebase_admin
from firebase_admin import credentials, messaging

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Honey History API",
    description="Cloud Run에서 실행되는 오늘의 역사 API with Supabase",
    version="1.0.0"
)

# CORS 설정 (모든 오리진 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Supabase 클라이언트 초기화
supabase_client: Optional[Client] = None


def _parse_topic_utc_offset_hours(topic_name: Optional[str]) -> Optional[int]:
    """토픽명에서 UTC 오프셋(시간)을 추출. 예: "history_9_kr" -> 9

    우선순위:
    1) 정규식으로 중간의 정수 시간차 추출 (예: _9_ / _-5_ 등)
    2) 지역 코드가 'kr'인 경우 9
    추출 실패 시 None 반환
    """
    if not topic_name:
        return None

    try:
        import re

        # 패턴 예시: "history_9_kr", "foo_-3_bar" 등에서 숫자 캡처
        match = re.search(r"_(?P<hours>-?\d+)_", topic_name)
        if match:
            return int(match.group("hours"))

        # 지역 코드 기반 기본값 (향후 확장 가능)
        if topic_name.endswith("_kr") or "_kr" in topic_name:
            return 9
    except Exception:
        pass

    return None


def get_supabase_client() -> Optional[Client]:
    """Supabase 클라이언트를 가져오거나 생성"""
    global supabase_client

    if supabase_client is None:
        # 환경변수에서 가져오기 (Cloud Run은 환경변수 사용)
        SUPABASE_URL = os.environ.get("SUPABASE_URL")
        SUPABASE_KEY = os.environ.get("SUPABASE_ANON_KEY")

        if not SUPABASE_URL or not SUPABASE_KEY:
            logger.warning("Supabase 환경변수가 설정되지 않았습니다. DB 기능이 비활성화됩니다.")
            return None

        try:
            supabase_client = create_client(SUPABASE_URL, SUPABASE_KEY)
            logger.info("Supabase 클라이언트 초기화 성공")
        except Exception as e:
            logger.error(f"Supabase 클라이언트 초기화 실패: {str(e)}")
            return None

    return supabase_client


# 오늘 날짜의 이벤트를 Supabase에서 조회
def get_today_event_from_supabase(client: Client, topic_name: Optional[str] = None) -> Optional[Dict[str, str]]:
    try:
        # 토픽에서 시간대 오프셋(시간) 추출. 실패 시 KR(+9) 기본값 사용
        offset_hours = _parse_topic_utc_offset_hours(topic_name)
        if offset_hours is None:
            offset_hours = 9

        today_dt = datetime.utcnow() + timedelta(hours=offset_hours)
        today_str = today_dt.strftime('%m%d')
        resp = (
            client
            .table('daily_events')
            .select('title, body')
            .eq('date_key', today_str)
            .limit(1)
            .execute()
        )

        if resp.data:
            event = resp.data[0]
            title = event.get('title')
            body = event.get('body')
            if title and body:
                logger.info(f"Supabase 오늘 이벤트 사용(date_key={today_str}, offset={offset_hours}h, topic={topic_name})")
                return {"title": title, "body": body}
        logger.warning(f"오늘(date_key={today_str}) 이벤트가 없거나 필드 누락. payload/기본값 사용 (offset={offset_hours}h, topic={topic_name})")
        return None
    except Exception as e:
        logger.error(f"Supabase 오늘 이벤트 조회 실패: {str(e)}")
        return None

# Firebase Admin 초기화
def initialize_firebase_app() -> bool:
    """Firebase Admin SDK 초기화. 이미 초기화되어 있으면 True 반환"""
    try:
        # 이미 초기화된 경우
        if firebase_admin._apps:
            return True

        # 우선순위: 명시적 경로(FIREBASE_CREDENTIALS_PATH) → 기본 애플리케이션 자격증명(GOOGLE_APPLICATION_CREDENTIALS 또는 런타임 SA)
        credentials_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
        if credentials_path:
            cred = credentials.Certificate(credentials_path)
            firebase_admin.initialize_app(cred)
        else:
            # Cloud Run에서는 기본 서비스 계정으로 ADC 사용 가능
            firebase_admin.initialize_app()

        logger.info("Firebase Admin 초기화 성공")
        return True
    except Exception as e:
        logger.error(f"Firebase Admin 초기화 실패: {str(e)}")
        return False



@app.on_event("startup")
async def startup_event():
    """앱 시작시 Supabase 연결 테스트"""
    client = get_supabase_client()
    if client:
        try:
            # 연결 테스트
            response = client.table('daily_events').select("id").limit(1).execute()
            logger.info("Supabase 연결 테스트 성공")
        except Exception as e:
            logger.error(f"Supabase 연결 테스트 실패: {str(e)}")

    # Firebase 초기화 시도
    initialize_firebase_app()


@app.get("/ping")
async def ping():
    """헬스체크 및 연결 테스트용 엔드포인트"""
    supabase_status = "connected" if get_supabase_client() else "disconnected"

    return {
        "status": "healthy",
        "message": "pong",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "cloud-run-fastapi",
        "region": os.environ.get("REGION", "unknown"),
        "revision": os.environ.get("K_REVISION", "unknown"),
        "supabase_status": supabase_status
    }


@app.post("/pong")
async def handle_pubsub_and_notify_fcm(request: Request):
    """Pub/Sub 메시지를 수신하면 FCM 토픽("history_9_kr")으로 알림을 전송"""
    try:
        # Firebase Admin 준비
        if not firebase_admin._apps:
            initialized = initialize_firebase_app()
            if not initialized:
                raise HTTPException(status_code=500, detail="Firebase not initialized")

        # 요청 페이로드(있다면) 로깅용으로만 사용
        try:
            payload = await request.json()
            logger.info(f"/pong 수신 페이로드: {payload}")
        except Exception:
            payload = {}


        # Supabase에서 오늘의 이벤트 조회 시도 (성공 시 payload 대신 사용)
        topic_name = "history_9_kr"
        supabase = get_supabase_client()
        event_texts = get_today_event_from_supabase(supabase, topic_name) if supabase else None

        # 우선순위: Supabase 결과 > 요청 바디 값 > 기본값
        notif_title = event_texts.get("title") if event_texts else "오늘의 역사"
        notif_body = event_texts.get("body") if event_texts else "오늘은 무슨 일이 있었을까요?"

        # 이미지 URL은 요청값 우선, 없으면 기본값 사용
        image_url = (payload.get("image_url") if isinstance(payload, dict) else None) or None

        message = messaging.Message(
            notification=messaging.Notification(
                title=notif_title,
                body=notif_body,
                image=image_url,
            ),
            data={
                "event": "pubsub_received",
                "timestamp": datetime.utcnow().isoformat(),
            },
            android=messaging.AndroidConfig(
                notification=messaging.AndroidNotification(
                    image=image_url,
                )
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        mutable_content=True,
                    )
                ),
                fcm_options=messaging.APNSFCMOptions(
                    image=image_url,
                )
            ),
            webpush=messaging.WebpushConfig(
                notification=messaging.WebpushNotification(
                    image=image_url,
                )
            ),
            topic=topic_name,
        )
        message_id = messaging.send(message)
        logger.info(f"FCM 전송 성공. message_id={message_id}")
        return {"status": "success", "message_id": message_id}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"FCM 전송 실패: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to send FCM")


@app.get("/")
async def root():
    """API 정보를 반환하는 루트 엔드포인트"""
    supabase_enabled = get_supabase_client() is not None

    return {
        "message": "오늘의 역사 API on Google Cloud Run",
        "version": "1.0.0",
        "endpoints": {
            "ping": "/ping - 헬스체크",
            "docs": "/docs - API 문서 (Swagger UI)",
            "redoc": "/redoc - API 문서 (ReDoc)"
        },
        "features": {
            "database": "Supabase" if supabase_enabled else "Disabled",
            "fallback": "Available"
        },
        "deployment": {
            "platform": "Google Cloud Run",
            "region": os.environ.get("REGION", "unknown"),
            "service": os.environ.get("K_SERVICE", "unknown")
        }
    }


# Cloud Run은 PORT 환경변수를 자동으로 설정함
if __name__ == "__main__":
    import uvicorn

    # 로컬 개발시 .env 파일 로드 (선택사항)
    try:
        from dotenv import load_dotenv

        load_dotenv()
        logger.info("로컬 환경: .env 파일 로드됨")
    except ImportError:
        logger.info("프로덕션 환경: 환경변수 사용")

    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)