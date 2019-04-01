:: First of all, elevate priviledges
@if not "%1"=="iam_admin" (powershell start -verb runas '%0' iam_admin & exit /b)

@echo off
:: Adding registry entries to enable management of Turbo Boost
@REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7 /v Attributes /t REG_DWORD /d 2 /f >nul 2>&1

:: Get current power plan
for /f "tokens=4" %%I in ('powercfg -getactivescheme') do set CurrentPowerPlanGUID=%%I

:: Enable Turbo Boost for current power plan DC/AC [AC-Plugged in | DC - On battery]
@powercfg -setacvalueindex %CurrentPowerPlanGUID% 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 2 >nul 2>&1
@powercfg -setdcvalueindex %CurrentPowerPlanGUID% 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 2 >nul 2>&1

:: Force reload
@powercfg /SETACTIVE %CurrentPowerPlanGUID%

:: Check if change was succesful
set KEY_NAME=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\%CurrentPowerPlanGUID%\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7

set VALUE_NAME_AC=ACSettingIndex
FOR /F "tokens=1-3" %%A IN ('REG QUERY %KEY_NAME% /v %VALUE_NAME_AC% 2^>nul') DO (
    set KeyValueAC=%%C)

set VALUE_NAME_DC=DCSettingIndex
FOR /F "tokens=1-3" %%A IN ('REG QUERY %KEY_NAME% /v %VALUE_NAME_DC% 2^>nul') DO (
    set KeyValueDC=%%C
)

IF "%KeyValueAC%"=="0x2" IF "%KeyValueDC%"=="0x2" (GOTO SUCCESS)

:FAIL
msg "%username%" Enabling Turbo Boost failed or unsupported! ! !
GOTO EXIT0

:SUCCESS
msg "%username%" Turbo Boost is now enabled!

:EXIT0

