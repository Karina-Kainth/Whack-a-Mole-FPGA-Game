# Whack-a-Mole on FPGA

Whack-a-Mole is a hardware/digital-logic recreation of the classic arcade game that includes:
- A "mole" spawning at a random position and for a random duration on a VGA display
- A player that has to hit the matching key on a PS/2 keyboard before it disappears
- A live score and a countdown timer displayed on the DE1-SoC board's seven-segment display

![Verilog](https://img.shields.io/badge/HDL-Verilog-blue)
![Platform](https://img.shields.io/badge/Platform-DE1--SoC%20%7C%20Cyclone%20V-orange)
![Tool](https://img.shields.io/badge/Toolchain-Intel%20Quartus%20Prime-red)

## Demo

https://github.com/user-attachments/assets/3e716e27-234d-474e-ae8d-465323e5469d

## Controls

| Key | Action |
|---|---|
| `S` | Start the game |
| `1` / `2` / `3` | Select difficulty (fastest → slowest mole timing) |
| `F1`–`F4` | "Whack" the mole in that position |
| `R` | Reset the game at any time |

## Module Breakdown

| Module | File | Responsibility |
|---|---|---|
| `totalProject` | `Total Project/totalProject.v` | Top-level: wires keyboard, FSM, HEX displays, and VGA together |
| `fsm` | `FSM/fsm.v` | Core game logic — state machine, scoring, difficulty-based timing, LFSR-driven randomization |
| `PS2_Controller` / `PS2_Demo` | `keyboard/` | PS/2 protocol decode + arrow/key mapping into game input signals |
| `timer` | `OtherComponents/timer.v` | Parameterized countdown used for mole display time, mole delay, and the 60s game clock |
| `randomNumGen` | `OtherComponents/randomNumGen.v` | 16-bit Fibonacci LFSR for pseudo-random mole position/timing |
| `Hexadecimal_To_Seven_Segment` | `OtherComponents/Hexadecimal_To_Seven_Segment.v` | Combinational hex → 7-segment decoder for score/timer display |
| `vga_top` | `vga_display/vga_top.v` | Computes mole sprite pixel coordinates and color per active mole |
| `vga_adapter` | `vga_adapter/vga_adapter.v` | Dual-port frame buffer; loads background from `.mif`, merges mole writes |
| `vga_controller` | `vga_adapter/vga_controller.v` | Generates HSYNC/VSYNC and pixel counters for a 640×480@60Hz signal |
| `vga_pll` | `vga_adapter/vga_pll.v` | Converts the 50 MHz board clock to the 25 MHz VGA pixel clock |

## Getting Started

**Hardware:** DE1-SoC board (Intel Cyclone V, `5CSEMA5F31C6`), VGA monitor, PS/2 keyboard

**Toolchain:** Intel Quartus Prime

1. Clone the repo and open `Total Project/totalProject.qpf` in Quartus.
2. Compile the project (`Processing → Start Compilation`).
3. Program the DE1-SoC via `Tools → Programmer` using the generated `totalProject.sof`.
4. Connect a PS/2 keyboard and a VGA monitor to the board, then power on.
5. Press `1`/`2`/`3` to pick a difficulty, `S` to start, and start whacking moles with `F1`–`F4`.

## License

This project was completed for academic purposes as part of ECE241 coursework in collaboration with Prithika Paraneetharan.
