# sheets_updater.py
"""
Google Sheets 업데이트 스크립트
처리된 결과를 Google Sheets에 업데이트
"""

import json
import gspread
import argparse
from google.oauth2.service_account import Credentials
from typing import Dict, List


class SheetsUpdater:
    """Google Sheets 업데이트 서비스"""
    
    def __init__(self, credentials_file: str = 'credentials.json'):
        """
        초기화
        
        Args:
            credentials_file: 서비스 계정 키 파일 경로
        """
        self.credentials_file = credentials_file
        self.scopes = ['https://www.googleapis.com/auth/spreadsheets']
        self._client = None
        
    def _get_client(self) -> gspread.Client:
        """Google Sheets 클라이언트 반환 (Lazy Loading)"""
        if self._client is None:
            credentials = Credentials.from_service_account_file(
                self.credentials_file,
                scopes=self.scopes
            )
            self._client = gspread.authorize(credentials)
        return self._client
    
    def load_processed_results(self, json_file: str) -> Dict:
        """
        처리된 결과 JSON 파일 로드
        
        Args:
            json_file: JSON 파일 경로
            
        Returns:
            결과 데이터 딕셔너리 (custom_id를 키로 사용)
        """
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                results_list = json.load(f)
            
            # custom_id를 키로 하는 딕셔너리로 변환
            results_dict = {}
            for item in results_list:
                custom_id = item['custom_id']
                results_dict[custom_id] = item['content']
            
            print(f"📂 결과 파일 로드 완료: {len(results_dict)}개 항목")
            return results_dict
            
        except FileNotFoundError:
            print(f"❌ 결과 파일을 찾을 수 없습니다: {json_file}")
            return {}
        except json.JSONDecodeError as e:
            print(f"❌ JSON 파일 형식 오류: {e}")
            return {}
        except Exception as e:
            print(f"❌ 결과 파일 로드 실패: {e}")
            return {}
    
    def update_sheet(self, spreadsheet_id: str, sheet_name: str, 
                     results_data: Dict, start_row: int = 2):
        """
        시트 데이터 업데이트
        
        Args:
            spreadsheet_id: 스프레드시트 ID
            sheet_name: 시트 이름
            results_data: 결과 데이터
            start_row: 시작 행 번호 (기본값: 2)
        """
        try:
            # 클라이언트 및 워크시트 가져오기
            client = self._get_client()
            spreadsheet = client.open_by_key(spreadsheet_id)
            worksheet = spreadsheet.worksheet(sheet_name)
            
            print(f"📊 시트 '{sheet_name}' 연결 완료")
            
            # 시트의 모든 데이터 가져오기
            all_values = worksheet.get_all_values()
            
            # 데이터가 있는 행 수 확인
            data_rows = len([row for row in all_values[start_row-1:] if any(cell.strip() for cell in row[:1])])
            
            print(f"📋 업데이트할 행 수: {data_rows}개")
            
            # 각 행 처리
            updated_count = 0
            for row_num in range(start_row, start_row + data_rows):
                try:
                    # A열 값 읽기 (ID)
                    cell_value = worksheet.acell(f'A{row_num}').value
                    if not cell_value:
                        continue
                    
                    # 결과 데이터에서 해당 ID 찾기
                    if cell_value in results_data:
                        data = results_data[cell_value]
                        
                        # C, D, E, F 열에 데이터 업데이트
                        # C: year, D: simple, E: detail, F: related_movies
                        updates = [
                            [data.get('year', '')],           # C열
                            [data.get('simple', '')],         # D열  
                            [data.get('detail', '')],         # E열
                            [data.get('related_movies', '')]  # F열
                        ]
                        
                        # 배치 업데이트
                        worksheet.update(values=[updates[0]], range_name=f'C{row_num}')
                        worksheet.update(values=[updates[1]], range_name=f'D{row_num}')
                        worksheet.update(values=[updates[2]], range_name=f'E{row_num}')
                        worksheet.update(values=[updates[3]], range_name=f'F{row_num}')
                        
                        updated_count += 1
                        print(f"✅ 행 {row_num} 업데이트 완료: {cell_value}")
                    else:
                        print(f"⚠️ 행 {row_num}: '{cell_value}' 데이터를 찾을 수 없습니다")
                        
                except Exception as e:
                    print(f"❌ 행 {row_num} 업데이트 실패: {e}")
                    continue
            
            print(f"🎉 업데이트 완료! 총 {updated_count}개 행 업데이트됨")
            
        except gspread.WorksheetNotFound:
            print(f"❌ 시트 '{sheet_name}'를 찾을 수 없습니다")
        except Exception as e:
            print(f"❌ 시트 업데이트 실패: {e}")


def main():
    """메인 함수"""
    parser = argparse.ArgumentParser(description='Google Sheets 결과 업데이트')
    parser.add_argument('--json-file', 
                       default='out/processed_results_batch_685bf51099f881909f38b5dc0b5e9c99.json',
                       help='처리된 결과 JSON 파일 경로')
    parser.add_argument('--spreadsheet-id',
                       default='1n5swi9I4-04YZ6qAT3G0gQX9cB3QbBEv0DX5YYhvTuA',
                       help='Google Sheets 스프레드시트 ID')
    parser.add_argument('--sheet-name',
                       default='test_quarter',
                       help='업데이트할 시트 이름')
    parser.add_argument('--credentials',
                       default='credentials.json',
                       help='Google API 인증 키 파일')
    parser.add_argument('--start-row',
                       type=int,
                       default=2,
                       help='시작 행 번호 (기본값: 2)')
    
    args = parser.parse_args()
    
    print("📊 Google Sheets 업데이트 시작")
    print("=" * 50)
    
    # 업데이터 초기화
    updater = SheetsUpdater(args.credentials)
    
    # 결과 데이터 로드
    results_data = updater.load_processed_results(args.json_file)
    
    if not results_data:
        print("❌ 업데이트할 데이터가 없습니다")
        return
    
    # 시트 업데이트
    updater.update_sheet(
        spreadsheet_id=args.spreadsheet_id,
        sheet_name=args.sheet_name,
        results_data=results_data,
        start_row=args.start_row
    )


if __name__ == "__main__":
    main() 