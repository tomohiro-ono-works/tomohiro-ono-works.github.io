@echo off
cd %~dp0
cd ..
set ROOT_DIR=%cd%
set CONFIG_PATH=%1
powershell -NoProfile -ExecutionPolicy Bypass -File ".\proc\ControllerManagedCsv.ps1" ^
    -ConfigPath %CONFIG_PATH%
cd /d "%ROOT_DIR%"
