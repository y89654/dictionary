@echo off
setlocal enabledelayedexpansion

title 字典查询工具
color 0A

:: 设置文件路径
set "dict_file=dictionary.txt"
set "drawn_file=drawn_numbers.txt"
set "wrong_book_file=wrong_book.txt"
set "wrong_tested_file=wrong_tested.txt"

:: 初始化文件
if not exist "%drawn_file%" echo. > "%drawn_file%"
if not exist "%wrong_book_file%" echo. > "%wrong_book_file%"
if not exist "%wrong_tested_file%" echo. > "%wrong_tested_file%"

:: 检查字典文件是否存在
if not exist "%dict_file%" (
    echo 字典文件 %dict_file% 不存在！
    echo 请创建字典文件，格式为：英文 中文（每行一个词条）
    pause
    exit /b
)

:MAIN_MENU
cls
echo ===============================
echo          字典查询工具
echo ===============================
echo 1. 按序号查询单词
echo 2. 显示全部单词
echo 3. 随机抽取单词
echo 4. 重置已抽取记录
echo 5. 错题本功能
echo 6. 退出
echo ===============================
call :COUNT_WRONG_WORDS
echo 当前错题本共有 !wrong_count! 个单词
echo ===============================
set /p choice=请选择功能 [1-6]: 

if "%choice%"=="1" goto QUERY_BY_NUMBER
if "%choice%"=="2" goto SHOW_ALL
if "%choice%"=="3" goto RANDOM_DRAW
if "%choice%"=="4" goto RESET_DRAWN
if "%choice%"=="5" goto WRONG_BOOK_MENU
if "%choice%"=="6" exit /b

echo 无效选择，请重新输入！
pause
goto MAIN_MENU

:QUERY_BY_NUMBER
cls
echo ===== 按序号查询 =====
call :COUNT_LINES

:QUERY_LOOP
cls
echo ===== 按序号查询 =====
echo 字典共有 !total_lines! 个词条
echo.
set /p number=请输入要查询的序号（输入0返回主菜单）: 

:: 检查是否返回主菜单
if "!number!"=="0" goto MAIN_MENU

:: 验证输入
echo !number!|findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo 请输入有效的数字！
    pause
    goto QUERY_LOOP
)

if !number! lss 1 (
    echo 序号不能小于1！
    pause
    goto QUERY_LOOP
)

if !number! gtr !total_lines! (
    echo 序号不能大于 !total_lines!！
    pause
    goto QUERY_LOOP
)

:: 读取指定行
set line_count=0
set "found=0"
for /f "tokens=1,*" %%a in ('type "%dict_file%"') do (
    set /a line_count+=1
    if !line_count! equ !number! (
        set "found=1"
        echo.
        echo 序号: !number!
        echo 英文: %%a
        echo 中文: %%b
        echo.
    )
)

if "!found!"=="0" (
    echo 未找到序号 !number! 对应的词条！
)

echo.
echo 1. 继续查询
echo 2. 返回主菜单
set /p continue_choice=请选择: 

if "!continue_choice!"=="1" goto QUERY_LOOP
goto MAIN_MENU

:SHOW_ALL
cls
echo ===== 全部词条 =====
call :COUNT_LINES
echo 字典共有 !total_lines! 个词条
echo.

set line_count=0
for /f "tokens=1,*" %%a in ('type "%dict_file%"') do (
    set /a line_count+=1
    echo !line_count!. %%a - %%b
)

echo.
pause
goto MAIN_MENU

:RANDOM_DRAW
cls
echo ===== 随机抽取 =====
call :COUNT_LINES

:: 检查是否所有词条都已抽取
call :COUNT_DRAWN
if !drawn_count! geq !total_lines! (
    echo 所有词条都已经被抽取过了！
    echo 请选择重置功能来重新开始抽取
    pause
    goto MAIN_MENU
)

:: 生成随机数（排除已抽取的）
:GEN_RANDOM
set /a random_num=!random! %% !total_lines! + 1

:: 改进的检查逻辑
set already_drawn=0
for /f "usebackq" %%i in ("%drawn_file%") do (
    if "%%i"=="!random_num!" set already_drawn=1
)
if !already_drawn! equ 1 goto GEN_RANDOM

:: 显示英文
set line_count=0
for /f "tokens=1,*" %%a in ('type "%dict_file%"') do (
    set /a line_count+=1
    if !line_count! equ !random_num! (
        echo.
        echo 抽取的单词：
        echo 英文: %%a
        set "english=%%a"
        set "chinese=%%b"
        set "current_number=!random_num!"
    )
)

echo.
echo 按任意键显示中文...
pause >nul

:: 显示中文
echo 中文: !chinese!
echo.

:: 记录已抽取序号（确保只写入纯数字）
echo !random_num!>>"%drawn_file%"
echo 该序号 [!random_num!] 已被标记为已抽取

:: 询问是否加入错题本
echo.
echo 是否认识这个单词？
echo 1. 认识
echo 2. 不认识（加入错题本）
set /p know_choice=请选择: 

if "!know_choice!"=="2" (
    call :ADD_TO_WRONG_BOOK "!english!" "!chinese!" "!current_number!"
)

echo.
echo 1. 继续抽取
echo 2. 返回主菜单
set /p next_choice=请选择: 

if "!next_choice!"=="1" goto RANDOM_DRAW
goto MAIN_MENU

:RESET_DRAWN
cls
echo ===== 重置已抽取记录 =====
echo 这将清除所有已抽取的记录，确定要继续吗？
echo.
echo 1. 确定重置
echo 2. 取消
set /p confirm=请选择: 

if "%confirm%"=="1" (
    echo. > "%drawn_file%"
    echo 已重置所有抽取记录！
) else (
    echo 已取消重置操作
)
pause
goto MAIN_MENU

:WRONG_BOOK_MENU
cls
call :COUNT_WRONG_WORDS
echo ===== 错题本功能 =====
echo 当前错题本共有 !wrong_count! 个单词
echo.
echo 1. 错题本测试
echo 2. 查看所有错题
echo 3. 编辑错题
echo 4. 清空错题本
echo 5. 重置错题测试记录
echo 6. 返回主菜单
echo.
set /p wrong_choice=请选择 [1-6]: 

if "!wrong_choice!"=="1" goto WRONG_BOOK_TEST
if "!wrong_choice!"=="2" goto SHOW_WRONG_WORDS
if "!wrong_choice!"=="3" goto EDIT_WRONG_WORDS
if "!wrong_choice!"=="4" goto CLEAR_WRONG_BOOK
if "!wrong_choice!"=="5" goto RESET_WRONG_TESTED
if "!wrong_choice!"=="6" goto MAIN_MENU

echo 无效选择！
pause
goto WRONG_BOOK_MENU

:WRONG_BOOK_TEST
cls
echo ===== 错题本测试 =====
call :COUNT_WRONG_WORDS

if !wrong_count! equ 0 (
    echo 错题本为空，无法进行测试！
    pause
    goto WRONG_BOOK_MENU
)

:: 检查是否所有错题都已测试
call :COUNT_WRONG_TESTED
if !wrong_tested_count! geq !wrong_count! (
    echo 所有错题都已经测试过了！
    echo 是否重置测试记录重新开始？
    echo.
    echo 1. 重置并重新开始
    echo 2. 返回错题本菜单
    set /p reset_test=请选择: 
    if "!reset_test!"=="1" (
        echo. > "%wrong_tested_file%"
        echo 已重置测试记录！
        pause
    ) else (
        goto WRONG_BOOK_MENU
    )
)

:: 随机选择错题（排除已测试的）
:GEN_WRONG_RANDOM
set /a random_wrong_num=!random! %% !wrong_count! + 1

:: 检查是否已测试
set already_tested=0
for /f "usebackq" %%i in ("%wrong_tested_file%") do (
    if "%%i"=="!random_wrong_num!" set already_tested=1
)
if !already_tested! equ 1 goto GEN_WRONG_RANDOM

:: 显示错题（英文）
set wrong_line_count=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    set /a wrong_line_count+=1
    if !wrong_line_count! equ !random_wrong_num! (
        echo.
        echo 测试单词：
        echo 英文: %%a
        set "test_english=%%a"
        set "test_chinese=%%b"
        set "current_wrong_number=!random_wrong_num!"
    )
)

echo.
echo 按任意键显示中文...
pause >nul

:: 显示中文
echo 中文: !test_chinese!
echo.

:: 记录已测试错题
echo !random_wrong_num!>>"%wrong_tested_file%"

:: 询问是否认识
echo.
echo 现在认识这个单词了吗？
echo 1. 认识了（从错题本移除）
echo 2. 还不认识（保留在错题本）
set /p know_now=请选择: 

if "!know_now!"=="1" (
    call :REMOVE_FROM_WRONG_BOOK "!current_wrong_number!"
    echo 该单词已从错题本移除！
)

echo.
echo 1. 继续测试
echo 2. 返回错题本菜单
set /p continue_test=请选择: 

if "!continue_test!"=="1" goto WRONG_BOOK_TEST
goto WRONG_BOOK_MENU

:SHOW_WRONG_WORDS
cls
echo ===== 所有错题 =====
call :COUNT_WRONG_WORDS

if !wrong_count! equ 0 (
    echo 错题本为空！
    pause
    goto WRONG_BOOK_MENU
)

echo 错题本共有 !wrong_count! 个单词：
echo.

set wrong_line_count=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    set /a wrong_line_count+=1
    echo !wrong_line_count!. %%a - %%b
)

echo.
pause
goto WRONG_BOOK_MENU

:EDIT_WRONG_WORDS
cls
echo ===== 编辑错题 =====
call :COUNT_WRONG_WORDS

if !wrong_count! equ 0 (
    echo 错题本为空，无法编辑！
    pause
    goto WRONG_BOOK_MENU
)

echo 当前错题列表：
echo.
set wrong_line_count=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    set /a wrong_line_count+=1
    echo !wrong_line_count!. %%a - %%b
)

echo.
set /p edit_number=请输入要编辑的错题序号（输入0返回）: 

if "!edit_number!"=="0" goto WRONG_BOOK_MENU

:: 验证输入
echo !edit_number!|findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo 请输入有效的数字！
    pause
    goto EDIT_WRONG_WORDS
)

if !edit_number! lss 1 (
    echo 序号不能小于1！
    pause
    goto EDIT_WRONG_WORDS
)

if !edit_number! gtr !wrong_count! (
    echo 序号不能大于 !wrong_count!！
    pause
    goto EDIT_WRONG_WORDS
)

:: 获取原单词信息
set edit_line_count=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    set /a edit_line_count+=1
    if !edit_line_count! equ !edit_number! (
        set "old_english=%%a"
        set "old_chinese=%%b"
    )
)

echo.
echo 当前单词信息：
echo 英文: !old_english!
echo 中文: !old_chinese!
echo.
set /p new_english=请输入新的英文（直接回车保持不变）: 
set /p new_chinese=请输入新的中文（直接回车保持不变）: 

:: 如果用户没有输入，保持原值
if "!new_english!"=="" set "new_english=!old_english!"
if "!new_chinese!"=="" set "new_chinese=!old_chinese!"

:: 更新错题本
call :UPDATE_WRONG_BOOK "!edit_number!" "!new_english!" "!new_chinese!"

echo.
echo 错题更新成功！
echo 新的单词信息：
echo 英文: !new_english!
echo 中文: !new_chinese!
echo.
pause
goto WRONG_BOOK_MENU

:CLEAR_WRONG_BOOK
cls
echo ===== 清空错题本 =====
echo 这将删除所有错题，确定要继续吗？
echo.
echo 1. 确定清空
echo 2. 取消
set /p confirm=请选择: 

if "!confirm!"=="1" (
    echo. > "%wrong_book_file%"
    echo. > "%wrong_tested_file%"
    echo 错题本已清空！
) else (
    echo 已取消操作
)
pause
goto WRONG_BOOK_MENU

:RESET_WRONG_TESTED
cls
echo ===== 重置错题测试记录 =====
echo 这将重置所有错题的测试状态，确定要继续吗？
echo.
echo 1. 确定重置
echo 2. 取消
set /p confirm=请选择: 

if "!confirm!"=="1" (
    echo. > "%wrong_tested_file%"
    echo 已重置错题测试记录！
) else (
    echo 已取消操作
)
pause
goto WRONG_BOOK_MENU

:COUNT_LINES
set total_lines=0
for /f "usebackq" %%a in ("%dict_file%") do set /a total_lines+=1
goto :eof

:COUNT_DRAWN
set drawn_count=0
for /f "usebackq" %%a in ("%drawn_file%") do set /a drawn_count+=1
goto :eof

:COUNT_WRONG_WORDS
set wrong_count=0
for /f "usebackq" %%a in ("%wrong_book_file%") do (
    if not "%%a"=="" set /a wrong_count+=1
)
goto :eof

:COUNT_WRONG_TESTED
set wrong_tested_count=0
for /f "usebackq" %%a in ("%wrong_tested_file%") do (
    if not "%%a"=="" set /a wrong_tested_count+=1
)
goto :eof

:ADD_TO_WRONG_BOOK
set "english=%~1"
set "chinese=%~2"
set "original_number=%~3"

:: 检查是否已经存在
set already_exists=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    if "%%a"=="!english!" set already_exists=1
)

if !already_exists! equ 0 (
    echo !english! !chinese! [原序号:!original_number!]>>"%wrong_book_file%"
    echo 单词已添加到错题本！
) else (
    echo 该单词已在错题本中！
)
goto :eof

:REMOVE_FROM_WRONG_BOOK
set "remove_number=%~1"

:: 创建临时文件
set "temp_file=%temp%\wrong_temp.txt"
if exist "!temp_file!" del "!temp_file!"

set current_line=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    set /a current_line+=1
    if not !current_line! equ !remove_number! (
        echo %%a %%b>>"!temp_file!"
    )
)

:: 用临时文件替换原文件
copy "!temp_file!" "%wrong_book_file%" >nul
del "!temp_file!"
goto :eof

:UPDATE_WRONG_BOOK
set "update_number=%~1"
set "new_english=%~2"
set "new_chinese=%~3"

:: 创建临时文件
set "temp_file=%temp%\wrong_temp.txt"
if exist "!temp_file!" del "!temp_file!"

set current_line=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    set /a current_line+=1
    if !current_line! equ !update_number! (
        echo !new_english! !new_chinese!>>"!temp_file!"
    ) else (
        echo %%a %%b>>"!temp_file!"
    )
)

:: 用临时文件替换原文件
copy "!temp_file!" "%wrong_book_file%" >nul
del "!temp_file!"
goto :eof