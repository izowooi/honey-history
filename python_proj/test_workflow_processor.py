import unittest
import os
import json
from unittest.mock import patch, mock_open, MagicMock
from workflow_processor import WorkflowProcessor, Test02WorkflowProcessor

class TestWorkflowProcessor(unittest.TestCase):
    """WorkflowProcessor 클래스 테스트"""
    
    def setUp(self):
        """테스트 전 설정"""
        # 테스트용 워크플로우 JSON 데이터
        self.test_workflow = {
            "17": {
                "inputs": {
                    "image": "test_image.png"
                }
            }
        }
        
        # 테스트용 이미지 파일 생성
        self.test_image_path = "2d/base_img.png"
        if not os.path.exists(self.test_image_path):
            with open(self.test_image_path, "wb") as f:
                f.write(b"test image data")
    
    def tearDown(self):
        """테스트 후 정리"""
        # 테스트용 이미지 파일 삭제
        if os.path.exists(self.test_image_path):
            os.remove(self.test_image_path)
    
    @patch('builtins.open', new_callable=mock_open, read_data=json.dumps({"test": "data"}))
    def test_load_workflow(self, mock_file):
        """워크플로우 파일 로드 테스트"""
        processor = Test02WorkflowProcessor("test_workflow.json")
        mock_file.assert_called_once_with("test_workflow.json", 'r')
    
    def test_upload_image_success(self):
        """이미지 업로드 성공 테스트"""
        # 실제 ComfyUI 서버로 테스트 실행
        processor = Test02WorkflowProcessor("test_workflow.json", "http://192.168.50.213:8188")
        result = processor.upload_image(self.test_image_path)
        
        # 검증
        self.assertIsNotNone(result)
        self.assertTrue(isinstance(result, str))
        self.assertTrue(len(result) > 0)
    
    @patch('requests.post')
    def test_upload_image_failure(self, mock_post):
        """이미지 업로드 실패 테스트"""
        # Mock 응답 설정
        mock_response = MagicMock()
        mock_response.status_code = 500
        mock_post.return_value = mock_response
        
        # 테스트 실행
        processor = Test02WorkflowProcessor("test_workflow.json")
        
        # 예외 발생 확인
        with self.assertRaises(Exception) as context:
            processor.upload_image(self.test_image_path)
        
        self.assertIn("이미지 업로드 실패", str(context.exception))
    
    def test_upload_image_file_not_found(self):
        """존재하지 않는 이미지 파일 업로드 테스트"""
        processor = Test02WorkflowProcessor("test_workflow.json")
        
        with self.assertRaises(FileNotFoundError) as context:
            processor.upload_image("nonexistent_image.png")
        
        self.assertIn("이미지 파일을 찾을 수 없습니다", str(context.exception))
    
    @patch('workflow_processor.WorkflowProcessor.upload_image')
    def test_modify_prompt_with_image(self, mock_upload):
        """이미지가 포함된 프롬프트 수정 테스트"""
        # Mock 설정
        mock_upload.return_value = "uploaded_image.png"
        
        # 테스트 데이터
        prompt_data = {
            "image": self.test_image_path,
            "positive_prompt": "test positive prompt",
            "negative_prompt": "test negative prompt"
        }
        
        # 테스트 실행
        processor = Test02WorkflowProcessor("test_workflow.json")
        processor.workflow_data = self.test_workflow
        processor.modify_prompt(prompt_data)
        
        # 검증
        self.assertEqual(processor.workflow_data["17"]["inputs"]["image"], "uploaded_image.png")
        mock_upload.assert_called_once_with(self.test_image_path)
    
    def test_modify_prompt_without_image(self):
        """이미지가 없는 프롬프트 수정 테스트"""
        # 테스트 데이터
        prompt_data = {
            "positive_prompt": "test positive prompt",
            "negative_prompt": "test negative prompt"
        }
        
        # 테스트 실행
        processor = Test02WorkflowProcessor("test_workflow.json")
        processor.workflow_data = self.test_workflow
        processor.modify_prompt(prompt_data)
        
        # 검증
        self.assertEqual(processor.workflow_data["17"]["inputs"]["image"], "test_image.png")


if __name__ == '__main__':
    unittest.main() 