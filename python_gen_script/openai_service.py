# openai_service.py
"""
OpenAI API 연동 서비스
Single Responsibility Principle: OpenAI API 호출만 담당
"""

import json
import re
from typing import Dict, Optional
from openai import OpenAI, api_key
from dotenv import load_dotenv
import os

class OpenAIService:
    """OpenAI API 서비스 클래스"""

    def __init__(self, api_key: str, model: str = "gpt-4.1-nano-2025-04-14"):
        """
        OpenAI 서비스 초기화

        Args:
            api_key: OpenAI API 키
            model: 사용할 모델명 (기본값: gpt-4o-mini)
        """
        self.client = OpenAI(api_key=api_key)
        self.model = model

        # 시스템 프롬프트
        self.system_prompt = (
            "당신은 세계사에 정통한 학자이자 스토리텔러입니다. "
            "독자가 몰입할 수 있도록 생생하고 흥미로운 서술을 사용하세요."
        )

    def generate_content(self, topic: str, date: str = "") -> Dict[str, str]:
        """
        주제에 대한 컨텐츠 생성

        Args:
            topic: 주제 (예: "관동 대지진")
            date: 날짜 (예: "09-01", 선택사항)

        Returns:
            Dict with 'simple' and 'detail' keys
        """
        try:
            # 사용자 프롬프트 생성
            user_prompt = self._create_user_prompt(topic, date)

            # OpenAI API 호출
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self.system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=0.7,
                max_tokens=2000
            )

            # 응답 파싱
            content = response.choices[0].message.content
            return self._parse_response(content)

        except Exception as e:
            print(f"❌ OpenAI API 호출 실패: {e}")
            return {
                'simple': f'{topic}에 대한 간단한 설명을 생성할 수 없습니다.',
                'detail': f'{topic}에 대한 상세한 설명을 생성할 수 없습니다.',
                'year': '연도 추출 실패'
            }

    def _create_user_prompt(self, topic: str, date: str = "") -> str:
        """사용자 프롬프트 생성"""
        date_info = f"<DATE>{date}</DATE>\n" if date else ""

        prompt = f'''{date_info}"{topic}"에 대해 두 가지 버전의 글을 작성해주세요.

조건
• 첫 문장은 반드시 날짜의 의미를 포함하고, AI가 찾아낸 연도와 <DATE>를 활용해 다양하게 시작하세요. 
 예: "1885년 7월 6일의 OO에서는…", "1832년 7월 6일의 OO에서는…", "바로 오늘(7월 6일), …", "1885년 7월 6일…". 
• 번호, 글머리표, 하이픈을 절대 쓰지 말고 자연스러운 문단으로만 서술하세요. 
• 적절한 이모지를 섞어 흥미를 높여주세요. 
• 첫 번째 버전은 초등학생 눈높이에 맞춰 300자 내외로 짧고 간단하게 작성하세요. 
• 두 번째 버전은 고등학생 수준으로 1500자 내외이며 배경·전개·영향까지 깊이 있게 다뤄 주세요. 
• 최종 출력은 아래 JSON 형식을 그대로 지켜 주세요(큰따옴표, 줄바꿈 유지).

{{
 "simple": "<300자 내외 문단>",
 "detail": "<1500자 내외 문단>",
 "year": "<AI가 찾아낸 연도>",
}}'''

        return prompt

    def _parse_response(self, content: str) -> Dict[str, str]:
        """OpenAI 응답 파싱"""
        try:
            # JSON 응답 파싱 시도
            # 코드 블록 제거 (```json ... ``` 형태)
            content = re.sub(r'```json\n?', '', content)
            content = re.sub(r'```\n?', '', content)

            # JSON 파싱
            parsed = json.loads(content)

            return {
                'simple': parsed.get('simple', ''),
                'detail': parsed.get('detail', ''),
                'year': parsed.get('year', '')
            }

        except json.JSONDecodeError as e:
            print(f"⚠️ JSON 파싱 실패: {e}")
            print(f"원본 응답: {content}")

            # JSON 파싱 실패 시 텍스트에서 추출 시도
            return self._extract_from_text(content)

    def _extract_from_text(self, content: str) -> Dict[str, str]:
        """텍스트에서 simple/detail 추출 (fallback)"""
        try:
            # "simple": "..." 패턴 찾기
            simple_pattern = r'"simple":\s*"([^"]*(?:\\.[^"]*)*)"'
            detail_pattern = r'"detail":\s*"([^"]*(?:\\.[^"]*)*)"'
            year_pattern = r'"year":\s*"([^"]*)"'

            simple_match = re.search(simple_pattern, content, re.DOTALL)
            detail_match = re.search(detail_pattern, content, re.DOTALL)
            year_match = re.search(year_pattern, content)

            simple_text = simple_match.group(1) if simple_match else '추출 실패'
            detail_text = detail_match.group(1) if detail_match else '추출 실패'
            year_text = year_match.group(1) if year_match else '추출 실패'

            # 이스케이프 문자 처리
            simple_text = simple_text.replace('\\"', '"').replace('\\n', '\n')
            detail_text = detail_text.replace('\\"', '"').replace('\\n', '\n')
            year_text = year_text.replace('\\"', '"').replace('\\n', '\n')

            return {
                'simple': simple_text,
                'detail': detail_text,
                'year': year_text
            }

        except Exception as e:
            print(f"❌ 텍스트 추출 실패: {e}")
            return {
                'simple': '내용 추출 실패',
                'detail': '내용 추출 실패',
                'year': '연도 추출 실패'
            }


def test_openai_service():
    """OpenAI 서비스 테스트 함수"""
    print("🤖 OpenAI 서비스 테스트 시작")

    load_dotenv()
    api_key = os.getenv('OPENAI_API_KEY')
    print(f"📌 OPENAI_API_KEY: {api_key}")
    # 서비스 초기화
    service = OpenAIService(api_key)

    # 테스트 주제들
    test_topics = [
        {"topic": "관동 대지진", "date": "09-01"}
        #{"topic": "런던 대화재", "date": "09-02"}
    ]

    for test_case in test_topics:
        print(f"\n📝 주제: {test_case['topic']} (날짜: {test_case['date']})")
        print("-" * 50)

        try:
            # 컨텐츠 생성
            result = service.generate_content(test_case['topic'], test_case['date'])

            print("🔍 Simple 버전:")
            print(result['simple'])
            print(f"📏 길이: {len(result['simple'])}자")

            print("\n📖 Detail 버전:")
            print(result['detail'])
            print(f"📏 길이: {len(result['detail'])}자")

            print(f"\n📅 AI가 찾아낸 연도: {result['year']}")
        except Exception as e:
            print(f"❌ 테스트 실패: {e}")

    print("\n✅ 테스트 완료!")


if __name__ == "__main__":
    test_openai_service()