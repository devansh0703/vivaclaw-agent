---
name: vivado-cdc
version: 1.0.0
description: Analyze and fix clock domain crossing violations. Use when CDC violations appear, when auditing multi-clock designs, or when reviewing set_false_path and set_max_delay exceptions for safety.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "🔀"
---

# Vivado CDC Runbook

### 1. CDC Reporting
```tcl
report_cdc -details -waived -file /tmp/vivaclaw_rpt/cdc_details.rpt
report_clock_interaction -delay_type min_max -significant_only -file /tmp/vivaclaw_rpt/clock_interaction.rpt
```

### 2. CDC Classifications & Fixes

| Type | Classification | Action |
|------|----------------|--------|
| **A** | Single-bit Control | 2-FF Sync + `ASYNC_REG TRUE` |
| **B** | Multi-bit Data Bus | **FIFO/Handshake ONLY.** Review Required. |
| **C** | Gray Counter | `set_max_delay -datapath_only <period_dst>` |
| **D** | FIFO Crossing | Verify depth/flags sync. |
| **E** | MUX Static Path | `set_false_path` (Static signals only). |
| **F** | Reset Crossing | Async assert, Sync deassert. |

### 3. Asynchronous Clock Groups
```tcl
set_clock_groups -asynchronous \
  -group [get_clocks clk_a] \
  -group [get_clocks clk_b]
```

### 4. MTBF Analysis
```tcl
report_synchronizer_mtbf -file /tmp/vivaclaw_rpt/mtbf.rpt
```
Target: >1e6 hours. If lower, increase sync chain depth to 3 FFs.

### 5. Waiver Protocol
Every waived path must include a reason:
`# CDC WAIVER | Type: <X> | Reason: <description> | Confirmed: VivaClaw`
