from abc import ABC, abstractmethod
import json
import requests
import os

class WorkflowProcessor(ABC):
    """워크플로우 처리를 위한 추상 기본 클래스"""
    
    def __init__(self, workflow_file, comfyui_url="http://192.168.50.213:8188"):
        self.workflow_file = workflow_file
        self.comfyui_url = comfyui_url
        self.workflow_data = self._load_workflow()
    
    def _load_workflow(self):
        """워크플로우 파일 로드"""
        with open(self.workflow_file, 'r') as f:
            return json.load(f)
    
    def upload_image(self, image_path):
        """이미지를 ComfyUI 서버에 업로드"""
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"이미지 파일을 찾을 수 없습니다: {image_path}")
            
        url = f"{self.comfyui_url}/upload/image"
        
        with open(image_path, 'rb') as f:
            # 파일명에 2d 폴더 경로 추가
            filename = os.path.basename(image_path)
            files = {
                'image': (f"2d/{filename}", f, 'image/png'),
                'overwrite': (None, 'true')
            }
            
            response = requests.post(url, files=files)
            
            if response.status_code == 200:
                result = response.json()
                return result['name']  # 업로드된 파일명 반환
            else:
                raise Exception(f"이미지 업로드 실패: {response.status_code}")
    
    @abstractmethod
    def modify_prompt(self, prompt_data):
        """프롬프트 데이터를 워크플로우에 맞게 수정"""
        pass
    
    def get_workflow(self):
        """수정된 워크플로우 반환"""
        return self.workflow_data


class Test01WorkflowProcessor(WorkflowProcessor):
    """test_01.json 워크플로우 처리기"""

    def modify_prompt(self, prompt_data):
        # 긍정 프롬프트 수정 (node 6)
        self.workflow_data["6"]["inputs"]["text"] = prompt_data["positive_prompt"]
        # 부정 프롬프트 수정 (node 3)
        self.workflow_data["3"]["inputs"]["text"] = prompt_data["negative_prompt"]


class Test02WorkflowProcessor(WorkflowProcessor):
    """test_02.json 워크플로우 처리기"""
    
    def modify_prompt(self, prompt_data):
        # 이미지 파일 업로드 및 수정 (node 17)
        if "image" in prompt_data:
            uploaded_filename = self.upload_image(prompt_data["image"])
            self.workflow_data["17"]["inputs"]["image"] = uploaded_filename
        
        # 긍정 프롬프트 수정 (node 15)
        self.workflow_data["15"]["inputs"]["prompt"] = prompt_data["positive_prompt"]
        
        # 부정 프롬프트 수정 (node 16)
        self.workflow_data["16"]["inputs"]["text"] = prompt_data["negative_prompt"]


class WildcardAnimationWorkflowProcessor(WorkflowProcessor):
    """wildcard_animation.json 워크플로우 처리기"""
    
    def modify_prompt(self, prompt_data):
        # 이미지 파일 업로드 및 수정 (node 7)
        if "image" in prompt_data:
            uploaded_filename = self.upload_image(prompt_data["image"])
            self.workflow_data["7"]["inputs"]["image"] = uploaded_filename
            
        # 긍정 프롬프트 수정 (node 5)
        self.workflow_data["5"]["inputs"]["prompt"] = prompt_data["positive_prompt"]
        # 부정 프롬프트 수정 (node 6)
        self.workflow_data["6"]["inputs"]["prompt"] = prompt_data["negative_prompt"]


class WorkflowProcessorFactory:
    """워크플로우 처리기 팩토리 클래스"""
    
    @staticmethod
    def create_processor(workflow_file, comfyui_url="http://192.168.50.213:8188"):
        """워크플로우 파일에 맞는 처리기 생성"""
        if workflow_file == "test_01.json":
            return Test01WorkflowProcessor(workflow_file, comfyui_url)
        if workflow_file == "test_02.json":
            return Test02WorkflowProcessor(workflow_file, comfyui_url)
        elif workflow_file == "wildcard_animation.json":
            return WildcardAnimationWorkflowProcessor(workflow_file, comfyui_url)
        else:
            raise ValueError(f"지원하지 않는 워크플로우 파일: {workflow_file}") 