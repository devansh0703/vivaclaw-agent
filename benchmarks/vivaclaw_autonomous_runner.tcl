set benchmarks {s27 s298 s344 s349 s382 s386 s38417}
set part "xc7a12ticsg325-1L"
set rpt_dir "/tmp/vivaclaw_metrics"
file mkdir $rpt_dir

proc log_metric { b name val } {
    puts "VIVACLAW_METRIC | $b | $name | $val"
}

foreach b $benchmarks {
    puts "\n>>> AGENT START: Processing $b"
    create_project -in_memory -part $part
    read_verilog "benchmarks/dff_behavioral.v"
    if { [file exists "benchmarks/${b}_clean.v"] } {
        read_verilog "benchmarks/${b}_clean.v"
    } else {
        read_verilog "benchmarks/${b}.v"
    }
    
    # Autonomous Skill: Synthesis
    synth_design -top $b -part $part -directive Default
    
    # Autonomous Skill: Implementation (Full stack)
    opt_design
    place_design
    phys_opt_design
    route_design
    
    # Autonomous Skill: Bitstream
    # Note: Using -force to overwrite
    catch { write_bitstream -force /tmp/vivaclaw_$b.bit } result
    puts "BITSTREAM_LOG: $result"
    
    # Autonomous Skill: Reports & Health Score
    report_utilization -file $rpt_dir/${b}_util.rpt
    report_timing_summary -file $rpt_dir/${b}_timing.rpt
    
    set wns [get_property SLACK [get_timing_paths -delay_type max]]
    set luts [exec grep "Slice LUTs" $rpt_dir/${b}_util.rpt | head -n 1 | awk "{print \$5}"]
    set ffs  [exec grep "Slice Registers" $rpt_dir/${b}_util.rpt | head -n 1 | awk "{print \$5}"]
    
    log_metric $b "WNS" $wns
    log_metric $b "LUTs" $luts
    log_metric $b "FFs" $ffs
    
    # Health Score Logic
    set score 100
    if { $wns < 0 } { set score [expr $score - 25] }
    log_metric $b "HealthScore" $score
    
    puts ">>> AGENT END: $b Complete\n"
    close_project
}
