@echo off
setlocal enabledelayedexpansion

REM Set download URLs
set PYTHON_URL=https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe
set VSCODE_URL=https://update.code.visualstudio.com/latest/win32-x64-user/stable

REM Set installer filenames
set PYTHON_INSTALLER=python312-installer.exe
set VSCODE_INSTALLER=VSCodeSetup.exe

echo [1/8] Checking for Python 3.12...
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python not found. Downloading Python 3.12 installer...
    powershell -Command "Invoke-WebRequest -Uri %PYTHON_URL% -OutFile %PYTHON_INSTALLER%"
    if exist %PYTHON_INSTALLER% (
        echo Installing Python 3.12...
        %PYTHON_INSTALLER% /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
        
        del %PYTHON_INSTALLER%
    ) else (
        echo Error: Failed to download Python installer.
        exit /b 1
    )
) else (
    python --version | findstr "3.12" >nul
    if %errorlevel% neq 0 (
        echo Python found, but not version 3.12. Downloading and installing Python 3.12...
        powershell -Command "Invoke-WebRequest -Uri %PYTHON_URL% -OutFile %PYTHON_INSTALLER%"
        if exist %PYTHON_INSTALLER% (
            %PYTHON_INSTALLER% /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
           
            del %PYTHON_INSTALLER%
        ) else (
            echo Error: Failed to download Python installer.
            exit /b 1
        )
    ) else (
        echo Python 3.12 is installed.
    )
)

echo [2/8] Checking for Visual Studio Code...
REM after installation VS code should not launch automatically, so we use /silent
where code >nul 2>nul
if %errorlevel% neq 0 (
    echo VS Code not found. Downloading VS Code installer...
    powershell -Command "Invoke-WebRequest -Uri %VSCODE_URL% -OutFile %VSCODE_INSTALLER%"
    if exist %VSCODE_INSTALLER% (
        echo Installing VS Code...
        REM /silent prevents VS Code from launching automatically after installation
        %VSCODE_INSTALLER% /silent /mergetasks=!runcode
        REM Add VS Code to PATH for current user
        set VSCODE_PATH="%LocalAppData%\Programs\Microsoft VS Code\bin"
        REM if exist "%VSCODE_PATH%\code.cmd" (
            REM set PATH="%PATH%;%VSCODE_PATH%"
            REM Install Jupyter extensions for VS Code
            echo Installing Jupyter extensions for VS Code...
            call %VSCODE_PATH%\code --install-extension ms-toolsai.jupyter  --install-extension ms-toolsai.jupyter-renderers  --force
            )
        del %VSCODE_INSTALLER%
    ) else (
        echo Error: Failed to download VS Code installer.
        exit /b 1
    )
) else (
    echo VS Code is installed.
)


echo [3/8] Refreshing PATH environment variable...
REM refresh path environment variable using PowerShell
REM This ensures that the newly installed Python and VS Code are recognized in the PATH.
powershell -Command "setx PATH $env:PATH; $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine')+';'+[System.Environment]::GetEnvironmentVariable('Path', 'User')"


echo PATH refreshed.

echo [4/8] Printing Python version...
python --version
if %errorlevel% neq 0 (
    echo Error: Unable to run Python.
    exit /b 1
)

echo [5/8] Creating virtual environment...
python -m venv venv
if %errorlevel% neq 0 (
    echo Error: Failed to create virtual environment.
    exit /b 1
)

echo [6/8] Activating virtual environment...
call venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo Error: Failed to activate virtual environment.
    exit /b 1
)

REM Ensure pip is up-to-date
echo Upgrading pip...
python -m pip install --upgrade pip

REM install langgraph
echo [7/8] Installing lang-graph...
pip install langgraph
if %errorlevel% neq 0 (
    echo Error: Failed to install lang-graph.
    exit /b 1
)

REM install jupyter notebook

echo [8/8] Installing jupyter notebook...
pip install jupyter notebook
if %errorlevel% neq 0 (
    echo Error: Failed to install jupyter notebook.
    exit /b 1
)

echo Setup completed successfully!
pause
endlocal
