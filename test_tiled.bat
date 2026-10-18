@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM ============================================================
REM  Generate the two-step tiling multiplier RTL and simulate it
REM  with iverilog/vvp inside WSL against an exhaustive/random TB.
REM
REM  Usage:
REM     test_tiled.bat SIZE [LEVEL] [MAXDSP] [MODE]
REM        SIZE = N or NxM ; LEVEL = 3..7 ; MAXDSP = int ; MODE = ss|su|us|uu
REM
REM  Examples:
REM     test_tiled.bat 8 3 0 ss
REM     test_tiled.bat 24 4 1 ss
REM     test_tiled.bat 12x10 5 0 uu
REM
REM  Notes: behavioural DSP `*` and (* use_dsp *) are simulated natively by
REM  iverilog; LUT6/LUT6_2/CARRY4 use the bundled sim models.
REM ============================================================

set PYEXE=%LEGO_PYEXE%
set SCRIPT_DIR=%~dp0

if "%PYEXE%"=="" (
    echo [ERROR] LEGO_PYEXE is not set.
    echo         Point it at the interpreter that can import gurobipy:
    echo             set LEGO_PYEXE=C:\gurobi1001\win64\python37\bin\python.exe
    exit /b 1
)
if not exist "%PYEXE%" (
    echo [ERROR] LEGO_PYEXE does not exist: %PYEXE%
    exit /b 1
)

set SIZE=%~1
set LEVEL=%~2
set MAXDSP=%~3
set MODE=%~4
if "%SIZE%"==""  set SIZE=8
if "%LEVEL%"==""  set LEVEL=4
if "%MAXDSP%"=="" set MAXDSP=0
if "%MODE%"==""   set MODE=uu

set SIGN=
if /I "%MODE%"=="ss" set SIGN=--sign-a --sign-b
if /I "%MODE%"=="su" set SIGN=--sign-a
if /I "%MODE%"=="us" set SIGN=--sign-b

REM ---- detect NxM and build the output filename like run_tiled.py ----
set IS_ASYM=0
echo %SIZE% | findstr /C:"x" >nul
if %ERRORLEVEL%==0 set IS_ASYM=1

if "%IS_ASYM%"=="1" (
    for /f "tokens=1,2 delims=x" %%a in ("%SIZE%") do ( set WA=%%a & set WB=%%b )
    set BASE=tiled_mult_!WA!x!WB!_L%LEVEL%_d%MAXDSP%_%MODE%
    set WARG=--Wa !WA! --Wb !WB!
) else (
    set WA=%SIZE%
    set WB=%SIZE%
    set BASE=tiled_mult_%SIZE%b_L%LEVEL%_d%MAXDSP%_%MODE%
    set WARG=--W %SIZE%
)
set VFILE=!BASE!.v
set TBFILE=!BASE!_tb.v

echo [1/2] Generating RTL: !WARG! --booth-level %LEVEL% --max-dsp %MAXDSP% %SIGN%
"%PYEXE%" "%SCRIPT_DIR%run_tiled.py" !WARG! --booth-level %LEVEL% --max-dsp %MAXDSP% %SIGN% --out "%SCRIPT_DIR%!VFILE!"
if errorlevel 1 ( echo [ERROR] generation failed & exit /b 1 )

REM ---- translate path to WSL and simulate ----
set WIN_DIR=%SCRIPT_DIR:~0,-1%
set DRIVE=%WIN_DIR:~0,1%
set DRIVE=%DRIVE:C=c%
set DRIVE=%DRIVE:D=d%
set DRIVE=%DRIVE:E=e%
set WSL_DIR=/mnt/%DRIVE%%WIN_DIR:~2%
set WSL_DIR=%WSL_DIR:\=/%
set OUTF=/tmp/!BASE!.out

echo [2/2] iverilog + vvp in WSL  (Wa=!WA! Wb=!WB!)
wsl.exe bash -lc "cd \"%WSL_DIR%\" && iverilog -g2012 -o %OUTF% LUT6.v LUT6_2.v CARRY4.v !VFILE! !TBFILE! && vvp %OUTF%"
set RC=%ERRORLEVEL%
if not "%RC%"=="0" ( echo [ERROR] simulation failed (rc=%RC%) & exit /b %RC% )
echo [OK] done.
