---
name: vivado-flow
version: 1.0.0
description: Run a complete Vivado design flow: project creation, synthesis, implementation, bitstream. Use when asked to build, synthesize, implement, or compile an FPGA design from RTL sources.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "🔁"
---

# Vivado Full Flow Runbook

### 1. Pre-flight Checks
- Verify `vivado` is on PATH.
- Confirm target FPGA part number and top module name.
- Ensure all RTL (Verilog/VHDL) and XDC files are accessible.

### 2. Project Creation (In-Memory)
```tcl
create_project -in_memory -part <part_number>
read_verilog [glob src/*.v]
read_vhdl [glob src/*.vhd]
read_xdc constraints.xdc
set_property top <top_module> [current_fileset]
update_compile_order -fileset sources_1
```

### 3. Synthesis
```tcl
synth_design -top <top_module> -part <part_number> -directive Default -flatten_hierarchy rebuilt -fsm_extraction auto -retiming
write_checkpoint -force /tmp/vivaclaw_post_synth.dcp
report_utilization -file /tmp/vivaclaw_rpt/post_synth_util.rpt
```

### 4. Implementation Sequence
```tcl
opt_design -directive Default
write_checkpoint -force /tmp/vivaclaw_post_opt.dcp
place_design -directive Default
write_checkpoint -force /tmp/vivaclaw_post_place.dcp
phys_opt_design -directive Default
route_design -directive Default
write_checkpoint -force /tmp/vivaclaw_post_route.dcp
```

### 5. Post-Route Verification
- **Timing:** Extract WNS/TNS. If WNS < 0, STOP and invoke `vivado-timing`.
- **DRC:** `report_drc -file /tmp/vivaclaw_rpt/post_route_drc.rpt`.
- **Gate:** Only run `write_bitstream` if zero CRITICAL WARNINGS or ERRORS.

### 6. Bitstream Generation
```tcl
write_bitstream -force /tmp/vivaclaw_output.bit
```
