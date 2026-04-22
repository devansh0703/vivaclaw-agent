---
name: vivado-flow
version: 1.0.0
description: Run a complete Vivado FPGA design flow from RTL sources to bitstream. Use when asked to synthesize, implement, build, or compile an FPGA design. Also handles project creation, checkpoint management, and run orchestration.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    alwaysActive: false
    emoji: "🔁"
---

# Vivado Full Flow

Drives end-to-end: project creation → synthesis → opt → place → phys_opt → route → bitstream.

## Prerequisites

Confirm before starting:
- `vivado` is on PATH: `which vivado`
- Part number is known (e.g. `xcvu9p-flgb2104-2-i`)
- Top module name is known
- RTL source files and XDC constraints are accessible

## Project Setup

```tcl
# Create in-memory project (no .xpr written to disk unless needed)
create_project vivaclaw_proj /tmp/vivaclaw_proj -part <PART> -force

# Add sources
read_verilog  [glob <rtl_dir>/*.v]
read_verilog -sv [glob <rtl_dir>/*.sv]
read_vhdl     [glob <rtl_dir>/*.vhd]
read_xdc      <constraints.xdc>

set_property top <TOP_MODULE> [current_fileset]
update_compile_order -fileset sources_1
```

## Synthesis

```tcl
synth_design \
  -top    <TOP_MODULE> \
  -part   <PART> \
  -directive <SYNTH_DIRECTIVE> \
  -flatten_hierarchy rebuilt \
  -fsm_extraction auto

write_checkpoint -force /tmp/vivaclaw_post_synth.dcp
report_timing_summary -file /tmp/vivaclaw_synth_timing.rpt
report_utilization    -file /tmp/vivaclaw_synth_util.rpt
```

## Implementation

```tcl
opt_design    -directive <OPT_DIRECTIVE>
write_checkpoint -force /tmp/vivaclaw_post_opt.dcp

place_design  -directive <PLACE_DIRECTIVE>
write_checkpoint -force /tmp/vivaclaw_post_place.dcp

phys_opt_design -directive <PHYSOPT_DIRECTIVE>

route_design  -directive <ROUTE_DIRECTIVE>
write_checkpoint -force /tmp/vivaclaw_post_route.dcp
```

## Closure Check

After route, extract WNS and TNS:
```bash
grep -E "WNS|TNS|WHS" /tmp/vivaclaw_route_timing.rpt | head -20
```
If WNS < 0: invoke **vivado-timing** skill. Do not proceed to bitstream.

## Bitstream

Only run after:
1. WNS >= 0, TNS = 0
2. `report_drc` shows zero CRITICAL errors

```tcl
report_drc -file /tmp/vivaclaw_drc.rpt
# Parse: if "CRITICAL" errors found → STOP, report to user

write_bitstream -force /tmp/vivaclaw_output.bit
```

## Checkpoint Resume

If a post-route DCP exists and the user wants to skip re-running:
```tcl
open_checkpoint /tmp/vivaclaw_post_route.dcp
```

## Log Parsing Patterns

After every Vivado call, scan stdout for:
```
ERROR:           → stop, report
CRITICAL WARNING:→ evaluate, may stop
WNS.*(-[\d\.]+) → timing violation, invoke timing skill
```
