import asyncio
import websockets
from kivy.app import App
from kivy.uix.label import Label
from kivy.uix.boxlayout import BoxLayout
from kivy.clock import Clock
from plyer import gyroscope

class GyroscopeApp(App):
    def build(self):
        self.message_label = Label(text="Gyroscope Data:\nX=0.0\nY=0.0\nZ=0.0")
        layout = BoxLayout(orientation='vertical')
        layout.add_widget(self.message_label)

        self.enable_gyroscope()
        self.start_gyroscope_data_collection()

        return layout

    def enable_gyroscope(self):
        gyroscope.enable()

    def get_gyroscope_data(self):
        return gyroscope.rotation

    async def send_gyroscope_data(self, websocket):
        while True:
            gyroscope_data = self.get_gyroscope_data()
            message = f"Gyroscope Data:\nX={gyroscope_data[0]:.2f}\nY={gyroscope_data[1]:.2f}\nZ={gyroscope_data[2]:.2f}"
            self.message_label.text = message

            print(message)
            await websocket.send(message)
            await asyncio.sleep(1)

    def start_gyroscope_data_collection(self):
        # Use Clock.schedule_once to start the asyncio event loop
        from functools import partial
        Clock.schedule_once(partial(asyncio.run, self.hello))

    async def hello(self, dt):
        uri = "ws://192.168.0.23:8765"
        async with websockets.connect(uri) as websocket:
            print("WebSocket connection established.")
            await self.send_gyroscope_data(websocket)

if __name__ == "__main__":
    GyroscopeApp().run()
