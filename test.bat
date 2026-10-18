@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM  Exhaustive testbench launcher for ILP FPGA multiplier
REM  Supports BOTH symmetric (W) and asymmetric (WaxWb) sizes.
REM
REM  Usage:
REM     test.bat 8 4                 (symmetric W=8 S=4)
REM     test.bat 8 4 carry
REM     test.bat 16 8 nocarry
REM     test.bat 9x7 4               (asymmetric Wa=9 Wb=7 S=4)
REM     test.bat 12x16 8 carry
REM
REM  Behavior:
REM    1) Regenerate RTL via run.bat
REM    2) Build an exhaustive testbench iterating all (a, b)
REM    3) Run iverilog/vvp inside WSL
REM
REM  Note: exhaustive runs are O(2^(Wa+Wb)) -- only practical up to Wa+Wb<=12.
REM        Larger sizes: edit the testbench to use random sampling instead.
REM ============================================================

set SCRIPT_DIR=%~dp0
set SIZE=%~1
set S=%~2
set MODE=%~3

if "%SIZE%"=="" set SIZE=8
if "%S%"==""    set S=4

if /I not "%MODE%"=="" if /I not "%MODE%"=="carry" if /I not "%MODE%"=="nocarry" (
    echo [ERROR] Third argument must be "carry" or "nocarry".
    exit /b 1
)

REM Detect WaxWb syntax
set IS_ASYM=0
echo %SIZE% | findstr /C:"x" >nul
if %ERRORLEVEL%==0 set IS_ASYM=1

if "%IS_ASYM%"=="1" (
    for /f "tokens=1,2 delims=x" %%a in ("%SIZE%") do (
        set WA=%%a
        set WB=%%b
    )
    set NAME_TAG=!WA!x!WB!
) else (
    set WA=%SIZE%
    set WB=%SIZE%
    set NAME_TAG=%SIZE%b
)

echo [1/3] Generating RTL: run.bat %SIZE% %S% %MODE%
call "%SCRIPT_DIR%run.bat" %SIZE% %S% %MODE%
if errorlevel 1 (
    echo [ERROR] run.bat failed.
    exit /b 1
)

set VFILE=ilp_mult_!NAME_TAG!_S%S%.v
set TBFILE=ilp_mult_!NAME_TAG!_S%S%_exhaustive_tb.v
set OUTFILE=/tmp/ilp_mult_!NAME_TAG!_S%S%_exhaustive_tb.out

set PYEXE=C:\gurobi1001\win64\python37\bin\python.exe
if not exist "%PYEXE%" (
    echo [ERROR] Cannot find %PYEXE%
    echo         Please update PYEXE in test.bat.
    exit /b 1
)

echo [2/3] Writing exhaustive testbench: %TBFILE%
"%PYEXE%" "%SCRIPT_DIR%generate_exhaustive_tb.py" --Wa !WA! --Wb !WB! --out "%SCRIPT_DIR%%TBFILE%"
if errorlevel 1 (
    echo [ERROR] Failed to write exhaustive testbench.
    exit /b 1
)

set WIN_DIR=%SCRIPT_DIR:~0,-1%
set DRIVE_LETTER=%WIN_DIR:~0,1%
set DRIVE_LETTER=%DRIVE_LETTER:C=c%
set DRIVE_LETTER=%DRIVE_LETTER:D=d%
set DRIVE_LETTER=%DRIVE_LETTER:E=e%
set WSL_DIR=/mnt/%DRIVE_LETTER%%WIN_DIR:~2%
set WSL_DIR=%WSL_DIR:\=/%
if "%WSL_DIR%"=="" (
    echo [ERROR] Failed to translate project path into WSL path.
    exit /b 1
)

echo [3/3] Running exhaustive simulation in WSL  (Wa=!WA! Wb=!WB!)
wsl.exe bash -lc "cd \"%WSL_DIR%\" && iverilog -g2012 -o %OUTFILE% LUT6.v LUT6_2.v CARRY4.v %VFILE% %TBFILE% && vvp %OUTFILE%"
set RC=%ERRORLEVEL%

if not "%RC%"=="0" (
    echo [ERROR] Exhaustive simulation failed with exit code %RC%.
    exit /b %RC%
)

echo [OK] Exhaustive simulation passed.
exit /b 0
