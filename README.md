# Pinball Game

This repository contains a classic pinball game implementation using Python and Pygame. The game features realistic pinball mechanics, including flippers, bumpers, ball physics, and a scoring system. The goal is to score as many points as possible by hitting bumpers and keeping the ball in play.

## Features
- **Realistic Ball Physics**: Gravity, bouncing, and momentum simulation
- **Flipper Controls**: Left and right flippers controlled by arrow keys
- **Bumpers**: Multiple bumpers that award points when hit
- **Scoring System**: Earn 100 points for each bumper hit
- **Lives System**: Start with 3 lives, lose one when ball falls below flippers
- **Game Over/Restart**: Complete game loop with restart functionality
- **Smooth Animations**: 60 FPS gameplay with smooth ball movement and flipper action

## Installation

### Prerequisites
- Python 3.6 or higher
- pip (Python package installer)

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/megatech81/pinball-game.git
   cd pinball-game
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the game**:
   ```bash
   python pinball.py
   ```

## How to Play

### Controls
- **Left Arrow Key**: Activate left flipper
- **Right Arrow Key**: Activate right flipper
- **R Key**: Reset ball position (when ball falls off screen)
- **Space Bar**: Restart game (when game over)

### Gameplay
1. Use the left and right arrow keys to control the flippers
2. Keep the ball in play by hitting it with the flippers
3. Hit the red bumpers to score points (100 points each)
4. Bumpers will flash yellow when hit
5. You start with 3 lives
6. Lose a life when the ball falls below the flippers
7. Game ends when all lives are lost
8. Try to achieve the highest score possible!

### Game Elements
- **White Ball**: The pinball that you control with the flippers
- **Silver Flippers**: Use these to hit the ball and keep it in play
- **Red Bumpers**: Hit these to score points and get extra ball momentum
- **Score Display**: Shows current score and remaining lives

## Development

### Project Structure
```
pinball-game/
├── pinball.py          # Main game implementation
├── requirements.txt    # Python dependencies
└── README.md          # This file
```

### Technical Details
- Built with Python and Pygame
- Object-oriented design with separate classes for Ball, Flipper, Bumper, and Game
- Real-time collision detection and physics simulation
- 60 FPS smooth gameplay

## Contributing
Feel free to fork this repository and submit pull requests for improvements or new features!

## License
This project is open source. Feel free to use and modify as needed.