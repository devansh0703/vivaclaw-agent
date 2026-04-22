set benchmarks {b01 b02 b03 b04 b05 b06 b07 b08 b09 b10 b11 b12 b13 b14 b15 b17 b18 b19 b20 b21 b22}
set part "xc7a12ticsg325-1L"
set rpt_dir "/tmp/vivaclaw_itc99_metrics"
file mkdir $rpt_dir

proc log_metric { b name val } {
    puts "VIVACLAW_METRIC | $b | $name | $val"
}

foreach b $benchmarks {
    puts "\n>>> VIVACLAW AGENT: Processing ITC-99 Benchmark $b"
    create_project -in_memory -part $part
    
    # Read behavioral DFF if needed by design (some ITC99 use them)
    read_verilog "benchmarks/dff_behavioral.v"
    read_verilog "benchmarks/itc99_repo/${b}.v"
    
    # Autonomous Skill: Synthesis with escalation logic for large designs
    if { $b == "b17" || $b == "b18" || $b == "b19" || $b == "b20" || $b == "b21" || $b == "b22" } {
        # Large designs might need more resources or runtime
        synth_design -top $b -part $part -directive PerformanceOptimized
    } else {
        synth_design -top $b -part $part -directive Default
    }
    
    # Autonomous Skill: Implementation
    opt_design
    place_design
    phys_opt_design
    route_design
    
    # Autonomous Skill: Metrics Extraction
    report_utilization -file $rpt_dir/${b}_util.rpt
    report_timing_summary -file $rpt_dir/${b}_timing.rpt
    
    # Extract data using shell parsing as per VivaClaw logic
    set luts [exec grep "Slice LUTs" $rpt_dir/${b}_util.rpt | head -n 1 | awk "{print \$5}"]
    set ffs  [exec grep "Slice Registers" $rpt_dir/${b}_util.rpt | head -n 1 | awk "{print \$5}"]
    set wns [get_property SLACK [get_timing_paths -delay_type max]]
    
    log_metric $b "LUTs" $luts
    log_metric $b "FFs" $ffs
    log_metric $b "WNS" $wns
    
    # Health Score
    set score 100
    if { [string length $wns] > 0 && $wns < 0 } { set score [expr $score - 25] }
    log_metric $b "HealthScore" $score
    
    puts ">>> VIVACLAW AGENT: $b Complete\n"
    close_project
}
