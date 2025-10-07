@echo off
setlocal enabledelayedexpansion

title �ֵ��ѯ����
color 0A

:: �����ļ�·��
set "dict_file=dictionary.txt"
set "drawn_file=drawn_numbers.txt"
set "wrong_book_file=wrong_book.txt"
set "wrong_tested_file=wrong_tested.txt"

:: ��ʼ���ļ�
if not exist "%drawn_file%" echo. > "%drawn_file%"
if not exist "%wrong_book_file%" echo. > "%wrong_book_file%"
if not exist "%wrong_tested_file%" echo. > "%wrong_tested_file%"

:: ����ֵ��ļ��Ƿ����
if not exist "%dict_file%" (
    echo �ֵ��ļ� %dict_file% �����ڣ�
    echo �봴���ֵ��ļ�����ʽΪ��Ӣ�� ���ģ�ÿ��һ��������
    pause
    exit /b
)

:MAIN_MENU
cls
echo ===============================
echo          �ֵ��ѯ����
echo ===============================
echo 1. ����Ų�ѯ����
echo 2. ��ʾȫ������
echo 3. �����ȡ����
echo 4. �����ѳ�ȡ��¼
echo 5. ���Ȿ����
echo 6. �˳�
echo ===============================
call :COUNT_WRONG_WORDS
echo ��ǰ���Ȿ���� !wrong_count! ������
echo ===============================
set /p choice=��ѡ���� [1-6]: 

if "%choice%"=="1" goto QUERY_BY_NUMBER
if "%choice%"=="2" goto SHOW_ALL
if "%choice%"=="3" goto RANDOM_DRAW
if "%choice%"=="4" goto RESET_DRAWN
if "%choice%"=="5" goto WRONG_BOOK_MENU
if "%choice%"=="6" exit /b

echo ��Чѡ�����������룡
pause
goto MAIN_MENU

:QUERY_BY_NUMBER
cls
echo ===== ����Ų�ѯ =====
call :COUNT_LINES

:QUERY_LOOP
cls
echo ===== ����Ų�ѯ =====
echo �ֵ乲�� !total_lines! ������
echo.
set /p number=������Ҫ��ѯ����ţ�����0�������˵���: 

:: ����Ƿ񷵻����˵�
if "!number!"=="0" goto MAIN_MENU

:: ��֤����
echo !number!|findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo ��������Ч�����֣�
    pause
    goto QUERY_LOOP
)

if !number! lss 1 (
    echo ��Ų���С��1��
    pause
    goto QUERY_LOOP
)

if !number! gtr !total_lines! (
    echo ��Ų��ܴ��� !total_lines!��
    pause
    goto QUERY_LOOP
)

:: ��ȡָ����
set line_count=0
set "found=0"
for /f "tokens=1,*" %%a in ('type "%dict_file%"') do (
    set /a line_count+=1
    if !line_count! equ !number! (
        set "found=1"
        echo.
        echo ���: !number!
        echo Ӣ��: %%a
        echo ����: %%b
        echo.
    )
)

if "!found!"=="0" (
    echo δ�ҵ���� !number! ��Ӧ�Ĵ�����
)

echo.
echo 1. ������ѯ
echo 2. �������˵�
set /p continue_choice=��ѡ��: 

if "!continue_choice!"=="1" goto QUERY_LOOP
goto MAIN_MENU

:SHOW_ALL
cls
echo ===== ȫ������ =====
call :COUNT_LINES
echo �ֵ乲�� !total_lines! ������
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
echo ===== �����ȡ =====
call :COUNT_LINES

:: ����Ƿ����д������ѳ�ȡ
call :COUNT_DRAWN
if !drawn_count! geq !total_lines! (
    echo ���д������Ѿ�����ȡ���ˣ�
    echo ��ѡ�����ù��������¿�ʼ��ȡ
    pause
    goto MAIN_MENU
)

:: ������������ų��ѳ�ȡ�ģ�
:GEN_RANDOM
set /a random_num=!random! %% !total_lines! + 1

:: �Ľ��ļ���߼�
set already_drawn=0
for /f "usebackq" %%i in ("%drawn_file%") do (
    if "%%i"=="!random_num!" set already_drawn=1
)
if !already_drawn! equ 1 goto GEN_RANDOM

:: ��ʾӢ��
set line_count=0
for /f "tokens=1,*" %%a in ('type "%dict_file%"') do (
    set /a line_count+=1
    if !line_count! equ !random_num! (
        echo.
        echo ��ȡ�ĵ��ʣ�
        echo Ӣ��: %%a
        set "english=%%a"
        set "chinese=%%b"
        set "current_number=!random_num!"
    )
)

echo.
echo ���������ʾ����...
pause >nul

:: ��ʾ����
echo ����: !chinese!
echo.

:: ��¼�ѳ�ȡ��ţ�ȷ��ֻд�봿���֣�
echo !random_num!>>"%drawn_file%"
echo ����� [!random_num!] �ѱ����Ϊ�ѳ�ȡ

:: ѯ���Ƿ������Ȿ
echo.
echo �Ƿ���ʶ������ʣ�
echo 1. ��ʶ
echo 2. ����ʶ��������Ȿ��
set /p know_choice=��ѡ��: 

if "!know_choice!"=="2" (
    call :ADD_TO_WRONG_BOOK "!english!" "!chinese!" "!current_number!"
)

echo.
echo 1. ������ȡ
echo 2. �������˵�
set /p next_choice=��ѡ��: 

if "!next_choice!"=="1" goto RANDOM_DRAW
goto MAIN_MENU

:RESET_DRAWN
cls
echo ===== �����ѳ�ȡ��¼ =====
echo �⽫��������ѳ�ȡ�ļ�¼��ȷ��Ҫ������
echo.
echo 1. ȷ������
echo 2. ȡ��
set /p confirm=��ѡ��: 

if "%confirm%"=="1" (
    echo. > "%drawn_file%"
    echo ���������г�ȡ��¼��
) else (
    echo ��ȡ�����ò���
)
pause
goto MAIN_MENU

:WRONG_BOOK_MENU
cls
call :COUNT_WRONG_WORDS
echo ===== ���Ȿ���� =====
echo ��ǰ���Ȿ���� !wrong_count! ������
echo.
echo 1. ���Ȿ����
echo 2. �鿴���д���
echo 3. �༭����
echo 4. ��մ��Ȿ
echo 5. ���ô�����Լ�¼
echo 6. �������˵�
echo.
set /p wrong_choice=��ѡ�� [1-6]: 

if "!wrong_choice!"=="1" goto WRONG_BOOK_TEST
if "!wrong_choice!"=="2" goto SHOW_WRONG_WORDS
if "!wrong_choice!"=="3" goto EDIT_WRONG_WORDS
if "!wrong_choice!"=="4" goto CLEAR_WRONG_BOOK
if "!wrong_choice!"=="5" goto RESET_WRONG_TESTED
if "!wrong_choice!"=="6" goto MAIN_MENU

echo ��Чѡ��
pause
goto WRONG_BOOK_MENU

:WRONG_BOOK_TEST
cls
echo ===== ���Ȿ���� =====
call :COUNT_WRONG_WORDS

if !wrong_count! equ 0 (
    echo ���ⱾΪ�գ��޷����в��ԣ�
    pause
    goto WRONG_BOOK_MENU
)

:: ����Ƿ����д��ⶼ�Ѳ���
call :COUNT_WRONG_TESTED
if !wrong_tested_count! geq !wrong_count! (
    echo ���д��ⶼ�Ѿ����Թ��ˣ�
    echo �Ƿ����ò��Լ�¼���¿�ʼ��
    echo.
    echo 1. ���ò����¿�ʼ
    echo 2. ���ش��Ȿ�˵�
    set /p reset_test=��ѡ��: 
    if "!reset_test!"=="1" (
        echo. > "%wrong_tested_file%"
        echo �����ò��Լ�¼��
        pause
    ) else (
        goto WRONG_BOOK_MENU
    )
)

:: ���ѡ����⣨�ų��Ѳ��Եģ�
:GEN_WRONG_RANDOM
set /a random_wrong_num=!random! %% !wrong_count! + 1

:: ����Ƿ��Ѳ���
set already_tested=0
for /f "usebackq" %%i in ("%wrong_tested_file%") do (
    if "%%i"=="!random_wrong_num!" set already_tested=1
)
if !already_tested! equ 1 goto GEN_WRONG_RANDOM

:: ��ʾ���⣨Ӣ�ģ�
set wrong_line_count=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    set /a wrong_line_count+=1
    if !wrong_line_count! equ !random_wrong_num! (
        echo.
        echo ���Ե��ʣ�
        echo Ӣ��: %%a
        set "test_english=%%a"
        set "test_chinese=%%b"
        set "current_wrong_number=!random_wrong_num!"
    )
)

echo.
echo ���������ʾ����...
pause >nul

:: ��ʾ����
echo ����: !test_chinese!
echo.

:: ��¼�Ѳ��Դ���
echo !random_wrong_num!>>"%wrong_tested_file%"

:: ѯ���Ƿ���ʶ
echo.
echo ������ʶ�����������
echo 1. ��ʶ�ˣ��Ӵ��Ȿ�Ƴ���
echo 2. ������ʶ�������ڴ��Ȿ��
set /p know_now=��ѡ��: 

if "!know_now!"=="1" (
    call :REMOVE_FROM_WRONG_BOOK "!current_wrong_number!"
    echo �õ����ѴӴ��Ȿ�Ƴ���
)

echo.
echo 1. ��������
echo 2. ���ش��Ȿ�˵�
set /p continue_test=��ѡ��: 

if "!continue_test!"=="1" goto WRONG_BOOK_TEST
goto WRONG_BOOK_MENU

:SHOW_WRONG_WORDS
cls
echo ===== ���д��� =====
call :COUNT_WRONG_WORDS

if !wrong_count! equ 0 (
    echo ���ⱾΪ�գ�
    pause
    goto WRONG_BOOK_MENU
)

echo ���Ȿ���� !wrong_count! �����ʣ�
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
echo ===== �༭���� =====
call :COUNT_WRONG_WORDS

if !wrong_count! equ 0 (
    echo ���ⱾΪ�գ��޷��༭��
    pause
    goto WRONG_BOOK_MENU
)

echo ��ǰ�����б�
echo.
set wrong_line_count=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    set /a wrong_line_count+=1
    echo !wrong_line_count!. %%a - %%b
)

echo.
set /p edit_number=������Ҫ�༭�Ĵ�����ţ�����0���أ�: 

if "!edit_number!"=="0" goto WRONG_BOOK_MENU

:: ��֤����
echo !edit_number!|findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo ��������Ч�����֣�
    pause
    goto EDIT_WRONG_WORDS
)

if !edit_number! lss 1 (
    echo ��Ų���С��1��
    pause
    goto EDIT_WRONG_WORDS
)

if !edit_number! gtr !wrong_count! (
    echo ��Ų��ܴ��� !wrong_count!��
    pause
    goto EDIT_WRONG_WORDS
)

:: ��ȡԭ������Ϣ
set edit_line_count=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    set /a edit_line_count+=1
    if !edit_line_count! equ !edit_number! (
        set "old_english=%%a"
        set "old_chinese=%%b"
    )
)

echo.
echo ��ǰ������Ϣ��
echo Ӣ��: !old_english!
echo ����: !old_chinese!
echo.
set /p new_english=�������µ�Ӣ�ģ�ֱ�ӻس����ֲ��䣩: 
set /p new_chinese=�������µ����ģ�ֱ�ӻس����ֲ��䣩: 

:: ����û�û�����룬����ԭֵ
if "!new_english!"=="" set "new_english=!old_english!"
if "!new_chinese!"=="" set "new_chinese=!old_chinese!"

:: ���´��Ȿ
call :UPDATE_WRONG_BOOK "!edit_number!" "!new_english!" "!new_chinese!"

echo.
echo ������³ɹ���
echo �µĵ�����Ϣ��
echo Ӣ��: !new_english!
echo ����: !new_chinese!
echo.
pause
goto WRONG_BOOK_MENU

:CLEAR_WRONG_BOOK
cls
echo ===== ��մ��Ȿ =====
echo �⽫ɾ�����д��⣬ȷ��Ҫ������
echo.
echo 1. ȷ�����
echo 2. ȡ��
set /p confirm=��ѡ��: 

if "!confirm!"=="1" (
    echo. > "%wrong_book_file%"
    echo. > "%wrong_tested_file%"
    echo ���Ȿ����գ�
) else (
    echo ��ȡ������
)
pause
goto WRONG_BOOK_MENU

:RESET_WRONG_TESTED
cls
echo ===== ���ô�����Լ�¼ =====
echo �⽫�������д���Ĳ���״̬��ȷ��Ҫ������
echo.
echo 1. ȷ������
echo 2. ȡ��
set /p confirm=��ѡ��: 

if "!confirm!"=="1" (
    echo. > "%wrong_tested_file%"
    echo �����ô�����Լ�¼��
) else (
    echo ��ȡ������
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

:: ����Ƿ��Ѿ�����
set already_exists=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    if "%%a"=="!english!" set already_exists=1
)

if !already_exists! equ 0 (
    echo !english! !chinese! [ԭ���:!original_number!]>>"%wrong_book_file%"
    echo ��������ӵ����Ȿ��
) else (
    echo �õ������ڴ��Ȿ�У�
)
goto :eof

:REMOVE_FROM_WRONG_BOOK
set "remove_number=%~1"

:: ������ʱ�ļ�
set "temp_file=%temp%\wrong_temp.txt"
if exist "!temp_file!" del "!temp_file!"

set current_line=0
for /f "tokens=1,*" %%a in ('type "%wrong_book_file%"') do (
    set /a current_line+=1
    if not !current_line! equ !remove_number! (
        echo %%a %%b>>"!temp_file!"
    )
)

:: ����ʱ�ļ��滻ԭ�ļ�
copy "!temp_file!" "%wrong_book_file%" >nul
del "!temp_file!"
goto :eof

:UPDATE_WRONG_BOOK
set "update_number=%~1"
set "new_english=%~2"
set "new_chinese=%~3"

:: ������ʱ�ļ�
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

:: ����ʱ�ļ��滻ԭ�ļ�
copy "!temp_file!" "%wrong_book_file%" >nul
del "!temp_file!"
goto :eof