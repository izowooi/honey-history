import argparse
from pathlib import Path
from pydub import AudioSegment


def convert_m4a_to_mp3(input_folder: str, output_folder: str = 'mp3_files', bitrate: str = '192k') -> None:
    """Convert all .m4a files in a folder to .mp3.

    - Creates the output folder if it does not exist
    - Skips conversion if the target .mp3 already exists
    """
    input_path = Path(input_folder)
    if not input_path.exists():
        print(f"오류: '{input_path}' 폴더가 존재하지 않습니다.")
        return

    output_path = Path(output_folder)
    if not output_path.exists():
        output_path.mkdir(parents=True, exist_ok=True)
        print(f"'{output_path}' 폴더를 생성했습니다.")

    num_converted = 0
    num_skipped = 0
    num_failed = 0

    for entry in input_path.iterdir():
        if not entry.is_file() or entry.suffix.lower() != '.m4a':
            continue

        mp3_filename = f"{entry.stem}.mp3"
        mp3_path = output_path / mp3_filename

        if mp3_path.exists():
            print(f"건너뛰기: {mp3_filename} (이미 존재함)")
            num_skipped += 1
            continue

        try:
            audio = AudioSegment.from_file(entry, format='m4a')
            audio.export(mp3_path, format='mp3', bitrate=bitrate)
            print(f"변환 완료: {entry.name} -> {mp3_filename}")
            num_converted += 1
        except FileNotFoundError as e:
            # Likely ffmpeg is missing
            print("오류: ffmpeg 또는 avlib가 설치되어 있는지 확인해주세요.")
            print(str(e))
            return
        except Exception as e:
            print(f"오류 발생 ({entry.name}): {str(e)}")
            num_failed += 1

    if num_converted == 0 and num_skipped == 0:
        print("변환할 m4a 파일이 없습니다.")

    print(f"\n처리 요약 - 변환: {num_converted}개, 건너뜀: {num_skipped}개, 실패: {num_failed}개")
    print(f"출력 폴더: {output_path.resolve()}")


def main() -> None:
    parser = argparse.ArgumentParser(description="M4A 파일을 MP3로 변환합니다.")
    parser.add_argument('folder', nargs='?', default='m4a_files', help="변환할 M4A 파일이 있는 폴더 경로")
    parser.add_argument('-o', '--output', default='mp3_files', help="MP3 파일을 저장할 폴더 경로 (기본값: mp3_files)")
    parser.add_argument('-b', '--bitrate', default='192k', help="MP3 비트레이트 (예: 128k, 192k, 256k)")

    args = parser.parse_args()
    convert_m4a_to_mp3(args.folder, args.output, args.bitrate)


if __name__ == "__main__":
    main()
