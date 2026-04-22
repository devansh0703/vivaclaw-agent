---
name: vivado-reports
version: 1.0.0
description: Parse Vivado reports and produce a structured design health score. Use when analyzing run results, comparing multiple runs, generating a health score, or surfacing key findings from report files.
metadata:
  openclaw:
    requires:
      bins:
        - vivado
    emoji: "📊"
---

# Vivado Reports Runbook

### 1. Standard Report Suite
```tcl
report_utilization -file /tmp/vivaclaw_rpt/utilization.rpt
report_timing_summary -file /tmp/vivaclaw_rpt/timing.rpt
report_cdc -file /tmp/vivaclaw_rpt/cdc.rpt
report_drc -file /tmp/vivaclaw_rpt/drc.rpt
report_power -file /tmp/vivaclaw_rpt/power.rpt
report_design_analysis -complexity -congestion -file /tmp/vivaclaw_rpt/analysis.rpt
```

### 2. Design Health Score (Max 100)
- **Timing (25 pts):** WNS >= 0 (25), -5 per 0.5ns violation.
- **Constraints (20 pts):** -5 per `no_clock`, -2 per unconstrained I/O.
- **CDC (20 pts):** 0 unwaived (20), -10 per Type B violation.
- **DRC (15 pts):** 0 CRITICAL (15), -5 per CRITICAL.
- **Utilization (10 pts):** All < 80% (10), -5 if any > 90%.
- **Power (10 pts):** SAIF annotated (5), `power_opt` used (5).

### 3. Headline Extraction (Shell)
```bash
grep "WNS=" timing.rpt | awk '{print $NF}'
grep "Slice LUTs" utilization.rpt | awk '{print $NF}'
grep -c "CRITICAL WARNING" drc.rpt
```

### 4. Anomaly Detection
- Utilization jump > 5% without RTL change.
- WNS improved but TNS worsened (systemic issue).
- Logic levels increased post-phys_opt (unintended path creation).
