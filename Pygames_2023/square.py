import pygame

# Import pygame.locals for easier access to key coordinates
# Updated to conform to flake8 and black standards
from pygame.locals import (
    K_UP,
    K_DOWN,
    K_LEFT,
    K_RIGHT,
    K_ESCAPE,
    KEYDOWN,
    QUIT,
)

# Define constants for the screen width and height
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600

# Define a Player object by extending pygame.sprite.Sprite
# The surface drawn on the screen is now an attribute of 'player'
class Player(pygame.sprite.Sprite):
    def __init__(self):
        super(Player, self).__init__()
        self.surf = pygame.Surface((75, 25))
        self.surf.fill((0, 0, 0))
        self.rect = self.surf.get_rect()

# Initialize pygame
pygame.init()

# Create the screen object
# The size is determined by the constant SCREEN_WIDTH and SCREEN_HEIGHT
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))

# Instantiate player. Right now, this is just a rectangle.
player = Player()

# set the pygame window name
pygame.display.set_caption('The Square')
 
# Create game text font object.
game_text_font = pygame.font.Font('freesansbold.ttf', 32)

# game font color
game_text_font_color = (0, 0, 128)
 
# create a game text surface object,
game_text = game_text_font.render('Use the arrow key to get the gold coin', True,game_text_font_color) # update

# game text position
game_font_position = (20,20)

# Variable to keep the main loop running
running = True

# Main loop
while running:
    # Look at every event in the queue
    for event in pygame.event.get():
        # Did the user hit a key?
        if event.type == KEYDOWN:
            # Was it the Escape key? If so, stop the loop.
            if event.key == K_ESCAPE:
                running = False
            #if event.key in [K_UP, K_DOWN,K_LEFT,K_RIGHT]:
            #    start game logic
        # Did the user click the window close button? If so, stop the loop.
        elif event.type == QUIT:
            running = False

        ## Fill the screen with color white
        screen.fill((255,255,255)) ## change this to a shade of blu

        # Create a surface to pass in a
        surf = pygame.Surface((50,50)) # this will be randomely generated

        # Put the center of surf at the center of the display
        surf_center = (
            (SCREEN_WIDTH-surf.get_width())/2,
            (SCREEN_HEIGHT-surf.get_height())/2
        ) ## change this to randomely generate a position with a certain range

        # Draw surf at the new coordinates
        screen.blit(player.surf, surf_center)
        screen.blit(game_text,game_font_position)
        pygame.display.flip()
        


pygame.quit()