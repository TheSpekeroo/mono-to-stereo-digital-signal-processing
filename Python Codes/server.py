import asyncio
import websockets

async def handle_gyroscope_data(websocket, path):
    try:
        while True:
            gyroscope_data = await websocket.recv()
            print(f"Received gyroscope data: {gyroscope_data}")

            # You can perform further processing or respond to the client if needed

    except websockets.exceptions.ConnectionClosedError:
        print("Client disconnected")

async def main():
    server = await websockets.serve(handle_gyroscope_data, "0.0.0.0", 8765)
    print(f"WebSocket server is now listening on ws://0.0.0.0:8765")

    # Run the server indefinitely
    await server.wait_closed()

if __name__ == "__main__":
    asyncio.run(main())
