@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM ============================================================
REM  Launcher for the TWO-STEP tiling multiplier
REM  (Step1 DSP+Booth+LUT tiling ILP  ->  Step2 LUT+CARRY4 merge ILP)
REM
REM  Usage:
REM     run_tiled.bat SIZE [LEVEL] [MAXDSP] [MODE] [STEP2]
REM
REM     SIZE   : N          (symmetric NxN)      e.g. 24
REM              NxM        (asymmetric)         e.g. 24x18
REM     LEVEL  : Booth level 3..7  (default 4)  OR MIXED: 34567 / 3,4,5 / mix
REM     MAXDSP : DSP48 budget       (default 0 = logic only)
REM     MODE   : ss | su | us | uu  (default uu)  signed-a / signed-b
REM     STEP2  : Step-2 merge reduction-step budget S (default empty = auto).
REM              Smaller S = shallower/wider tree (lower latency, more LUTs);
REM              the solver still escalates from S if infeasible. Sweep it for
REM              the area-latency Pareto.
REM
REM  Examples:
REM     run_tiled.bat 24 7 4 ss        (24x24, Booth L7, up to 4 DSPs, signed)
REM     run_tiled.bat 24 4 1 ss        (24x24, Booth L4, 1 DSP, signed)
REM     run_tiled.bat 32 34567 1 ss    (32x32, MIXED Booth levels 3..7, 1 DSP)
REM     run_tiled.bat 32 mix 1 ss      (same -- 'mix' = levels 3..7)
REM     run_tiled.bat 16 5 0 uu        (16x16, Booth L5, logic only, unsigned)
REM     run_tiled.bat 24x18 4 2 su
REM     run_tiled.bat 32 mix 1 ss 8    (32x32, force Step-2 step budget S=8)
REM ============================================================

set PYEXE=C:\gurobi1001\win64\python37\bin\python.exe
set SCRIPT_DIR=%~dp0

if not exist "%PYEXE%" (
    echo [ERROR] Cannot find %PYEXE%
    echo         Update PYEXE in run_tiled.bat to point to your Gurobi python.
    exit /b 1
)

if "%~1"=="" (
    echo Usage: run_tiled.bat SIZE [LEVEL] [MAXDSP] [MODE] [STEP2]
    echo    SIZE = N or NxM ; LEVEL = 3..7 ; MAXDSP = int ; MODE = ss^|su^|us^|uu
    echo    STEP2 = Step-2 merge step budget S (default auto)
    echo Running default 24x24 Booth L4 max_dsp=1 signed ...
    "%PYEXE%" "%SCRIPT_DIR%run_tiled.py" --W 24 --booth-level 4 --max-dsp 1 --signed
    goto :eof
)

set SIZE=%~1
set LEVEL=%~2
set MAXDSP=%~3
set MODE=%~4
set STEP2=%~5
if "%LEVEL%"==""  set LEVEL=4
if "%MAXDSP%"=="" set MAXDSP=0
if "%MODE%"==""   set MODE=uu

REM ---- optional Step-2 merge step budget ----
set S2ARG=
if not "%STEP2%"=="" set S2ARG=--step2-steps %STEP2%

REM ---- sign flags from MODE ----
set SIGN=
if /I "%MODE%"=="ss" set SIGN=--sign-a --sign-b
if /I "%MODE%"=="su" set SIGN=--sign-a
if /I "%MODE%"=="us" set SIGN=--sign-b
if /I "%MODE%"=="uu" set SIGN=

REM ---- detect NxM (asymmetric) ----
echo %SIZE% | findstr /C:"x" >nul
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2 delims=x" %%a in ("%SIZE%") do (
        set WA=%%a
        set WB=%%b
    )
    echo Asymmetric Wa=!WA! Wb=!WB!  L=%LEVEL%  maxDSP=%MAXDSP%  mode=%MODE%  S2=%STEP2%
    "%PYEXE%" "%SCRIPT_DIR%run_tiled.py" --Wa !WA! --Wb !WB! --booth-levels %LEVEL% --max-dsp %MAXDSP% %SIGN% %S2ARG%
) else (
    echo Symmetric W=%SIZE%  L=%LEVEL%  maxDSP=%MAXDSP%  mode=%MODE%  S2=%STEP2%
    "%PYEXE%" "%SCRIPT_DIR%run_tiled.py" --W %SIZE% --booth-levels %LEVEL% --max-dsp %MAXDSP% %SIGN% %S2ARG%
)
