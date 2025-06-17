import gspread
from google.oauth2.service_account import Credentials


# 1. 인증 설정
def setup_sheets_client():
    """Google Sheets 클라이언트 설정"""
    # JSON 키 파일 경로 (다운로드한 파일명으로 변경하세요)
    SERVICE_ACCOUNT_FILE = 'credentials.json'

    # 스코프 설정
    SCOPES = ['https://www.googleapis.com/auth/spreadsheets']

    # 인증 정보 로드
    credentials = Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes=SCOPES
    )

    # gspread 클라이언트 생성
    client = gspread.authorize(credentials)

    return client


# 2. 스프레드시트 연결 테스트
def test_connection():
    """스프레드시트 연결 및 데이터 읽기 테스트"""
    try:
        # 클라이언트 설정
        client = setup_sheets_client()

        # 스프레드시트 열기 (실제 ID로 변경)
        SPREADSHEET_ID = '1n5swi9I4-04YZ6qAT3G0gQX9cB3QbBEv0DX5YYhvTuA'
        spreadsheet = client.open_by_key(SPREADSHEET_ID)

        # test_sheet 워크시트 선택
        worksheet = spreadsheet.worksheet('test_sheet')

        # 모든 데이터 읽기
        all_data = worksheet.get_all_records()
        print("📊 스프레드시트 데이터:")
        for row in all_data:
            print(row)

        # 특정 셀 읽기
        cell_value = worksheet.acell('A1').value
        print(f"\n📍 A1 셀 값: {cell_value}")

        print("\n✅ 연결 성공!")
        return worksheet

    except Exception as e:
        print(f"❌ 연결 실패: {e}")
        return None


# 3. 데이터 쓰기 테스트
def write_test_data(worksheet):
    """새로운 데이터 추가"""
    try:
        # 새 행 추가
        new_row = ["김철수", "30", "부산"]
        worksheet.append_row(new_row)
        print("✅ 새 데이터 추가 완료!")

        # 특정 셀 업데이트 (최신 방법 - named arguments 사용)
        worksheet.update(values=[['추가날짜']], range_name='D1')
        worksheet.update(values=[['2025-06-17']], range_name='D2')
        print("✅ 셀 업데이트 완료!")

        # 또는 update_acell 사용 (더 간단)
        worksheet.update_acell('E1', '상태')
        worksheet.update_acell('E2', '완료')
        print("✅ 추가 셀 업데이트 완료!")

    except Exception as e:
        print(f"❌ 데이터 쓰기 실패: {e}")


# 실행
if __name__ == "__main__":
    print("🚀 Google Sheets API 테스트 시작")

    # 연결 테스트
    worksheet = test_connection()

    if worksheet:
        # 데이터 쓰기 테스트
        write_test_data(worksheet)

        print("\n🎉 모든 테스트 완료!")
    else:
        print("❌ 테스트 실패")