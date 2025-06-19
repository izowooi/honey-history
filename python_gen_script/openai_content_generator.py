# openai_content_generator.py
"""
OpenAI API를 사용한 컨텐츠 생성기
Single Responsibility Principle: OpenAI API를 통한 컨텐츠 생성만 담당
"""

import os
from typing import Dict, Optional
from dotenv import load_dotenv
from openai_service import OpenAIService


class OpenAIContentGenerator:
    """OpenAI API를 사용한 컨텐츠 생성기"""

    def __init__(self):
        """OpenAI 컨텐츠 생성기 초기화"""
        # 환경 변수 로드
        load_dotenv()
        api_key = os.getenv('OPENAI_API_KEY')
        
        if not api_key:
            raise ValueError("OPENAI_API_KEY가 설정되지 않았습니다. .env 파일을 확인해주세요.")
        
        # OpenAI 서비스 초기화
        self.openai_service = OpenAIService(api_key)

    def generate_content(self, title: str, date: str) -> Dict[str, str]:
        """
        제목과 날짜를 기반으로 컨텐츠 생성

        Args:
            title: 주제/제목 (예: "관동 대지진")
            date: 날짜 (예: "09-01")

        Returns:
            Dict with 'simple', 'detail', 'year' keys
        """
        try:
            print(f"🤖 OpenAI API로 컨텐츠 생성 중: {title} ({date})")
            
            # OpenAI API 호출하여 컨텐츠 생성
            result = self.openai_service.generate_content(title, date)
            
            # 결과 검증
            if not result.get('simple') or not result.get('detail'):
                raise ValueError("OpenAI API에서 유효한 컨텐츠를 받지 못했습니다.")
            
            print(f"✅ 컨텐츠 생성 완료:")
            print(f"   - Simple: {len(result['simple'])}자")
            print(f"   - Detail: {len(result['detail'])}자")
            print(f"   - Year: {result['year']}")
            
            return result
            
        except Exception as e:
            print(f"❌ 컨텐츠 생성 실패: {e}")
            # 에러 발생 시 기본값 반환
            return {
                'simple': f'{title}에 대한 간단한 설명을 생성할 수 없습니다.',
                'detail': f'{title}에 대한 상세한 설명을 생성할 수 없습니다.',
                'year': '연도 추출 실패'
            }

    def generate_multiple_contents(self, content_list: list) -> list:
        """
        여러 컨텐츠를 일괄 생성

        Args:
            content_list: [{'title': '제목', 'date': '날짜'}, ...] 형태의 리스트

        Returns:
            생성된 컨텐츠 리스트
        """
        results = []
        
        for i, content_info in enumerate(content_list, 1):
            print(f"\n📝 [{i}/{len(content_list)}] 컨텐츠 생성 중...")
            
            title = content_info.get('title', '')
            date = content_info.get('date', '')
            
            if not title or not date:
                print(f"⚠️ 제목 또는 날짜가 누락됨: title='{title}', date='{date}'")
                continue
            
            # 컨텐츠 생성
            result = self.generate_content(title, date)
            
            # 원본 정보와 함께 결과 저장
            content_result = {
                'title': title,
                'date': date,
                'simple': result['simple'],
                'detail': result['detail'],
                'year': result['year']
            }
            
            results.append(content_result)
            
            # API 호출 간격 조절 (Rate limiting 방지)
            import time
            time.sleep(1)
        
        print(f"\n✅ 총 {len(results)}개의 컨텐츠 생성 완료!")
        return results


def test_openai_content_generator():
    """OpenAI 컨텐츠 생성기 테스트"""
    print("🧪 OpenAI 컨텐츠 생성기 테스트")
    print("=" * 50)
    
    try:
        # 생성기 초기화
        generator = OpenAIContentGenerator()
        
        # 테스트 데이터
        test_contents = [
            {'title': '관동 대지진', 'date': '09-01'},
            {'title': '런던 대화재', 'date': '09-02'}
        ]
        
        # 컨텐츠 생성
        results = generator.generate_multiple_contents(test_contents)
        
        # 결과 출력
        for i, result in enumerate(results, 1):
            print(f"\n📋 결과 {i}:")
            print(f"제목: {result['title']}")
            print(f"날짜: {result['date']}")
            print(f"연도: {result['year']}")
            print(f"Simple: {result['simple'][:100]}...")
            print(f"Detail: {result['detail'][:100]}...")
            
    except Exception as e:
        print(f"❌ 테스트 실패: {e}")


if __name__ == "__main__":
    test_openai_content_generator() 