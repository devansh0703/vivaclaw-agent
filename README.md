# VivaClaw 🦞⚡

**VivaClaw** is a high-performance OpenClaw agent designed for autonomous FPGA design automation using Xilinx Vivado. It acts as a principal-level FPGA engineer, capable of managing the entire design lifecycle from RTL synthesis to bitstream generation.

## Features

- **Autonomous Design Flows**: Complete `Synthesis -> Opt -> Place -> Route -> Bitstream` pipelines.
- **Timing Closure Expert**: Specialized skills for analyzing WNS/TNS and escalating implementation directives (Levels 0-5).
- **CDC Safety Audit**: Multi-clock domain crossing analysis and automated synchronizer verification.
- **Design Health Scoring**: Automated 0-100 scoring based on timing, utilization, and DRC cleanliness.
- **Debug Insertion**: Autonomous ILA/VIO core insertion with resource budget checking.
- **Multi-Benchmark Validated**: Stress-tested against ISCAS-89 and ITC-99 benchmark suites.

## Repository Structure

- `vivaclaw/`: The core agent workspace (SOUL, AGENTS, IDENTITY, and Domain Skills).
- `skills/`: 12 specialized Vivado domain skills in Markdown format.
- `benchmarks/`: TCL runners and source files for VLSI benchmarks.
- `results/`: Collected metrics and logs from validation runs.

## Benchmark Validation

VivaClaw has been validated against:
- **ISCAS-89 Sequential Circuits**: Verified error recovery and behavioral wrapping.
- **ITC-99 Industrial RTL**: Verified scalability from simple FSMs to complex processors.

| Design | LUTs | FFs | Result |
| :--- | :--- | :--- | :--- |
| b01 - b15 | 10 - 4000+ | 5 - 1000+ | ✅ Success |
| s38417 | 1,395 | 1,544 | ✅ Success |

## Installation

1. Install [OpenClaw](https://github.com/openclaw/openclaw).
2. Copy the `vivaclaw/` directory to `~/.openclaw/agents/vivaclaw/workspace/`.
3. Register the agent in your `~/.openclaw/openclaw.json`.
4. Ensure `vivado` is in your system `PATH`.

🦞 *VivaClaw: Closes timing before breakfast.*
