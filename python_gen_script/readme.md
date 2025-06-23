

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