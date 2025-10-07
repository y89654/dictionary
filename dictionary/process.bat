@echo off
setlocal enabledelayedexpansion

set "input_file=dictionary.txt"
set "output_file=new_file.txt"

if not exist "%input_file%" (
    echo 文件不存在: %input_file%
    pause
    exit /b
)

(
    for /f "tokens=1" %%a in ('type "%input_file%"') do (
        echo %%a
    )
) > "%output_file%"

echo 文件处理完成！
echo 原文件: %input_file%
echo 新文件: %output_file%
pause