@echo off
setlocal enabledelayedexpansion

:start
set /p "range=请输入数字区间（格式：开始-结束，例如：1-60）: "

:: 提取开始和结束数字
for /f "tokens=1,2 delims=-" %%a in ("!range!") do (
    set start=%%a
    set end=%%b
)

:: 检查是否成功提取
if "!start!"=="" (
    echo 输入格式错误！请使用"开始-结束"的格式
    goto start
)

if "!end!"=="" (
    echo 输入格式错误！请使用"开始-结束"的格式
    goto start
)

:: 验证数字有效性
if !start! gtr !end! (
    echo 错误：开始数字不能大于结束数字！
    goto start
)

echo.
echo 输出结果：
echo.

:: 循环输出数字
for /l %%i in (!start!,1,!end!) do (
    echo %%i
)

echo.
set /a count=end-start+1
echo 输出完成！共输出了 !count! 个数字。
pause