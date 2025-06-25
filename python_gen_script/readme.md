
# 작업 순서

1. **시트 데이터 생성**: 구글 스프레드 시트에서 json 으로 변환하여 받습니다.
2. **배치 데이터 생성**: `batch_file_generator.py`를 실행하여 json 파일로부터 배치 요청 파일을 생성합니다.
    - `batch_file_generator.py`는 `--data-file` 옵션을 사용하여 1에서 생성한 json 파일을 인자로 받습니다.
    - `batch_file_generator.py`는 `--model` 옵션을 사용하여 모델별로 배치 요청 파일을 생성합니다.
    - 예시: `python3 batch_file_generator.py --model o4-mini-2025-04-16`
    - 여러 모델에 대해 반복 실행할 수 있습니다. ( [models](https://platform.openai.com/docs/models) [playground](https://platform.openai.com/playground/prompts) 참조 )
3. **배치 실행**: `batch_runner.py`를 실행하여 배치 요청을 실행합니다.
    - 콘솔 로그에서 배치 요청 ID를 확인할 수 있습니다.
    - [batches](https://platform.openai.com/batches) 페이지에서 배치 요청의 상태를 확인할 수 있습니다.
4. **배치 상태 확인**: `batch_status_checker.py`를 실행하여 배치 요청의 상태를 확인합니다.
    - `--batch-id` 옵션에 위에서 얻은 배치 요청 ID를 인자로 넣어 api 결과를 json 형태로 받습니다.
    - 결과는 `out` 디렉토리에 `processed_results_batch_<배치 ID>.json` 파일로 저장됩니다.
5. **구글 시트에 결과 업로드**: `sheet_uploader.py`를 실행하여 구글 시트에 결과를 업로드합니다.
    - `--json-file` 옵션에 4에서 생성한 json 파일을 인자로 넣어 실행합니다.

# 젠킨스

## 배치 요청

```shell
#!/bin/bash

PYTHON_PROJ=$WORKSPACE/python_gen_script
PYTHON_PATH="/opt/homebrew/Cellar/python@3.11/3.11.13/bin/python3.11"

# Python 버전 확인
echo "Using Python: $PYTHON_PATH"
$PYTHON_PATH --version

echo "PYTHON_PROJ: $PYTHON_PROJ"
cd $PYTHON_PROJ

# 가상환경 생성 (없을 경우에만)
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    $PYTHON_PATH -m venv venv
fi

source venv/bin/activate

# pip 업그레이드
# pip install --upgrade pip

# requirements.txt 설치
# pip install -r requirements.txt

MODEL_O3=o3-2025-04-26
python3 batch_file_generator.py --model o4-mini-2025-04-16
python3 batch_file_generator.py --model gpt-4.1-mini-2025-04-14
python3 batch_file_generator.py --model $MODEL_O3

python3 batch_runner.py

deactivate
```

## 요청 다운로드

```shell
#!/bin/bash

PYTHON_PROJ=$WORKSPACE/python_gen_script
PYTHON_PATH="/opt/homebrew/Cellar/python@3.11/3.11.13/bin/python3.11"

# Python 버전 확인
echo "Using Python: $PYTHON_PATH"
$PYTHON_PATH --version

echo "PYTHON_PROJ: $PYTHON_PROJ"
cd $PYTHON_PROJ

# 가상환경 생성 (없을 경우에만)
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    $PYTHON_PATH -m venv venv
fi

source venv/bin/activate

# pip 업그레이드
# pip install --upgrade pip

# requirements.txt 설치
# pip install -r requirements.txt

python3 batch_status_checker.py --batch-id batch_6859db897e448190840824bb65e476f4
python3 batch_status_checker.py --batch-id batch_6859dd027fc48190b94a461a0a85024e
python3 batch_status_checker.py --batch-id batch_6859dd34096081909d12971f73566bab

deactivate
```