set part "xc7a12ticsg325-1L"
set benchmark_dir "benchmarks"
set rpt_dir "/tmp/vivaclaw_benchmark_rpt"
file mkdir $rpt_dir

proc run_benchmark { name file top } {
    global part rpt_dir
    puts "VIVA_BENCHMARK_START: $name"
    
    create_project -in_memory -part $part
    read_verilog "benchmarks/dff_behavioral.v"
    read_verilog $file
    
    synth_design -top $top -part $part -directive Default
    opt_design
    place_design
    route_design
    
    report_utilization -file $rpt_dir/${name}_util.rpt
    report_timing_summary -file $rpt_dir/${name}_timing.rpt
    
    # Authoritative extraction as per vivado-reports skill
    set wns [get_property SLACK [get_timing_paths -delay_type max]]
    
    # Use shell parsing as per VivaClaw logic for robustness
    set luts [exec grep "Slice LUTs" $rpt_dir/${name}_util.rpt | head -n 1 | awk "{print \$5}"]
    
    puts "BENCHMARK_RESULT_$name: WNS=$wns, LUTs=$luts"
    puts "VIVA_BENCHMARK_END: $name"
    close_project
}

run_benchmark "s27" "benchmarks/s27_clean.v" "s27"
run_benchmark "s38417" "benchmarks/s38417_clean.v" "s38417"
