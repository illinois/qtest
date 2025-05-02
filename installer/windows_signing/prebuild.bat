ee@echo off

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
set BASE_PATH=%ROOT_PATH%\src

REM Unzip necessary files

@REM Delete folder if it exists
if exist "%SCRIPT_PATH%SignTool" rmdir /s /q "%SCRIPT_PATH%SignTool"
if exist "%SCRIPT_PATH%microsoft.trusted.signing.client" rmdir /s /q "%SCRIPT_PATH%microsoft.trusted.signing.client"

echo Unzipping SignTool-10.0.22621.6-x64.zip
powershell -Command "Expand-Archive -Path '%SCRIPT_PATH%SignTool-10.0.22621.6-x64.zip' -DestinationPath '%SCRIPT_PATH%SignTool'"
call :check_command_status "unzip SignTool-10.0.22621.6-x64.zip"

echo Downloading microsoft.trusted.signing.client.1.0.76.zip
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.nuget.org/api/v2/package/microsoft.trusted.signing.client/1.0.76' -OutFile '%SCRIPT_PATH%microsoft.trusted.signing.client.1.0.76.zip'"
call :check_command_status "download microsoft.trusted.signing.client.1.0.76.zip"

echo Unzipping microsoft.trusted.signing.client.1.0.76.zip
powershell -Command "Expand-Archive -Path '%SCRIPT_PATH%microsoft.trusted.signing.client.1.0.76.zip' -DestinationPath '%SCRIPT_PATH%microsoft.trusted.signing.client'"
call :check_command_status "unzip microsoft.trusted.signing.client.1.0.76.zip"


REM Define files to sign
set FILES_TO_SIGN=portamex.mexw64 portavmex.mexw64 cddgmpmex.mexw64 cddmex.mexw64

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
