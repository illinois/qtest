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
    PKG_NAME="maca64_qtest_Installer.pkg"
else
    MAC_FOLDER_NAME="maci64"
    PKG_NAME="maci64_qtest_Installer.pkg"
fi

# Define constants
INSTALLER_SIGNING_IDENTITY="Developer ID Installer: University of Illinois at Urbana-Champaign (UPV4CB4H6W)"
APP_SIGNING_IDENTITY="Developer ID Application: University of Illinois at Urbana-Champaign (UPV4CB4H6W)"

APP_UNIQUE_ID="edu.illinois.psychology.qtest"
ENTITLEMENTS_FILE="entitlements.plist"
ENTITLEMENTS_PATH="$SCRIPT_PATH/$ENTITLEMENTS_FILE"
ROOT_PATH="$SCRIPT_PATH/../.."
BASE_PATH="$ROOT_PATH/build/macOS/$MAC_FOLDER_NAME"
APP_NAME="qtest.app"
APP_PATH="$BASE_PATH/$APP_NAME"
INSTALLER_DIR_NAME="temp_installer"
INSTALLER_DIR_PATH="$BASE_PATH/$INSTALLER_DIR_NAME"
PKG_PATH="$BASE_PATH/$PKG_NAME"
INFO_PLIST_NAME="Info.plist"
INFO_PLIST_PATH="$BASE_PATH/$INFO_PLIST_NAME"
ZIP_NAME="qtest_Installer.zip"
ZIP_PATH="$BASE_PATH/$ZIP_NAME"
PROFILE_NAME="qtest_signing_profile"
TEAM_ID="UPV4CB4H6W"
VERBOSE_LEVEL=4
OPTIONS="--options=runtime"
TIMESTAMP="--timestamp"


# Define executable paths within the app bundle
EXECUTABLES=("Contents/MacOS/setup")

# Function to check the exit status of commands
check_command_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed."
        exit 1
    fi
}

mkdir $INSTALLER_DIR_PATH
cp -r "$APP_PATH" "$INSTALLER_DIR_PATH/"
pkgbuild --analyze --root "$INSTALLER_DIR_PATH" "$INFO_PLIST_PATH"
check_command_status "pkgbuild analyze"
/usr/libexec/PlistBuddy -c "Set :0:BundleIsRelocatable false" $INFO_PLIST_PATH
check_command_status "Plist update"

pkgbuild --root "$INSTALLER_DIR_PATH" \
        --component-plist "$INFO_PLIST_PATH" \
        --identifier "$APP_UNIQUE_ID" \
        --install-location /Applications \
        --version "$QTEST_VERSION" \
        --sign "$INSTALLER_SIGNING_IDENTITY" \
        "$PKG_PATH"
check_command_status "pkgbuild building pkg file"

# Create a zip archive of the application bundle
ditto -c -k --keepParent "$PKG_PATH" "$ZIP_PATH"
check_command_status "ditto zip creation"

# Store notarization credentials
xcrun notarytool store-credentials "$PROFILE_NAME" --apple-id "$APPLE_ID" --team-id "$TEAM_ID" --password "$PASSWORD" --validate
check_command_status "notarytool store-credentials"

# Submit the zip file for notarization
xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$PROFILE_NAME" --team-id "$TEAM_ID" --wait
check_command_status "notarytool submit"

# Staple the notarization ticket to the application
xcrun stapler staple "$PKG_PATH"
check_command_status "stapler staple"

# Verify the application's code signature
spctl -a -v --type install "$PKG_PATH"
check_command_status "spctl verification"

echo "Code signing, notarization, and verification of installer completed successfully."
