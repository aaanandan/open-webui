@echo off
:: Set default port if not provided
if not defined PORT set "PORT=8080"

:: Set CORS allowed origins
set "CORS_ALLOW_ORIGIN=http://localhost:5173;http://localhost:8080"

:: Run uvicorn with specified settings
uvicorn open_webui.main:app --port %PORT% --host 0.0.0.0 --forwarded-allow-ips=* --reload
