#
# SDC file for counter design
#

# Period and fanout information in global.tcl file
set CLK "clock"
set MAX_FAN_OUT 50
set MAX_CAPACITANCE 0.1
set OUTPUT_PINS_CAPACITANCE 1.0
set IO_DELAY 0.5
set CLOCK_PERIOD 10

set_max_fanout $MAX_FAN_OUT [current_design]
# TODO: not sure if this is a problem or not? Further experimentation warranted
# set_max_capacitance $MAX_CAPACITANCE [current_design]
set_load -pin_load $OUTPUT_PINS_CAPACITANCE [all_outputs]

# This is an experiment to see if we can force the compiler t try and meet a 10% slack limit
# Clock is 15000ps, risin
# TODO: Holding off on trying this until I ensure the RAM is still the bottleneck
# set_max_delay -from {fetch_or_execute} -to {memory_reg} 6000

# Create the transmitter clock
create_clock    -name $CLK  \
                -period $CLOCK_PERIOD \
                -waveform [list [expr $CLOCK_PERIOD / 2.0] 0] \
                [get_ports $CLK]

# Set input and output delays
set_input_delay $IO_DELAY -clock $CLK [remove_from_collection [all_inputs] $CLK]
set_output_delay $IO_DELAY -clock $CLK [all_outputs]


