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
        시트 데이터 업데이트 (배치 방식)
        
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
            
            # 배치 업데이트를 위한 데이터 준비
            batch_updates = []
            updated_count = 0
            skipped_count = 0
            
            for row_num in range(start_row, start_row + data_rows):
                try:
                    # A열 값 읽기 (ID)
                    if row_num - start_row < len(all_values) - (start_row - 1):
                        row_data = all_values[row_num - 1] if row_num - 1 < len(all_values) else []
                        cell_value = row_data[0] if len(row_data) > 0 else ""
                        
                        # C, D, E, F 열 값 확인 (인덱스 2, 3, 4, 5)
                        existing_year = row_data[2] if len(row_data) > 2 else ""
                        existing_simple = row_data[3] if len(row_data) > 3 else ""
                        existing_detail = row_data[4] if len(row_data) > 4 else ""
                        existing_movies = row_data[5] if len(row_data) > 5 else ""
                        
                    else:
                        cell_value = worksheet.acell(f'A{row_num}').value
                        # 개별 셀 읽기로 기존 값 확인
                        existing_year = worksheet.acell(f'C{row_num}').value or ""
                        existing_simple = worksheet.acell(f'D{row_num}').value or ""
                        existing_detail = worksheet.acell(f'E{row_num}').value or ""
                        existing_movies = worksheet.acell(f'F{row_num}').value or ""
                    
                    if not cell_value:
                        continue
                    
                    # 기존 값이 있는지 확인 (하나라도 값이 있으면 스킵)
                    has_existing_data = any([
                        existing_year.strip(),
                        existing_simple.strip(),
                        existing_detail.strip(),
                        existing_movies.strip()
                    ])
                    
                    if has_existing_data:
                        skipped_count += 1
                        print(f"⏭️ 행 {row_num} 스킵: '{cell_value}' (기존 데이터 존재)")
                        continue
                    
                    # 결과 데이터에서 해당 ID 찾기
                    if cell_value in results_data:
                        data = results_data[cell_value]
                        
                        # 배치 업데이트 요청 추가
                        batch_updates.append({
                            'range': f'C{row_num}:F{row_num}',
                            'values': [[
                                data.get('year', ''),
                                data.get('simple', ''),
                                data.get('detail', ''),
                                data.get('related_movies', '')
                            ]]
                        })
                        
                        updated_count += 1
                        print(f"📝 행 {row_num} 업데이트 준비 완료: {cell_value}")
                    else:
                        print(f"⚠️ 행 {row_num}: '{cell_value}' 데이터를 찾을 수 없습니다")
                        
                except Exception as e:
                    print(f"❌ 행 {row_num} 처리 실패: {e}")
                    continue
            
            # 배치 업데이트 실행
            if batch_updates:
                print(f"🚀 배치 업데이트 시작: {len(batch_updates)}개 행")
                
                # 배치 크기 제한 (한 번에 너무 많이 업데이트하지 않도록)
                batch_size = 10
                for i in range(0, len(batch_updates), batch_size):
                    batch_chunk = batch_updates[i:i + batch_size]
                    
                    try:
                        worksheet.batch_update(batch_chunk)
                        print(f"✅ 배치 {i//batch_size + 1}/{(len(batch_updates)-1)//batch_size + 1} 완료")
                        
                        # API 호출 간격 조절 (선택사항)
                        import time
                        time.sleep(1)  # 1초 대기
                        
                    except Exception as e:
                        print(f"❌ 배치 업데이트 실패: {e}")
                        # 개별 업데이트로 폴백
                        for update in batch_chunk:
                            try:
                                worksheet.update(values=update['values'], range_name=update['range'])
                                time.sleep(0.5)  # 개별 업데이트 시 더 긴 대기
                            except Exception as fallback_e:
                                print(f"❌ 개별 업데이트도 실패: {fallback_e}")
            
            print(f"🎉 업데이트 완료! 총 {updated_count}개 행 업데이트됨, 스킵된 행 수: {skipped_count}")
            
        except gspread.WorksheetNotFound:
            print(f"❌ 시트 '{sheet_name}'를 찾을 수 없습니다")
        except Exception as e:
            print(f"❌ 시트 업데이트 실패: {e}")


def main():
    """메인 함수"""
    parser = argparse.ArgumentParser(description='Google Sheets 결과 업데이트')
    parser.add_argument('--json-file', 
                       default='out/processed_results_batch_685c04bfd7c08190932992ef3950e693.json',
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