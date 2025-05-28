import json
import urllib.request
import urllib.parse
import uuid
import websocket
import time

# ComfyUI 서버 주소
server_address = "192.168.50.213:8188"


def queue_prompt(prompt):
    """프롬프트를 큐에 추가하고 prompt_id 반환"""
    p = {"prompt": prompt}
    data = json.dumps(p).encode('utf-8')
    req = urllib.request.Request(f"http://{server_address}/prompt", data=data)
    return json.loads(urllib.request.urlopen(req).read())


def get_image(filename, subfolder, folder_type):
    """생성된 이미지 다운로드"""
    data = {"filename": filename, "subfolder": subfolder, "type": folder_type}
    url_values = urllib.parse.urlencode(data)
    with urllib.request.urlopen(f"http://{server_address}/view?{url_values}") as response:
        return response.read()


def get_history(prompt_id):
    """실행 히스토리 가져오기"""
    with urllib.request.urlopen(f"http://{server_address}/history/{prompt_id}") as response:
        return json.loads(response.read())


def generate_image(workflow_json):
    """이미지 생성 메인 함수"""
    # JSON 파일 로드
    with open(workflow_json, 'r') as f:
        prompt = json.load(f)

    # 필요시 프롬프트 수정
    # 예: prompt["6"]["inputs"]["text"] = "새로운 프롬프트"

    # 프롬프트 실행
    prompt_id = queue_prompt(prompt)['prompt_id']

    # 완료 대기
    while True:
        history = get_history(prompt_id)
        if prompt_id in history:
            break
        time.sleep(1)

    # 이미지 정보 추출
    outputs = history[prompt_id]['outputs']
    images = []

    for node_id in outputs:
        node_output = outputs[node_id]
        if 'images' in node_output:
            for image in node_output['images']:
                image_data = get_image(
                    image['filename'],
                    image['subfolder'],
                    image['type']
                )
                images.append(image_data)

    return images


# 사용 예시
if __name__ == "__main__":
    # Export한 workflow JSON 파일 경로
    workflow_file = "Lesson2.json"

    # 이미지 생성
    generated_images = generate_image(workflow_file)

    # 이미지 저장
    for idx, image_data in enumerate(generated_images):
        with open(f"output_{idx}.png", "wb") as f:
            f.write(image_data)
        print(f"이미지 저장됨: output_{idx}.png")