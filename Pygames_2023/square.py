import pygame
import random

# Initialize Pygame
pygame.init()

# Set the dimensions of the game screen
screen_width = 800
screen_height = 600

# Create the game screen
screen = pygame.display.set_mode((screen_width, screen_height))
pygame.display.set_caption("The Square")

# Set the color for the game screen
WHITE = (255, 255, 255)
screen.fill(WHITE)

# Set the position of the score text
score_x = screen_width - 100
score_y = 50
# Create the score text
score_text = font.render("Score: 0", True, (0, 0, 0))

# Set up the instructions
instruction_font = pygame.font.Font(None, 24)
instruction_color = (0, 0, 0)
instruction_text = "Use the arrow keys to get the gold coin"
instruction_x = (screen_width - instruction_font.size(instruction_text)[0]) // 2
instruction_y = screen_height - instruction_font.size(instruction_text)[1] - 10

# Set the dimensions for the black rectangular border
border_width = 200
border_height = 150
border_thickness = 10
border_color = (0, 0, 0)

# Set the dimensions for the white rectangular block & initial position
white_box_size = 10
white_box_color = (255, 255, 255)
white_box_x = border_thickness
white_box_y = screen_height - border_height + border_thickness

# Set up the gold box
gold_box_size = 10
gold_box_color = (255, 215, 0)
gold_box_x = random.randint(border_thickness, screen_width - border_thickness - gold_box_size)
gold_box_y = random.randint(screen_height - border_height + border_thickness, screen_height - gold_box_size)

# Set up the black box
black_box_size = 10
black_box_color = (0, 0, 0)
black_box_x = random.randint(border_thickness, screen_width - border_thickness - black_box_size)
black_box_y = random.randint(screen_height - border_height + border_thickness, screen_height - black_box_size)
black_box_direction = random.choice(["left", "right", "up", "down"])
black_box_speed = 2

# Load the sounds
pygame.mixer.music.load("background_music.mp3")
collision_sound = pygame.mixer.Sound("collision_sound.wav")

# Start the game
#pygame.mixer.music.play(-1)
#game_started = False

# Set up the clock
#clock = pygame.time.Clock()

pygame.quit()