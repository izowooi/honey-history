# sheets_service.py
"""
Google Sheets API 관련 서비스
Single Responsibility Principle: Google Sheets 연동만 담당
"""

import gspread
from google.oauth2.service_account import Credentials
from typing import List, Dict, Optional
from config import SPREADSHEET_ID, SERVICE_ACCOUNT_FILE, SCOPES, COLUMN_MAPPING


class SheetsService:
    """Google Sheets 연동 서비스"""

    def __init__(self):
        self._client = None
        self._spreadsheet = None

    def _get_client(self) -> gspread.Client:
        """Google Sheets 클라이언트 반환 (Lazy Loading)"""
        if self._client is None:
            credentials = Credentials.from_service_account_file(
                SERVICE_ACCOUNT_FILE,
                scopes=SCOPES
            )
            self._client = gspread.authorize(credentials)
        return self._client

    def _get_spreadsheet(self) -> gspread.Spreadsheet:
        """스프레드시트 반환 (Lazy Loading)"""
        if self._spreadsheet is None:
            client = self._get_client()
            self._spreadsheet = client.open_by_key(SPREADSHEET_ID)
        return self._spreadsheet

    def get_worksheet(self, sheet_name: str) -> gspread.Worksheet:
        """워크시트 반환"""
        try:
            spreadsheet = self._get_spreadsheet()
            return spreadsheet.worksheet(sheet_name)
        except gspread.WorksheetNotFound:
            raise ValueError(f"시트 '{sheet_name}'를 찾을 수 없습니다.")

    def get_row_data(self, worksheet: gspread.Worksheet, row_num: int) -> Dict[str, str]:
        """특정 행의 데이터 반환"""
        try:
            row_values = worksheet.row_values(row_num)

            # 빈 셀 처리 (리스트 길이 부족한 경우)
            while len(row_values) < len(COLUMN_MAPPING):
                row_values.append('')

            # 컬럼 매핑에 따라 딕셔너리 생성
            data = {}
            for col_name, col_letter in COLUMN_MAPPING.items():
                col_index = ord(col_letter) - ord('A')  # A=0, B=1, C=2...
                data[col_name] = row_values[col_index] if col_index < len(row_values) else ''

            return data
        except Exception as e:
            raise RuntimeError(f"행 {row_num} 데이터 읽기 실패: {e}")

    def update_cell(self, worksheet: gspread.Worksheet, row_num: int,
                    column_name: str, value: str) -> None:
        """특정 셀 업데이트"""
        try:
            if column_name not in COLUMN_MAPPING:
                raise ValueError(f"알 수 없는 컬럼: {column_name}")

            col_letter = COLUMN_MAPPING[column_name]
            cell_address = f"{col_letter}{row_num}"
            worksheet.update_acell(cell_address, value)
        except Exception as e:
            raise RuntimeError(f"셀 {column_name}{row_num} 업데이트 실패: {e}")

    def get_data_rows_count(self, worksheet: gspread.Worksheet) -> int:
        """데이터가 있는 행 수 반환"""
        try:
            all_values = worksheet.get_all_values()
            # 빈 행 제외하고 카운트 (헤더 제외)
            data_rows = 0
            for i, row in enumerate(all_values[1:], start=2):  # 2행부터 시작
                if any(cell.strip() for cell in row[:2]):  # A, B 컬럼에 데이터가 있으면
                    data_rows = i
            return data_rows
        except Exception as e:
            raise RuntimeError(f"데이터 행 수 계산 실패: {e}")

    def batch_update_row(self, worksheet: gspread.Worksheet, row_num: int,
                         updates: Dict[str, str]) -> None:
        """한 행의 여러 컬럼을 일괄 업데이트"""
        try:
            for column_name, value in updates.items():
                if column_name in COLUMN_MAPPING:
                    self.update_cell(worksheet, row_num, column_name, value)
        except Exception as e:
            raise RuntimeError(f"행 {row_num} 일괄 업데이트 실패: {e}")