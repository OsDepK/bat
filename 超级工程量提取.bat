@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

for /f "delims=" %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"

color 0C
echo ========================================
echo 超级工程量提取工具
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

REM 清空或创建工程量.txt文件
echo. > 工程量.txt

REM 获取当前目录的绝对路径
cd /d "%~dp0"
pushd .
set "rootpath=%cd%"
popd

REM 获取当前目录名
for %%I in (".") do set "currentfolder=%%~nxI"

REM 根目录：计算第一个文件名并输出两行标题（第一行：文件夹名；第二行：第一个文件名）
set "firstrootfile="
for /f "delims=" %%i in ('dir /b /a-d /o:e 2^>nul') do (
    if not defined firstrootfile set "firstrootfile=%%i"
)
if defined firstrootfile (
    echo %currentfolder% >> 工程量.txt
    echo   %firstrootfile% >> 工程量.txt
)

REM 列出当前目录下的文件（不含子目录），按扩展名分组；跳过标题中已使用的第一个文件
set "lastExt="
for %%X in ("%firstrootfile%") do set "lastExt=%%~xX"
for /f "delims=" %%i in ('dir /b /a-d /o:e 2^>nul') do (
    if /I not "%%i"=="%firstrootfile%" (
        for %%x in ("%%i") do set "curExt=%%~xx"
        if /I not "!curExt!"=="!lastExt!" echo ---------------------------- >> 工程量.txt
        set "lastExt=!curExt!"
        echo   %%i >> 工程量.txt
    )
)
echo. >> 工程量.txt
echo ---------------------------- >> 工程量.txt
echo ---------------------------- >> 工程量.txt
echo. >> 工程量.txt

REM 递归遍历所有子目录
for /f "delims=" %%d in ('dir /s /b /ad') do (
    REM 获取目录名（不包含路径）
    for %%I in ("%%d") do set "foldername=%%~nxI"
    
    REM 获取相对于当前目录的完整路径
    set "fullpath=%%d"
    set "relpath=!fullpath:%rootpath%\=!"
    
    REM 标题（不带上级路径）：第一行文件夹名；第二行第一个文件名
    set "firstfile="
    for /f "delims=" %%f in ('dir "%%d" /b /a-d /o:e 2^>nul') do (
        if not defined firstfile set "firstfile=%%f"
    )
    if defined firstfile (
        echo !foldername! >> 工程量.txt
        echo   !firstfile! >> 工程量.txt
    )
    
    REM 列出该目录下的文件，仅输出文件名；按扩展名分组；跳过标题中已使用的第一个文件
    set "lastExt="
    for %%X in ("!firstfile!") do set "lastExt=%%~xX"
    for /f "delims=" %%f in ('dir "%%d" /b /a-d /o:e 2^>nul') do (
        if /I not "%%f"=="!firstfile!" (
            for %%x in ("%%f") do set "curExt=%%~xx"
            if /I not "!curExt!"=="!lastExt!" echo ---------------------------- >> 工程量.txt
            set "lastExt=!curExt!"
            echo   %%f >> 工程量.txt
        )
    )
    if defined firstfile (
        echo. >> 工程量.txt
        echo ---------------------------- >> 工程量.txt
        echo ---------------------------- >> 工程量.txt
        echo. >> 工程量.txt
    )
)

echo %ESC%[92m已提取完成，请在本bat文件同目录下查看: 工程量.txt%ESC%[0m
echo %ESC%[92m========================================%ESC%[0m
set /p _=%ESC%[92m请按回车退出...%ESC%[0m
color 07