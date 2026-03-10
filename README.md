# Polimi Reti Logiche Final Project 2024-2025

[cite_start]This is a VHDL hardware module designed for differential filtering[cite: 17]. [cite_start]It was developed as the final project for the Reti Logiche (Logic Networks) course at Politecnico di Milano[cite: 17].

## How it works
[cite_start]The module reads data from an external memory, applies a filter, and writes the results back[cite: 19]. [cite_start]It uses a Finite State Machine (FSM) to coordinate everything synchronously [cite: 94-95].

Key features:
* [cite_start]Supports both 3rd-order and 5th-order differential filters [cite: 28-31].
* [cite_start]Uses bit-shifts for division to keep the hardware simple and fast [cite: 51-52].
* [cite_start]Output is automatically saturated to the signed 8-bit range of -128 to +127[cite: 22, 136].

## Technical Details
[cite_start]The design was synthesized for a Xilinx Artix-7 FPGA using Vivado[cite: 416].

* [cite_start]**Clock:** 50 MHz (20ns period)[cite: 424].
* [cite_start]**Timing:** The design is efficient, with a positive slack of nearly 14ns[cite: 424, 429].
* [cite_start]**Resources:** It uses very few resources—less than 1% of the total LUTs and Registers on the target chip[cite: 422].

### Hardware Utilization
| Resource | Count | % Used |
| :--- | :--- | :--- |
| LUTs | 1156 | [cite_start]0.86% [cite: 422] |
| Registers | 228 | [cite_start]0.08% [cite: 422] |
| DSP/BRAM | 0 | [cite_start]0.00% [cite: 422] |

## Author
* [cite_start]**Ambrogio Gao** (Matricola 214428) [cite: 6-7]
* [cite_start]Ingegneria Informatica, Politecnico di Milano [cite: 8]

## License
Licensed under the MIT License.
