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

# Set the dimensions for the white rectangular block
white_box_size = 10
white_box_color = (255, 255, 255)
white_box_x = border_thickness
white_box_y = screen_height - border_height + border_thickness

pygame.quit()