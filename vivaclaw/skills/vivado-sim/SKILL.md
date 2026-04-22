---
name: vivado-sim
version: 1.0.0
description: Run Vivado simulations using xsim. Use when asked to simulate RTL, run behavioral, post-synthesis, or post-implementation simulation, or compile HDL for simulation.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "🧪"
---

# Vivado Simulation Runbook

### 1. Simulation Modes
| Mode | Input | Command Flag |
|------|-------|--------------|
| **Behavioral** | RTL Sources | `-mode behavioral` |
| **Post-Synth** | `post_synth.dcp` | `-mode functional` |
| **Post-Impl** | `post_route.dcp` + SDF | `-mode timesim` |

### 2. CLI Execution (Fast)
```bash
xvlog src/*.v
xvhdl src/*.vhd
xelab --debug all --snapshot sim_snap work.testbench
xsim sim_snap --R --log xsim.log --wdb sim.wdb
```

### 3. Verification
```bash
grep -E "ERROR|FAIL|ASSERT|fatal" xsim.log
```

### 4. Waveform Capture
TCL for xsim:
```tcl
open_vcd simulation.vcd
log_vcd [get_objects -r /*]
run 1ms
close_vcd
```

### 5. Timing Simulation
```tcl
write_verilog -mode timesim -sdf_anno true post_route_sim.v
write_sdf -mode timesim post_route_sim.sdf
```
Compile with `xvlog -d SDF_ANNOTATE`.
