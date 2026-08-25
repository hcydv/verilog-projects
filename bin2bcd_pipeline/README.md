# BIN2BCD Pipeline

## Introduction

This project implements a **16-bit binary to 5-digit BCD converter** using Verilog.

The converter is based on the **Double Dabble (Shift-and-Add-3)** algorithm and is implemented as a **16-stage pipeline**, allowing new input data to be accepted every clock cycle.

## Features

- 16-bit unsigned binary input
- 20-bit BCD output
- Double Dabble algorithm
- 16-stage pipeline architecture
- Supports continuous input
- Supports bubbles through `in_valid`
- `in_valid` and `out_valid` pipeline alignment

## Interface

```verilog
module bin2bcd_pipeline(
    input  wire        clk,
    input  wire        rst_n,

    input  wire [15:0] bin_in,
    input  wire        in_valid,

    output reg  [19:0] bcd_out,
    output reg         out_valid
);
```

The BCD output format is:

```text
bcd_out[19:16] : ten-thousands digit
bcd_out[15:12] : thousands digit
bcd_out[11:8]  : hundreds digit
bcd_out[7:4]   : tens digit
bcd_out[3:0]   : ones digit
```

For example:

```text
bin_in  = 12345
bcd_out = 20'h12345
```

## Double Dabble Algorithm

Each pipeline stage performs one round of the **Shift-and-Add-3** algorithm:

1. Check every BCD digit.
2. If a BCD digit is greater than or equal to 5, add 3.
3. Shift the complete intermediate data left by one bit.

The intermediate data width is 36 bits:

```text
[35:16] : 20-bit BCD field
[15:0]  : 16-bit binary field
```

Since the binary input is 16 bits wide, the conversion requires **16 rounds**.

## Pipeline Architecture

The 16 conversion rounds are expanded into a **16-stage pipeline**:

```text
bin_in
  |
  v
Stage 0
  |
  v
Stage 1
  |
  v
 ...
  |
  v
Stage 15
  |
  v
bcd_out
```

Each stage performs:

```text
Add-3
  +
Left Shift
  +
Pipeline Register
```

After the pipeline is filled, the module can accept a new input every clock cycle.

## Valid Pipeline

The `in_valid` signal propagates through the pipeline together with the corresponding data.

```text
in_valid
   |
   v
valid_pipe[0]
   |
   v
valid_pipe[1]
   |
   v
  ...
   |
   v
valid_pipe[15]
   |
   v
out_valid
```

This ensures that `out_valid` remains aligned with the corresponding `bcd_out`.

The valid pipeline also allows bubbles to propagate correctly when `in_valid` is low.

## Verification

The design was verified using simulation with multiple input values:

- `0`
- `12345`
- `11111`
- `22222`
- `33333`
- `44444`
- `54321`

Continuous input data and gaps in `in_valid` were also tested to verify pipeline operation and valid-signal alignment.

Example conversion:

```text
Binary input : 12345
BCD output   : 12345
```

## Files

- `bin2bcd_pipeline.v` — RTL design
- `tb_bin2bcd_pipeline.v` — Testbench

## Key Concepts

- Double Dabble / Shift-and-Add-3
- 16-stage pipeline
- Pipelined datapath
- Latency and throughput
- Valid signal alignment
- Bubble propagation
- Generate statement
- Combinational logic
- Pipeline registers
