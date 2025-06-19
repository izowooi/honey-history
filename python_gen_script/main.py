# main.py
"""
메인 애플리케이션
Single Responsibility Principle: 전체 워크플로우 조정만 담당
Dependency Inversion Principle: 구체 클래스가 아닌 인터페이스에 의존
"""

from sheets_service import SheetsService
from content_processor import ContentProcessor, DummyContentGenerator, OpenAIContentGenerator
from config import SHEET_NAMES, DATA_START_ROW, FILL_COLUMNS
from typing import List


class SheetProcessor:
    """시트 처리 메인 클래스"""

    def __init__(self, sheets_service: SheetsService, content_processor: ContentProcessor):
        self.sheets_service = sheets_service
        self.content_processor = content_processor

    def process_sheet(self, sheet_name: str) -> None:
        """특정 시트 처리"""
        print(f"\n📋 '{sheet_name}' 시트 처리 시작...")

        try:
            # 워크시트 가져오기
            worksheet = self.sheets_service.get_worksheet(sheet_name)

            # 데이터 행 수 확인
            last_row = self.sheets_service.get_data_rows_count(worksheet)

            if last_row < DATA_START_ROW:
                print(f"⚠️ '{sheet_name}' 시트에 처리할 데이터가 없습니다.")
                return

            print(f"📊 처리할 데이터 행: {DATA_START_ROW}행 ~ {last_row}행")

            # 각 행 처리
            processed_count = 0
            skipped_count = 0

            for row_num in range(DATA_START_ROW, last_row + 1):
                try:
                    if self._process_row(worksheet, row_num):
                        processed_count += 1
                    else:
                        skipped_count += 1
                except Exception as e:
                    print(f"❌ {row_num}행 처리 실패: {e}")
                    skipped_count += 1

            print(f"✅ '{sheet_name}' 시트 처리 완료!")
            print(f"   - 처리됨: {processed_count}행")
            print(f"   - 건너뜀: {skipped_count}행")

        except Exception as e:
            print(f"❌ '{sheet_name}' 시트 처리 실패: {e}")

    def _process_row(self, worksheet, row_num: int) -> bool:
        """단일 행 처리"""
        # 현재 행 데이터 읽기
        row_data = self.sheets_service.get_row_data(worksheet, row_num)

        # ID나 TITLE이 없으면 건너뛰기
        if not row_data.get('id', '').strip() or not row_data.get('title', '').strip():
            print(f"⏭️ {row_num}행: ID 또는 TITLE이 비어있어 건너뜀")
            return False

        # 이미 모든 컨텐츠가 채워져 있으면 건너뛰기
        if not self.content_processor.is_content_needed(row_data):
            print(f"⏭️ {row_num}행: 이미 모든 컨텐츠가 채워져 있어 건너뜀")
            return False

        # 컨텐츠 생성
        title = row_data['title']
        date = row_data.get('id', '')  # ID 컬럼을 날짜로 사용 (예: "09-01")
        
        print(f"🔄 {row_num}행 처리 중: '{title}' (날짜: {date})")

        # OpenAI API 호출하여 컨텐츠 생성
        generated_content = self.content_processor.process_title(title, date)

        # OpenAI 응답을 시트 컬럼에 맞게 매핑
        updates = {}
        for field in FILL_COLUMNS:
            if not row_data.get(field, '').strip():  # 빈 필드만
                if field == 'year':
                    updates[field] = generated_content.get('year', '')
                elif field == 'content_simple':
                    updates[field] = generated_content.get('simple', '')
                elif field == 'content_detailed':
                    updates[field] = generated_content.get('detail', '')

        if updates:
            # 시트 업데이트
            self.sheets_service.batch_update_row(worksheet, row_num, updates)
            print(f"✅ {row_num}행 업데이트 완료: {list(updates.keys())}")
            return True
        else:
            print(f"⏭️ {row_num}행: 업데이트할 내용이 없음")
            return False

    def process_multiple_sheets(self, sheet_names: List[str]) -> None:
        """여러 시트 일괄 처리"""
        print(f"🚀 시트 일괄 처리 시작 (총 {len(sheet_names)}개 시트)")

        for sheet_name in sheet_names:
            try:
                self.process_sheet(sheet_name)
            except Exception as e:
                print(f"❌ '{sheet_name}' 시트 처리 중 오류: {e}")

        print("\n🎉 모든 시트 처리 완료!")


def main():
    """메인 함수"""
    print("=" * 50)
    print("📊 Google Sheets 컨텐츠 자동 생성기")
    print("=" * 50)

    try:
        # 의존성 주입 (Dependency Injection)
        sheets_service = SheetsService()
        
        # OpenAI 컨텐츠 생성기 사용 (DummyContentGenerator 대신)
        try:
            content_generator = OpenAIContentGenerator()
            print("🤖 OpenAI API를 사용한 컨텐츠 생성기 초기화 완료")
        except Exception as e:
            print(f"⚠️ OpenAI 초기화 실패, 더미 생성기로 대체: {e}")
            content_generator = DummyContentGenerator()
        
        content_processor = ContentProcessor(content_generator)

        # 메인 처리기 생성
        processor = SheetProcessor(sheets_service, content_processor)

        # 테스트 시트만 처리
        test_sheet_name = SHEET_NAMES['TEST']
        processor.process_sheet(test_sheet_name)

        # 전체 시트 처리하려면 아래 주석 해제
        # all_sheets = list(SHEET_NAMES.values())
        # processor.process_multiple_sheets(all_sheets)

    except Exception as e:
        print(f"❌ 애플리케이션 실행 실패: {e}")


if __name__ == "__main__":
    main()