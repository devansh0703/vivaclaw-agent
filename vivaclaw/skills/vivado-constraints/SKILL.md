---
name: vivado-constraints
version: 1.0.0
description: Author and audit Vivado XDC constraint files. Use when creating constraints, finding unconstrained paths, debugging timing exceptions, checking clock definitions, or auditing I/O delays for completeness.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "📐"
---

# Vivado Constraints Runbook

### 1. Constraint Audit
```tcl
check_timing -override_defaults {
  no_clock no_input_delay no_output_delay
  multiple_clock unconstrained_internal_endpoints
} -file /tmp/vivaclaw_rpt/check_timing.rpt

report_exceptions -coverage -ignored -file /tmp/vivaclaw_rpt/exceptions.rpt
```

### 2. Clock Definitions
- **Primary:** `create_clock -period 10.0 -name sys_clk [get_ports sys_clk]`
- **Generated:** `create_generated_clock -name clk_div2 -source [get_pins mmcm/CLKIN1] -divide_by 2 [get_pins mmcm/CLKOUT0]`

### 3. I/O Delays
- **Input:** `set_input_delay -clock <clk> -max <val> [get_ports <in>]`
- **Output:** `set_output_delay -clock <clk> -max <val> [get_ports <out>]`
- Use `-min` for hold/setup-min checks.

### 4. XDC Ordering Rules
1. Primary Clocks
2. Generated Clocks
3. Clock Groups / CDC
4. Timing Exceptions (`set_false_path`, `set_multicycle_path`)
5. I/O Constraints
6. Physical / Location Constraints (`LOC`, `PACKAGE_PIN`)

### 5. Finding Unconstrained Pins
```tcl
set unconstrained [get_pins -hierarchical -filter {IS_CLOCK == 1 && CLK_OUT_PROPAGATION == ""}]
foreach pin $unconstrained { puts "MISSING CLOCK: $pin" }
```
