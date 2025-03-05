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

# Check if QTEST_VERSION is set
if [ -z "$QTEST_VERSION" ]; then
    echo "Error: QTEST_VERSION environment variable not set."
    exit 1
else
    echo "QTEST_VERSION is set to $QTEST_VERSION"
fi


if [ "$(uname -m)" = "arm64" ]; then
    MAC_FOLDER_NAME="maca64"
else
    MAC_FOLDER_NAME="maci64"
fi

# Define constants
APP_SIGNING_IDENTITY="Developer ID Application: University of Illinois at Urbana-Champaign (UPV4CB4H6W)"

ENTITLEMENTS_FILE="entitlements.plist"
ENTITLEMENTS_PATH="$SCRIPT_PATH/$ENTITLEMENTS_FILE"
ROOT_PATH="$SCRIPT_PATH/../.."
BASE_PATH="$ROOT_PATH/build/macOS/$MAC_FOLDER_NAME"
APP_NAME="qtest.app"
APP_PATH="$BASE_PATH/$APP_NAME"
ZIP_NAME="qtest.zip"
ZIP_PATH="$BASE_PATH/$ZIP_NAME"
PROFILE_NAME="qtest_signing_profile"
TEAM_ID="UPV4CB4H6W"
VERBOSE_LEVEL=4
OPTIONS="--options=runtime"
TIMESTAMP="--timestamp"

# Define executable paths within the app bundle
EXECUTABLES=("Contents/MacOS/applauncher" "Contents/MacOS/qtest" "Contents/MacOS/prelaunch")

# Function to check the exit status of commands
check_command_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed."
        exit 1
    fi
}

# Remove existing signatures
for EXEC in "${EXECUTABLES[@]}"; do
    codesign --remove-signature "$APP_PATH/$EXEC"
    check_command_status "codesign for $EXEC"
done

# Set the version in the Info.plist file
INFO_PLIST_PATH="$APP_PATH/Contents/Info.plist"
if [ -f "$INFO_PLIST_PATH" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $QTEST_VERSION" "$INFO_PLIST_PATH"
    check_command_status "Set CFBundleShortVersionString in Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $QTEST_VERSION" "$INFO_PLIST_PATH"
    check_command_status "Set CFBundleVersion in Info.plist"
else
    echo "Error: Info.plist not found at $INFO_PLIST_PATH"
    exit 1
fi

# Sign individual executables
for EXEC in "${EXECUTABLES[@]}"; do
    codesign --verbose=$VERBOSE_LEVEL $OPTIONS -s "$APP_SIGNING_IDENTITY" --entitlements $ENTITLEMENTS_PATH $TIMESTAMP "$APP_PATH/$EXEC"
    check_command_status "codesign for $EXEC"
done


# commented becuase the above loop already signed the whole executable
# Sign the entire application bundle
# codesign --verbose=$VERBOSE_LEVEL $OPTIONS -s "$APP_SIGNING_IDENTITY" --entitlements $ENTITLEMENTS_PATH $TIMESTAMP "$APP_PATH"
# check_command_status "codesign for application bundle"

# Create a zip archive of the application bundle
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
check_command_status "ditto zip creation"

# Store notarization credentials
xcrun notarytool store-credentials "$PROFILE_NAME" --apple-id "$APPLE_ID" --team-id "$TEAM_ID" --password "$PASSWORD" --validate
check_command_status "notarytool store-credentials"

# Submit the zip file for notarization
xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$PROFILE_NAME" --team-id "$TEAM_ID" --wait
check_command_status "notarytool submit"

# Staple the notarization ticket to the application
xcrun stapler staple "$APP_PATH"
check_command_status "stapler staple"

# Verify the application's code signature
spctl -a -t exec -vvv "$APP_PATH"
check_command_status "spctl verification"

echo "Code signing, notarization, and verification of application completed successfully."
