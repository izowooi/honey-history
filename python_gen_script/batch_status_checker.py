# batch_status_checker.py
"""
배치 상태 조회 스크립트
Single Responsibility Principle: 배치 상태 조회만 담당
"""

import argparse
from openai_batch_service import OpenAIBatchService
from dotenv import load_dotenv
import os


def check_batch_status(batch_id: str, download_results: bool = False):
    """
    배치 상태 조회 및 결과 다운로드
    
    Args:
        batch_id: 배치 작업 ID
        download_results: 완료 시 결과 다운로드 여부
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
        
        if download_results:
            print("📥 결과 다운로드 중...")
            results = service.download_results(batch_id)
            
            if results:
                # 결과 저장
                saved_file = service.save_processed_results(results)
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
        else:
            print("💡 결과를 다운로드하려면 --download 옵션을 추가하세요.")
            
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


def main():
    """메인 함수"""
    parser = argparse.ArgumentParser(description='배치 상태 조회 및 결과 다운로드')
    parser.add_argument('--batch-id', required=True, help='배치 작업 ID')
    parser.add_argument('--download', action='store_true', help='완료 시 결과 다운로드')
    
    args = parser.parse_args()
    
    check_batch_status(args.batch_id, args.download)


if __name__ == "__main__":
    main() 