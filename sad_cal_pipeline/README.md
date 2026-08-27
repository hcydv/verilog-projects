# SAD Calculator Pipeline

## Introduction

This project implements an **8-pixel SAD (Sum of Absolute Differences) calculator** using Verilog.

The design uses a **4-stage pipeline** to calculate the absolute difference between two groups of 8-bit input data and then accumulate the results through a multi-stage adder tree.

After the pipeline is filled, the module can accept a new input transaction every clock cycle.

---

## Features

- 8 parallel 8-bit input data pairs
- 64-bit input bus for each data group
- 4-stage pipelined architecture
- Sum of Absolute Differences calculation
- Maximum SAD value of 2040
- Supports continuous input
- Supports bubbles through `in_valid`
- Valid signal pipeline alignment
- Self-checking testbench
- Automatic PASS / ERROR comparison

---

## Interface

```verilog
module sad_cal_pipeline(
    input  wire        clk,
    input  wire        rst_n,

    input  wire [63:0] a_data,
    input  wire [63:0] b_data,
    input  wire        in_valid,

    output reg  [10:0] sad_out,
    output reg         out_valid
);
```

Each 64-bit input contains eight 8-bit unsigned data values.

The input layout is:

```text
a_data[7:0]   = A0
a_data[15:8]  = A1
a_data[23:16] = A2
a_data[31:24] = A3
a_data[39:32] = A4
a_data[47:40] = A5
a_data[55:48] = A6
a_data[63:56] = A7
```

`b_data` uses the same format.

---

## SAD Algorithm

The module calculates:

```text
SAD =
|A0 - B0| +
|A1 - B1| +
|A2 - B2| +
|A3 - B3| +
|A4 - B4| +
|A5 - B5| +
|A6 - B6| +
|A7 - B7|
```

For example:

```text
A = {10, 20, 30, 40, 50, 60, 70, 80}
B = {15, 18, 35, 30, 55, 65, 60, 90}
```

The absolute differences are:

```text
5, 2, 5, 10, 5, 5, 10, 10
```

Therefore:

```text
SAD = 52
```

---

## Output Width

The maximum difference between two 8-bit unsigned values is:

```text
255
```

The maximum possible SAD value is:

```text
255 × 8 = 2040
```

Therefore the output width is 11 bits:

```verilog
output reg [10:0] sad_out;
```

---

## Pipeline Architecture

The calculation is divided into four stages.

### Stage 0 - Absolute Difference

Eight absolute differences are calculated in parallel:

```text
8 × 8-bit differences
```

The result of each subtraction is stored as an 8-bit value.

```text
8 values
↓
8 × 8-bit
```

---

### Stage 1 - First Addition Stage

Adjacent differences are added together:

```text
diff0 + diff1
diff2 + diff3
diff4 + diff5
diff6 + diff7
```

This produces four 9-bit partial sums.

```text
8 values
↓
4 values
```

---

### Stage 2 - Second Addition Stage

The four partial sums are further reduced:

```text
sum0 + sum1
sum2 + sum3
```

This produces two 10-bit partial sums.

```text
4 values
↓
2 values
```

---

### Stage 3 - Final Addition

The final SAD value is calculated:

```text
sum0 + sum1
```

This produces an 11-bit result.

```text
2 values
↓
1 SAD result
```

The overall datapath can be represented as:

```text
A/B Input
   |
   v
8 Absolute Differences
   |
   v
4 Partial Sums
   |
   v
2 Partial Sums
   |
   v
Final SAD
```

---

## Pipeline Registers

Each pipeline stage contains registers to store intermediate results.

The widths increase as the adder tree progresses:

```text
Stage 0 : 8-bit  × 8
Stage 1 : 9-bit  × 4
Stage 2 : 10-bit × 2
Stage 3 : 11-bit × 1
```

This ensures that no overflow occurs during accumulation.

---

## Valid Pipeline

The `in_valid` signal is propagated through the pipeline together with the data.

```text
in_valid
   |
   v
valid[0]
   |
   v
valid[1]
   |
   v
valid[2]
   |
   v
valid[3]
   |
   v
out_valid
```

This keeps `out_valid` aligned with the corresponding `sad_out`.

The design can therefore distinguish valid output data from invalid pipeline cycles.

---

## Bubble Support

The module supports invalid cycles between valid transactions.

For example:

```text
in_valid:

1 1 0 1 0 0 1 1
```

This represents:

```text
A B - C - - D E
```

The invalid cycles are treated as bubbles and propagate through the pipeline together with the valid information.

The valid output sequence remains:

```text
A B - C - - D E
```

after the corresponding pipeline delay.

---

## Throughput and Latency

The pipeline can accept one new input transaction every clock cycle.

Therefore:

```text
Throughput = 1 transaction / clock
```

The calculation datapath contains four pipeline stages.

An additional registered output stage is used for `sad_out` and `out_valid`, so the externally observed latency includes this output register.

---

## Verification

A self-checking Verilog testbench is used to verify the design.

The testbench contains a reference function that independently calculates the expected SAD value.

The verification process is:

```text
Input Data
   |
   v
Reference SAD Calculation
   |
   v
Expected Result Pipeline
   |
   v
Compare with DUT Output
```

When `out_valid` is asserted, the testbench automatically compares:

```text
sad_out
```

with:

```text
expected_sad
```

The testbench reports:

```text
PASS
```

when the output matches the reference result, and:

```text
ERROR
```

when a mismatch is detected.

---

## Test Cases

The design was tested with multiple types of input data.

### Zero Difference

```text
A = {0,0,0,0,0,0,0,0}
B = {0,0,0,0,0,0,0,0}
```

Expected:

```text
SAD = 0
```

---

### Maximum Difference

```text
A = {255,255,255,255,255,255,255,255}
B = {0,0,0,0,0,0,0,0}
```

Expected:

```text
SAD = 2040
```

---

### Normal Data

```text
A = {10,20,30,40,50,60,70,80}
B = {15,18,35,30,55,65,60,90}
```

Expected:

```text
SAD = 52
```

---

### Single Difference

```text
A = {10,20,30,40,50,60,70,80}
B = {10,20,30,40,50,60,70,90}
```

Expected:

```text
SAD = 10
```

---

### Continuous Input

Multiple valid transactions are applied on consecutive clock cycles to verify that the pipeline can continuously process input data.

```text
in_valid = 1 1 1 1 1 ...
```

After the pipeline is filled, valid SAD results are produced continuously.

---

### Bubble Test

The design was also tested with gaps in `in_valid`.

Example:

```text
in_valid = 1 1 0 1 0 0 1 1
```

This verifies that bubble propagation does not affect the order or correctness of valid transactions.

---

## Files

```text
sad_cal_pipeline/
├── README.md
├── rtl/
│   └── sad_cal_pipeline.v
├── sim/
│   └── tb_sad_cal_pipeline.v
└── images/
    └── waveform.png
```

### RTL

```text
rtl/sad_cal_pipeline.v
```

Contains the 4-stage pipelined SAD calculator.

### Testbench

```text
sim/tb_sad_cal_pipeline.v
```

Contains the self-checking verification environment and reference SAD calculation.

### Waveform

```text
images/waveform.png
```

Contains the simulation waveform showing pipeline operation and valid-signal propagation.

---

## Key Concepts Practiced

This project was mainly used to practice the following RTL and verification concepts:

- Pipelined datapath design
- Parallel absolute difference calculation
- Adder tree architecture
- Bit-width analysis
- Pipeline registers
- Latency and throughput
- Valid signal alignment
- Bubble propagation
- Combinational and sequential logic separation
- Verilog functions
- Self-checking testbench
- Reference model
- Automatic output comparison

---

## Summary

This project implements an 8-pixel SAD calculator using a 4-stage pipelined datapath.

Compared with a single-cycle combinational implementation, the pipelined architecture divides the calculation into several shorter stages and allows multiple input transactions to be processed simultaneously.

After the pipeline is filled, the design can accept a new input every clock cycle while maintaining correct data and valid-signal alignment.

The project also introduces a self-checking verification approach, where a reference model automatically calculates expected results and compares them with the DUT output.
