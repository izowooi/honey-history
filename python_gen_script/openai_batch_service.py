# openai_batch_service.py
"""
OpenAI Batch API 연동 서비스 (Simple Version)
"""

import json
import re
from typing import Dict, List, Optional
from openai import OpenAI
from dotenv import load_dotenv
import os


class OpenAIBatchService:
    """OpenAI Batch API 서비스 클래스"""

    def __init__(self, api_key: str, model: str = "gpt-4.1-nano-2025-04-14"):
        """
        OpenAI Batch 서비스 초기화

        Args:
            api_key: OpenAI API 키
            model: 사용할 모델명
        """
        self.client = OpenAI(api_key=api_key)
        self.model = model

        # 시스템 프롬프트
        self.system_prompt = (
            """역할:
            - 복잡한 역사를 흥미진진한 이야기로 풀어내는 역사 해설가
            - 어린이부터 성인까지 모든 연령층이 이해할 수 있게 설명하는 교육자
            - 과거와 현재를 연결하여 역사의 의미를 찾아주는 안내자

            목표:
            - 독자가 "와, 이런 일이 있었구나!"라고 감탄하게 만들기
            - 역사적 사실을 정확하면서도 재미있게 전달하기
            - 그 시대의 상황과 감정을 생생하게 느낄 수 있게 하기
            """
        )

    def upload_batch_file(self, file_path: str = "batchinput.jsonl") -> str:
        """
        배치 파일 업로드

        Args:
            file_path: 업로드할 JSONL 파일 경로

        Returns:
            file_id: 업로드된 파일 ID
        """
        try:
            print(f"📤 배치 파일 업로드 중: {file_path}")

            batch_input_file = self.client.files.create(
                file=open(file_path, "rb"),
                purpose="batch"
            )

            print(f"✅ 파일 업로드 완료! File ID: {batch_input_file.id}")
            return batch_input_file.id

        except Exception as e:
            print(f"❌ 파일 업로드 실패: {e}")
            return None

    def create_batch_job(self, file_id: str, description: str = "History content generation") -> str:
        """
        배치 작업 생성

        Args:
            file_id: 업로드된 파일 ID
            description: 배치 작업 설명

        Returns:
            batch_id: 배치 작업 ID
        """
        try:
            print(f"🚀 배치 작업 생성 중...")

            batch = self.client.batches.create(
                input_file_id=file_id,
                endpoint="/v1/chat/completions",
                completion_window="24h",
                metadata={
                    "description": description
                }
            )

            print(f"✅ 배치 작업 생성 완료!")
            print(f"   Batch ID: {batch.id}")
            print(f"   상태: {batch.status}")
            print(f"   설명: {description}")

            return batch.id

        except Exception as e:
            print(f"❌ 배치 작업 생성 실패: {e}")
            return None

    def check_batch_status(self, batch_id: str) -> Dict:
        """
        배치 상태 조회

        Args:
            batch_id: 배치 작업 ID

        Returns:
            배치 상태 정보
        """
        try:
            batch = self.client.batches.retrieve(batch_id)

            status_info = {
                'id': batch.id,
                'status': batch.status,
                'created_at': batch.created_at,
                'completed_at': batch.completed_at,
                'failed_at': batch.failed_at,
                'output_file_id': batch.output_file_id,
                'error_file_id': batch.error_file_id,
                'request_counts': batch.request_counts.__dict__ if batch.request_counts else {},
                'metadata': batch.metadata
            }

            print(f"📊 배치 상태: {batch.status}")
            if batch.request_counts:
                counts = batch.request_counts
                print(f"   진행률: {counts.completed}/{counts.total} 완료")
                if counts.failed > 0:
                    print(f"   실패: {counts.failed}개")

            return status_info

        except Exception as e:
            print(f"❌ 배치 상태 조회 실패: {e}")
            return {}

    def download_results(self, batch_id: str, output_file: str = None) -> List[Dict]:
        """
        배치 결과 다운로드

        Args:
            batch_id: 배치 작업 ID
            output_file: 결과를 저장할 파일명 (선택사항)

        Returns:
            처리된 결과 리스트
        """
        try:
            # 배치 상태 확인
            batch = self.client.batches.retrieve(batch_id)

            if batch.status != "completed":
                print(f"⚠️ 배치가 아직 완료되지 않았습니다. 현재 상태: {batch.status}")
                return []

            if not batch.output_file_id:
                print("❌ 출력 파일이 없습니다.")
                return []

            print(f"📥 결과 다운로드 중...")

            # 결과 파일 다운로드
            result_file_response = self.client.files.content(batch.output_file_id)
            result_content = result_file_response.content.decode('utf-8')

            # 파일로 저장 (옵션)
            if output_file:
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(result_content)
                print(f"💾 원본 결과 저장: {output_file}")

            # 결과 파싱
            results = []
            for line_num, line in enumerate(result_content.strip().split('\n'), 1):
                if line:
                    try:
                        result_data = json.loads(line)

                        # 성공한 요청만 처리
                        if (result_data.get('response') and
                                result_data['response'].get('status_code') == 200):

                            content = result_data['response']['body']['choices'][0]['message']['content']
                            parsed_content = self._parse_response(content)

                            results.append({
                                'custom_id': result_data['custom_id'],
                                'content': parsed_content,
                                'line_number': line_num
                            })
                        else:
                            # 실패한 요청 로깅
                            print(f"❌ 라인 {line_num} 요청 실패: {result_data['custom_id']}")
                            if 'error' in result_data:
                                print(f"   에러: {result_data['error']}")

                    except json.JSONDecodeError as e:
                        print(f"❌ 라인 {line_num} JSON 파싱 실패: {e}")

            print(f"✅ 결과 파싱 완료: {len(results)}개 성공")
            return results

        except Exception as e:
            print(f"❌ 결과 다운로드 실패: {e}")
            return []

    def save_processed_results(self, results: List[Dict], filename: str = None) -> str:
        """
        파싱된 결과를 JSON 파일로 저장

        Args:
            results: 파싱된 결과 리스트
            filename: 저장할 파일명

        Returns:
            저장된 파일명
        """
        if not filename:
            from datetime import datetime
            filename = f"processed_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

        try:
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(results, f, ensure_ascii=False, indent=2)

            print(f"💾 처리된 결과 저장 완료: {filename}")
            return filename

        except Exception as e:
            print(f"❌ 결과 저장 실패: {e}")
            return None

    def process_batch_complete(self, file_path: str = "batchinput.jsonl",
                               description: str = "History content generation") -> str:
        """
        배치 전체 프로세스 실행 (업로드 + 생성)

        Args:
            file_path: JSONL 파일 경로
            description: 배치 설명

        Returns:
            batch_id: 생성된 배치 ID
        """
        print("🎯 배치 전체 프로세스 시작")

        # 1. 파일 업로드
        file_id = self.upload_batch_file(file_path)
        if not file_id:
            return None

        # 2. 배치 작업 생성
        batch_id = self.create_batch_job(file_id, description)
        if not batch_id:
            return None

        print(f"\n🎉 배치 프로세스 완료!")
        print(f"배치 ID: {batch_id}")
        print(f"상태 확인: service.check_batch_status('{batch_id}')")
        print(f"결과 다운로드: service.download_results('{batch_id}')")

        return batch_id

    def _parse_response(self, content: str) -> Dict[str, str]:
        """OpenAI 응답 파싱 (기존 코드와 동일)"""
        try:
            # JSON 응답 파싱 시도
            content = re.sub(r'```json\n?', '', content)
            content = re.sub(r'```\n?', '', content)

            parsed = json.loads(content)

            return {
                'simple': parsed.get('simple', ''),
                'detail': parsed.get('detail', ''),
                'year': parsed.get('year', '')
            }

        except json.JSONDecodeError as e:
            print(f"⚠️ JSON 파싱 실패: {e}")
            return self._extract_from_text(content)

    def _create_user_prompt(self, topic: str, date: str = "") -> str:
        """사용자 프롬프트 생성"""
        date_info = f"<DATE>{date}</DATE>\n" if date else ""

        prompt = f'''{date_info}오늘 {date}에 일어난 역사적 사건 또는 인물에 대해 "{topic}"를 소재로 두 가지 버전의 글을 작성해주세요.

📝 작성 원칙
- 마치 그 현장에 있었던 것처럼 생생하고 구체적으로 서술하세요
- 당시 사람들의 감정과 상황을 상상할 수 있게 묘사하세요  
- 현재 우리 삶과의 연관성이나 교훈도 자연스럽게 포함하세요
- 번호나 글머리표 없이 자연스러운 문단으로만 구성하세요
- 적절한 이모지로 흥미를 더해주세요.

📚 두 가지 버전 요구사항

**간단 버전 (Simple)**
- 대상: 초등학생도 이해할 수 있는 수준
- 길이: 250-350자 (모바일에서 읽기 좋은 길이)
- 특징: 핵심만 간추려 호기심을 자극하는 "오늘의 한 입 역사"
- 시작: 날짜와 함께 흥미로운 첫 문장으로 시작

**상세 버전 (Detail)**
- 대상: 중고등학생 이상 수준
- 길이: 1300-1700자 (충분한 배경 설명 포함)
- 구성: 배경 상황 → 사건 전개 → 결과와 영향 → 현재적 의미
- 특징: 역사적 맥락과 인물의 심리까지 깊이 있게 다루기

🎯 출력 형식
반드시 아래 JSON 형식으로 정확히 출력하세요:

{{
 "simple": "<간단 버전 내용>",
 "detail": "<상세 버전 내용>", 
 "year": "<정확한 연도>",
 "related_movies": "<관련 영화나 드라마를 쉼표로 구분하여 3-5개 (예: 영화제목1, 드라마제목2, 영화제목3)>"
}}

💡 참고사항
- 정확한 역사적 사실에 기반하되, 스토리텔링으로 재미있게 전달하세요
- 논란이 있는 사건의 경우 균형잡힌 시각으로 서술하세요  
- 관련 영화/드라마는 해당 사건이나 인물을 직접적으로 다룬 작품들로 선별하세요
- 관련 작품이 없거나 찾기 어려운 경우 "관련 작품 없음"으로 기재하세요'''

        return prompt

    def _extract_from_text(self, content: str) -> Dict[str, str]:
        """텍스트에서 simple/detail 추출 (기존 코드와 동일)"""
        try:
            simple_pattern = r'"simple":\s*"([^"]*(?:\\.[^"]*)*)"'
            detail_pattern = r'"detail":\s*"([^"]*(?:\\.[^"]*)*)"'
            year_pattern = r'"year":\s*"([^"]*)"'
            movie_pattern = r'"related_movies":\s*"([^"]*(?:\\.[^"]*)*)"'

            simple_match = re.search(simple_pattern, content, re.DOTALL)
            detail_match = re.search(detail_pattern, content, re.DOTALL)
            year_match = re.search(year_pattern, content)
            movie_match = re.search(movie_pattern, content, re.DOTALL)

            simple_text = simple_match.group(1) if simple_match else '추출 실패'
            detail_text = detail_match.group(1) if detail_match else '추출 실패'
            year_text = year_match.group(1) if year_match else '추출 실패'
            movie_text = movie_match.group(1) if movie_match else '관련 작품 없음'

            simple_text = simple_text.replace('\\"', '"').replace('\\n', '\n')
            detail_text = detail_text.replace('\\"', '"').replace('\\n', '\n')
            year_text = year_text.replace('\\"', '"').replace('\\n', '\n')
            movie_text = movie_text.replace('\\"', '"').replace('\\n', '\n')

            return {
                'simple': simple_text,
                'detail': detail_text,
                'year': year_text,
                'related_movies': movie_text,
            }

        except Exception as e:
            print(f"❌ 텍스트 추출 실패: {e}")
            return {
                'simple': '내용 추출 실패',
                'detail': '내용 추출 실패',
                'year': '연도 추출 실패',
                'related_movies': '관련 작품 없음'
            }

def test_create_batch_input_file():
    """배치 서비스 테스트"""
    print("🚀 OpenAI Batch 서비스 테스트")

    load_dotenv()
    api_key = os.getenv('OPENAI_API_KEY')

    # 서비스 초기화
    service = OpenAIBatchService(api_key)

    # 배치 입력 파일 생성
    print("\n📝 배치 입력 파일 생성 중...")
    create_batch_input_file(service)


def test_batch_status():
    """배치 상태 확인 테스트"""
    load_dotenv()
    api_key = os.getenv('OPENAI_API_KEY')

    # 서비스 초기화
    service = OpenAIBatchService(api_key)

    # 여기에 실제 배치 ID를 입력하세요
    batch_id = "batch_685437e7c1988190bebb1a90ba6f06b8"

    print(f"📊 배치 {batch_id} 상태 확인 중...")
    status = service.check_batch_status(batch_id)

    if status.get('status') == 'completed':
        print("🎉 배치 완료! 결과 다운로드 중...")
        results = service.download_results(batch_id)

        if results:
            # 결과 저장
            saved_file = service.save_processed_results(results)
            print(f"✅ 총 {len(results)}개 결과 처리 완료")
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

def test_batch_service():
    """배치 서비스 테스트"""
    print("🚀 OpenAI Batch 서비스 테스트")

    load_dotenv()
    api_key = os.getenv('OPENAI_API_KEY')

    gpt_4_1_nano = "gpt-4.1-nano-2025-04-14" # ( )
    o4_mini = "o4-mini-2025-04-16"  # 비용 효율적 추론 모델 (input 1.1, output 4.4)
    model_4_1 = "gpt-4.1-mini-2025-04-14"# 균형 모델 (input 2, output 8)
    o3 = "o3-2025-04-16"  # 가장 강력한 추론 모델 (추론 input 2, output 8)
    # 서비스 초기화
    service = OpenAIBatchService(api_key, model=o4_mini)

    # 방법 1: 전체 프로세스 한 번에
    print("\n=== 전체 프로세스 실행 ===")
    batch_id = service.process_batch_complete("batchinput.jsonl")

    if batch_id:
        print(f"\n배치 ID가 생성되었습니다: {batch_id}")
        print("이제 주기적으로 상태를 확인하세요:")
        print(f"service.check_batch_status('{batch_id}')")

    # 3. 상태 확인 (나중에 실행)
    if batch_id:
        service.check_batch_status(batch_id)


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


def check_existing_batch():
    """기존 배치 상태 확인 예제"""
    load_dotenv()
    api_key = os.getenv('OPENAI_API_KEY')
    service = OpenAIBatchService(api_key)

    # 여기에 실제 배치 ID를 입력하세요
    batch_id = "batch_YOUR_BATCH_ID_HERE"

    print(f"📊 배치 {batch_id} 상태 확인 중...")
    status = service.check_batch_status(batch_id)

    if status.get('status') == 'completed':
        print("🎉 배치 완료! 결과 다운로드 중...")
        results = service.download_results(batch_id)

        if results:
            # 결과 저장
            saved_file = service.save_processed_results(results)
            print(f"✅ 총 {len(results)}개 결과 처리 완료")


if __name__ == "__main__":
    test_create_batch_input_file()
    # test_batch_service()
    # test_batch_status()