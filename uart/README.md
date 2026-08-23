# UART RTL Design

## Features
- UART TX and RX
- 8-bit data
- 1 start bit
- 1 stop bit
- No parity
- 115200 baud
- LSB first
- RX two-stage synchronizer
- Loopback verification

## Structure
- `uart_tx.v` : UART transmitter
- `uart_rx.v` : UART receiver
- `uart_top.v` : TX/RX integration
- `tb_uart_tx.v` : TX testbench
- `tb_uart_rx.v` : RX testbench
- `tb_uart_loopback.v` : loopback testbench

## Verification
The TX output is connected directly to the RX input in loopback simulation.

Test flow:

`parallel data -> TX -> serial line -> RX -> parallel data`

Loopback simulation passed.
