# batch_file_generator.py
"""
배치 입력 파일 생성 스크립트
Single Responsibility Principle: 배치 입력 파일 생성만 담당
"""

import json
import os
import argparse
from openai_batch_service import OpenAIBatchService
from dotenv import load_dotenv


def create_batch_input_file(service: OpenAIBatchService, test_data: dict, file_path: str = "batchinput.jsonl"):
    """
    배치 입력 파일 생성
    
    Args:
        service: OpenAIBatchService 인스턴스
        test_data: 처리할 데이터 딕셔너리 (키: 날짜, 값: 이벤트 정보)
        file_path: 생성할 파일 경로
    """
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
    
    # 객체의 키값들을 순회
    for date_key, event_data in test_data.items():
        title = event_data["title"]
        date = event_data["id"]
        
        # custom_id 생성 (06-02 형태)
        custom_id = f"{date}"
        
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


def generate_batch_file(model: str = "gpt-4.1-2025-04-14", data_file: str = "historical_events (3).json"):
    """
    배치 파일 생성 메인 함수
    
    Args:
        model: 사용할 모델명
        data_file: 읽어올 데이터 파일 경로
    """
    print("📝 배치 입력 파일 생성기")
    print("=" * 50)
    
    # 환경 변수 로드
    load_dotenv()
    api_key = os.getenv('OPENAI_API_KEY')
    
    if not api_key:
        print("❌ OPENAI_API_KEY가 설정되지 않았습니다.")
        return
    
    # 데이터 파일 로드
    try:
        with open(data_file, 'r', encoding='utf-8') as f:
            test_data = json.load(f)
        print(f"📂 데이터 파일 로드 완료: {data_file} ({len(test_data)}개 항목)")
    except FileNotFoundError:
        print(f"❌ 데이터 파일을 찾을 수 없습니다: {data_file}")
        return
    except json.JSONDecodeError as e:
        print(f"❌ JSON 파일 형식 오류: {e}")
        return
    except Exception as e:
        print(f"❌ 데이터 파일 로드 실패: {e}")
        return
    
    # 서비스 초기화 (모델명 전달)
    service = OpenAIBatchService(api_key, model=model)
    
    print(f"🤖 사용 모델: {model}")
    
    # 배치 입력 파일 생성
    create_batch_input_file(service, test_data)


def main():
    """메인 함수"""
    parser = argparse.ArgumentParser(description='배치 입력 파일 생성')
    parser.add_argument('--model', 
                       default="gpt-4.1-2025-04-14",
                       help='사용할 모델명 (기본값: gpt-4.1-2025-04-14)')
    parser.add_argument('--data-file',
                       default="historical_events.json",
                       help='읽어올 데이터 파일 경로 (기본값: historical_events.json)')
    
    args = parser.parse_args()
    
    generate_batch_file(args.model, args.data_file)


if __name__ == "__main__":
    main() 