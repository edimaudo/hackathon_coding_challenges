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

# Set the dimensions for the black rectangular border
border_width = 200
border_height = 150
border_thickness = 50

# Set the dimensions for the white rectangular block
block_size = 10

# Set the position of the score text
score_x = screen_width - 100
score_y = 50

# Create the score text
score_text = font.render("Score: 0", True, (0, 0, 0))


pygame.quit()