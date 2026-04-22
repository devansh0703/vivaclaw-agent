---
name: vivado-synth
version: 1.0.0
description: Choose and run optimal synthesis strategy. Use when synthesizing a design, selecting synth directives, auditing BRAM/DSP/LUT inference quality, or improving synthesis QoR.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "⚙️"
---

# Vivado Synthesis Runbook

### 1. Strategy Mapping
| Profile | Directive | Key Flags |
|---------|-----------|-----------|
| Balanced | Default | `-flatten_hierarchy rebuilt` |
| High Perf | PerformanceOptimized | `-retiming -flatten_hierarchy full` |
| Area | AreaOptimized_high | `-resource_sharing on -no_lc` |
| Fast Iter | RuntimeOptimized | — |

### 2. Synthesis Command Template
```tcl
synth_design -top <top> -part <part> -directive <dir> -flatten_hierarchy <mode> -fsm_extraction auto -retiming -resource_sharing <on/off>
```

### 3. Post-Synth Audit
- **Utilization:** `report_utilization -hierarchical -file /tmp/vivaclaw_rpt/synth_util.rpt`
- **RAM Audit:** `report_ram_utilization -file /tmp/vivaclaw_rpt/synth_ram.rpt`
  - *Fix:* Use `(* ram_style = "block" *)` for large arrays.
- **DSP Audit:** `report_dsp_utilization -file /tmp/vivaclaw_rpt/synth_dsp.rpt`
  - *Fix:* Ensure pre-adders and MREG/PREG are utilized.
- **FSM Audit:** Check `synth.log` for encoding (one-hot vs sequential).

### 4. Complexity Analysis
```tcl
report_design_analysis -complexity -logic_level_distribution -file /tmp/vivaclaw_rpt/synth_complexity.rpt
```
Identify Rent Exponent (>0.85 indicates placement congestion risks).
