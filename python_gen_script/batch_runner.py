# batch_runner.py
"""
배치 서비스 실행 스크립트
Single Responsibility Principle: 배치 작업 실행만 담당
"""

from openai_batch_service import OpenAIBatchService
from dotenv import load_dotenv
import os


def run_batch_job(file_path: str = "batchinput.jsonl", description: str = "History content generation"):
    """
    배치 작업 실행
    
    Args:
        file_path: JSONL 파일 경로
        description: 배치 작업 설명
    
    Returns:
        batch_id: 생성된 배치 ID
    """
    print("🚀 배치 작업 실행기")
    print("=" * 50)
    
    # 환경 변수 로드
    load_dotenv()
    api_key = os.getenv('OPENAI_API_KEY')
    
    if not api_key:
        print("❌ OPENAI_API_KEY가 설정되지 않았습니다.")
        return None
    
    # 모델 선택
    gpt_4_1_nano = "gpt-4.1-nano-2025-04-14"  # 가장 빠른 모델
    o4_mini = "o4-mini-2025-04-16"  # 비용 효율적 추론 모델 (input 1.1, output 4.4)
    model_4_1_mini = "gpt-4.1-mini-2025-04-14"  # 비용 효율적 균형 모델 (input 0.4, output 1.6)
    model_4_1 = "gpt-4.1-2025-04-14"  # 플래그십 균형 모델 (input 2, output 8)
    o3 = "o3-2025-04-16"  # 가장 강력한 추론 모델 (input 2, output 8)
    
    # 서비스 초기화 (기본값: gpt-4.1-mini)
    service = OpenAIBatchService(api_key, model=model_4_1_mini)
    
    # 파일 존재 확인
    if not os.path.exists(file_path):
        print(f"❌ 배치 입력 파일이 없습니다: {file_path}")
        print("먼저 batch_file_generator.py를 실행하여 파일을 생성하세요.")
        return None
    
    # 배치 작업 실행
    print(f"📁 배치 파일: {file_path}")
    print(f"🤖 사용 모델: {service.model}")
    print(f"📝 작업 설명: {description}")
    
    batch_id = service.process_batch_complete(file_path, description)
    
    if batch_id:
        print(f"\n✅ 배치 작업이 성공적으로 시작되었습니다!")
        print(f"📋 배치 ID: {batch_id}")
        print(f"\n📊 상태 확인 방법:")
        print(f"python batch_status_checker.py --batch-id {batch_id}")
        print(f"\n⏰ 배치 완료까지 시간이 걸릴 수 있습니다.")
        print(f"24시간 이내에 결과를 다운로드해야 합니다.")
        return batch_id
    else:
        print("❌ 배치 작업 시작에 실패했습니다.")
        return None


def main():
    """메인 함수"""
    # 기본 설정으로 배치 작업 실행
    batch_id = run_batch_job()
    
    if batch_id:
        print(f"\n🎯 다음 단계:")
        print(f"- 배치 상태 확인 및 다운로드 : python batch_status_checker.py --batch-id {batch_id}")


if __name__ == "__main__":
    main() 