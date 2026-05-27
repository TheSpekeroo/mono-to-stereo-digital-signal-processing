import pygame
from pydub import AudioSegment
import tempfile
import os
import threading

def get_angle_input(angle_input):
    while True:
        try:
            angle = float(input("Enter angle (0.0 to 360.0): "))
            if 0.0 <= angle <= 360.0:
                # Normalize the angle to the range 0.0 to 1.0
                angle_input.append(angle)
            else:
                print("Angle must be between 0.0 and 360.0")
        except ValueError:
            print("Invalid input. Please enter a number.")

def play_audio(file_path, angle_input, volume_factor, channel):
    audio = AudioSegment.from_file(file_path)

    # Save the adjusted audio to a temporary WAV file with a unique name
    temp_path = tempfile.mktemp(suffix=".wav")
    audio.export(temp_path, format="wav")

    sound = pygame.mixer.Sound(temp_path)

    # Play the audio and adjust volume dynamically
    channel.play(sound)
    while channel.get_busy():
        if angle_input:
            angle = angle_input[0]
            # Adjust volume based on the angle and the provided volume_factor
            if volume_factor == 0:
                if 45 > angle >= 0:
                    volume = 1 - 0.5 * (angle / 45)
                elif 360 >= angle > 315:
                    volume = 0.5 + 0.5 * ((angle - 315) / 45)
                else:
                    volume = 0
            elif volume_factor == 1:
                if 90 > angle >= 45:
                    volume = 1 - 0.5 * ((angle - 45) / 45)
                elif 45 >= angle > 0:
                    volume = 0.5 + 0.5 * ((angle) / 45)
                else:
                    volume = 0
            elif volume_factor == 2:
                if 135 > angle >= 90:
                    volume = 1 - 0.5 * ((angle - 90) / 45)
                elif 90 >= angle > 45:
                    volume = 0.5 + 0.5 * ((angle - 45) / 45)
                else:
                    volume = 0
            elif volume_factor == 3:
                if 180 > angle >= 135:
                    volume = 1 - 0.5 * ((angle - 135) / 45)
                elif 135 >= angle > 90:
                    volume = 0.5 + 0.5 * ((angle - 90) / 45)
                else:
                    volume = 0
            elif volume_factor == 4:
                if 225 > angle >= 180:
                    volume = 1 - 0.5 * ((angle - 180) / 45)
                elif 180 >= angle > 135:
                    volume = 0.5 + 0.5 * ((angle - 135) / 45)
                else:
                    volume = 0
            elif volume_factor == 5:
                if 270 > angle >= 225:
                    volume = 1 - 0.5 * ((angle - 225) / 45)
                elif 225 >= angle > 180:
                    volume = 0.5 + 0.5 * ((angle - 180) / 45)
                else:
                    volume = 0
            elif volume_factor == 6:
                if 315 > angle >= 270:
                    volume = 1 - 0.5 * ((angle - 270) / 45)
                elif 270 >= angle > 225:
                    volume = 0.5 + 0.5 * ((angle - 225) / 45)
                else:
                    volume = 0
            elif volume_factor == 7:
                if 360 > angle >= 315:
                    volume = 1 - 0.5 * ((angle - 315) / 45)
                elif 315 >= angle > 270:
                    volume = 0.5 + 0.5 * ((angle - 270) / 45)
                else:
                    volume = 0
            channel.set_volume(volume)
            angle_input.pop(0) if angle_input else None  # Check if the list is not empty before popping

    # Remove the temporary file
    os.remove(temp_path)

def main():
    pygame.init()
    pygame.display.set_mode((1, 1))
    pygame.mixer.init()

    audio_files = [
        "processed_audio-0deg.mp3", "processed_audio-45deg.mp3", "processed_audio-90deg.mp3",
        "processed_audio-135deg.mp3", "processed_audio-180deg.mp3", "processed_audio-225deg.mp3",
        "processed_audio-270deg.mp3", "processed_audio-315deg.mp3"
    ]

    angle_input = []

    input_thread = threading.Thread(target=get_angle_input, args=(angle_input,))
    input_thread.daemon = True
    input_thread.start()

    print("Waiting for user input...")

    try:
        # Create eight Pygame mixer channels for each audio file
        channels = [pygame.mixer.Channel(i) for i in range(8)]

        while True:
            if angle_input:
                angle = angle_input[0]
                print(f"Playing audio files with angle {angle} degrees...")

                # Use threads to play all audio files simultaneously
                threads = []
                for i in range(8):
                    thread = threading.Thread(target=play_audio, args=(audio_files[i], angle_input, i, channels[i]))
                    thread.start()
                    threads.append(thread)

                # Wait for all threads to finish
                for thread in threads:
                    thread.join()

    except KeyboardInterrupt:
        pass
    finally:
        pygame.mixer.quit()
        pygame.quit()

if __name__ == "__main__":
    main()
