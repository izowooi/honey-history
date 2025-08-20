import json
import csv
import os

def convert_json_to_csv():
    """
    'input/history_noti.json' 파일을 읽어 'output_for_supabase.csv' 파일로 변환합니다.
    """
    json_file_path = os.path.join('input', 'history_noti.json')
    csv_file_path = 'output_for_supabase.csv'

    # 입력 파일이 있는지 확인합니다.
    if not os.path.exists(json_file_path):
        print(f"오류: '{json_file_path}' 파일을 찾을 수 없습니다.")
        print("스크립트와 같은 폴더에 'input' 폴더를 만들고 그 안에 'history_noti.json' 파일을 넣어주세요.")
        return

    try:
        # 1. JSON 파일 읽기 (UTF-8 인코딩 사용)
        with open(json_file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # 2. CSV 파일 작성 (UTF-8 인코딩 사용)
        with open(csv_file_path, 'w', newline='', encoding='utf-8') as f:
            # CSV 작성기 생성
            writer = csv.writer(f)

            # 3. 헤더 작성 (Supabase 컬럼명과 일치)
            header = ['date_key', 'title', 'body']
            writer.writerow(header)

            # 4. 데이터 행 작성
            # JSON 데이터의 각 항목(key, value)을 순회
            for date_key, content in data.items():
                # CSV 파일에 쓸 한 줄의 데이터를 리스트로 만듭니다.
                row = [date_key, content['title'], content['body']]
                writer.writerow(row)

        print(f"성공! '{csv_file_path}' 파일이 생성되었습니다.")
        print("이제 Supabase 대시보드에서 이 파일을 가져오기(import)할 수 있습니다.")

    except json.JSONDecodeError:
        print(f"오류: '{json_file_path}' 파일이 올바른 JSON 형식이 아닙니다.")
    except Exception as e:
        print(f"알 수 없는 오류가 발생했습니다: {e}")

# 스크립트 실행
if __name__ == "__main__":
    convert_json_to_csv()
