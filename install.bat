@echo off
setlocal enabledelayedexpansion

:: Colors for output
set RED=[91m
set GREEN=[92m
set YELLOW=[93m
set NC=[0m

:: Function to print colored messages
:print_message
echo %~1
exit /b

:: Function to check if a command exists
:check_command
where %~1 >nul 2>nul
if %errorlevel% neq 0 (
    echo %RED%Error: %~1 is not installed%NC%
    exit /b 1
)
exit /b 0

:: Function to check system requirements
:check_system_requirements
echo %YELLOW%Checking system requirements...%NC%

:: Check Python version
python --version >nul 2>nul
if %errorlevel% neq 0 (
    echo %RED%Error: Python is not installed%NC%
    exit /b 1
)

:: Check pip
pip --version >nul 2>nul
if %errorlevel% neq 0 (
    echo %RED%Error: pip is not installed%NC%
    exit /b 1
)

echo %GREEN%System requirements check completed%NC%
exit /b 0

:: Function to create virtual environment
:create_virtual_env
echo %YELLOW%Creating virtual environment...%NC%

if not exist venv (
    python -m venv venv
    call venv\Scripts\activate.bat
) else (
    call venv\Scripts\activate.bat
)

echo %GREEN%Virtual environment created and activated%NC%
exit /b 0

:: Function to install Python dependencies
:install_python_dependencies
echo %YELLOW%Installing Python dependencies...%NC%

python -m pip install --upgrade pip
pip install fastapi uvicorn detoxify transformers torch opencv-python-headless

echo %GREEN%Python dependencies installed%NC%
exit /b 0

:: Function to create necessary directories
:create_directories
echo %YELLOW%Creating necessary directories...%NC%

if not exist data\pipelines mkdir data\pipelines
if not exist data\cache mkdir data\cache

echo %GREEN%Directories created%NC%
exit /b 0

:: Function to create configuration file
:create_config
echo %YELLOW%Creating configuration file...%NC%

(
echo import os
echo.
echo # Base paths
echo BASE_DIR = os.path.dirname^(os.path.abspath^(__file__^)^)
echo DATA_DIR = os.path.join^(BASE_DIR, "data"^)
echo.
echo # Pipeline settings
echo PIPELINES_DIR = os.path.join^(DATA_DIR, "pipelines"^)
echo CACHE_DIR = os.path.join^(DATA_DIR, "cache"^)
echo.
echo # Server settings
echo HOST = "0.0.0.0"
echo PORT = 9099
echo.
echo # Model settings
echo MODEL_CACHE_DIR = os.path.join^(CACHE_DIR, "models"^)
) > config.py

echo %GREEN%Configuration file created%NC%
exit /b 0

:: Function to create main application file
:create_main_app
echo %YELLOW%Creating main application file...%NC%

(
echo from fastapi import FastAPI
echo from fastapi.middleware.cors import CORSMiddleware
echo import uvicorn
echo.
echo app = FastAPI^(^)
echo.
echo # Configure CORS
echo app.add_middleware^(
echo     CORSMiddleware,
echo     allow_origins=["*"],
echo     allow_credentials=True,
echo     allow_methods=["*"],
echo     allow_headers=["*"],
echo ^)
echo.
echo @app.get^("/"^)
echo async def root^(^):
echo     return {"message": "Pipeline service is running"}
echo.
echo @app.get^("/health"^)
echo async def health_check^(^):
echo     return {"status": True}
echo.
echo if __name__ == "__main__":
echo     uvicorn.run^(app, host="0.0.0.0", port=9099^)
) > main.py

echo %GREEN%Main application file created%NC%
exit /b 0

:: Function to create startup script
:create_startup_script
echo %YELLOW%Creating startup script...%NC%

(
echo @echo off
echo call venv\Scripts\activate.bat
echo python main.py
) > start.bat

echo %GREEN%Startup script created%NC%
exit /b 0

:: Main installation process
:main
echo %YELLOW%Starting installation process...%NC%

call :check_system_requirements
if %errorlevel% neq 0 exit /b 1

call :create_virtual_env
if %errorlevel% neq 0 exit /b 1

call :install_python_dependencies
if %errorlevel% neq 0 exit /b 1

call :create_directories
if %errorlevel% neq 0 exit /b 1

call :create_config
if %errorlevel% neq 0 exit /b 1

call :create_main_app
if %errorlevel% neq 0 exit /b 1

call :create_startup_script
if %errorlevel% neq 0 exit /b 1

echo %GREEN%Installation completed successfully!%NC%
echo %YELLOW%To start the service, run: start.bat%NC%
exit /b 0

:: Run main function
call :main 