#!/bin/bash
# Mobile Pinball Build Script
# This script demonstrates the build process for the mobile pinball game

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
GODOT_EXECUTABLE=${GODOT_EXECUTABLE:-"godot"}

echo "🎯 Mobile Pinball Game Build Script"
echo "=================================="

# Check if Godot is available
if ! command -v $GODOT_EXECUTABLE &> /dev/null; then
    echo "❌ Godot Engine not found. Please install Godot 4.3+ or set GODOT_EXECUTABLE environment variable."
    echo "   Download from: https://godotengine.org/download"
    exit 1
fi

# Check Godot version
GODOT_VERSION=$($GODOT_EXECUTABLE --version 2>&1 | head -n1 | grep -o '[0-9]\+\.[0-9]\+')
echo "✅ Found Godot Engine version: $GODOT_VERSION"

if [[ ! "$GODOT_VERSION" =~ ^4\.[3-9]$ ]] && [[ ! "$GODOT_VERSION" =~ ^[5-9]\. ]]; then
    echo "⚠️  Warning: Recommended Godot version is 4.3+. Found: $GODOT_VERSION"
fi

# Create build directory
mkdir -p "$BUILD_DIR"

echo ""
echo "📱 Available Build Targets:"
echo "  android-debug  : Android debug APK"
echo "  android-release: Android release APK (requires signing)"
echo "  ios-debug     : iOS Xcode project for debugging"
echo "  ios-release   : iOS Xcode project for release"
echo "  test          : Test project validation"

# Function to check export templates
check_templates() {
    local platform=$1
    echo "🔍 Checking export templates for $platform..."
    
    $GODOT_EXECUTABLE --headless --path "$PROJECT_DIR" --export-debug "$platform" /tmp/test_export 2>&1 | grep -q "No export template found" && {
        echo "❌ Export templates not found for $platform"
        echo "   Please install export templates:"
        echo "   1. Open Godot Editor"
        echo "   2. Go to Editor → Manage Export Templates"
        echo "   3. Download templates for version $GODOT_VERSION"
        return 1
    }
    
    echo "✅ Export templates found for $platform"
    return 0
}

# Function to build Android debug
build_android_debug() {
    echo "🤖 Building Android Debug APK..."
    
    if ! check_templates "Android"; then
        return 1
    fi
    
    local output_file="$BUILD_DIR/pinball_mobile_debug.apk"
    
    $GODOT_EXECUTABLE --headless --path "$PROJECT_DIR" --export-debug "Android" "$output_file"
    
    if [ -f "$output_file" ]; then
        echo "✅ Android debug build successful: $output_file"
        ls -lh "$output_file"
    else
        echo "❌ Android debug build failed"
        return 1
    fi
}

# Function to build Android release
build_android_release() {
    echo "🤖 Building Android Release APK..."
    
    if ! check_templates "Android"; then
        return 1
    fi
    
    local output_file="$BUILD_DIR/pinball_mobile_release.apk"
    
    echo "⚠️  Note: Release builds require proper signing configuration"
    echo "   Configure keystore in Godot project settings before release builds"
    
    $GODOT_EXECUTABLE --headless --path "$PROJECT_DIR" --export-release "Android" "$output_file"
    
    if [ -f "$output_file" ]; then
        echo "✅ Android release build successful: $output_file"
        ls -lh "$output_file"
    else
        echo "❌ Android release build failed"
        return 1
    fi
}

# Function to build iOS
build_ios() {
    local mode=$1
    echo "🍎 Building iOS $mode project..."
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "❌ iOS builds require macOS"
        return 1
    fi
    
    if ! check_templates "iOS"; then
        return 1
    fi
    
    local output_dir="$BUILD_DIR/ios_$mode"
    mkdir -p "$output_dir"
    
    $GODOT_EXECUTABLE --headless --path "$PROJECT_DIR" --export-$mode "iOS" "$output_dir/pinball_mobile.xcodeproj"
    
    if [ -d "$output_dir/pinball_mobile.xcodeproj" ]; then
        echo "✅ iOS $mode build successful: $output_dir"
        echo "   Open the Xcode project to build and deploy to device"
    else
        echo "❌ iOS $mode build failed"
        return 1
    fi
}

# Function to test project
test_project() {
    echo "🧪 Testing project..."
    
    # Validate project structure
    if [ ! -f "$PROJECT_DIR/project.godot" ]; then
        echo "❌ project.godot not found"
        return 1
    fi
    
    if [ ! -f "$PROJECT_DIR/scenes/EnhancedMain.tscn" ]; then
        echo "❌ Main scene not found"
        return 1
    fi
    
    # Test import
    echo "   Importing project assets..."
    $GODOT_EXECUTABLE --headless --path "$PROJECT_DIR" --quit 2>&1 | grep -q "ERROR" && {
        echo "❌ Project import errors detected"
        return 1
    }
    
    echo "✅ Project validation successful"
    
    # List available export presets
    echo ""
    echo "📋 Available export presets:"
    grep -A 1 "^\[preset\." "$PROJECT_DIR/export_presets.cfg" | grep "^name=" | sed 's/name="/  - /' | sed 's/"$//'
}

# Main execution
case "${1:-test}" in
    "android-debug")
        build_android_debug
        ;;
    "android-release")
        build_android_release
        ;;
    "ios-debug")
        build_ios "debug"
        ;;
    "ios-release")
        build_ios "release"
        ;;
    "test")
        test_project
        ;;
    *)
        echo "❌ Unknown target: $1"
        echo "   Usage: $0 [android-debug|android-release|ios-debug|ios-release|test]"
        exit 1
        ;;
esac

echo ""
echo "🎉 Build script completed!"
echo ""
echo "📚 Next steps:"
echo "   • For Android: Install APK on device for testing"
echo "   • For iOS: Open Xcode project and deploy to device"
echo "   • For release: Configure signing and store metadata"
echo ""
echo "📖 See MOBILE_SETUP.md for detailed instructions"