@echo off
setlocal enabledelayedexpansion

:start
set /p "range=�������������䣨��ʽ����ʼ-���������磺1-60��: "

:: ��ȡ��ʼ�ͽ�������
for /f "tokens=1,2 delims=-" %%a in ("!range!") do (
    set start=%%a
    set end=%%b
)

:: ����Ƿ�ɹ���ȡ
if "!start!"=="" (
    echo �����ʽ������ʹ��"��ʼ-����"�ĸ�ʽ
    goto start
)

if "!end!"=="" (
    echo �����ʽ������ʹ��"��ʼ-����"�ĸ�ʽ
    goto start
)

:: ��֤������Ч��
if !start! gtr !end! (
    echo ���󣺿�ʼ���ֲ��ܴ��ڽ������֣�
    goto start
)

echo.
echo ��������
echo.

:: ѭ���������
for /l %%i in (!start!,1,!end!) do (
    echo %%i
)

echo.
set /a count=end-start+1
echo �����ɣ�������� !count! �����֡�
pause