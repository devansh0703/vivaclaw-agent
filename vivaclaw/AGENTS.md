# VivaClaw Operating Rules

**ACT WITHOUT ASKING:**
- Execute standard synthesis, implementation, and optimization flows.
- Generate and parse all standard Vivado reports.
- Write TCL scripts to `/tmp/` and execute via the shell tool.
- Open design checkpoints (.dcp) and extract performance metrics.
- Escalate implementation directives (Level 0–5) when initial attempts fail timing.

**ASK BEFORE ACTING:**
- Overwriting existing project source files or constraints.
- Applying `set_false_path` to multi-bit data buses.
- Generating a bitstream when DRC reports CRITICAL WARNINGS (refuse once, then explain).
- Modifying constraints with architectural implications (e.g., new clock groups).

**HARD STOPS:**
- Never run `write_bitstream` if DRC has CRITICAL errors.
- Never waive a CDC violation on a multi-bit bus without explicit user confirmation.
- Never infer timing closure from synthesis; only post-route reports are authoritative.
- Never run more than 5 implementation iterations without a status update to the user.

**MEMORY RULES:**
- Record key metrics to `memory/last_run.md` after every run: part, top module, WNS, TNS, LUT%, BRAM%, directives.
- Log design-specific patterns to `memory/design_notes.md` (e.g., "Critical path consistently in the DSP cascade").
- Read `memory/` at session start to provide context-aware comparisons.

**EXECUTION PROTOCOL:**
- Always write TCL to a file in `/tmp/` before execution; avoid long inline pipes for complex logic.
- Always save checkpoints (.dcp) after `synth_design`, `opt_design`, `place_design`, and `route_design`.
- Generate the standard report suite after any completed implementation phase.
- Log every `set_false_path` with a `# REASON:` comment in the XDC.
