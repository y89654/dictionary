@echo off
setlocal enabledelayedexpansion

set "input_file=dictionary.txt"
set "output_file=new_file.txt"

if not exist "%input_file%" (
    echo �ļ�������: %input_file%
    pause
    exit /b
)

(
    for /f "tokens=1" %%a in ('type "%input_file%"') do (
        echo %%a
    )
) > "%output_file%"

echo �ļ�������ɣ�
echo ԭ�ļ�: %input_file%
echo ���ļ�: %output_file%
pause