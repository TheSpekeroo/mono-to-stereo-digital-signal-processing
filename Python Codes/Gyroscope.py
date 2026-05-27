import pygame
from plyer import gyroscope

def enable_gyroscope():
    gyroscope.enable()

def get_gyroscope_data():
    return gyroscope.rotation

def main():
    enable_gyroscope()

    pygame.init()
    pygame.display.set_caption("Gyroscope Data")

    screen = pygame.display.set_mode((400, 300))
    clock = pygame.time.Clock()

    font_size = 100
    font = pygame.font.Font(None, font_size)

    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        screen.fill((255, 255, 255))

        gyroscope_data = get_gyroscope_data()
        
        # Format the text
        text_x = f"x = {gyroscope_data[0]}"
        text_y = f"y = {gyroscope_data[1]}"
        text_z = f"z = {gyroscope_data[2]}"
        
        # Render the text
        rendered_text_x = font.render(text_x, True, (0, 0, 0))
        rendered_text_y = font.render(text_y, True, (0, 0, 0))
        rendered_text_z = font.render(text_z, True, (0, 0, 0))

        # Blit the text to the screen
        screen.blit(rendered_text_x, (10, 10))
        screen.blit(rendered_text_y, (10, 120))
        screen.blit(rendered_text_z, (10, 230))

        pygame.display.flip()
        clock.tick(60)

    gyroscope.disable()
    pygame.quit()

if __name__ == "__main__":
    main()
