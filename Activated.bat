@echo off
cls
color 0A

REM ===============================================
REM [CHECK] Run as Administrator
REM ===============================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this script as Administrator.
    echo [STATUS] Relaunching with Admin rights...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~fnx0\"' -Verb RunAs"
    exit /b
)

echo ================================================
echo         Windows Activation Demo
echo ================================================
echo.

REM ===============================================
REM [STATUS] Checking Windows activation status
REM ===============================================
echo [STATUS] Checking if Windows is already activated...
set "currentStatus="
for /f "tokens=2 delims==" %%i in ('wmic path SoftwareLicensingProduct where "Name like 'Windows%%'" get LicenseStatus /value ^| find "LicenseStatus"') do (
    set "currentStatus=%%i"
)

if "%currentStatus%"=="1" (
    echo [STATUS] Windows is already activated.
    pause
    exit /b
) else (
    echo [STATUS] Windows is not activated. Proceeding with activation...
)
echo.

REM ===============================================
REM Detecting Windows product name and edition
REM ===============================================
echo [STATUS] Detecting Windows version...
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul ^| find /i "ProductName"') do set "productName=%%B"
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul ^| find "EditionID"') do set "edition=%%B"

if "%productName%"=="" (
    echo [ERROR] Could not detect Windows product name.
    pause
    exit /b
)
if "%edition%"=="" (
    echo [ERROR] Could not detect Windows edition.
    pause
    exit /b
)

echo [STATUS] Product: %productName%
echo [STATUS] Edition: %edition%
echo.

REM ===============================================
REM Checking Windows version (10 or 11)
REM ===============================================
echo %productName% | findstr /i "Windows 11" >nul
if %errorlevel%==0 (
    set version=11
    echo [STATUS] Detected: Windows 11.
) else (
    set version=10
    echo [STATUS] Detected: Windows 10.
)
echo.

REM ===============================================
REM Setting KMS Activation Key (GVLK - Generic Volume License Key)
REM ===============================================
set key=

if "%version%"=="10" (
    if /i "%edition%"=="Professional" (
        set key=W269N-WFGWX-YVC9B-4J6C9-T83GX
        echo [STATUS] Selected key for Windows 10 Professional.
    ) else if /i "%edition%"=="Core" (
        set key=TX9XD-98N7V-6WMQ6-BX7FG-H8Q99
        echo [STATUS] Selected key for Windows 10 Home.
    ) else if /i "%edition%"=="Enterprise" (
        set key=NPPR9-FWDCX-D2C8J-H872K-2YT43
        echo [STATUS] Selected key for Windows 10 Enterprise.
    )
) else if "%version%"=="11" (
    if /i "%edition%"=="Professional" (
        set key=W269N-WFGWX-YVC9B-4J6C9-T83GX
        echo [STATUS] Selected key for Windows 11 Professional.
    ) else if /i "%edition%"=="Core" (
        set key=NW6C2-QMPVW-D7KKK-3GKT6-VCFB2
        echo [STATUS] Selected key for Windows 11 Home.
    ) else if /i "%edition%"=="Enterprise" (
        set key=NPPR9-FWDCX-D2C8J-H872K-2YT43
        echo [STATUS] Selected key for Windows 11 Enterprise.
    )
)

if "%key%"=="" (
    echo [ERROR] No valid KMS key found for your system.
    pause
    exit /b
)
echo.

REM ===============================================
REM Setting up KMS Server
REM ===============================================
set kmsServer=kms8.msguides.com

echo [STATUS] Installing KMS key...
slmgr /ipk %key% >nul 2>&1
echo [STATUS] KMS key installed.
echo.

echo [STATUS] Configuring KMS server: %kmsServer%...
slmgr /skms %kmsServer% >nul 2>&1
echo [STATUS] KMS server set.
echo.

echo [STATUS] Activating Windows...
slmgr /ato >nul 2>&1
echo [STATUS] Activation command executed.
echo.

echo [STATUS] Verifying activation status...
slmgr /xpr >nul 2>&1
echo [STATUS] Activation status checked.
echo.

echo ================================================
echo         Activation Completed
echo ================================================
pause
