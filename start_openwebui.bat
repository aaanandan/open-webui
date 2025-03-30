@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ===================================
echo 🚀 Starting OpenWebUI...
echo ===================================

:: Navigate to the extracted directory
cd /d %~dp0

:: Check if Conda is installed
where conda >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Conda not found! Please install Conda and try again.
    exit /b 1
)

:: Activate Conda environment
echo 🔹 Activating Conda environment...
call conda activate open-webui
if %errorlevel% neq 0 (
    echo ❌ Failed to activate Conda environment! Ensure it exists.
    exit /b 1
)

:: Start Backend
echo 🔹 Starting backend...
start cmd /k "cd backend && call start_windows.bat"

:: Start Frontend
@REM echo 🔹 Starting frontend...
@REM start cmd /k "cd frontend && npx serve -s"

echo ✅ OpenWebUI is now running! Open your browser and go to http://localhost:8080
