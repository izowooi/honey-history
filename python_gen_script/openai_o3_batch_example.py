# openai_o3_batch_example.py
"""
OpenAI o3 모델을 사용한 배치 요청 예시
- o3 모델은 고급 추론 능력을 가진 모델
- 배치 API를 통해 50% 할인된 가격으로 사용 가능
- 복잡한 수학, 코딩, 과학 문제에 특히 강함
"""

import json
import time
from datetime import datetime
from typing import List, Dict
from openai import OpenAI
from dotenv import load_dotenv
import os


class OpenAIO3BatchService:
    """OpenAI o3 모델 배치 서비스"""

    def __init__(self, api_key: str):
        """
        서비스 초기화

        Args:
            api_key: OpenAI API 키
        """
        self.client = OpenAI(api_key=api_key)
        # o3 모델 사용 (고급 추론 모델)
        self.model = "o3-mini"

    def create_o3_batch_requests(self, tasks: List[Dict[str, str]]) -> str:
        """
        o3 모델용 배치 요청 생성

        Args:
            tasks: 처리할 작업 리스트
                  [{"id": "task1", "prompt": "문제 설명", "type": "math/coding/reasoning"}]

        Returns:
            생성된 JSONL 파일명
        """
        batch_requests = []

        for i, task in enumerate(tasks):
            # o3 모델에 최적화된 프롬프트 구성
            messages = [
                {
                    "role": "developer",
                    "content": self._get_system_prompt(task.get("type", "general"))
                },
                {
                    "role": "user",
                    "content": task["prompt"]
                }
            ]

            # o3 모델용 배치 요청 구성
            request = {
                "custom_id": task.get("id", f"task-{i}"),
                "method": "POST",
                "url": "/v1/chat/completions",
                "body": {
                    "model": self.model,
                    "messages": messages,
                    "max_completion_tokens": 4000,  # o3 모델은 max_completion_tokens 필수
                    "reasoning_effort": task.get("effort", "medium"),  # low, medium, high
                    "temperature": 0.7
                }
            }
            batch_requests.append(request)

        # JSONL 파일 생성
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"o3_batch_requests_{timestamp}.jsonl"

        with open(filename, 'w', encoding='utf-8') as f:
            for request in batch_requests:
                f.write(json.dumps(request, ensure_ascii=False) + '\n')

        print(f"📝 배치 요청 파일 생성: {filename}")
        print(f"   총 {len(batch_requests)}개 요청")

        return filename

    def _get_system_prompt(self, task_type: str) -> str:
        """작업 유형별 시스템 프롬프트 생성"""
        prompts = {
            "math": "당신은 수학 문제 해결 전문가입니다. 단계별로 논리적으로 사고하여 정확한 답을 제공하세요.",
            "coding": "당신은 프로그래밍 전문가입니다. 효율적이고 가독성 좋은 코드를 작성하고 자세히 설명하세요.",
            "science": "당신은 과학 연구자입니다. 과학적 원리를 바탕으로 정확하고 상세한 분석을 제공하세요.",
            "reasoning": "당신은 논리적 사고 전문가입니다. 체계적으로 분석하고 근거를 바탕으로 결론을 도출하세요.",
            "history": "당신은 역사 전문가입니다. 정확한 사실을 바탕으로 흥미롭게 설명하세요.",
            "general": "당신은 도움이 되는 AI 어시스턴트입니다. 정확하고 유용한 정보를 제공하세요."
        }
        return prompts.get(task_type, prompts["general"])

    def submit_batch(self, jsonl_file: str, description: str = "o3 모델 배치 처리") -> str:
        """
        배치 작업 제출

        Args:
            jsonl_file: JSONL 파일 경로
            description: 배치 작업 설명

        Returns:
            배치 ID
        """
        try:
            # 1. 파일 업로드
            print(f"📤 파일 업로드 중: {jsonl_file}")
            with open(jsonl_file, 'rb') as f:
                batch_input_file = self.client.files.create(
                    file=f,
                    purpose="batch"
                )

            print(f"✅ 파일 업로드 완료: {batch_input_file.id}")

            # 2. 배치 작업 생성
            print("🚀 배치 작업 생성 중...")
            batch = self.client.batches.create(
                input_file_id=batch_input_file.id,
                endpoint="/v1/chat/completions",
                completion_window="24h",
                metadata={"description": description}
            )

            print(f"✅ 배치 작업 생성 완료!")
            print(f"   배치 ID: {batch.id}")
            print(f"   상태: {batch.status}")
            print(f"   예상 완료: 24시간 이내")

            return batch.id

        except Exception as e:
            print(f"❌ 배치 제출 실패: {e}")
            return None

    def check_batch_status(self, batch_id: str) -> Dict:
        """배치 상태 확인"""
        try:
            batch = self.client.batches.retrieve(batch_id)

            status_info = {
                'id': batch.id,
                'status': batch.status,
                'created_at': batch.created_at,
                'completed_at': batch.completed_at,
                'request_counts': batch.request_counts.__dict__ if batch.request_counts else {}
            }

            print(f"📊 배치 상태: {batch.status}")
            if batch.request_counts:
                counts = batch.request_counts
                total = counts.total or 0
                completed = counts.completed or 0
                failed = counts.failed or 0

                if total > 0:
                    progress = (completed / total) * 100
                    print(f"   진행률: {completed}/{total} ({progress:.1f}%)")
                    if failed > 0:
                        print(f"   실패: {failed}개")

            return status_info

        except Exception as e:
            print(f"❌ 상태 확인 실패: {e}")
            return {}

    def download_results(self, batch_id: str) -> List[Dict]:
        """배치 결과 다운로드 및 파싱"""
        try:
            batch = self.client.batches.retrieve(batch_id)

            if batch.status != "completed":
                print(f"⚠️ 배치가 아직 완료되지 않았습니다: {batch.status}")
                return []

            if not batch.output_file_id:
                print("❌ 출력 파일이 없습니다.")
                return []

            print("📥 결과 다운로드 중...")

            # 결과 파일 다운로드
            result_content = self.client.files.content(batch.output_file_id)
            result_text = result_content.content.decode('utf-8')

            # 결과 파싱
            results = []
            for line_num, line in enumerate(result_text.strip().split('\n'), 1):
                if line:
                    try:
                        result_data = json.loads(line)

                        if (result_data.get('response') and
                                result_data['response'].get('status_code') == 200):

                            response_body = result_data['response']['body']
                            content = response_body['choices'][0]['message']['content']

                            # o3 모델 특성: reasoning tokens 정보 포함
                            usage = response_body.get('usage', {})

                            results.append({
                                'custom_id': result_data['custom_id'],
                                'content': content,
                                'usage': {
                                    'prompt_tokens': usage.get('prompt_tokens', 0),
                                    'completion_tokens': usage.get('completion_tokens', 0),
                                    'reasoning_tokens': usage.get('reasoning_tokens', 0),  # o3 특징
                                    'total_tokens': usage.get('total_tokens', 0)
                                },
                                'line_number': line_num
                            })
                        else:
                            print(f"❌ 라인 {line_num} 실패: {result_data['custom_id']}")

                    except json.JSONDecodeError as e:
                        print(f"❌ 라인 {line_num} JSON 파싱 실패: {e}")

            print(f"✅ 결과 처리 완료: {len(results)}개 성공")
            return results

        except Exception as e:
            print(f"❌ 결과 다운로드 실패: {e}")
            return []

    def save_results(self, results: List[Dict], filename: str = None):
        """결과를 파일로 저장"""
        if not filename:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"o3_mini_results_{timestamp}.json"

        try:
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(results, f, ensure_ascii=False, indent=2)

            print(f"💾 결과 저장 완료: {filename}")

            # 토큰 사용량 요약
            if results:
                total_reasoning_tokens = sum(r['usage']['reasoning_tokens'] for r in results)
                total_completion_tokens = sum(r['usage']['completion_tokens'] for r in results)

                print(f"📊 토큰 사용량 요약:")
                print(f"   추론 토큰: {total_reasoning_tokens:,}")
                print(f"   완성 토큰: {total_completion_tokens:,}")
                print(f"   총 작업: {len(results)}개")

        except Exception as e:
            print(f"❌ 저장 실패: {e}")


def create_sample_tasks() -> List[Dict[str, str]]:
    """샘플 작업들 생성 (다양한 영역)"""
    tasks = [
        {
            "id": "math-1",
            "type": "math",
            "effort": "high",
            "prompt": "다음 방정식을 풀어주세요: x³ - 6x² + 11x - 6 = 0. 모든 구해주세요."
        }
    ]
    return tasks


def main():
    """메인 실행 함수"""
    print("🧠 OpenAI o3-mini 모델 배치 처리 예시")
    print("=" * 50)

    # 환경 변수에서 API 키 로드
    load_dotenv()
    api_key = os.getenv('OPENAI_API_KEY')

    if not api_key:
        print("❌ OPENAI_API_KEY 환경 변수가 설정되지 않았습니다.")
        return

    # 서비스 초기화
    service = OpenAIO3BatchService(api_key)

    # 샘플 작업 생성
    tasks = create_sample_tasks()
    print(f"📋 생성된 작업 수: {len(tasks)}개")

    # 1. 배치 요청 파일 생성
    jsonl_file = service.create_o3_batch_requests(tasks)

    # 2. 배치 제출
    batch_id = service.submit_batch(jsonl_file, "o3 모델 다양한 영역 테스트")

    if batch_id:
        print(f"\n🎉 배치 제출 완료!")
        print(f"배치 ID: {batch_id}")
        print(f"\n다음 명령어로 상태 확인:")
        print(f"service.check_batch_status('{batch_id}')")
        print(f"\n완료 후 결과 다운로드:")
        print(f"results = service.download_results('{batch_id}')")
        print(f"service.save_results(results)")

        # 상태 확인 예시 (첫 한 번만)
        print(f"\n📊 현재 상태 확인:")
        service.check_batch_status(batch_id)


def check_existing_batch_example():
    """기존 배치 확인 예시 함수"""
    load_dotenv()
    api_key = os.getenv('OPENAI_API_KEY')
    service = OpenAIO3BatchService(api_key)

    # 실제 배치 ID로 교체하세요
    batch_id = "batch_YOUR_ACTUAL_BATCH_ID_HERE"

    print(f"📊 배치 {batch_id} 상태 확인 중...")
    status = service.check_batch_status(batch_id)

    if status.get('status') == 'completed':
        print("🎉 배치 완료! 결과 다운로드 중...")
        results = service.download_results(batch_id)

        if results:
            service.save_results(results)
            print(f"✅ 총 {len(results)}개 결과 저장 완료")

            # 샘플 결과 출력
            for i, result in enumerate(results[:2]):  # 처음 2개만
                print(f"\n--- 결과 {i + 1}: {result['custom_id']} ---")
                print(f"내용: {result['content'][:200]}...")
                print(f"추론 토큰: {result['usage']['reasoning_tokens']}")


if __name__ == "__main__":
    main()

    # 기존 배치 확인을 원할 경우 주석 해제
    # check_existing_batch_example()