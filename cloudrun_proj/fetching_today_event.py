import os
from datetime import datetime
from supabase import create_client, Client

def fetch_today_event():
    """
    Supabase에서 오늘 날짜에 해당하는 이벤트를 가져와 출력합니다.
    """
    try:
        # 1. Supabase 접속 정보 설정
        # 실제 운영 환경에서는 환경 변수 등을 사용하는 것이 안전합니다.
        # 위에서 찾은 URL과 anon key를 아래에 붙여넣으세요.
        supabase_url = os.environ.get("SUPABASE_URL")
        supabase_key = os.environ.get("SUPABASE_ANON_KEY")

        # URL 또는 키가 입력되지 않았는지 확인
        if "YOUR_SUPABASE_URL" in supabase_url or "YOUR_SUPABASE_ANON_KEY" in supabase_key:
            print("🛑 오류: Supabase URL과 Key를 코드에 입력해주세요.")
            return

        # Supabase 클라이언트 생성
        supabase: Client = create_client(supabase_url, supabase_key)

        # 2. 오늘 날짜를 'MMDD' 형식으로 만들기 (예: '0820')
        today_str = datetime.now().strftime('%m%d')
        print(f"🔍 오늘 날짜 키: {today_str}")

        # 3. 데이터베이스에서 데이터 조회
        # 'daily_events' 테이블에서 'date_key'가 오늘 날짜와 일치하는 행을 찾습니다.
        response = supabase.from_('daily_events').select('title, body').execute()

        # 4. 결과 처리
        # response.data는 리스트 형태로 결과를 반환합니다. (예: [{'title': '...', 'body': '...'}])
        if response.data:
            event = response.data[0]
            print("\n--- 오늘의 역사 알림 ---")
            print(f"📌 제목: {event['title']}")
            print(f"💬 내용: {event['body']}")
            print("----------------------")
        else:
            print(f"\n✅ 오늘({today_str})에 해당하는 데이터가 없습니다.")

    except Exception as e:
        print(f"❌ 오류가 발생했습니다: {e}")

# 스크립트 실행
if __name__ == "__main__":
    fetch_today_event()
