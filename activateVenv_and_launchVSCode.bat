
@echo off
REM Activate the virtual environment
call venv\Scripts\activate.bat


REM Set environment variables for VS Code
set VIRTUAL_ENV=%CD%\venv
set PYTHONPATH=%CD%\venv\Lib\site-packages
set PATH=%VIRTUAL_ENV%\Scripts;%PATH%



REM Launch VS Code from the activated venv prompt

set VSCODE_PATH="%LocalAppData%\Programs\Microsoft VS Code\bin"
        if exist "%VSCODE_PATH%\code.cmd" (
            set PATH=%PATH%;%VSCODE_PATH%
        )

code .

pause
