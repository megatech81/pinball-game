# Pinball Game

A classic pinball game implementation available for both desktop and mobile platforms. The desktop version uses Python and pygame, while the mobile version is built with Godot Engine for cross-platform deployment to Android and iOS.

## Versions

### Desktop Version (Python/Pygame)
A complete pinball game with realistic physics, flippers, bumpers, and scoring system. Perfect for desktop gaming with keyboard controls.

### Mobile Version (Godot Engine)
Enhanced mobile version featuring:
- **Cross-Platform**: Deploy to Android and iOS
- **Enhanced Graphics**: High-resolution textures, particle effects, and lighting
- **Touch Controls**: Intuitive mobile gameplay
- **Responsive UI**: Optimized for various screen sizes

## Features
- **Realistic Physics**: Ball movement with gravity and collision detection
- **Flippers**: Left and right flippers for ball control
- **Bumpers**: Interactive bumpers that award points when hit
- **Scoring System**: Earn 100 points for each bumper hit
- **Game Over**: Game ends when the ball falls below the flippers
- **Restart**: Easy restart functionality

## Desktop Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/megatech81/pinball-game.git
   cd pinball-game
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

## How to Run

### Desktop Version
```bash
python pinball_game.py
```

### Mobile Version
See [Mobile Setup Guide](mobile/MOBILE_SETUP.md) for detailed instructions on building and deploying the mobile version.

## How to Play

### Desktop Controls
- **Left Arrow Key**: Activate left flipper
- **Right Arrow Key**: Activate right flipper
- **Spacebar**: Launch ball (when ball is at starting position)
- **R**: Restart game (when game over)

### Mobile Controls
- **Tap Left Side**: Activate left flipper
- **Tap Right Side**: Activate right flipper
- **Tap Top Area**: Launch ball
- **Tap Anywhere**: Restart game (when game over)

### Objective
- Use the flippers to keep the ball in play
- Hit the blue bumpers to score points (100 points each)
- Try to achieve the highest score possible
- The game ends when the ball falls below the flippers

### Tips
- Time your flipper activation to send the ball toward bumpers
- The flippers provide more force when actively pressed
- Ball physics include gravity and realistic bouncing

## Technical Details

### Desktop Version
- **Language**: Python 3
- **Graphics Library**: pygame 2.5.2
- **Resolution**: 800x900 pixels
- **FPS**: 60 frames per second

### Mobile Version
- **Engine**: Godot 4.3+
- **Platforms**: Android, iOS
- **Resolution**: 720x1280 pixels (mobile portrait)
- **Rendering**: Mobile-optimized pipeline
- **Graphics**: Enhanced textures, particles, and lighting effects

## Development

For mobile development setup, build instructions, and deployment guidelines, see the [Mobile Setup Guide](mobile/MOBILE_SETUP.md).

## Project Structure

```
pinball-game/
├── pinball_game.py          # Desktop Python version
├── requirements.txt         # Python dependencies
├── README.md               # This file
├── PROJECT_PLAN.md         # Development plan
└── mobile/                 # Mobile Godot version
    ├── project.godot       # Godot project configuration
    ├── scenes/            # Game scenes
    ├── scripts/           # Game logic scripts
    ├── assets/            # Graphics and audio assets
    ├── export_presets.cfg # Mobile export settings
    └── MOBILE_SETUP.md    # Mobile development guide
```

Enjoy playing the pinball game on your preferred platform!