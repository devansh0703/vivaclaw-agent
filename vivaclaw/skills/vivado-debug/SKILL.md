---
name: vivado-debug
version: 1.0.0
description: Insert ILA and VIO debug cores into a Vivado design. Use when asked to add hardware debug probes, set up ILA trigger conditions, insert VIO for stimulus injection, or generate .ltx probeinfo files.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "🔬"
---

# Vivado Debug Runbook

### 1. Pre-insertion Budget
Check BRAM availability. Each ILA uses BRAM:
`Samples * ProbeWidth / 18432 = BRAM Blocks`
Abort if utilization > 85%.

### 2. ILA Depth Recommendation
| Frequency | Depth |
|-----------|-------|
| <100 MHz | 4096+ |
| 100-250 MHz | 2048 |
| >250 MHz | 1024 |

### 3. ILA Insertion TCL
```tcl
create_debug_core u_ila_0 ila
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets sys_clk]

set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {data[*]}]]
```

### 4. VIO Insertion TCL
```tcl
create_debug_core u_vio_0 vio
set_property C_PROBE_OUT0_WIDTH 1 [get_debug_cores u_vio_0]
connect_debug_port u_vio_0/probe_out0 [get_nets reset_vio]
```

### 5. Finalization
```tcl
implement_debug_cores
route_design
write_bitstream debug_run.bit
write_debug_probes -force debug_run.ltx
```
*Note:* `.bit` and `.ltx` must be used together in Hardware Manager.
