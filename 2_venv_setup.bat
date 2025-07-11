@echo off
echo [1/4] Creating virtual environment...
python -m venv venv
if %errorlevel% neq 0 (
    echo Error: Failed to create virtual environment.
    exit /b 1
)

echo [2/4] Activating virtual environment...
call venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo Error: Failed to activate virtual environment.
    exit /b 1
)

REM Ensure pip is up-to-date
echo Upgrading pip...
python -m pip install --upgrade pip

REM install langgraph
echo [3/4] Installing lang-graph...
pip install langgraph
if %errorlevel% neq 0 (
    echo Error: Failed to install lang-graph.
)

REM install jupyter notebook

echo [4/4] Installing jupyter notebook...
pip install jupyter notebook
if %errorlevel% neq 0 (
    echo Error: Failed to install jupyter notebook.
)

echo Virtual environment setup complete.