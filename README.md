# Pinball Game

A classic pinball game implementation using Python and pygame. The game features realistic pinball physics, flippers, bumpers, and a scoring system. The goal is to score as many points as possible by hitting bumpers and keeping the ball in play using the flippers.

## Features
- **Realistic Physics**: Ball movement with gravity and collision detection
- **Flippers**: Left and right flippers controlled by arrow keys
- **Bumpers**: Interactive bumpers that give points when hit
- **Scoring System**: Earn 100 points for each bumper hit
- **Game Over**: Game ends when the ball falls below the flippers
- **Restart**: Easy restart functionality

## Installation

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

Run the game using Python:
```bash
python pinball_game.py
```

## How to Play

### Controls
- **Left Arrow Key**: Activate left flipper
- **Right Arrow Key**: Activate right flipper
- **Spacebar**: Launch ball (when ball is at starting position)
- **R**: Restart game (when game over)

### Objective
- Use the flippers to keep the ball in play
- Hit the blue bumpers to score points (100 points each)
- Try to achieve the highest score possible
- The game ends when the ball falls below the flippers

### Tips
- Time your flipper activation to send the ball toward bumpers
- The flippers provide more force when actively pressed
- Ball physics include gravity and realistic bouncing

## Game Mechanics

- **Ball Physics**: The ball responds to gravity and bounces off walls and objects
- **Flipper Control**: Flippers have two positions - rest and active (when key is pressed)
- **Bumpers**: Five bumpers are placed strategically on the playfield
- **Collision Detection**: Realistic collision detection between ball, flippers, and bumpers
- **Scoring**: Points are awarded when the ball hits bumpers

## Technical Details

- **Language**: Python 3
- **Graphics Library**: pygame 2.5.2
- **Resolution**: 800x900 pixels
- **FPS**: 60 frames per second

Enjoy playing the pinball game!