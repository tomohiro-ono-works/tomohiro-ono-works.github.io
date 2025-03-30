@REM @echo off
set CURRENT_DIR=%cd%
cd ..
call proc\ControllerManagedCsv.bat ".\testcase\config2.json"
cd %CURRENT_DIR%