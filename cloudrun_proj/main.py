from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict
import random
from datetime import datetime
import os

app = FastAPI(
    title="Image Gallery API",
    description="Cloud Run에서 실행되는 이미지 갤러리 API",
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

# R2 이미지 URL (고정)
R2_IMAGE_URL = "https://pub-faf21c880e254e7483b84cb14bb8854e.r2.dev/Firefly_ff-00198%20Steady%20portrait%20of%20a%20be%20168550%20uqj.jpg"

@app.get("/ping")
async def ping():
    """헬스체크 및 연결 테스트용 엔드포인트"""
    return {
        "status": "healthy",
        "message": "pong",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "cloud-run-fastapi",
        "region": os.environ.get("REGION", "unknown"),
        "revision": os.environ.get("K_REVISION", "unknown")
    }

@app.get("/random-images")
async def get_random_images(
    count: int = Query(10, ge=1, le=50, description="반환할 이미지 개수")
) -> Dict:
    """랜덤하게 이미지 URL 10개를 반환하는 엔드포인트"""
    
    images = []
    
    for i in range(count):
        # 각 이미지에 랜덤 ID 부여 (실제로는 같은 이미지지만 메타데이터는 다름)
        img_id = random.randint(10000, 99999)
        
        images.append({
            "id": f"img_{img_id}",
            "url": R2_IMAGE_URL,
            "title": f"Random Image {img_id}",
            "description": f"This is a randomly selected image with ID {img_id}",
            "metadata": {
                "width": 300,
                "height": 300,
                "format": "jpg",
                "size_kb": random.randint(50, 150)
            },
            "tags": random.sample(["portrait", "artistic", "firefly", "steady", "beautiful"], k=3)
        })
    
    return {
        "count": count,
        "images": images,
        "timestamp": datetime.utcnow().isoformat(),
        "source": "cloudflare-r2"
    }

@app.get("/")
async def root():
    """API 정보를 반환하는 루트 엔드포인트"""
    return {
        "message": "Image Gallery API on Google Cloud Run",
        "version": "1.0.0",
        "endpoints": {
            "ping": "/ping - 헬스체크",
            "random_images": "/random-images?count=10 - 랜덤 이미지 반환",
            "docs": "/docs - API 문서 (Swagger UI)",
            "redoc": "/redoc - API 문서 (ReDoc)"
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
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)