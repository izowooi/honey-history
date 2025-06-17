# content_processor.py
"""
컨텐츠 생성 및 처리 서비스
Single Responsibility Principle: 컨텐츠 생성만 담당
Open/Closed Principle: 새로운 AI 서비스 추가 시 확장 가능
"""

from abc import ABC, abstractmethod
from typing import Dict
import re


class ContentGenerator(ABC):
    """컨텐츠 생성기 인터페이스"""

    @abstractmethod
    def generate_content(self, title: str) -> Dict[str, str]:
        """제목을 기반으로 컨텐츠 생성"""
        pass


class DummyContentGenerator(ContentGenerator):
    """더미 컨텐츠 생성기 (테스트용)"""

    def generate_content(self, title: str) -> Dict[str, str]:
        """더미 데이터로 컨텐츠 생성"""
        if not title or not title.strip():
            return {
                'year': '',
                'content_simple': '',
                'content_detailed': ''
            }

        # 제목에서 연도 추출 시도
        year = self._extract_year_from_title(title)

        # 더미 데이터 생성
        simple_content = f"{title}에 대한 간단한 설명입니다."
        detailed_content = f"{title}에 대한 상세한 설명입니다. 이 사건은 {year}년에 발생했으며, 역사적으로 중요한 의미를 가지고 있습니다."

        return {
            'year': year,
            'content_simple': simple_content,
            'content_detailed': detailed_content
        }

    def _extract_year_from_title(self, title: str) -> str:
        """제목에서 연도 추출"""
        # 숫자 4자리 패턴 찾기 (연도로 추정)
        year_pattern = r'\b(19|20)\d{2}\b'
        match = re.search(year_pattern, title)
        if match:
            return match.group()

        # 연도가 없으면 더미 연도 반환
        dummy_years = {
            '관동 대지진': '1923',
            '런던 대화재': '1666',
            '히로시마': '1945',
            '체르노빌': '1986'
        }

        for keyword, year in dummy_years.items():
            if keyword in title:
                return year

        return '2000'  # 기본값


class OpenAIContentGenerator(ContentGenerator):
    """OpenAI API를 사용한 컨텐츠 생성기 (향후 구현용)"""

    def __init__(self, api_key: str):
        self.api_key = api_key
        # TODO: OpenAI 클라이언트 초기화

    def generate_content(self, title: str) -> Dict[str, str]:
        """OpenAI API로 컨텐츠 생성"""
        # TODO: OpenAI API 호출 구현
        raise NotImplementedError("OpenAI 연동은 아직 구현되지 않았습니다.")


class ContentProcessor:
    """컨텐츠 처리 메인 클래스"""

    def __init__(self, content_generator: ContentGenerator):
        self.content_generator = content_generator

    def process_title(self, title: str) -> Dict[str, str]:
        """제목을 처리하여 컨텐츠 생성"""
        try:
            return self.content_generator.generate_content(title)
        except Exception as e:
            print(f"컨텐츠 생성 실패 (제목: {title}): {e}")
            return {
                'year': '',
                'content_simple': '생성 실패',
                'content_detailed': '생성 실패'
            }

    def is_content_needed(self, row_data: Dict[str, str]) -> bool:
        """컨텐츠 생성이 필요한지 확인"""
        # YEAR, CONTENT_SIMPLE, CONTENT_DETAILED 중 하나라도 비어있으면 생성 필요
        required_fields = ['year', 'content_simple', 'content_detailed']
        return any(not row_data.get(field, '').strip() for field in required_fields)