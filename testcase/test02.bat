@echo off
set CURRENT_DIR=%cd%
cd %~dp0
cd ..
powershell -NoProfile -ExecutionPolicy Bypass -File ".\proc\ConvertCsv_1.ps1" ^
    -FilePath "���f�[�^\�T���v��02_sjis.csv" ^
    -ProjectName "�v���W�F�N�g�Q" ^
    -Encoding "Default" ^
    -HeaderLine 1 ^
    -DataStartLine 2 ^
    -Delimiter "," ^
    -OutputEncoding "Default"
cd /d "%CURRENT_DIR%"