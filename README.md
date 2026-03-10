# Polimi Reti Logiche Final Project 2024-2025

**Final Grade: 30/30 cum laude**

This is a VHDL hardware module designed for differential filtering. It was developed as the final project for the Reti Logiche course at Politecnico di Milano.

## Functionality
The module reads data from an external memory, applies a filter, and writes the results back. It uses a Finite State Machine (FSM) to coordinate all operations synchronously.

Key features:
* Supports both 3rd-order and 5th-order differential filters.
* Uses bit-shifts for division instead of complex dividers to save hardware resources.
* Output is automatically saturated to the signed 8-bit range (-128 to +127).

## Technical Specifications
The design was synthesized for a Xilinx Artix-7 FPGA using Vivado.

* **Clock:** 50 MHz (20ns period).
* **Timing:** The design is efficient, with a positive slack of 13.985 ns.
* **Resources:** Uses less than 1% of the total LUTs and Registers on the target chip.

### Hardware Utilization
| Resource | Count | % Used |
| :--- | :--- | :--- |
| LUTs | 1156 | 0.86% |
| Registers | 228 | 0.08% |
| DSP/BRAM | 0 | 0.00% |

## Author
* **Ambrogio Gao**
* Ingegneria Informatica, Politecnico di Milano

## License
Licensed under the MIT License.
