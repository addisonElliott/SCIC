#
# SDC file for counter design
#

# Period and fanout information in global.tcl file
set CLK "clock"
set MAX_FAN_OUT 100
set CLOCK_PERIOD 10

set_max_fanout $MAX_FAN_OUT [current_design]
set_max_capacitance 50
# set_load XXX load capacitance of output wires

# Create the transmitter clock
create_clock    -name $CLK  \
                -period $CLOCK_PERIOD \
                -waveform [list [expr $CLOCK_PERIOD / 2.0] 0] \
                [get_ports $CLK]

# Set input and output delays
set_input_delay 0.5 -clock $CLK [remove_from_collection [all_inputs] $CLK]
set_output_delay 0.5 -clock $CLK [all_outputs]

# set_false_path  -from  [get_ports {$SEL0 $SEL1}]


