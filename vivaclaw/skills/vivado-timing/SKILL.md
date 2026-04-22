---
name: vivado-timing
version: 1.0.0
description: Analyze and fix timing violations. Use when WNS is negative, when asked to close timing, fix setup/hold violations, analyze critical paths, or improve max frequency.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "⏱️"
---

# Vivado Timing Closure Runbook

### 1. Diagnostic Suite
```tcl
open_checkpoint /tmp/vivaclaw_post_route.dcp
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_internal -max_paths 10 -input_pins -file /tmp/vivaclaw_rpt/timing_summary.rpt
report_design_analysis -timing -logic_level_distribution -file /tmp/vivaclaw_rpt/design_analysis.rpt
```

### 2. Path Investigation
```tcl
set p [get_timing_paths -max_paths 1 -slack_lesser_than 0 -delay_type max]
if {$p != ""} {
    puts "SLACK: [get_property SLACK $p]"
    puts "LOGIC_LEVELS: [get_property LOGIC_LEVELS $p]"
    puts "DATAPATH_DELAY: [get_property DATAPATH_DELAY $p]"
}
```

### 3. Strategy Table
| Condition | Action |
|-----------|--------|
| Logic Levels > 8 | Re-synth: `-directive PerformanceOptimized -retiming` |
| Route Delay > 60% | `route_design -directive AggressiveExplore` |
| Hold Violation | `phys_opt_design -directive ExploreWithHoldFix` |
| High Fanout (>5k) | `set_property MAX_FANOUT 100 [get_cells <driver>]` |

### 4. Logic Level Targets (MHz vs Levels)
| MHz | Max Levels |
|-----|-----------|
| 100 | 16 |
| 200 | 8 |
| 300 | 6 |
| 400 | 4 |

### 5. Directive Escalation Ladder
1. `place=WLDrivenPlacement, route=Default`
2. `place=AltSpreadLogic_high, route=Explore`
3. `place=ExtraNetDelay_high, route=AggressiveExplore`
4. `phys_opt=AggressiveExplore, route=MoreGlobalIterations`
5. `phys_opt=AlternativeFlowWithRetiming, route=AggressiveExplore`
