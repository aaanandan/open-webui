@echo off
@REM yarn install --ignore-engines
@REM yarn build

echo Creating deployment package...
mkdir openwebui-bundle\build
mkdir openwebui-bundle\backend

:: Copy backend & frontend
xcopy /E /I backend openwebui-bundle\backend
xcopy /E /I build openwebui-bundle\build

:: Copy database and scripts if available
if exist CHANGELOG.md copy CHANGELOG.md openwebui-bundle\backend\open_webui\
if exist start_openwebui.bat copy start_openwebui.bat openwebui-bundle\
if exist install.bat copy install.bat openwebui-bundle\

powershell Compress-Archive -Path openwebui-bundle -DestinationPath openwebui.zip -Force
echo Build complete! "Extract and install using: unzip openwebui.zip && cd openwebui-bundle && install.bat"
