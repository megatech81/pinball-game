# Mobile Pinball Game - Development Setup

This document describes how to set up and build the mobile version of the pinball game using Godot Engine.

## Overview

The mobile version is a complete port of the original Python/pygame pinball game to Godot Engine 4.3, featuring:

- **Enhanced Graphics**: High-resolution textures, particle effects, and lighting
- **Touch Controls**: Intuitive touch-based gameplay for mobile devices
- **Responsive UI**: Optimized for various screen sizes and orientations
- **Cross-Platform**: Single codebase for both Android and iOS deployment

## Prerequisites

### Required Software

1. **Godot Engine 4.3+**
   - Download from: https://godotengine.org/download
   - Ensure you have the standard version (not the .NET version)

2. **For Android Development:**
   - Android Studio
   - Android SDK (API level 29 or higher)
   - Android NDK
   - Java Development Kit (JDK) 11 or higher

3. **For iOS Development:**
   - Xcode 12 or higher (macOS only)
   - iOS Development certificate and provisioning profiles
   - Apple Developer Account

## Project Structure

```
mobile/
├── project.godot           # Main project configuration
├── export_presets.cfg      # Export settings for Android/iOS
├── icon.svg               # Application icon
├── scenes/
│   ├── Main.tscn          # Basic game scene
│   └── EnhancedMain.tscn  # Enhanced graphics scene
├── scripts/
│   ├── PinballGame.gd     # Basic game logic
│   └── EnhancedPinballGame.gd # Enhanced version with graphics
└── assets/
    ├── textures/          # Game textures (auto-generated)
    └── sounds/            # Sound effects (future enhancement)
```

## Setup Instructions

### 1. Open Project in Godot

1. Launch Godot Engine
2. Click "Import" in the project manager
3. Navigate to the `mobile/` directory
4. Select `project.godot`
5. Click "Import & Edit"

### 2. Configure Export Templates

1. In Godot, go to `Editor → Manage Export Templates`
2. Download the official export templates for version 4.3
3. Templates will be automatically installed

### 3. Android Setup

1. Go to `Project → Export`
2. Select "Android" preset
3. Configure the following settings:
   - **Package Name**: `com.megatech81.pinballmobile`
   - **App Name**: `Pinball Mobile`
   - **Target SDK**: 33 or higher
   - **Min SDK**: 21 or higher
4. Set up Android SDK path in `Editor → Editor Settings → Export → Android`

### 4. iOS Setup (macOS only)

1. Go to `Project → Export`
2. Select "iOS" preset
3. Configure:
   - **Bundle Identifier**: `com.megatech81.pinballmobile`
   - **App Store Team ID**: Your Apple Developer Team ID
   - **Provisioning Profile**: Your app's provisioning profile

## Game Features

### Enhanced Graphics

- **Procedural Textures**: High-quality textures generated at runtime
- **Particle Systems**: Trail effects for ball movement and collision sparks
- **Dynamic Lighting**: Glow effects on active flippers and hit bumpers
- **Smooth Animations**: Flipper movements and bumper hit reactions

### Mobile-Optimized Controls

- **Touch Areas**: Screen divided into touch zones for left/right flippers
- **Launch Control**: Tap upper screen area to launch ball
- **Visual Feedback**: Active flippers glow when pressed
- **Game Restart**: Tap anywhere when game over to restart

### Responsive Design

- **Portrait Orientation**: Optimized for mobile portrait mode (720x1280)
- **Scalable UI**: Text and controls scale with screen size
- **Performance**: Mobile-optimized rendering pipeline

## Building for Mobile

### Android Build

1. Ensure Android SDK is properly configured
2. Go to `Project → Export`
3. Select "Android" preset
4. Click "Export Project"
5. Choose output location for APK file
6. Click "Save" to build

### iOS Build

1. Ensure Xcode and certificates are configured
2. Go to `Project → Export`
3. Select "iOS" preset
4. Click "Export Project"
5. Choose output location for Xcode project
6. Open the exported project in Xcode to build and deploy

## Testing

### Desktop Testing

The game can be tested on desktop using keyboard controls:
- **Left Arrow**: Left flipper
- **Right Arrow**: Right flipper
- **Spacebar**: Launch ball
- **R**: Restart game

### Mobile Testing

1. Build and install APK on Android device
2. Or use Godot's remote debugging feature:
   - Enable "Remote Debug" in export settings
   - Connect device via USB
   - Deploy directly from Godot editor

## Performance Optimization

The mobile version includes several optimizations:

- **Mobile Renderer**: Uses Godot's mobile rendering pipeline
- **Texture Compression**: ASTC/ETC2 compression for mobile GPU efficiency
- **Particle Limits**: Optimized particle counts for mobile performance
- **Frame Rate**: Locked to 60 FPS for smooth gameplay

## Deployment

### Google Play Store

1. Generate signed APK using your keystore
2. Test on various Android devices
3. Create store listing with screenshots
4. Upload APK to Google Play Console

### Apple App Store

1. Build with distribution certificate
2. Test on various iOS devices
3. Create App Store listing
4. Submit through App Store Connect

## Troubleshooting

### Common Issues

1. **Build Failures**: Ensure all SDKs are properly installed and configured
2. **Performance Issues**: Reduce particle counts or texture quality
3. **Touch Not Working**: Check TouchScreenButton configuration
4. **Graphics Issues**: Verify mobile renderer is selected

### Debug Tools

- Use Godot's remote debugger for real-time testing
- Enable debug builds for detailed error information
- Monitor performance using Godot's profiler

## Next Steps

Future enhancements could include:

1. **Sound Effects**: Add audio feedback for collisions and scoring
2. **Multiple Tables**: Create different pinball table layouts
3. **Power-ups**: Special ball effects and bonus features
4. **Leaderboards**: Online high score tracking
5. **Haptic Feedback**: Vibration effects for mobile devices

For support or questions, refer to the main project documentation or Godot's official documentation at https://docs.godotengine.org/