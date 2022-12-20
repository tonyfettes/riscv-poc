
set search_path [getenv SYN_LIB_PATH]
set target_library [getenv SYN_LIB_FILE]

set link_library [concat "*" $target_library]

# Set constraints
set CLK_TRANSITION 0.1
set CLK_UNCERTAINTY 0.1
set CLK_LATENCY 0.1

set AVG_INPUT_DELAY 0.1
set AVG_OUTPUT_DELAY 0.1

set CRIT_RANGE 1.0

set MAX_TRANSITION 1.0
set FAST_TRANSITION 0.1
set MAX_FANOUT 32
set MID_FANOUT 8
set LOW_FANOUT 1
set HIGH_DRIVE 0
set HIGH_LOAD 1.0
set AVG_LOAD 0.1
set AVG_FANOUT_LOAD 10

set DRIVING_CELL dffacs1

set WIRE_LOAD "tsmcwire"
set LOGICLIB [getenv SYN_LIB_NAME]

set sys_clk $clock_name

# Compile
set compile_top_all_paths "true"
set auto_wire_load_selection "false"
set compile_seqmap_synchronous_extraction "true"

set_host_options -max_cores 4

if { $dc_shell_status != [list] } {
  current_design $design_name
  link
  set_wire_load_model -name $WIRE_LOAD -lib $LOGICLIB $design_name
  set_wire_load_mode top
  set_fix_multiple_port_nets -outputs -buffer_constants
  create_clock -period $clock_period -name $sys_clk [find port $sys_clk]
  set_clock_uncertainty $CLK_UNCERTAINTY $sys_clk
  set_fix_hold $sys_clk
  group_path -from [all_inputs] -name input_grp
  group_path -to [all_outputs] -name output_grp
  set_driving_cell -lib_cell $DRIVING_CELL [all_inputs]
  remove_driving_cell [find port $sys_clk]
  set_fanout_load $AVG_FANOUT_LOAD [all_outputs]
  set_load $AVG_LOAD [all_outputs]
  set_input_delay $AVG_INPUT_DELAY -clock $sys_clk [all_inputs]
  remove_input_delay -clock $sys_clk [find port $sys_clk]
  set_output_delay $AVG_OUTPUT_DELAY -clock $sys_clk [all_outputs]
  set_dont_touch $reset_name
  set_resistance 0 $reset_name
  set_drive 0 $reset_name
  set_critical_range $CRIT_RANGE [current_design]
  set_max_delay $clock_period [all_outputs]
  set MAX_FANOUT $MAX_FANOUT
  set MAX_TRANSITION $MAX_TRANSITION
  uniquify
  ungroup -all -flatten

  redirect $chk_file { check_design }

  #if { ![compile -map_effort $map_effort -area_effort low] } { exit 1 }
  if { ![compile -map_effort $map_effort] } { exit 1 }

  write -hier -format verilog -output $netlist_file $design_name
  write -hier -format ddc -output $ddc_file $design_name
  write -format svsim -output $svsim_file $design_name

  redirect $rep_file { report_design -nosplit }
  redirect -append $rep_file { report_area }
  redirect -append $rep_file { report_timing -max_paths 2 -input_pins -nets -transition_time -nosplit }
  redirect -append $rep_file { report_constraint -max_delay -verbose -nosplit }
  redirect $res_file { report_resources -hier }
  remove_design -all
  read_file -format verilog -netlist $netlist_file
  current_design $design_name
  redirect -append $rep_file { report_reference -nosplit }
  quit
} else {
  quit
}
