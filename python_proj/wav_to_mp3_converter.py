import os
from pydub import AudioSegment
import argparse

def convert_wav_to_mp3(input_folder):
    # 입력 폴더가 존재하는지 확인
    if not os.path.exists(input_folder):
        print(f"오류: '{input_folder}' 폴더가 존재하지 않습니다.")
        return

    # mp3 파일을 저장할 폴더 생성
    output_folder = 'mp3_files'
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
        print(f"'{output_folder}' 폴더를 생성했습니다.")

    # 폴더 내의 모든 파일 검색
    for filename in os.listdir(input_folder):
        if filename.lower().endswith('.wav'):
            # 전체 파일 경로 생성
            wav_path = os.path.join(input_folder, filename)
            # mp3 파일명 생성 (확장자만 변경)
            mp3_filename = os.path.splitext(filename)[0] + '.mp3'
            mp3_path = os.path.join(output_folder, mp3_filename)

            # 이미 변환된 파일이 있는지 확인
            if os.path.exists(mp3_path):
                print(f"건너뛰기: {mp3_filename} (이미 존재함)")
                continue

            try:
                # wav 파일 로드
                audio = AudioSegment.from_wav(wav_path)
                # mp3로 변환 및 저장
                audio.export(mp3_path, format='mp3')
                print(f"변환 완료: {filename} -> {mp3_filename}")
            except Exception as e:
                print(f"오류 발생 ({filename}): {str(e)}")

def main():
    target_folder = 'wav_files'  # 변환할 WAV 파일이 있는 폴더 경로
    convert_wav_to_mp3(target_folder)

if __name__ == "__main__":
    main() 