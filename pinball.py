import pygame
import math
import random

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
SILVER = (192, 192, 192)
GRAY = (128, 128, 128)

class Ball:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.radius = 8
        self.vel_x = 0
        self.vel_y = 0
        self.gravity = 0.3
        self.bounce_damping = 0.8
        
    def update(self):
        # Apply gravity
        self.vel_y += self.gravity
        
        # Update position
        self.x += self.vel_x
        self.y += self.vel_y
        
        # Bounce off walls
        if self.x - self.radius <= 0 or self.x + self.radius >= SCREEN_WIDTH:
            self.vel_x = -self.vel_x * self.bounce_damping
            self.x = max(self.radius, min(SCREEN_WIDTH - self.radius, self.x))
            
        if self.y - self.radius <= 0:
            self.vel_y = -self.vel_y * self.bounce_damping
            self.y = self.radius
            
    def draw(self, screen):
        pygame.draw.circle(screen, WHITE, (int(self.x), int(self.y)), self.radius)
        pygame.draw.circle(screen, GRAY, (int(self.x), int(self.y)), self.radius, 2)

class Flipper:
    def __init__(self, x, y, side):
        self.x = x
        self.y = y
        self.side = side  # 'left' or 'right'
        self.angle = 0
        self.max_angle = 45 if side == 'left' else -45
        self.length = 80
        self.width = 10
        self.active = False
        self.rotation_speed = 15
        
    def update(self):
        if self.active:
            if self.side == 'left':
                self.angle = min(self.angle + self.rotation_speed, self.max_angle)
            else:
                self.angle = max(self.angle - self.rotation_speed, self.max_angle)
        else:
            if self.side == 'left':
                self.angle = max(self.angle - self.rotation_speed, 0)
            else:
                self.angle = min(self.angle + self.rotation_speed, 0)
    
    def get_end_pos(self):
        rad = math.radians(self.angle)
        end_x = self.x + self.length * math.cos(rad)
        end_y = self.y - self.length * math.sin(rad)
        return end_x, end_y
        
    def draw(self, screen):
        end_x, end_y = self.get_end_pos()
        pygame.draw.line(screen, SILVER, (self.x, self.y), (end_x, end_y), self.width)
        pygame.draw.circle(screen, GRAY, (int(self.x), int(self.y)), 8)
        
    def check_collision(self, ball):
        # Simple collision detection with flipper
        end_x, end_y = self.get_end_pos()
        
        # Distance from ball to flipper line
        line_length = math.sqrt((end_x - self.x)**2 + (end_y - self.y)**2)
        if line_length == 0:
            return False
            
        # Vector from flipper start to ball
        ball_vec_x = ball.x - self.x
        ball_vec_y = ball.y - self.y
        
        # Vector along flipper
        flipper_vec_x = (end_x - self.x) / line_length
        flipper_vec_y = (end_y - self.y) / line_length
        
        # Project ball vector onto flipper vector
        projection = ball_vec_x * flipper_vec_x + ball_vec_y * flipper_vec_y
        projection = max(0, min(line_length, projection))
        
        # Closest point on flipper to ball
        closest_x = self.x + projection * flipper_vec_x
        closest_y = self.y + projection * flipper_vec_y
        
        # Distance from ball to closest point
        distance = math.sqrt((ball.x - closest_x)**2 + (ball.y - closest_y)**2)
        
        if distance <= ball.radius + self.width/2:
            # Calculate bounce
            normal_x = (ball.x - closest_x) / distance
            normal_y = (ball.y - closest_y) / distance
            
            # Reflect velocity
            dot_product = ball.vel_x * normal_x + ball.vel_y * normal_y
            ball.vel_x -= 2 * dot_product * normal_x
            ball.vel_y -= 2 * dot_product * normal_y
            
            # Add flipper force if active
            if self.active:
                force = 15
                ball.vel_x += normal_x * force
                ball.vel_y += normal_y * force
            
            # Move ball out of collision
            ball.x = closest_x + normal_x * (ball.radius + self.width/2 + 1)
            ball.y = closest_y + normal_y * (ball.radius + self.width/2 + 1)
            
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
        color = YELLOW if self.hit_animation > 0 else RED
        pygame.draw.circle(screen, color, (int(self.x), int(self.y)), self.radius)
        pygame.draw.circle(screen, BLACK, (int(self.x), int(self.y)), self.radius, 3)
        
    def check_collision(self, ball):
        distance = math.sqrt((ball.x - self.x)**2 + (ball.y - self.y)**2)
        if distance <= ball.radius + self.radius:
            # Calculate bounce direction
            if distance == 0:
                return False
                
            normal_x = (ball.x - self.x) / distance
            normal_y = (ball.y - self.y) / distance
            
            # Reflect velocity with some added force
            dot_product = ball.vel_x * normal_x + ball.vel_y * normal_y
            ball.vel_x -= 2 * dot_product * normal_x
            ball.vel_y -= 2 * dot_product * normal_y
            
            # Add some extra bounce force
            force = 8
            ball.vel_x += normal_x * force
            ball.vel_y += normal_y * force
            
            # Move ball out of collision
            ball.x = self.x + normal_x * (ball.radius + self.radius + 1)
            ball.y = self.y + normal_y * (ball.radius + self.radius + 1)
            
            # Trigger animation
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
        self.left_flipper = Flipper(SCREEN_WIDTH // 2 - 120, SCREEN_HEIGHT - 100, 'left')
        self.right_flipper = Flipper(SCREEN_WIDTH // 2 + 120, SCREEN_HEIGHT - 100, 'right')
        
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
        self.lives = 3
        self.game_over = False
        self.font = pygame.font.Font(None, 36)
        
    def handle_events(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE and self.game_over:
                    self.reset_game()
                elif event.key == pygame.K_r and self.ball.y > SCREEN_HEIGHT:
                    self.reset_ball()
                    
        # Handle flipper controls
        keys = pygame.key.get_pressed()
        self.left_flipper.active = keys[pygame.K_LEFT]
        self.right_flipper.active = keys[pygame.K_RIGHT]
        
        return True
        
    def reset_ball(self):
        if self.lives > 0:
            self.ball = Ball(SCREEN_WIDTH // 2, 100)
            self.ball.vel_x = random.randint(-3, 3)
            self.ball.vel_y = 0
        
    def reset_game(self):
        self.ball = Ball(SCREEN_WIDTH // 2, 100)
        self.score = 0
        self.lives = 3
        self.game_over = False
        
    def update(self):
        if not self.game_over:
            # Update game objects
            self.ball.update()
            self.left_flipper.update()
            self.right_flipper.update()
            
            for bumper in self.bumpers:
                bumper.update()
                
            # Check collisions
            self.left_flipper.check_collision(self.ball)
            self.right_flipper.check_collision(self.ball)
            
            for bumper in self.bumpers:
                if bumper.check_collision(self.ball):
                    self.score += bumper.points
                    
            # Check if ball fell below flippers (game over condition)
            if self.ball.y > SCREEN_HEIGHT:
                self.lives -= 1
                if self.lives <= 0:
                    self.game_over = True
                else:
                    self.reset_ball()
                    
    def draw(self):
        self.screen.fill(BLACK)
        
        # Draw game objects
        if not self.game_over or self.ball.y <= SCREEN_HEIGHT:
            self.ball.draw(self.screen)
            
        self.left_flipper.draw(self.screen)
        self.right_flipper.draw(self.screen)
        
        for bumper in self.bumpers:
            bumper.draw(self.screen)
            
        # Draw borders
        pygame.draw.rect(self.screen, WHITE, (0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), 5)
        
        # Draw UI
        score_text = self.font.render(f"Score: {self.score}", True, WHITE)
        lives_text = self.font.render(f"Lives: {self.lives}", True, WHITE)
        self.screen.blit(score_text, (10, 10))
        self.screen.blit(lives_text, (10, 50))
        
        # Draw controls
        controls_text = self.font.render("Controls: Left/Right arrows for flippers", True, WHITE)
        self.screen.blit(controls_text, (10, SCREEN_HEIGHT - 60))
        
        if self.ball.y > SCREEN_HEIGHT and not self.game_over:
            reset_text = self.font.render("Press R to reset ball", True, WHITE)
            self.screen.blit(reset_text, (SCREEN_WIDTH // 2 - 120, SCREEN_HEIGHT // 2))
            
        if self.game_over:
            game_over_text = self.font.render("GAME OVER", True, RED)
            restart_text = self.font.render("Press SPACE to restart", True, WHITE)
            final_score_text = self.font.render(f"Final Score: {self.score}", True, WHITE)
            
            self.screen.blit(game_over_text, (SCREEN_WIDTH // 2 - 100, SCREEN_HEIGHT // 2 - 50))
            self.screen.blit(final_score_text, (SCREEN_WIDTH // 2 - 120, SCREEN_HEIGHT // 2))
            self.screen.blit(restart_text, (SCREEN_WIDTH // 2 - 140, SCREEN_HEIGHT // 2 + 50))
        
        pygame.display.flip()
        
    def run(self):
        running = True
        while running:
            running = self.handle_events()
            self.update()
            self.draw()
            self.clock.tick(FPS)
            
        pygame.quit()

if __name__ == "__main__":
    game = PinballGame()
    game.run()