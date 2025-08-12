import json
import os
from pathlib import Path

def merge_historical_events(input_folder: str):
    """
    4개 분기별 역사 이벤트 JSON 파일을 하나로 병합하여 output 폴더에 저장합니다.
    
    Args:
        input_folder (str): 입력 파일들이 있는 폴더 경로
    """
    
    # 파일명 정의
    file_names = [
        'historical_events_1q.json',
        'historical_events_2q.json',
        'historical_events_3q.json',
        'historical_events_4q.json'
    ]
    
    # 병합된 데이터를 저장할 딕셔너리
    merged_data = {}
    
    # 각 파일을 읽어서 병합
    for file_name in file_names:
        file_path = os.path.join(input_folder, file_name)
        
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                data = json.load(file)
                
                # 데이터를 병합 (딕셔너리 업데이트)
                merged_data.update(data)
                print(f"✅ {file_name} 파일 로드 완료 - {len(data)}개 이벤트")
                
        except FileNotFoundError:
            print(f"⚠️  경고: {file_path} 파일을 찾을 수 없습니다.")
        except json.JSONDecodeError:
            print(f"❌ 오류: {file_path} 파일의 JSON 형식이 올바르지 않습니다.")
        except Exception as e:
            print(f"❌ 오류: {file_path} 파일을 읽는 중 문제가 발생했습니다: {e}")
    
    # output 폴더 생성
    output_folder = 'output'
    os.makedirs(output_folder, exist_ok=True)
    
    # 병합된 데이터를 파일로 저장
    output_file_path = os.path.join(output_folder, 'historical_events.json')
    
    try:
        with open(output_file_path, 'w', encoding='utf-8') as output_file:
            json.dump(merged_data, output_file, ensure_ascii=False, indent=2)
        
        print(f"\n🎉 병합 완료!")
        print(f"📁 출력 파일: {output_file_path}")
        print(f"📊 총 이벤트 수: {len(merged_data)}개")
        
        # 월별 이벤트 수 출력 (선택사항)
        monthly_count = {}
        for event_id in merged_data.keys():
            month = event_id.split('-')[0]
            monthly_count[month] = monthly_count.get(month, 0) + 1
        
        print(f"\n📅 월별 이벤트 분포:")
        for month in sorted(monthly_count.keys()):
            print(f"   {month}월: {monthly_count[month]}개")
            
    except Exception as e:
        print(f"❌ 오류: 병합된 파일을 저장하는 중 문제가 발생했습니다: {e}")

# 메인 실행 부분
if __name__ == "__main__":
    # input_folder 경로를 지정합니다
    input_folder_path = "input"  # 현재 디렉터리를 기본값으로 설정
    
    print("🔄 역사 이벤트 파일 병합을 시작합니다...")
    print(f"📂 입력 폴더: {input_folder_path}")
    
    merge_historical_events(input_folder_path)
