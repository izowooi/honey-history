# batch_status_checker.py
"""
배치 상태 조회 스크립트
Single Responsibility Principle: 배치 상태 조회만 담당
"""

import argparse
from openai_batch_service import OpenAIBatchService
from dotenv import load_dotenv
import os


def check_batch_status(batch_id: str):
    """
    배치 상태 조회 및 결과 다운로드
    
    Args:
        batch_id: 배치 작업 ID
    """
    print("📊 배치 상태 조회기")
    print("=" * 50)
    
    # 환경 변수 로드
    load_dotenv()
    api_key = os.getenv('OPENAI_API_KEY')
    
    if not api_key:
        print("❌ OPENAI_API_KEY가 설정되지 않았습니다.")
        return
    
    # 서비스 초기화
    service = OpenAIBatchService(api_key)
    
    print(f"📋 배치 ID: {batch_id}")
    status = service.check_batch_status(batch_id)
    
    if status.get('status') == 'completed':
        print("🎉 배치 완료!")
        
        # 결과 파일명 생성
        result_filename = f"processed_results_{batch_id}.json"
        
        # 파일이 이미 존재하는지 확인
        if os.path.exists(result_filename):
            print(f"📁 결과 파일이 이미 존재합니다: {result_filename}")
            print("💡 기존 파일을 사용합니다. 새로 다운로드하지 않습니다.")
            
            # 기존 파일에서 결과 읽기
            try:
                with open(result_filename, 'r', encoding='utf-8') as f:
                    import json
                    results = json.load(f)
                
                print(f"✅ 기존 파일에서 {len(results)}개 결과를 불러왔습니다.")
                
                # 결과 미리보기
                print(f"\n📋 결과 미리보기:")
                for i, result in enumerate(results[:2], 1):  # 처음 2개만 표시
                    print(f"\n--- 결과 {i} ---")
                    print(f"Custom ID: {result['custom_id']}")
                    content = result['content']
                    print(f"Simple: {content['simple'][:100]}...")
                    print(f"Detail: {content['detail'][:100]}...")
                    print(f"Year: {content['year']}")
                    print(f"Movies: {content['related_movies']}")
                    
            except Exception as e:
                print(f"❌ 기존 파일 읽기 실패: {e}")
                print("📥 새로 다운로드를 시도합니다...")
                download_and_save_results(service, batch_id, result_filename)
        else:
            print("📥 결과 다운로드 중...")
            download_and_save_results(service, batch_id, result_filename)

    else:
        print(f"\n📋 배치 상태 상세 정보:")
        print("-" * 50)
        print(f"배치 ID: {status.get('id', 'N/A')}")
        print(f"상태: {status.get('status', 'N/A')}")
        print(f"생성 시간: {status.get('created_at', 'N/A')}")
        print(f"완료 시간: {status.get('completed_at', 'N/A')}")
        print(f"실패 시간: {status.get('failed_at', 'N/A')}")
        print(f"출력 파일 ID: {status.get('output_file_id', 'N/A')}")
        print(f"에러 파일 ID: {status.get('error_file_id', 'N/A')}")
        
        # 요청 카운트 정보
        request_counts = status.get('request_counts', {})
        if request_counts:
            print(f"\n📊 요청 처리 현황:")
            print(f"  총 요청 수: {request_counts.get('total', 0)}")
            print(f"  완료된 요청: {request_counts.get('completed', 0)}")
            print(f"  실패한 요청: {request_counts.get('failed', 0)}")
            print(f"  진행률: {request_counts.get('completed', 0)}/{request_counts.get('total', 0)}")
        
        # 메타데이터 정보
        metadata = status.get('metadata', {})
        if metadata:
            print(f"\n🏷️ 메타데이터:")
            for key, value in metadata.items():
                print(f"  {key}: {value}")
        
        print(f"\n⏳ 배치가 아직 완료되지 않았습니다. 나중에 다시 확인해주세요.")


def download_and_save_results(service: OpenAIBatchService, batch_id: str, filename: str):
    """
    결과 다운로드 및 저장
    
    Args:
        service: OpenAIBatchService 인스턴스
        batch_id: 배치 작업 ID
        filename: 저장할 파일명
    """
    results = service.download_results(batch_id)

    if results:
        # 결과 저장 (파일명 지정)
        saved_file = service.save_processed_results(results, filename)
        print(f"✅ 총 {len(results)}개 결과 처리 완료")
        print(f"💾 저장된 파일: {saved_file}")

        # 결과 미리보기
        print(f"\n📋 결과 미리보기:")
        for i, result in enumerate(results[:2], 1):  # 처음 2개만 표시
            print(f"\n--- 결과 {i} ---")
            print(f"Custom ID: {result['custom_id']}")
            content = result['content']
            print(f"Simple: {content['simple'][:100]}...")
            print(f"Detail: {content['detail'][:100]}...")
            print(f"Year: {content['year']}")
            print(f"Movies: {content['related_movies']}")
    else:
        print("❌ 결과 다운로드에 실패했습니다.")


def main():
    """메인 함수"""
    parser = argparse.ArgumentParser(description='배치 상태 조회 및 결과 다운로드')
    parser.add_argument('--batch-id', required=True, help='배치 작업 ID')

    args = parser.parse_args()
    
    check_batch_status(args.batch_id)


if __name__ == "__main__":
    main() 