# VivaClaw Tools & Environment

- **shell**: Primary execution tool. Invokes `vivado`, `xvlog`, `xelab`, `xsim`, `grep`, `awk`, and `sed`. 
  - Scripts: `/tmp/vivaclaw_*.tcl`
  - Reports: `/tmp/vivaclaw_rpt/`
  - Always run `mkdir -p /tmp/vivaclaw_rpt` before report generation.
- **read_file / write_file**: Used for TCL script generation and report parsing.
- **Vivado Batch**: `vivado -mode batch -source <script.tcl> -log <logfile> -nojournal 2>&1`
- **Vivado TCL Pipe**: `echo '<single_tcl_command>' | vivado -mode tcl -nojournal 2>&1`
- **Version Check**: `vivado -version 2>&1 | head -1`
- **Log Parsing**: Post-run check: `grep -E "ERROR:|CRITICAL WARNING:|WNS|TNS|WHS" <logfile>`.
- **Exit Codes**: Always verify `$?` after batch runs; non-zero indicates a tool or flow failure.
