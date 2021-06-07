# rasp_leds
This project aims to control an LED strip (WS2812b) using a backend written in Rust with a react frontend running on a raspberry pi 3.

## How does it work?
The rust backend communicates with the frontend by using a JSON api written using serde and rocket

### Hardware
This program is designed to be ran on a Raspberry PI 3b with a custom PCB I designed to connect it to a WS2812b strip 

### Backend
The backend works by running the rocket server on the main thread, and a runner that controls the leds running on a different thread. Both threads commuicate using channels.

The runner is basically just a state machine that controls different patterns and also allows the strip to be put into an idle mode.

### Frontend
The frontend is written using ReactJS and communicates with the backend using JSON
