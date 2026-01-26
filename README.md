# Stopwatch Project for Intel DE10-Lite FPGA

A digital stopwatch implementation in Verilog HDL for the Intel DE10-Lite development board.

## Features (To be implemented)
- MM:SS format display
- Start/Pause/Reset functionality
- Debounced button inputs
- 7-segment display output

## Board Configuration
- **Clock**: 50 MHz (CLOCK_50)
- **Inputs**: 
  - KEY[0]: Start/Pause toggle (active-low)
  - KEY[1]: Reset (active-low)
- **Outputs**: 
  - HEX0-HEX3: 7-segment displays (active-low)

## Development Environment
- **FPGA**: Intel DE10-Lite
- **Toolchain**: Quartus Prime Lite
- **HDL**: Verilog


