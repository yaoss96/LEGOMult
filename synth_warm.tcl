# synth_warm.tcl -- synth.tcl with the warm-up the batch flow needs.
#
# A fresh `vivado -mode batch` session fails its first synth_design with
#   couldn't read file ".../unimacro/unimacro_vhdl.tcl": No error
# because the helper process that spawns child vivados is not ready yet.
# ip_sweep.tcl and bws_synth.tcl both absorb this with a throw-away synthesis;
# this wrapper does the same, then hands over to synth.tcl unchanged.
#
#   vivado -mode batch -source synth_warm.tcl -tclargs <file.v> <part> <mode> <period>
catch {
    set wpart [lindex $argv 1]
    if {$wpart eq ""} { set wpart "xc7s100fgga676-2" }
    create_project -in_memory -part $wpart
    set wf "[pwd]/_warm_synth.v"
    set fo [open $wf w]
    puts $fo "module warmup(input a, input b, output o); assign o = a & b; endmodule"
    close $fo
    read_verilog $wf
    synth_design -top warmup -part $wpart
    close_project
}
source [file join [file dirname [info script]] synth.tcl]
