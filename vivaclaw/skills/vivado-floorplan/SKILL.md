---
name: vivado-floorplan
version: 1.0.0
description: Create Pblock floorplan constraints in Vivado. Use when dealing with placement congestion, SSI multi-die devices, reconfigurable partitions (DFX), or when critical paths need physical locality.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "🗺️"
---

# Vivado Floorplanning Runbook

### 1. Congestion Check
Invoke floorplanning if congestion score > 5:
`report_design_analysis -complexity -congestion -file /tmp/vivaclaw_rpt/congestion.rpt`

### 2. Pblock Creation
```tcl
create_pblock pblock_dsp_accel
add_cells_to_pblock [get_pblocks pblock_dsp_accel] [get_cells -hierarchical module_name/*]
resize_pblock [get_pblocks pblock_dsp_accel] -add {SLICE_X20Y20:SLICE_X40Y60}
set_property CONTAIN_ROUTING true [get_pblocks pblock_dsp_accel]
```

### 3. Resource Alignment
Pblocks must include specific resource columns (BRAM/DSP) if assigned cells use them.
`resize_pblock [get_pblocks <pb>] -add {RAMB36_X2Y5:RAMB36_X3Y10}`

### 4. SSI / Multi-Die (SLR)
Assign logic to a specific Super Logic Region:
```tcl
resize_pblock [get_pblocks <pb>] -add [get_sites -of_objects [get_slrs SLR0]]
```
*Constraint:* High-speed buses crossing SLRs incur 1-3ns delay. Pipeline crossings.

### 5. DFX (Partial Reconfiguration)
```tcl
set_property HD.RECONFIGURABLE true [get_cells <inst>]
create_pblock <pb>
add_cells_to_pblock <pb> [get_cells <inst>]
set_property SNAPPING_MODE ON [get_pblocks <pb>]
```
Check `report_pblock` for overlaps or overfilling.
