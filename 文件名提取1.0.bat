@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 取 ANSI ESC 字符（支持逐行彩色输出，避免 COLOR 改变整屏颜色）
for /f "delims=" %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"

color 0C
echo ========================================
echo 超级文件名提取工具
echo ========================================
echo.
echo %ESC%[93m  OOOOO   SSSSS   DDDDD   EEEEE  PPPPP   K   K%ESC%[0m
echo %ESC%[93m O     O S     S  D    D  E      P    P  K  K %ESC%[0m
echo %ESC%[93m O     O S        D     D E      P    P  K K  %ESC%[0m
echo %ESC%[93m O     O  SSSSS   D     D EEEE   PPPPP   KK   %ESC%[0m
echo %ESC%[93m O     O       S  D     D E      P       K K  %ESC%[0m
echo %ESC%[93m O     O S     S  D    D  E      P       K  K %ESC%[0m
echo %ESC%[93m  OOOOO   SSSSS   DDDDD   EEEEE  P       K   K%ESC%[0m
echo %ESC%[93m               作者：OSDEPK%ESC%[0m
echo.
set /p _=按回车开始处理...
echo.
echo 开始提取文件列表...

REM 清空或创建文件名.txt文件
echo. > 文件名.txt

REM 获取当前目录的绝对路径
cd /d "%~dp0"
pushd .
set "rootpath=%cd%"
popd

REM 获取当前目录名
for %%I in (".") do set "currentfolder=%%~nxI"

REM 根目录：计算第一个文件名并输出两行标题（第一行：文件夹名；第二行：第一个文件名）
set "firstrootfile="
set "rootfilecount=0"
for /f "delims=" %%i in ('dir /b /a-d /o:e 2^>nul') do (
    if not defined firstrootfile set "firstrootfile=%%i"
    set /a rootfilecount+=1
)
if defined firstrootfile (
    echo %currentfolder% [文件数: !rootfilecount!] >> 文件名.txt
    echo   %firstrootfile% >> 文件名.txt
)

REM 先统计所有文件的扩展名（包括第一个文件）
set "extStats="
set "extList="
REM 收集所有扩展名到列表
for /f "delims=" %%i in ('dir /b /a-d /o:e 2^>nul') do (
    for %%x in ("%%i") do set "curExt=%%~xx"
    if "!curExt!"=="" (
        set "curExt=无扩展名"
    ) else (
        set "curExt=!curExt:~1!"
        if "!curExt!"=="" set "curExt=无扩展名"
    )
    REM 检查扩展名是否已在列表中
    set "found=0"
    for %%e in (!extList!) do (
        if /i "%%e"=="!curExt!" set "found=1"
    )
    if "!found!"=="0" (
        if defined extList (
            set "extList=!extList! !curExt!"
        ) else (
            set "extList=!curExt!"
        )
    )
)
REM 统计每种扩展名的数量
for %%e in (!extList!) do (
    set "ext=%%e"
    set "count=0"
    for /f "delims=" %%i in ('dir /b /a-d /o:e 2^>nul') do (
        for %%x in ("%%i") do set "fileExt=%%~xx"
        if "!fileExt!"=="" set "fileExt=无扩展名"
        if "!fileExt!" neq "" (
            set "fileExt=!fileExt:~1!"
            if "!fileExt!"=="" set "fileExt=无扩展名"
        )
        if /i "!fileExt!"=="!ext!" set /a count+=1
    )
    if defined extStats (
        set "extStats=!extStats! !ext!(!count!)"
    ) else (
        set "extStats=!ext!(!count!)"
    )
)

REM 列出当前目录下的文件（不含子目录），按扩展名分组；跳过标题中已使用的第一个文件
set "lastExt="
for %%X in ("%firstrootfile%") do set "lastExt=%%~xX"
for /f "delims=" %%i in ('dir /b /a-d /o:e 2^>nul') do (
    if /I not "%%i"=="%firstrootfile%" (
        for %%x in ("%%i") do set "curExt=%%~xx"
        if /I not "!curExt!"=="!lastExt!" echo ---------------------------- >> 文件名.txt
        set "lastExt=!curExt!"
        echo   %%i >> 文件名.txt
    )
)
REM 输出文件类型统计
if defined extStats (
    echo [统计: !extStats!] >> 文件名.txt
)
echo. >> 文件名.txt
echo ---------------------------- >> 文件名.txt
echo ---------------------------- >> 文件名.txt
echo. >> 文件名.txt

REM 递归遍历所有子目录
for /f "delims=" %%d in ('dir /s /b /ad') do (
    REM 获取目录名（不包含路径）
    for %%I in ("%%d") do set "foldername=%%~nxI"
    
    REM 获取相对于当前目录的完整路径
    set "fullpath=%%d"
    set "relpath=!fullpath:%rootpath%\=!"
    
    REM 标题（不带上级路径）：第一行文件夹名；第二行第一个文件名
    set "firstfile="
    set "filecount=0"
    for /f "delims=" %%f in ('dir "%%d" /b /a-d /o:e 2^>nul') do (
        if not defined firstfile set "firstfile=%%f"
        set /a filecount+=1
    )
    if defined firstfile (
        echo !foldername! [文件数: !filecount!] >> 文件名.txt
        echo   !firstfile! >> 文件名.txt
    )
    
    REM 先统计该目录下所有文件的扩展名（包括第一个文件）
    set "extStats="
    set "extList="
    REM 收集所有扩展名到列表
    for /f "delims=" %%f in ('dir "%%d" /b /a-d /o:e 2^>nul') do (
        for %%x in ("%%f") do set "curExt=%%~xx"
        if "!curExt!"=="" (
            set "curExt=无扩展名"
        ) else (
            set "curExt=!curExt:~1!"
            if "!curExt!"=="" set "curExt=无扩展名"
        )
        REM 检查扩展名是否已在列表中
        set "found=0"
        for %%e in (!extList!) do (
            if /i "%%e"=="!curExt!" set "found=1"
        )
        if "!found!"=="0" (
            if defined extList (
                set "extList=!extList! !curExt!"
            ) else (
                set "extList=!curExt!"
            )
        )
    )
    REM 统计每种扩展名的数量
    for %%e in (!extList!) do (
        set "ext=%%e"
        set "count=0"
        for /f "delims=" %%f in ('dir "%%d" /b /a-d /o:e 2^>nul') do (
            for %%x in ("%%f") do set "fileExt=%%~xx"
            if "!fileExt!"=="" set "fileExt=无扩展名"
            if "!fileExt!" neq "" (
                set "fileExt=!fileExt:~1!"
                if "!fileExt!"=="" set "fileExt=无扩展名"
            )
            if /i "!fileExt!"=="!ext!" set /a count+=1
        )
        if defined extStats (
            set "extStats=!extStats! !ext!(!count!)"
        ) else (
            set "extStats=!ext!(!count!)"
        )
    )
    
    REM 列出该目录下的文件，仅输出文件名；按扩展名分组；跳过标题中已使用的第一个文件
    set "lastExt="
    for %%X in ("!firstfile!") do set "lastExt=%%~xX"
    for /f "delims=" %%f in ('dir "%%d" /b /a-d /o:e 2^>nul') do (
        if /I not "%%f"=="!firstfile!" (
            for %%x in ("%%f") do set "curExt=%%~xx"
            if /I not "!curExt!"=="!lastExt!" echo ---------------------------- >> 文件名.txt
            set "lastExt=!curExt!"
            echo   %%f >> 文件名.txt
        )
    )
    REM 输出文件类型统计
    if defined firstfile (
        if defined extStats (
            echo [统计: !extStats!] >> 文件名.txt
        )
        echo. >> 文件名.txt
        echo ---------------------------- >> 文件名.txt
        echo ---------------------------- >> 文件名.txt
        echo. >> 文件名.txt
    )
)

echo %ESC%[92m已提取完成，请在本bat文件同目录下查看: 文件名.txt%ESC%[0m
echo %ESC%[92m========================================%ESC%[0m
set /p _=%ESC%[92m请按回车退出...%ESC%[0m
color 07