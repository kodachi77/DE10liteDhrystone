load_package report

if { $argc < 1 } {
    puts "Error: project name could not be determined."
    exit 13
}

set proj_name [lindex $argv 0]
project_open $proj_name
load_report

set panels(0) "*Slow 1200mV 85C Model Fmax Summary"
set panels(1) "*Slow 1200mV 85C Model Setup Summary"
set panels(2) "*Slow 1200mV 85C Model Hold Summary"
set panels(3) "*Slow 1200mV 0C Model Fmax Summary"
set panels(4) "*Slow 1200mV 0C Model Setup Summary"
set panels(5) "*Slow 1200mV 0C Model Hold Summary"
set panels(6) "*Clocks"
set panels(7) "*Clock Status Summary"
set panels(8) "*Unconstrained Paths Summary"


for { set i 0 }  { $i < [array size panels] }  { incr i } {
    set panel $panels($i)
    set id [get_report_panel_id $panel]

    if {$id != -1} {
        set fname [string tolower $panel]
        regsub -all " " $fname "_" fname
        regsub -all ***=* $fname "" fname
        write_report_panel -file "${fname}.html" -html -id $id
    } else {
        puts "Error: report panel '${panel}' could not be found."
    }
}

unload_report
project_close