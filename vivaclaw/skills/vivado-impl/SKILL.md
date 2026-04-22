---
name: vivado-impl
version: 1.0.0
description: Run Vivado implementation phases: opt_design, place_design, phys_opt_design, route_design. Use when asked to run implementation, choose implementation directives, or re-run specific implementation phases.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "🏗️"
---

# Vivado Implementation Runbook

### 1. Implementation Phases & Directives

| Phase | Directives (Ascending Intensity) |
|-------|---------------------------------|
| **opt** | Default, Explore, ExploreWithRemap, AggressiveExplore |
| **place** | Default, WLDrivenPlacement, AltSpreadLogic_high, ExtraNetDelay_high |
| **phys_opt**| Default, Explore, AggressiveExplore, AlternativeFlowWithRetiming |
| **route** | Default, Explore, AggressiveExplore, MoreGlobalIterations |

### 2. Implementation Execution
```tcl
open_checkpoint /tmp/vivaclaw_post_synth.dcp
opt_design -directive <dir>
place_design -directive <dir>
phys_opt_design -directive <dir>
route_design -directive <dir>
write_checkpoint -force /tmp/vivaclaw_post_route.dcp
```

### 3. Partial Re-route (Fast Fix)
If only a few nets are failing:
```tcl
route_design -unroute -nets [get_nets -hierarchical <pattern>]
route_design -directive AggressiveExplore -nets [get_nets -hierarchical <pattern>]
```

### 4. Incremental Flow
If a previous high-quality run exists:
```tcl
read_checkpoint -incremental reference.dcp
place_design
route_design
```
Check `get_property INCREMENTAL_REUSE [current_design]` to verify reuse % (>90% ideal).
