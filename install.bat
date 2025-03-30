@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ===================================
echo 🔍 Checking system requirements...
echo ===================================

:: Set minimum requirements
set MIN_RAM=8
set MIN_CPU_CORES=4
set MIN_DISK=20

echo System Requirements:
echo ===================================
echo  MIN_RAM: %MIN_RAM% GB
echo  MIN_CPU_CORES: %MIN_CPU_CORES%
echo  MIN_DISK: %MIN_DISK% GB
echo  8000 ports must be free
echo ===================================


:: Extract the package
if exist "openwebui.zip" (
    echo 🔹 Extracting openwebui.zip...
    powershell Expand-Archive -Path openwebui.zip -DestinationPath . -Force
) else (
    echo ❌ No package found. Please ensure openwebui.zip is present.
    exit /b 1
)
echo ✅ Extraction complete!

:: Navigate to extracted folder
cd openwebui-bundle

:: Check if Ollama is installed
where ollama >nul 2>nul
if %errorlevel% neq 0 (
    echo 🔹 Installing Ollama...
    powershell Invoke-WebRequest -Uri https://ollama.com/install.exe -OutFile ollama_installer.exe
    start /wait ollama_installer.exe /silent
    del ollama_installer.exe
) else (
    echo ✅ Ollama is already installed!
)

:: Check if DeepSeek model is installed
for /f %%A in ('ollama list') do (
    if "%%A"=="deepseek-r1:1.5b" (
        echo ✅ DeepSeek model is already installed!
        goto skip_deepseek
    )
)
echo 🔹 Pulling DeepSeek model...
ollama run deepseek-r1:1.5b
:skip_deepseek

:: Check & Install Conda if missing
where conda >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Conda not found. Installing Miniconda...
    powershell Invoke-WebRequest -Uri "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe" -OutFile miniconda_installer.exe
    start /wait miniconda_installer.exe /S /D=C:\Miniconda3
    del miniconda_installer.exe
    set PATH=%PATH%;C:\Miniconda3\Scripts;C:\Miniconda3
)

:: Create & activate Conda environment
call conda create --name open-webui python=3.11 -y
call conda activate open-webui

:: Install backend dependencies
echo Installing backend dependencies...
pip install -r backend\requirements.txt

echo ✅ Installation complete!
echo 🚀 You can now start the application by running: "cd openwebui-bundle && start_openwebui.bat"
