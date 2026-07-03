# =============================================================================
#  synth.tcl  --  Vivado out-of-context synthesis + REAL primitive count
#  for the generated tiled multipliers (apples-to-apples with the paper, which
#  reports post-synthesis LUTs on an AMD Kintex-7).
#
#  Usage (called by synth.bat, or directly):
#     vivado -mode batch -source synth.tcl -tclargs <file.v> [part] [mode] [period_ns]
#       <file.v>   : the generated multiplier RTL (e.g. tiled_mult_32b_L4_d1_ss.v)
#       part       : FPGA part        (default xc7k70tfbv484-3 = the paper's target)
#       mode       : comb | reg       (default comb)
#                      comb = pure combinational core; reports LUT/CARRY/DSP area
#                      reg  = register-sandwich (FF a,b in ; FF r out) + a clock,
#                             so you also get the critical-path delay (CPD)
#       period_ns  : target clock period for mode=reg (default 3.0)
#
#  Prints a single  "RESULT ..."  line and writes <file>_util.txt plus
#  <file>_cpd.txt containing the CPD/timing report.
# =============================================================================

set vfile  [lindex $argv 0]
set part   "xc7k70tfbv484-3"
set smode  "comb"
set period 3.0
if {[llength $argv] > 1} { set part   [lindex $argv 1] }
if {[llength $argv] > 2} { set smode  [lindex $argv 2] }
if {[llength $argv] > 3} { set period [lindex $argv 3] }

# ---- read RTL, detect the top module + its port widths -----------------------
set fh [open $vfile r]; set txt [read $fh]; close $fh
if {![regexp {module\s+(\w+)\s*\(} $txt -> top]} {
    puts "ERROR: no module found in $vfile"; exit 1
}
regexp {input\s+\[(\d+):0\]\s+a} $txt -> wam1
regexp {input\s+\[(\d+):0\]\s+b} $txt -> wbm1
regexp {output\s+\[(\d+):0\]\s+r} $txt -> rm1
puts "== synth  $vfile   top=$top   part=$part   mode=$smode =="

# Robust Windows/Vivado batch mode: avoid intermittent helper-process failures
# such as "couldn't read file .../retarget_vhdl.tcl: No error".
set_param general.maxThreads 1
set_param synth.maxThreads 1

read_verilog $vfile

if {$smode eq "reg"} {
    # ---- register-sandwich wrapper so the multiplier path is timed ----
    set wf "[file rootname $vfile]_sandwich.v"
    set o [open $wf w]
    puts $o "module ${top}_sandwich (input clk,"
    puts $o "  input  \[$wam1:0\] a_i, input \[$wbm1:0\] b_i, output reg \[$rm1:0\] r_o);"
    puts $o "  reg \[$wam1:0\] a_r; reg \[$wbm1:0\] b_r; wire \[$rm1:0\] r_w;"
    puts $o "  always @(posedge clk) begin a_r<=a_i; b_r<=b_i; r_o<=r_w; end"
    puts $o "  $top dut(.a(a_r), .b(b_r), .r(r_w));"
    puts $o "endmodule"
    close $o
    read_verilog $wf
    set syntop ${top}_sandwich
    synth_design -top $syntop -part $part
    create_clock -name clk -period $period [get_ports clk]
} else {
    set syntop $top
    synth_design -top $syntop -part $part -mode out_of_context
}

catch { opt_design -quiet }

# ---- count REAL primitives after optimisation --------------------------------
set nlut   [llength [get_cells -hier -filter {REF_NAME =~ LUT*}]]
set ncarry [llength [get_cells -hier -filter {REF_NAME =~ CARRY*}]]
set ndsp   [llength [get_cells -hier -filter {REF_NAME =~ DSP*}]]
set nff    [llength [get_cells -hier -filter {REF_NAME =~ FD*}]]

set rpt "[file rootname $vfile]_util.txt"
report_utilization -file $rpt

# "Slice LUTs" is the paper's yardstick (accounts for LUT-combining); pull it
# from the utilization report.  Falls back to the raw LUT-cell count.
set slicelut $nlut
set util [report_utilization -return_string]
if {![regexp {Slice LUTs\*?\s*\|\s*(\d+)} $util -> slicelut]} {
    regexp {CLB LUTs\*?\s*\|\s*(\d+)} $util -> slicelut
}

# ---- CPD / max data path ------------------------------------------------------
# Always emit a per-design CPD text file.  For the default pure-combinational
# core there is no clock, so Vivado timing_summary reports WNS/TNS=NA; use an
# explicit input-to-output timing report and parse "Data Path Delay".  For reg
# mode, report the FF-to-FF critical path and derive CPD from period-WNS.
set cpdrpt "[file rootname $vfile]_cpd.txt"
set cpd "NA"
set wns "NA"
set cpdfh [open $cpdrpt w]
puts $cpdfh "CPD report for $vfile"
puts $cpdfh "top=$top syntop=$syntop part=$part mode=$smode period_ns=$period"
puts $cpdfh ""
close $cpdfh

if {$smode eq "reg"} {
    set tpaths [get_timing_paths -delay_type max -max_paths 1]
    if {[llength $tpaths] > 0} {
        set wns [get_property SLACK [lindex $tpaths 0]]
        # CPD ~= target period - worst-negative-slack
        set cpd [format "%.3f" [expr {$period - $wns}]]
    }
    report_timing -delay_type max -max_paths 5 -sort_by group -file $cpdrpt -append
} else {
    if {[catch {report_timing -from [all_inputs] -to [all_outputs] -max_paths 5 -sort_by group -delay_type max -file $cpdrpt -append} terr]} {
        set cpdfh [open $cpdrpt a]
        puts $cpdfh "report_timing failed: $terr"
        close $cpdfh
    }
    if {![catch {set cpdfh [open $cpdrpt r]; set cpd_txt [read $cpdfh]; close $cpdfh}]} {
        if {[regexp {Data Path Delay:\s*([0-9]+(?:\.[0-9]+)?)ns} $cpd_txt -> cpd_val]} {
            set cpd [format "%.3f" $cpd_val]
        }
    }
}

# Prepend a compact summary to the CPD report for easy reading.
if {$cpd eq "NA"} {
    set cpd_summary "CPD=NA"
} elseif {$smode eq "reg"} {
    set cpd_summary [format "CPD=%sns(period=%.1f, WNS=%s)" $cpd $period $wns]
} else {
    set cpd_summary "CPD=${cpd}ns(input_to_output_max_data_path)"
}
if {![catch {set oldfh [open $cpdrpt r]; set old_cpd_txt [read $oldfh]; close $oldfh}]} {
    set newfh [open $cpdrpt w]
    puts $newfh $cpd_summary
    puts $newfh ""
    puts -nonewline $newfh $old_cpd_txt
    close $newfh
}

# ---- power (vectorless estimate; meaningful in reg mode with a clock) ---------
set pwrrpt "[file rootname $vfile]_power.txt"
set ptot "NA"; set pdyn "NA"; set plogic "NA"; set plut "NA"; set psig "NA"; set pdsp "NA"
if {![catch {report_power -file $pwrrpt}]} {
    if {![catch {set pf [open $pwrrpt r]; set ptxt [read $pf]; close $pf}]} {
        # values may be reported as "<0.001"; allow a leading '<'
        regexp {Total On-Chip Power \(W\)\s*\|\s*(<?[0-9.]+)} $ptxt -> ptot
        regexp {Dynamic \(W\)\s*\|\s*(<?[0-9.]+)} $ptxt -> pdyn
        regexp {Slice Logic\s*\|\s*(<?[0-9.]+)} $ptxt -> plogic
        regexp {LUT as Logic\s*\|\s*(<?[0-9.]+)} $ptxt -> plut
        regexp {Signals\s*\|\s*(<?[0-9.]+)} $ptxt -> psig
        regexp {DSPs\s*\|\s*(<?[0-9.]+)} $ptxt -> pdsp
    }
}

# ---- machine-readable metrics (one key=val per line) for the collator --------
set metrics "[file rootname $vfile]_metrics.txt"
set mf [open $metrics w]
puts $mf "module=$top"
puts $mf "part=$part"
puts $mf "mode=$smode"
puts $mf "SliceLUT=$slicelut"
puts $mf "LUTcells=$nlut"
puts $mf "CARRY4=$ncarry"
puts $mf "DSP=$ndsp"
puts $mf "FF=$nff"
puts $mf "CPD_ns=$cpd"
puts $mf "Pdyn_W=$pdyn"
puts $mf "Plogic_W=$plogic"
puts $mf "Plut_W=$plut"
puts $mf "Psignals_W=$psig"
puts $mf "Pdsp_W=$pdsp"
puts $mf "Ptot_W=$ptot"
close $mf

set line "RESULT  $top  :  SliceLUT=$slicelut  (LUTcells=$nlut)  CARRY4=$ncarry  DSP=$ndsp  FF=$nff  $cpd_summary  Pdyn=$pdyn  Plogic=$plogic  Ptot=$ptot"
puts "============================================================"
puts $line
puts "utilization report -> $rpt"
puts "CPD/timing report -> $cpdrpt"
puts "power report -> $pwrrpt"
puts "metrics -> $metrics"
puts "============================================================"
exit 0
