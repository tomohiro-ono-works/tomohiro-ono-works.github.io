@echo off
set CURRENT_DIR=%cd%
cd %~dp0
cd ..
powershell -NoProfile -ExecutionPolicy Bypass -File ".\proc\ConvertCsv_1.ps1" ^
    -FilePath "元データ\サンプル02_sjis.csv" ^
    -ProjectName "プロジェクト２" ^
    -Encoding "Default" ^
    -HeaderLine 1 ^
    -DataStartLine 2 ^
    -Delimiter "," ^
    -OutputEncoding "Default"
cd /d "%CURRENT_DIR%"