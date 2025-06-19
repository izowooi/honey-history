#!/usr/bin/env python3
"""
dotenv를 사용한 OPENAI_API_KEY 관리 예시
"""

import os
from dotenv import load_dotenv, set_key, get_key
from pathlib import Path

def create_env_file():
    """새로운 .env 파일 생성"""
    env_content = ""
    
    with open('.env', 'w', encoding='utf-8') as f:
        f.write(env_content)
    print("✅ .env 파일이 생성되었습니다.")

def load_environment_variables():
    """환경 변수 로드"""
    load_dotenv()
    print("✅ 환경 변수가 로드되었습니다.")

def get_api_key():
    """API 키 가져오기"""
    api_key = os.getenv('OPENAI_API_KEY')
    if api_key:
        # API 키 마스킹
        masked_key = api_key[:4] + '*' * (len(api_key) - 8) + api_key[-4:] if len(api_key) > 8 else '****'
        print(f"📌 OPENAI_API_KEY: {masked_key}")
        return api_key
    else:
        print("❌ OPENAI_API_KEY가 설정되지 않았습니다.")
        return None

def update_api_key(new_key):
    """API 키 업데이트"""
    try:
        set_key('.env', 'OPENAI_API_KEY', new_key)
        print("✅ OPENAI_API_KEY가 업데이트되었습니다.")
    except Exception as e:
        print(f"❌ API 키 업데이트 실패: {e}")

def example_usage():
    """실제 사용 예시"""
    print("\n🔧 실제 사용 예시:")
    print("-" * 30)
    
    # 환경 변수 로드
    load_dotenv()
    
    # API 키 가져오기
    api_key = os.getenv('OPENAI_API_KEY')
    if api_key:
        print(f"API 키 사용 가능: {api_key[:10]}...")
    else:
        print("API 키가 설정되지 않았습니다.")

def main():
    """메인 함수"""
    print("🚀 OpenAI API 키 관리")
    print("=" * 30)
    
    # .env 파일이 없으면 생성
    if not Path('.env').exists():
        print("📝 .env 파일이 없습니다. 새로 생성합니다...")
        create_env_file()
    
    # 환경 변수 로드
    load_environment_variables()

    #set_key('.env', 'OPENAI_API_KEY', 'sk-xxxxxxxxxxx')  # 예시 키, 실제 키로 교체 필요
    
    # API 키 조회
    print("\n🔍 API 키 조회:")
    get_api_key()
    
    # 실제 사용 예시
    example_usage()
    
    print("\n💡 사용 팁:")
    print("- .env 파일은 .gitignore에 추가하여 Git에 커밋하지 마세요")
    print("- 실제 API 키로 .env 파일을 수정한 후 사용하세요")

if __name__ == "__main__":
    main() 