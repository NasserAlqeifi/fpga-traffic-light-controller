# FPGA Traffic Light Controller

A fully functional smart traffic light control system for a 4-way intersection, implemented in VHDL and deployed on the Intel Cyclone IV E FPGA (EP4CE115F29C7) using Intel Quartus Prime 18.1. The system manages two axes of vehicle traffic, handles pedestrian crossing requests, and coordinates multiple Finite State Machines running in parallel on hardware.

## Overview
This project was designed to demonstrate how a real-world traffic intersection can be modeled and controlled at the hardware level using digital logic. Rather than relying on a microcontroller or software, all logic runs directly on the FPGA fabric using synthesized hardware circuits described in VHDL.

The design controls a 4-way intersection with two traffic axes:
- **X-axis**: lanes X1 and X2
- **Y-axis**: lanes Y1 and Y2

Each lane has a dedicated RGB traffic light (Red, Yellow, Green) for vehicles, and each crossing direction has a pedestrian signal (Red, Green) with a physical push button.

## Features
- 4-way intersection control with two independent traffic axes
- RGB vehicle traffic lights for each of the four lanes
- Pedestrian crossing support with push-button requests on all four directions
- Power-on startup sequence with yellow blinking initialization on all lights
- Priority-based FSM selector switching between startup, normal traffic, and pedestrian modes
- On-board clock divider converting the 50 MHz board clock to 1 Hz
- Modular VHDL design with each functional block as a separate, reusable component
- Pre-compiled `.sof` bitstream included for direct FPGA programming

## System Architecture
Six VHDL modules connected in a top-level block diagram (`Trafic_light.bdf`). Three FSMs run in parallel; a central selector module determines which drives the LED outputs.

**FSM Priority:** startup_done=0 - Startup FSM; startup_done=1 & request_active=1 - Pedestrian FSM; startup_done=1 & request_active=0 - Traffic FSM

## Hardware
- **Target FPGA:** Intel Cyclone IV E, EP4CE115F29C7
- **Board:** Terasic DE2-115
- **Tool:** Intel Quartus Prime 18.1.0 Lite Edition
- **Clock:** 50 MHz input - 1 Hz operating

## Signal Encoding
Vehicle lights (3-bit): `100`=Red, `010`=Yellow, `001`=Green
Pedestrian lights (2-bit): `10`=Red, `01`=Green

## Project Structure

```
fpga-traffic-light-controller/
├── Trafic_light.bdf                    # Top-level block diagram (Quartus)
├── Trafic_light.qpf                    # Quartus project file
├── Trafic_light.qsf                    # Quartus settings file
├── clock_divider.vhd                   # Clock divider: 50 MHz to 1 Hz
├── clock_divider.bsf                   # Block symbol file
├── startup_fsm.vhd                     # Startup/initialization FSM
├── startup_fsm.bsf
├── traffic_fsm.vhd                     # Normal traffic cycle FSM
├── traffic_fsm.bsf
├── pedestrian_request_fsm.vhd          # Pedestrian crossing FSM
├── pedestrian_request_fsm.bsf
├── phase_request_fsm.bsf               # Phase request block symbol
├── fsm_selector.vhd                    # Priority-based FSM selector
├── fsm_selector.bsf
├── led_organizer.vhd                   # LED output mapper
├── led_organizer.bsf
├── output_files/
│   └── Trafic_light.sof               # Compiled FPGA bitstream
└── README.md
```

## License
MIT License
