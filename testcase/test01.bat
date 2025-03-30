@REM @echo off
set CURRENT_DIR=%cd%
echo %CURRENT_DIR%
cd ..
call proc\ControllerManagedCsv.bat ".\testcase\config2.json"
echo %CURRENT_DIR%
cd %CURRENT_DIR%