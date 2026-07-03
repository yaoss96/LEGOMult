@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM ============================================================
REM  Vivado synthesis launcher -- REAL LUT/CARRY4/DSP counts
REM  (same yardstick as the paper: post-synthesis on Kintex-7)
REM
REM  Usage:
REM     synth.bat                         synth ALL tiled_mult_*.v (area)
REM     synth.bat tiled_mult_32b_L4_d1_ss.v          (area + comb CPD)
REM     synth.bat tiled_mult_32b_L4_d1_ss.v reg      (registered timing/CPD)
REM     synth.bat tiled_mult_32b_L4_d1_ss.v reg 3.5    (target period 3.5ns)
REM
REM  Override the part or vivado path if needed:
REM     set PART=xc7k70tfbv484-3
REM     set VIVADO=C:\Xilinx\Vivado\2022.1\bin\vivado.bat
REM  Results are appended to synth_results.txt
REM ============================================================

if "%VIVADO%"=="" set VIVADO=D:\xilinx\Vivado\2024.2\bin\vivado.bat
if "%PART%"==""   set PART=xc7k70tfbv484-3
set SCRIPT_DIR=%~dp0
set MODE=%~2
if "%MODE%"==""   set MODE=comb
set PERIOD=%~3
if "%PERIOD%"=="" set PERIOD=3.0

if not exist "%VIVADO%" (
    where "%VIVADO%" >nul 2>nul
    if errorlevel 1 (
        echo [ERROR] Cannot find Vivado ^("%VIVADO%"^).
        echo         Open the "Vivado ... Tcl Shell" / settings64.bat first,
        echo         or set VIVADO to the full path of vivado.bat.
        exit /b 1
    )
)

echo Synth run %DATE% %TIME%  part=%PART%  mode=%MODE% >> "%SCRIPT_DIR%synth_results.txt"

if not "%~1"=="" (
    call :one "%~1"
    if errorlevel 1 exit /b !ERRORLEVEL!
    goto :done
)

REM no file given -> synth every generated multiplier (skip tb / sandwich)
for %%F in ("%SCRIPT_DIR%tiled_mult_*.v") do (
    set NAME=%%~nF
    set SKIP=0
    echo !NAME! | findstr /C:"_tb" >nul && set SKIP=1
    echo !NAME! | findstr /C:"_sandwich" >nul && set SKIP=1
    if "!SKIP!"=="0" (
        call :one "%%F"
        if errorlevel 1 exit /b !ERRORLEVEL!
    )
)
goto :done

:one
echo.
echo ===== synthesizing %~nx1 =====
set BASELOG=%TEMP%\synth_%~n1
set LOG=%BASELOG%.log
set RC=1
set OK=0

REM Pass an absolute RTL path to Vivado. Relative paths can trigger Windows Vivado
REM helper-process read failures under .Xil/realtime on this host.
REM Vivado 2024.2 also intermittently generates helper Tcl paths like
REM .Xil/.../realtime\tiled_mult_32b_ss.tcl, where the backslash before t can be
REM interpreted as a Tcl escape. Retrying in a fresh process usually clears it.
for /L %%R in (1,1,5) do (
    if "!OK!"=="0" (
        if %%R GTR 1 echo [WARN] Vivado helper Tcl path/read failed; retry %%R/5...
        if exist "%SCRIPT_DIR%.Xil" rmdir /s /q "%SCRIPT_DIR%.Xil" >nul 2>nul
        set LOG=%BASELOG%_try%%R.log
        call "%VIVADO%" -mode batch -notrace -source "%SCRIPT_DIR%synth.tcl" -tclargs "%~f1" %PART% %MODE% %PERIOD% > "!LOG!" 2>&1
        set RC=!ERRORLEVEL!
        if "!RC!"=="0" (
            set OK=1
        ) else (
            set RETRYABLE=0
            REM rt-undefined is Vivado's intermittent .Xil/realtime helper Tcl bug.
            REM The line containing rt-undefined often does not contain the .Xil path,
            REM so check it separately from the "couldn't read file ... .Xil/Vivado" cases.
            findstr /C:"rt-undefined" "!LOG!" >nul 2>nul && set RETRYABLE=1
            findstr /C:"couldn't read file" "!LOG!" | findstr /C:"/Vivado/" /C:"\\Vivado\\" /C:"/.Xil/" /C:"\\.Xil\\" >nul 2>nul && set RETRYABLE=1
            if "!RETRYABLE!"=="0" (
                set OK=FAIL_NONRETRY
            )
        )
    )
)

findstr /C:"RESULT" /C:"== synth" /C:"ERROR" /C:"CRITICAL WARNING" /C:"utilization report" /C:"CPD/timing report" "%LOG%"
findstr /C:"RESULT" "%LOG%" >> "%SCRIPT_DIR%synth_results.txt"
if not "%RC%"=="0" (
    echo [ERROR] Vivado exited with code %RC%. Full log: "%LOG%"
    exit /b %RC%
)
exit /b 0

:done
echo.
echo Done. Per-design utilization: tiled_mult_*_util.txt
echo Per-design CPD/timing: tiled_mult_*_cpd.txt
echo Summary appended to synth_results.txt
exit /b 0
