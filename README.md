# Vending-Machine-Controller

This project is a Verilog RTL-based implementation of a configurable vending machine controller.
It simulates a real vending system with support for dynamic item setup, asynchronous user input, and real-time dispensing logic.
The design is modular, parameterized, and optimized for both configurability and fast operation.

# Features
Supports up to 1024 unique items
APB-like configuration interface running at 10 MHz
Real-time operation mode on a 100 MHz system clock
Handles asynchronous currency and item select inputs (10 kHz – 50 MHz)
Dispenses items within 10 system clock cycles
Returns change if overpaid
Modular, scalable, and clean RTL architecture
