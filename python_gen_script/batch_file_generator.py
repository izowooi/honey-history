# batch_file_generator.py
"""
배치 입력 파일 생성 스크립트
Single Responsibility Principle: 배치 입력 파일 생성만 담당
"""

import json
import os
from openai_batch_service import OpenAIBatchService
from dotenv import load_dotenv


def create_batch_input_file(service: OpenAIBatchService, file_path: str = "batchinput.jsonl"):
    """
    배치 입력 파일 생성
    
    Args:
        service: OpenAIBatchService 인스턴스
        file_path: 생성할 파일 경로
    """
    # 테스트 데이터 (제목과 날짜)
    test_data = [
        {"title": "엘리자베스 2세 여왕 대관식", "date": "06-02"},
        {"title": "1차 아편전쟁 촉발", "date": "06-03"}
    ]
    
    # 기존 파일이 있는지 확인
    existing_lines = []
    if os.path.exists(file_path):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                existing_lines = f.readlines()
            print(f"📂 기존 파일 발견: {len(existing_lines)}개 요청")
        except Exception as e:
            print(f"⚠️ 기존 파일 읽기 실패: {e}")
    
    # 새로운 요청들 생성
    new_requests = []
    start_id = len(existing_lines) + 1
    
    for i, data in enumerate(test_data, start_id):
        title = data["title"]
        date = data["date"]
        
        # custom_id 생성 (request-0901 형태)
        custom_id = f"request-{date.replace('-', '')}"
        
        # 시스템 프롬프트
        system_content = service.system_prompt
        
        # 사용자 프롬프트 생성
        user_content = service._create_user_prompt(title, date)
        
        # JSONL 형식으로 요청 생성
        request = {
            "custom_id": custom_id,
            "method": "POST",
            "url": "/v1/chat/completions",
            "body": {
                "model": service.model,
                "messages": [
                    {"role": "system", "content": system_content},
                    {"role": "user", "content": user_content}
                ],
                "max_tokens": 2000
            }
        }
        
        new_requests.append(request)
        print(f"📝 요청 생성: {custom_id} - {title}")
    
    # 파일에 쓰기 (기존 내용 + 새로운 내용)
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            # 기존 내용 쓰기
            for line in existing_lines:
                f.write(line)
            
            # 새로운 내용 쓰기
            for request in new_requests:
                f.write(json.dumps(request, ensure_ascii=False) + '\n')
        
        total_requests = len(existing_lines) + len(new_requests)
        print(f"✅ 배치 입력 파일 생성 완료: {file_path}")
        print(f"   - 기존 요청: {len(existing_lines)}개")
        print(f"   - 새 요청: {len(new_requests)}개")
        print(f"   - 총 요청: {total_requests}개")
        
    except Exception as e:
        print(f"❌ 파일 생성 실패: {e}")


def main():
    """메인 함수"""
    print("📝 배치 입력 파일 생성기")
    print("=" * 50)
    
    # 환경 변수 로드
    load_dotenv()
    api_key = os.getenv('OPENAI_API_KEY')
    
    if not api_key:
        print("❌ OPENAI_API_KEY가 설정되지 않았습니다.")
        return
    
    # 서비스 초기화
    service = OpenAIBatchService(api_key)
    
    # 배치 입력 파일 생성
    create_batch_input_file(service)


if __name__ == "__main__":
    main() 