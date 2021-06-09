# Hardware
I used a Raspberry PI 3 B+ with a custom PCB mounted on top that handles signal level conversion and the connection with the leds through a custom made wire. Below is a parts list with everything I used, and all the files for the custom pcb I designed using kicad are also in this directory. I chose to switch to using a 4 pin connector in case I ever decide that I would like to use WS2815 leds instead of W2812b due to the fact that the WS2812b's suffer from lots of voltage drop.

## Parts used
* Raspberry PI 3 B+
* 3.3v -> 5v Logic Level Converter ([BOB-12009](https://www.digikey.com/en/products/detail/sparkfun-electronics/BOB-12009/5673795?s=N4IgTCBcDaIEIHk4FoCMYAMGCcIC6AvkA))
* WS2812b LED light strip
* [5v Barrel Powerjack](https://www.digikey.com/en/products/detail/cui-devices/PJ-063AH/2161208)
* Micro-Fit 3.0 Molex Connectors
    * [Header connector](https://www.digikey.com/en/products/detail/molex/0430450400/252527?s=N4IgTCBcDaIOoFkCMAOJAWAtAOQCIgF0BfIA)
    * [Cable Assembly](https://www.digikey.com/en/products/detail/molex/0451320401/6208003?s=N4IgTCBcDaIAQMQg6gWQIwDZ1YLQDkAREAXQF8g)
* 03/18 Solid Core Thermostat Cable
* 5v power supply
* [Custom designed pcb](raspberrypi-led-hat)
