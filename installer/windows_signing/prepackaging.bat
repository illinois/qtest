@echo off

REM Check if environment variables are set
if "%AZURE_CLIENT_ID%"=="" (
    echo Error: AZURE_CLIENT_ID environment variable not set.
    exit /b 1
)
if "%AZURE_CLIENT_SECRET%"=="" (
    echo Error: AZURE_CLIENT_SECRET environment variable not set.
    exit /b 1
)
if "%AZURE_TENANT_ID%"=="" (
    echo Error: AZURE_TENANT_ID environment variable not set.
    exit /b 1
)


REM Define paths
set SCRIPT_PATH=%~dp0
set ROOT_PATH=%SCRIPT_PATH%..\..
set BASE_PATH=%ROOT_PATH%\build\windows\win64

REM Define files to sign
set FILES_TO_SIGN=qtest.exe

REM Function to check the exit status of commands
:check_command_status
if %errorlevel% neq 0 (
    echo Error: %1 failed.
    exit /b 1
)

REM Sign individual executables
for %%F in (%FILES_TO_SIGN%) do (
    echo Signing %BASE_PATH%\%%F
    "%SCRIPT_PATH%SignTool\signtool.exe" sign /v /fd SHA256 /tr "http://timestamp.acs.microsoft.com" /td SHA256 /dlib "%SCRIPT_PATH%microsoft.trusted.signing.client\bin\x64\Azure.CodeSigning.Dlib.dll" /dmdf "%SCRIPT_PATH%metadata.json" %BASE_PATH%\%%F
    if %errorlevel% neq 0 (
        echo Error: signtool sign for %%F failed.
        exit /b 1
    )
)

echo Code signing completed successfully.
exit /b 0
