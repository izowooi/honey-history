import json
import urllib.request
import urllib.parse
import uuid
import websocket
import time
from workflow_processor import WorkflowProcessorFactory

# ComfyUI 서버 주소
server_address = "192.168.50.213:8188"


def queue_prompt(prompt):
    """프롬프트를 큐에 추가하고 prompt_id 반환"""
    p = {"prompt": prompt}
    try:
        # 기본 JSON 직렬화 시도
        data = json.dumps(p).encode('utf-8')
    except Exception as e:
        print(f"기본 JSON 직렬화 실패: {e}")
        # 대체 방법: 수동으로 JSON 문자열 생성
        prompt_str = json.dumps(prompt)
        data = f'{{"prompt":{prompt_str}}}'.encode('utf-8')
    
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


def generate_image(processor, prompt_data):
    """이미지 생성 메인 함수"""
    # 프롬프트 수정
    processor.modify_prompt(prompt_data)
    
    # 수정된 워크플로우로 이미지 생성
    prompt_id = queue_prompt(processor.get_workflow())['prompt_id']

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
    # prompts.json 파일 로드
    with open('prompts.json', 'r', encoding='utf-8') as f:
        prompts = json.load(f)

    # 워크플로우 처리기 생성
    workflow_file = "test_03.json"
    processor = WorkflowProcessorFactory.create_processor(workflow_file)

    # is_processed가 false인 항목만 처리
    for prompt in prompts:
        if not prompt['is_processed']:
            print(f"처리 중: {prompt['name']} (ID: {prompt['id']})")
            
            # 이미지 생성
            generated_images = generate_image(processor, prompt)

            # 이미지 저장 (ID를 파일명에 포함)
            for idx, image_data in enumerate(generated_images):
                output_filename = f"{prompt['id']}_{idx}.png"
                with open(output_filename, "wb") as f:
                    f.write(image_data)
                print(f"이미지 저장됨: {output_filename}")

            # 처리 완료 표시
            prompt['is_processed'] = True

    # 처리 상태 저장
    with open('prompts.json', 'w', encoding='utf-8') as f:
        json.dump(prompts, f, ensure_ascii=False, indent=4)