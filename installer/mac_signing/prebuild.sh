#!/bin/bash

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

# Retrieve APPLE_ID, PASSWORD from environment variables
APPLE_ID="${APPLE_ID}"  # Ensure this environment variable is set before running the script
PASSWORD="${PASSWORD}"  # Ensure this environment variable is set before running the script

# Check if APPLE_ID, PASSWORD are set
if [ -z "$APPLE_ID" ] || [ -z "$PASSWORD" ]; then
    echo "Error: APPLE_ID or PASSWORD environment variable not set."
    exit 1
fi

# Define constants
APP_SIGNING_IDENTITY="Developer ID Application: University of Illinois at Urbana-Champaign (UPV4CB4H6W)"

# Check if APP_SIGNING_IDENTITY certificate is installed
if ! security find-certificate -c "$APP_SIGNING_IDENTITY" &> /dev/null; then
    echo "Error: Certificate for $APP_SIGNING_IDENTITY not found. Install them first."
    exit 1
fi

ENTITLEMENTS_FILE="entitlements.plist"
ENTITLEMENTS_PATH="$SCRIPT_PATH/$ENTITLEMENTS_FILE"
ROOT_PATH="$SCRIPT_PATH/../.."
PROFILE_NAME="qtest_signing_profile"
TEAM_ID="UPV4CB4H6W"
VERBOSE_LEVEL=4
OPTIONS="--options=runtime"
TIMESTAMP="--timestamp"

if [ "$(uname -m)" = "arm64" ]; then
    FILES=("cddgmpmex.mexmaca64" "cddmex.mexmaca64")
else
    FILES=("portamex.mexmaci64" "portavmex.mexmaci64")
fi

SRC_PATH="$ROOT_PATH/src"

# Function to check the exit status of commands
check_command_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed."
        exit 1
    fi
}

# Remove existing signatures
for FILE in "${FILES[@]}"; do
    codesign --remove-signature "$SRC_PATH/$FILE"
    check_command_status "codesign for $EXEC"
done

# Sign individual executables
for FILE in "${FILES[@]}"; do
    echo codesign --verbose=$VERBOSE_LEVEL $OPTIONS -s "$APP_SIGNING_IDENTITY" --entitlements $ENTITLEMENTS_PATH $TIMESTAMP "$SRC_PATH/$FILE"
    codesign --verbose=$VERBOSE_LEVEL $OPTIONS -s "$APP_SIGNING_IDENTITY" --entitlements $ENTITLEMENTS_PATH $TIMESTAMP "$SRC_PATH/$FILE"
    check_command_status "codesign for $EXEC"
done

echo "Code signing completed."
