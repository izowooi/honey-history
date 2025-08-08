import argparse
from pathlib import Path
from typing import Optional
from pydub import AudioSegment


def convert_m4a_to_mp3(
    input_folder: str,
    output_folder: str = 'mp3_files',
    bitrate: str = '128k',
    mono: bool = True,
    sample_rate: Optional[int] = None,
    vbr_quality: Optional[int] = None,
    lowpass_hz: Optional[int] = None,
) -> None:
    """Convert all .m4a files in a folder to .mp3.

    - Creates the output folder if it does not exist
    - Skips conversion if the target .mp3 already exists
    - Optional size controls: mono downmix, resample, VBR, lowpass
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

            # Optional size-reduction processing
            if mono:
                audio = audio.set_channels(1)
            if sample_rate is not None:
                audio = audio.set_frame_rate(sample_rate)

            export_kwargs = {"format": "mp3"}
            parameters = []
            if vbr_quality is not None:
                # VBR using libmp3lame quality scale (0=best/largest ~ 9=smallest)
                parameters += ["-q:a", str(vbr_quality)]
            else:
                export_kwargs["bitrate"] = bitrate

            if lowpass_hz is not None:
                parameters += ["-af", f"lowpass=f={lowpass_hz}"]

            if parameters:
                export_kwargs["parameters"] = parameters

            audio.export(mp3_path, **export_kwargs)
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
    parser.add_argument('-b', '--bitrate', default='96k', help="CBR MP3 비트레이트 (예: 96k, 128k, 192k). VBR 사용 시 무시됩니다.")
    parser.add_argument('--stereo', action='store_true', help="스테레오 유지 (기본값: 모노)")
    parser.add_argument('--sample-rate', type=int, default=24000, help="샘플레이트 설정 (예: 44100, 32000, 24000, 22050). 낮출수록 용량 감소")
    parser.add_argument('--vbr', type=int, choices=range(0, 10), metavar='Q', help="VBR 품질(0=최고음질~9=최소용량). 지정 시 CBR 비트레이트 무시")
    parser.add_argument('--lowpass', type=int, help="저역통과 필터 컷오프 Hz (예: 8000). 고역 제거로 용량 절감")
    parser.add_argument('--very-small', action='store_true', help="최소 용량 프리셋 적용 (모노, 16kHz, VBR7, lowpass 8000Hz)")

    args = parser.parse_args()

    mono = not args.stereo
    sample_rate = args.sample_rate
    vbr_quality = args.vbr
    lowpass_hz = args.lowpass
    bitrate = args.bitrate

    if args.very_small:
        mono = True
        sample_rate = 16000 if sample_rate is None else min(sample_rate, 16000)
        vbr_quality = 7 if vbr_quality is None else max(vbr_quality, 7)
        if lowpass_hz is None:
            lowpass_hz = 8000
        # If user didn't request VBR, we still keep bitrate as fallback but VBR takes precedence in export

    convert_m4a_to_mp3(
        args.folder,
        args.output,
        bitrate,
        mono=mono,
        sample_rate=sample_rate,
        vbr_quality=vbr_quality,
        lowpass_hz=lowpass_hz,
    )


if __name__ == "__main__":
    main()
