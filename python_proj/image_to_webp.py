#!/usr/bin/env python3
"""
이미지 파일을 WebP 형식으로 변환하는 스크립트
jpg, jpeg, png 파일을 webp로 변환하여 image_output 폴더에 저장
"""

import os
import sys
import argparse
from pathlib import Path
from PIL import Image
import concurrent.futures
from tqdm import tqdm


def convert_to_webp(input_path, output_path, quality=85):
    """
    이미지를 WebP 형식으로 변환

    Args:
        input_path: 입력 이미지 경로
        output_path: 출력 이미지 경로
        quality: WebP 품질 (1-100, 기본값 85)
    """
    try:
        # 이미지 열기
        with Image.open(input_path) as img:
            # RGBA 모드가 아닌 경우 RGB로 변환
            if img.mode not in ('RGB', 'RGBA'):
                img = img.convert('RGB')

            # WebP로 저장
            img.save(output_path, 'WEBP', quality=quality, method=6)

        return True, f"변환 완료: {input_path.name} → {output_path.name}"
    except Exception as e:
        return False, f"변환 실패: {input_path.name} - {str(e)}"


def process_images(folder_path, quality=85, max_workers=4):
    """
    폴더 내의 모든 이미지를 WebP로 변환

    Args:
        folder_path: 처리할 폴더 경로
        quality: WebP 품질 (1-100)
        max_workers: 동시 처리할 작업자 수
    """
    # Path 객체로 변환
    folder_path = Path(folder_path)

    # 폴더 존재 여부 확인
    if not folder_path.exists():
        print(f"오류: '{folder_path}' 폴더를 찾을 수 없습니다.")
        sys.exit(1)

    if not folder_path.is_dir():
        print(f"오류: '{folder_path}'는 폴더가 아닙니다.")
        sys.exit(1)

    # 출력 폴더 생성
    output_folder = folder_path / "image_output"
    output_folder.mkdir(exist_ok=True)

    # 지원하는 확장자 (대소문자 구분 없음)
    extensions = {'.jpg', '.jpeg', '.png', '.JPG', '.JPEG', '.PNG'}

    # 변환할 이미지 파일 찾기
    image_files = [f for f in folder_path.iterdir()
                   if f.is_file() and f.suffix in extensions]

    if not image_files:
        print("변환할 이미지 파일이 없습니다.")
        return

    print(f"\n{len(image_files)}개의 이미지 파일을 찾았습니다.")
    print(f"출력 폴더: {output_folder}")
    print(f"WebP 품질: {quality}%\n")

    # 성공/실패 카운터
    success_count = 0
    fail_count = 0

    # 멀티스레딩으로 변환 처리
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        # 작업 생성
        futures = []
        for img_file in image_files:
            # 출력 파일명 생성 (확장자를 .webp로 변경)
            output_file = output_folder / f"{img_file.stem}.webp"
            future = executor.submit(convert_to_webp, img_file, output_file, quality)
            futures.append(future)

        # 진행 상황 표시
        with tqdm(total=len(futures), desc="변환 진행") as pbar:
            for future in concurrent.futures.as_completed(futures):
                success, message = future.result()
                if success:
                    success_count += 1
                else:
                    fail_count += 1
                    print(f"\n{message}")
                pbar.update(1)

    # 결과 출력
    print(f"\n변환 완료!")
    print(f"성공: {success_count}개")
    if fail_count > 0:
        print(f"실패: {fail_count}개")
    print(f"출력 폴더: {output_folder}")


def main():
    """메인 함수"""
    parser = argparse.ArgumentParser(
        description="JPG, JPEG, PNG 이미지를 WebP로 변환합니다."
    )
    parser.add_argument(
        'folder',
        default='image_files',
        nargs='?',
        help="변환할 이미지가 있는 폴더 경로"
    )
    parser.add_argument(
        "-q", "--quality",
        type=int,
        default=85,
        help="WebP 품질 (1-100, 기본값: 85)"
    )
    parser.add_argument(
        "-w", "--workers",
        type=int,
        default=4,
        help="동시 처리 작업자 수 (기본값: 4)"
    )

    args = parser.parse_args()

    # 품질 값 검증
    if not 1 <= args.quality <= 100:
        print("오류: 품질은 1-100 사이의 값이어야 합니다.")
        sys.exit(1)

    # 이미지 처리 실행
    process_images(args.folder, args.quality, args.workers)


if __name__ == "__main__":
    main()