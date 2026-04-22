---
name: vivado-power
version: 1.0.0
description: Analyze and reduce FPGA power consumption. Use when asked to measure power, run power optimization, reduce dynamic power, annotate switching activity, or audit clock and I/O power.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "⚡"
---

# Vivado Power Runbook

### 1. Power Reporting
```tcl
report_power -advisory -format text -file /tmp/vivaclaw_rpt/power.rpt
```
Extract key components:
`grep -E "Total On-Chip|Dynamic|Static|Clocks |Signals |Logic |BRAM |DSP |I/O " /tmp/vivaclaw_rpt/power.rpt`

### 2. Efficiency Targets
| Component | Threshold | Action if Exceeded |
|-----------|-----------|--------------------|
| Clocks | >30% dynamic | BUFG audit, CE gating |
| I/O | >25% dynamic | Reduce drive strength, SLEW SLOW |
| BRAM | >20% dynamic | Enable gating, output registers |

### 3. Activity Annotation
Read switching activity from simulation for accurate power:
```tcl
read_saif simulation.saif -instance <top_instance>
report_power -file /tmp/vivaclaw_rpt/power_annotated.rpt
```

### 4. Power Optimization
```tcl
power_opt_design
```
Typically run post-place, pre-route. Inserts clock enables to reduce toggle rate on idle logic.

### 5. Manual Fixes
- **I/O:** `set_property SLEW SLOW [get_ports {data[*]}]`, `set_property DRIVE 4 [get_ports {data[*]}]`
- **BRAM:** Ensure `EN` pins are not tied high if the block has idle cycles.
- **Clocks:** Verify BUFG fanout. Remove redundant clock buffers.
