@echo off
setlocal enabledelayedexpansion

REM Set download URLs
set PYTHON_URL=https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe
set VSCODE_URL=https://update.code.visualstudio.com/latest/win32-x64-user/stable

REM Set installer filenames
set PYTHON_INSTALLER=python312-installer.exe
set VSCODE_INSTALLER=VSCodeSetup.exe

echo [1/3] Checking for Python 3.12...
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
        )
    ) else (
        echo Python 3.12 is installed.
    )
)

echo [2/3] Checking for Visual Studio Code...
REM after installation VS code should not launch automatically, so we use /silent
where code >nul 2>nul
if %errorlevel% neq 0 (
    echo VS Code not found. Downloading VS Code installer...
    powershell -Command "Invoke-WebRequest -Uri %VSCODE_URL% -OutFile %VSCODE_INSTALLER%"
    if exist %VSCODE_INSTALLER% (
        echo Installing VS Code...
        REM /silent prevents VS Code from launching automatically after installation
        %VSCODE_INSTALLER% /silent /mergetasks=!runcode
            REM Install Jupyter extensions for VS Code
            echo Installing Jupyter extensions for VS Code...
            call "%LocalAppData%\Programs\Microsoft VS Code\bin\code" --install-extension ms-toolsai.jupyter  --install-extension ms-toolsai.jupyter-renderers  --force
            )
        del %VSCODE_INSTALLER%
    ) else (
        echo Error: Failed to download VS Code installer.
    )
) else (
    echo VS Code is installed.
)


echo [3/3] Refreshing PATH environment variable...
REM refresh path environment variable using PowerShell
REM This ensures that the newly installed Python and VS Code are recognized in the PATH.
powershell -Command "set PATH $env:PATH; $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine')+';'+[System.Environment]::GetEnvironmentVariable('Path', 'User')"


echo PATH refreshed.

echo  Printing Python version...
python --version
if %errorlevel% neq 0 (
    echo Error: Unable to run Python.
)
echo Setup completed successfully!
pause
endlocal
