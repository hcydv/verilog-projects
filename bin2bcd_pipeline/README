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
