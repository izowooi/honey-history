from abc import ABC, abstractmethod
import json

class WorkflowProcessor(ABC):
    """워크플로우 처리를 위한 추상 기본 클래스"""
    
    def __init__(self, workflow_file):
        self.workflow_file = workflow_file
        self.workflow_data = self._load_workflow()
    
    def _load_workflow(self):
        """워크플로우 파일 로드"""
        with open(self.workflow_file, 'r') as f:
            return json.load(f)
    
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


class WildcardAnimationWorkflowProcessor(WorkflowProcessor):
    """wildcard_animation.json 워크플로우 처리기"""
    
    def modify_prompt(self, prompt_data):
        # 이미지 파일 수정 (node 7)
        self.workflow_data["7"]["inputs"]["image"] = prompt_data["image"]
        # 긍정 프롬프트 수정 (node 5)
        self.workflow_data["5"]["inputs"]["prompt"] = prompt_data["positive_prompt"]
        # 부정 프롬프트 수정 (node 6)
        self.workflow_data["6"]["inputs"]["prompt"] = prompt_data["negative_prompt"]


class WorkflowProcessorFactory:
    """워크플로우 처리기 팩토리 클래스"""
    
    @staticmethod
    def create_processor(workflow_file):
        """워크플로우 파일에 맞는 처리기 생성"""
        if workflow_file == "test_01.json":
            return Test01WorkflowProcessor(workflow_file)
        elif workflow_file == "wildcard_animation.json":
            return WildcardAnimationWorkflowProcessor(workflow_file)
        else:
            raise ValueError(f"지원하지 않는 워크플로우 파일: {workflow_file}") 