# FPGA Traffic Light Controller

A fully functional smart traffic light control system for a 4-way intersection, implemented in VHDL and deployed on the Intel Cyclone IV E FPGA (EP4CE115F29C7) using Intel Quartus Prime 18.1. The system manages two axes of vehicle traffic, handles pedestrian crossing requests, and coordinates multiple Finite State Machines running in parallel on hardware.

The project was completed as part of academic coursework at Hochschule Anhalt (Anhalt University of Applied Sciences) in 2024.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Module Descriptions](#module-descriptions)
- [Hardware Requirements](#hardware-requirements)
- [Pin Assignments](#pin-assignments)
- [Signal Encoding](#signal-encoding)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [License](#license)

---

## Overview

This project was designed to demonstrate how a real-world traffic intersection can be modeled and controlled at the hardware level using digital logic. Rather than relying on a microcontroller or software, all logic runs directly on the FPGA fabric using synthesized hardware circuits described in VHDL.

The design controls a 4-way intersection with two traffic axes:

- **X-axis**: lanes X1 and X2
- **Y-axis**: lanes Y1 and Y2

Each lane has a dedicated RGB traffic light (Red, Yellow, Green) for vehicles, and each crossing direction has a pedestrian signal (Red, Green) with a physical push button. The system safely coordinates all of these signals to prevent conflicting green lights and to allow pedestrian crossings at the appropriate time.

---

## Features

- 4-way intersection control with two independent traffic axes
- RGB vehicle traffic lights for each of the four lanes
- Pedestrian crossing support with push-button requests on all four directions
- Power-on startup sequence with yellow blinking initialization on all lights
- Priority-based FSM selector that switches cleanly between startup, normal traffic, and pedestrian modes
- On-board clock divider converting the 50 MHz board clock to a 1 Hz signal for human-visible LED timing
- Modular VHDL design with each functional block as a separate, reusable component
- Pre-compiled `.sof` bitstream included for direct FPGA programming without recompilation

---

## System Architecture

The design is built around six VHDL modules that are connected together in a top-level block diagram (`Trafic_light.bdf`). Three FSMs run in parallel, and a central selector module determines which one drives the LED outputs at any given time.

```
+-------------------------------------------------------------+
|                Top Level: Trafic_light.bdf                  |
|                                                             |
|  +----------------+     +----------------+                 |
|  | clock_divider  |     |  startup_fsm   |                 |
|  |  50 MHz to 1Hz |     |  (init blink)  |                 |
|  +-------+--------+     +-------+--------+                 |
|          |                      | startup_done             |
|          | slow_clk             v                          |
|          |              +----------------+                 |
|          +------------- | traffic_fsm    |                 |
|          |              | (main cycle)   |                 |
|          |              +-------+--------+                 |
|          |                      |                          |
|          +------------- +--------------------+             |
|          |              | pedestrian_request |             |
|          |              |       _fsm         |             |
|          |              +-------+------------+             |
|          |                      |                          |
|          |              +-------v--------+                 |
|          |              | fsm_selector   | (priority mux)  |
|          |              +-------+--------+                 |
|          |                      |                          |
|          |              +-------v--------+                 |
|          |              | led_organizer  |                 |
|          |              +-------+--------+                 |
|          |                      | 20 output pins           |
+----------+----------------------+----------------------------+
```

### FSM Priority Logic

The `fsm_selector` module applies the following priority order to determine which FSM controls the LEDs at any point in time:

```
1. startup_done = 0              =>  Startup FSM is in control
2. startup_done = 1,
   request_active = 1            =>  Pedestrian FSM is in control
3. startup_done = 1,
   request_active = 0            =>  Traffic FSM is in control
```

This guarantees that the startup sequence always runs first, pedestrian requests are never ignored when it is safe to serve them, and normal traffic cycling takes over when nothing else requires attention.

---

## Module Descriptions

### clock_divider.vhd

Generates a 1 Hz clock from the 50 MHz on-board oscillator. It uses a counter with a threshold of 25,000,000, toggling the output clock every half second. This slow clock is fed to all FSMs so that state transitions happen at a rate that is visible to the human eye. Without this module, state changes would occur millions of times per second and no LED change would be visible.

### startup_fsm.vhd

Runs once on power-on or reset. It blinks all yellow lights five times (ten clock ticks at 1 Hz) as a system initialization signal, then asserts a `startup_done` flag to hand control over to the main traffic FSM. This mimics the real-world behavior of traffic systems that run a self-test sequence before entering normal operation.

### traffic_fsm.vhd

The main traffic control state machine. It cycles through the following states continuously:

```
IDLE -> X_GREEN -> X_YELLOW -> Y_GREEN -> Y_YELLOW -> (back to X_GREEN)
```

When X is green, lanes X1 and X2 show green lights, and Y1 and Y2 show red. When X turns yellow, the system is transitioning before giving the other axis the right of way. Pedestrian lights are held at red during normal traffic operation and are only activated by the pedestrian FSM.

### pedestrian_request_fsm.vhd

Monitors four pedestrian push buttons, one per crossing direction. When a button is pressed, the request is latched and held until the system can safely serve it. A crossing is activated only when the corresponding traffic axis is currently showing green, which ensures that pedestrians never receive a green signal while vehicles on the same axis are also moving. The pedestrian green lasts for four clock cycles (four seconds) before the system returns to normal traffic control.

### fsm_selector.vhd

Acts as a 3-to-1 priority multiplexer for the LED output signals. It reads the `startup_done` and `request_active` flags and routes the correct FSM's outputs to the `led_organizer`. This clean separation means each FSM can be designed and tested independently without any awareness of the others.

### led_organizer.vhd

Takes the grouped LED output vectors from the selector and maps them to the 20 individual FPGA output pins. Vehicle light vectors are 3 bits wide (Red, Yellow, Green) and pedestrian light vectors are 2 bits wide (Red, Green). This module handles all the signal unpacking so that the rest of the design can work with clean, grouped data types.

---

## Hardware Requirements

| Property | Value |
|---|---|
| Target FPGA | Intel Cyclone IV E, EP4CE115F29C7 |
| Development Board | Terasic DE2-115 |
| EDA Tool | Intel Quartus Prime 18.1.0 Lite Edition |
| Input Clock | 50 MHz (on-board oscillator) |
| Operating Clock | 1 Hz (after clock division) |
| JTAG Programmer | USB Blaster or compatible |

---

## Pin Assignments

### Inputs

| Signal | FPGA Pin | Description |
|---|---|---|
| CLK | PIN_Y2 | 50 MHz system clock from on-board oscillator |
| Reset_MasterOFF | PIN_AG26 | Active-low master reset, clears all FSM states |
| X1F_Button | PIN_AH26 | Pedestrian crossing request button for X1 direction |
| X2F_Button | PIN_AG23 | Pedestrian crossing request button for X2 direction |
| Y1F_Button | PIN_AF26 | Pedestrian crossing request button for Y1 direction |
| Y2F_Button | PIN_AE24 | Pedestrian crossing request button for Y2 direction |

### Outputs: Vehicle Traffic Lights

| Lane | Red Pin | Yellow Pin | Green Pin |
|---|---|---|---|
| X1 | PIN_AF21 | PIN_AD22 | PIN_AD25 |
| X2 | PIN_Y16 | PIN_Y17 | PIN_AC15 |
| Y1 | PIN_AF15 | PIN_AE21 | PIN_AC22 |
| Y2 | PIN_AF16 | PIN_AE15 | PIN_AE16 |

### Outputs: Pedestrian Crossing Lights

| Crossing | Red Pin | Green Pin |
|---|---|---|
| X1F | PIN_AE22 | PIN_AF25 |
| X2F | PIN_AC19 | PIN_AD15 |
| Y1F | PIN_AD19 | PIN_AF24 |
| Y2F | PIN_AD21 | PIN_AC21 |

> Note: A test LED is connected to PIN_G19 for debugging purposes.

---

## Signal Encoding

All light signals throughout the design use a compact binary encoding:

**Vehicle lights (3-bit vector): [Red, Yellow, Green]**

| Encoding | Meaning |
|---|---|
| 100 | Red (stop) |
| 010 | Yellow (caution) |
| 001 | Green (go) |

**Pedestrian lights (2-bit vector): [Red, Green]**

| Encoding | Meaning |
|---|---|
| 10 | Red (do not cross) |
| 01 | Green (safe to cross) |

---

## Getting Started

### Prerequisites

- Intel Quartus Prime 18.1 or later (Lite Edition is sufficient for this device)
- Terasic DE2-115 board or any board with the EP4CE115F29C7 device
- USB Blaster or compatible JTAG programmer and cable

### 1. Clone the Repository

```bash
git clone https://github.com/NasserAlqeifi/fpga-traffic-light-controller.git
cd fpga-traffic-light-controller
```

### 2. Open the Project

1. Launch Intel Quartus Prime.
2. Go to **File -> Open Project**.
3. Navigate to the cloned folder and select `Trafic_light.qpf`.

### 3. Compile (Optional)

If you want to recompile the design from source:

1. Click **Processing -> Start Compilation** or press `Ctrl + L`.
2. The compiled bitstream will be written to `output_files/Trafic_light.sof`.

A pre-compiled `.sof` file is already included in the repository if you want to skip this step.

### 4. Program the FPGA

1. Connect the DE2-115 board to your computer via USB Blaster.
2. Power on the board.
3. In Quartus Prime, open **Tools -> Programmer**.
4. Click **Add File** and select `output_files/Trafic_light.sof`.
5. Make sure the USB Blaster is detected under **Hardware Setup**.
6. Click **Start** to program the board.

The system will immediately run the startup blink sequence and then enter normal traffic operation.

---

## Project Structure

```
fpga-traffic-light-controller/
|
|-- Trafic_light.qpf                  Quartus project file
|-- Trafic_light.qsf                  Quartus settings, pin assignments, and device config
|-- Trafic_light.bdf                  Top-level block diagram connecting all modules
|
|-- clock_divider.vhd                 Clock divider: 50 MHz to 1 Hz
|-- startup_fsm.vhd                   Startup initialization FSM
|-- traffic_fsm.vhd                   Main traffic light control FSM
|-- pedestrian_request_fsm.vhd        Pedestrian crossing request FSM
|-- fsm_selector.vhd                  Priority-based FSM output multiplexer
|-- led_organizer.vhd                 LED signal unpacker and pin router
|
|-- *.bsf                             Block symbol files for Quartus schematic editor
|
|-- output_files/
|   |-- Trafic_light.sof              Compiled FPGA bitstream (ready to program)
|
|-- README.md                         Project documentation
|-- .gitignore                        Excludes Quartus temp files and build artifacts
```

---

## License

This project is released under the MIT License. You are free to use, modify, and distribute it for any purpose, including commercial use, as long as the original license notice is retained.
