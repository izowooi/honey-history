# config.py
"""
설정 및 상수 관리
Single Responsibility Principle: 설정값 관리만 담당
"""

# Google Sheets 설정
SPREADSHEET_ID = '1n5swi9I4-04YZ6qAT3G0gQX9cB3QbBEv0DX5YYhvTuA'
SERVICE_ACCOUNT_FILE = 'credentials.json'
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']

# 시트 이름 목록
SHEET_NAMES = {
    'Q1': '1q',
    'Q2': '2q',
    'Q3': '3q',
    'Q4': '4q',
    'TEST': 'test_quarter'
}

# 컬럼 매핑
COLUMN_MAPPING = {
    'id': 'A',
    'title': 'B',
    'year': 'C',
    'content_simple': 'D',
    'content_detailed': 'E',
    'imageUrl': 'F'
}

# 데이터 시작 행 (헤더 제외)
DATA_START_ROW = 2

# 처리할 컬럼들
FILL_COLUMNS = ['year', 'content_simple', 'content_detailed']