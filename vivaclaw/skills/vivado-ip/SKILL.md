---
name: vivado-ip
version: 1.0.0
description: Create, configure, generate, and upgrade Xilinx IP cores. Use when instantiating IP catalog cores, configuring AXI interconnects, generating IP targets, handling OOC synthesis, upgrading stale IPs, or building block designs.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "📦"
---

# Vivado IP Runbook

### 1. IP Creation & Config
```tcl
create_ip -name <core_name> -vendor xilinx.com -library ip -module_name <inst_name>
set_property CONFIG.PARAM_NAME <value> [get_ips <inst_name>]
generate_target all [get_ips <inst_name>]
```

### 2. IP Status Audit
```tcl
foreach ip [get_ips] {
  set status [get_property IP_INTEGRATION_STATUS $ip]
  set locked [get_property IS_LOCKED $ip]
  puts "IP: $ip | Status: $status | Locked: $locked"
}
```

### 3. Upgrade Flow
```tcl
report_ip_status -file /tmp/vivaclaw_rpt/ip_status.rpt
upgrade_ip [get_ips -filter {UPGRADE_AVAILABLE == 1}]
```

### 4. Block Design (BD) Basics
```tcl
create_bd_design "system"
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_intercon
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/cpu/M_AXI" }  [get_bd_intf_pins axi_intercon/S00_AXI]
validate_bd_design
save_bd_design
```

### 5. License Check
```tcl
get_property IS_EVALUATION [get_ips <inst_name>]
```
*Warning:* Evaluation IPs produce bitstreams that expire after a few hours of hardware operation.
