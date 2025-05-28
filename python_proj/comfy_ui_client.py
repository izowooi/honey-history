import websocket
import json
import threading


class ComfyUIClient:
    def __init__(self, server_address="127.0.0.1:8188"):
        self.server_address = server_address
        self.ws = None
        self.prompt_id = None

    def connect_websocket(self):
        """WebSocket 연결"""
        self.ws = websocket.WebSocketApp(
            f"ws://{self.server_address}/ws",
            on_message=self.on_message,
            on_error=self.on_error,
            on_close=self.on_close
        )

        wst = threading.Thread(target=self.ws.run_forever)
        wst.daemon = True
        wst.start()

    def on_message(self, ws, message):
        """WebSocket 메시지 처리"""
        data = json.loads(message)
        if data['type'] == 'progress':
            value = data['data']['value']
            max_value = data['data']['max']
            print(f"진행률: {value}/{max_value}")
        elif data['type'] == 'executed':
            node = data['data']['node']
            print(f"노드 실행됨: {node}")

    def on_error(self, ws, error):
        print(f"에러 발생: {error}")

    def on_close(self, ws, close_status_code, close_msg):
        print("WebSocket 연결 종료")