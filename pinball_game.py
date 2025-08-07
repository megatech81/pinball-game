#!/usr/bin/env python3
"""
Pinball Game - A classic pinball game implementation using pygame
"""

import pygame
import math
import random
import sys

# Initialize Pygame
pygame.init()

# Constants
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 900
FPS = 60

# Colors
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
RED = (255, 0, 0)
BLUE = (0, 0, 255)
GREEN = (0, 255, 0)
YELLOW = (255, 255, 0)
GRAY = (128, 128, 128)
SILVER = (192, 192, 192)

class Ball:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.vx = 0
        self.vy = 0
        self.radius = 8
        self.gravity = 0.5
        self.bounce_damping = 0.8
        
    def update(self):
        # Apply gravity
        self.vy += self.gravity
        
        # Update position
        self.x += self.vx
        self.y += self.vy
        
        # Bounce off walls
        if self.x - self.radius <= 0 or self.x + self.radius >= SCREEN_WIDTH:
            self.vx = -self.vx * self.bounce_damping
            self.x = max(self.radius, min(SCREEN_WIDTH - self.radius, self.x))
            
        # Bounce off top wall
        if self.y - self.radius <= 0:
            self.vy = -self.vy * self.bounce_damping
            self.y = self.radius
    
    def draw(self, screen):
        pygame.draw.circle(screen, WHITE, (int(self.x), int(self.y)), self.radius)
        pygame.draw.circle(screen, GRAY, (int(self.x), int(self.y)), self.radius, 2)

class Flipper:
    def __init__(self, x, y, is_left=True):
        self.x = x
        self.y = y
        self.is_left = is_left
        self.angle = -30 if is_left else 30  # Default angle
        self.active_angle = -60 if is_left else 60  # Active angle when pressed
        self.current_angle = self.angle
        self.length = 80
        self.width = 8
        self.activated = False
        
    def update(self, pressed):
        target_angle = self.active_angle if pressed else self.angle
        # Smooth angle transition
        if abs(self.current_angle - target_angle) > 2:
            self.current_angle += (target_angle - self.current_angle) * 0.3
        else:
            self.current_angle = target_angle
        self.activated = pressed
    
    def get_end_position(self):
        angle_rad = math.radians(self.current_angle)
        end_x = self.x + math.cos(angle_rad) * self.length
        end_y = self.y + math.sin(angle_rad) * self.length
        return end_x, end_y
    
    def draw(self, screen):
        end_x, end_y = self.get_end_position()
        color = YELLOW if self.activated else SILVER
        pygame.draw.line(screen, color, (self.x, self.y), (end_x, end_y), self.width)
        pygame.draw.circle(screen, color, (int(self.x), int(self.y)), self.width // 2)
    
    def check_collision(self, ball):
        # Simple collision detection with flipper line
        end_x, end_y = self.get_end_position()
        
        # Distance from ball center to line
        A = self.y - end_y
        B = end_x - self.x
        C = self.x * end_y - end_x * self.y
        
        distance = abs(A * ball.x + B * ball.y + C) / math.sqrt(A * A + B * B)
        
        if distance <= ball.radius + self.width // 2:
            # Check if collision point is on the line segment
            dot_product = ((ball.x - self.x) * (end_x - self.x) + 
                          (ball.y - self.y) * (end_y - self.y))
            line_length_sq = (end_x - self.x) ** 2 + (end_y - self.y) ** 2
            
            if 0 <= dot_product <= line_length_sq:
                # Collision detected, apply force
                if self.activated:
                    # Strong upward force when flipper is activated
                    angle_rad = math.radians(self.current_angle - 90)
                    force = 15
                    ball.vx += math.cos(angle_rad) * force
                    ball.vy += math.sin(angle_rad) * force
                else:
                    # Gentle bounce
                    ball.vy *= -0.8
                return True
        return False

class Bumper:
    def __init__(self, x, y, radius=30):
        self.x = x
        self.y = y
        self.radius = radius
        self.hit_animation = 0
        self.points = 100
        
    def update(self):
        if self.hit_animation > 0:
            self.hit_animation -= 1
    
    def draw(self, screen):
        color = RED if self.hit_animation > 0 else BLUE
        pygame.draw.circle(screen, color, (int(self.x), int(self.y)), self.radius)
        pygame.draw.circle(screen, WHITE, (int(self.x), int(self.y)), self.radius, 3)
    
    def check_collision(self, ball):
        distance = math.sqrt((ball.x - self.x) ** 2 + (ball.y - self.y) ** 2)
        if distance <= ball.radius + self.radius:
            # Calculate collision normal
            normal_x = (ball.x - self.x) / distance
            normal_y = (ball.y - self.y) / distance
            
            # Reflect velocity
            dot_product = ball.vx * normal_x + ball.vy * normal_y
            ball.vx -= 2 * dot_product * normal_x
            ball.vy -= 2 * dot_product * normal_y
            
            # Add some extra force
            ball.vx += normal_x * 5
            ball.vy += normal_y * 5
            
            # Move ball outside bumper
            overlap = ball.radius + self.radius - distance
            ball.x += normal_x * overlap
            ball.y += normal_y * overlap
            
            # Animation and scoring
            self.hit_animation = 10
            return True
        return False

class PinballGame:
    def __init__(self):
        self.screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
        pygame.display.set_caption("Pinball Game")
        self.clock = pygame.time.Clock()
        
        # Game objects
        self.ball = Ball(SCREEN_WIDTH // 2, 100)
        self.left_flipper = Flipper(250, SCREEN_HEIGHT - 120, True)
        self.right_flipper = Flipper(550, SCREEN_HEIGHT - 120, False)
        
        # Create bumpers
        self.bumpers = [
            Bumper(200, 300),
            Bumper(400, 250),
            Bumper(600, 300),
            Bumper(300, 450),
            Bumper(500, 450),
        ]
        
        # Game state
        self.score = 0
        self.game_over = False
        self.font = pygame.font.Font(None, 36)
        self.big_font = pygame.font.Font(None, 72)
        
        # Ball launch
        self.ball.vx = random.uniform(-2, 2)
        self.ball.vy = 5
    
    def handle_events(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_r and self.game_over:
                    self.restart_game()
                elif event.key == pygame.K_SPACE and not self.game_over:
                    # Launch ball if it's at starting position
                    if self.ball.y < 150:
                        self.ball.vx = random.uniform(-3, 3)
                        self.ball.vy = 8
        return True
    
    def update(self):
        if self.game_over:
            return
            
        # Get keyboard input for flippers
        keys = pygame.key.get_pressed()
        self.left_flipper.update(keys[pygame.K_LEFT])
        self.right_flipper.update(keys[pygame.K_RIGHT])
        
        # Update ball
        self.ball.update()
        
        # Check flipper collisions
        self.left_flipper.check_collision(self.ball)
        self.right_flipper.check_collision(self.ball)
        
        # Check bumper collisions
        for bumper in self.bumpers:
            bumper.update()
            if bumper.check_collision(self.ball):
                self.score += bumper.points
        
        # Check game over condition
        if self.ball.y > SCREEN_HEIGHT:
            self.game_over = True
    
    def draw(self):
        self.screen.fill(BLACK)
        
        # Draw game objects
        self.ball.draw(self.screen)
        self.left_flipper.draw(self.screen)
        self.right_flipper.draw(self.screen)
        
        for bumper in self.bumpers:
            bumper.draw(self.screen)
        
        # Draw walls
        pygame.draw.rect(self.screen, WHITE, (0, 0, SCREEN_WIDTH, 10))  # Top wall
        pygame.draw.rect(self.screen, WHITE, (0, 0, 10, SCREEN_HEIGHT))  # Left wall
        pygame.draw.rect(self.screen, WHITE, (SCREEN_WIDTH - 10, 0, 10, SCREEN_HEIGHT))  # Right wall
        
        # Draw score
        score_text = self.font.render(f"Score: {self.score}", True, WHITE)
        self.screen.blit(score_text, (10, 20))
        
        # Draw controls
        controls_text = self.font.render("Left/Right arrows: Flippers  Space: Launch", True, WHITE)
        self.screen.blit(controls_text, (10, SCREEN_HEIGHT - 40))
        
        # Draw game over screen
        if self.game_over:
            game_over_text = self.big_font.render("GAME OVER", True, RED)
            restart_text = self.font.render("Press R to Restart", True, WHITE)
            
            game_over_rect = game_over_text.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2))
            restart_rect = restart_text.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2 + 60))
            
            self.screen.blit(game_over_text, game_over_rect)
            self.screen.blit(restart_text, restart_rect)
        
        pygame.display.flip()
    
    def restart_game(self):
        self.ball = Ball(SCREEN_WIDTH // 2, 100)
        self.ball.vx = random.uniform(-2, 2)
        self.ball.vy = 5
        self.score = 0
        self.game_over = False
        
        # Reset bumpers
        for bumper in self.bumpers:
            bumper.hit_animation = 0
    
    def run(self):
        running = True
        while running:
            running = self.handle_events()
            self.update()
            self.draw()
            self.clock.tick(FPS)
        
        pygame.quit()
        sys.exit()

def main():
    game = PinballGame()
    game.run()

if __name__ == "__main__":
    main()