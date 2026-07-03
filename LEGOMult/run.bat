@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM ============================================================
REM  Convenience launcher for the ILP-Driven FPGA Multiplier
REM  Supports BOTH symmetric (W) and asymmetric (WaxWb) sizes.
REM
REM  Usage:
REM     run.bat 8 4               (W=8 S=4 -- symmetric, LUT-CarryChain)
REM     run.bat 8 4 carry         (explicit carry mode)
REM     run.bat 8 4 nocarry       (force pure-LUT)
REM     run.bat 9x7 4             (Wa=9 Wb=7 S=4 -- asymmetric)
REM     run.bat 12x16 8 carry     (Wa=12 Wb=16 S=8)
REM     run.bat 3x7 3
REM ============================================================

set PYEXE=C:\gurobi1001\win64\python37\bin\python.exe
set SCRIPT_DIR=%~dp0

if not exist "%PYEXE%" (
    echo [ERROR] Cannot find %PYEXE%
    echo         Please update PYEXE in run.bat to point to your gurobi python.
    pause
    exit /b 1
)

if "%~1"=="" (
    echo Usage:
    echo    run.bat 8 4               ^(W=8  S=4   symmetric, LUT-CarryChain^)
    echo    run.bat 8 4 carry         ^(explicit carry mode^)
    echo    run.bat 16 8 nocarry      ^(force pure-LUT^)
    echo    run.bat 9x7 4             ^(asymmetric Wa=9 Wb=7 S=4^)
    echo    run.bat 12x16 8 carry     ^(asymmetric Wa=12 Wb=16 S=8^)
    echo.
    echo Running default 8x8 with S=4 ^(LUT-CarryChain^) ...
    "%PYEXE%" "%SCRIPT_DIR%run.py" --W 8 --S 4 --lut-carry
    goto :eof
)

set SIZE=%~1
set S=%~2
set MODE=%~3
set EXTRA=--lut-carry
if /I "%MODE%"=="carry"   set EXTRA=--lut-carry
if /I "%MODE%"=="nocarry" set EXTRA=--no-lut-carry

if not "%MODE%"=="" (
    if /I not "%MODE%"=="carry" if /I not "%MODE%"=="nocarry" (
        echo [ERROR] Third argument must be "carry" or "nocarry".
        exit /b 1
    )
)

REM Detect WaxWb syntax (asymmetric)
echo %SIZE% | findstr /C:"x" >nul
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2 delims=x" %%a in ("%SIZE%") do (
        set WA=%%a
        set WB=%%b
    )
    echo Asymmetric: Wa=!WA! Wb=!WB! S=%S%  %EXTRA%
    "%PYEXE%" "%SCRIPT_DIR%run.py" --Wa !WA! --Wb !WB! --S %S% %EXTRA%
) else (
    echo Symmetric:  W=%SIZE% S=%S%  %EXTRA%
    "%PYEXE%" "%SCRIPT_DIR%run.py" --W %SIZE% --S %S% %EXTRA%
)
