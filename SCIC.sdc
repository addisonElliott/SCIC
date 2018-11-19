# SDC Parameters
# ------------------------------------------------------------------------------------------------------
# Name of clock in Verilog code
set CLK "clock"

# Maximum fanout allowed for all gates, buffers will be added if this fanout is exceeded
set MAX_FAN_OUT 520

# Maximum capacitance a gate can have as its load in pF
set MAX_CAPACITANCE 1.10

# Capacitance load on the output pins in pF
set OUTPUT_PINS_CAPACITANCE 1.0

# Delay in ns from the clock edge to the input/output pins arriving
set IO_DELAY 0.25

# Clock period in ns
set CLOCK_PERIOD 20

# Percentage of clock period to add to the minimum slack required
# In other words, the RTL compiler will attempt to get a worst-case slack of SLACK_MARGIN * CLOCK_PERIOD
set SLACK_MARGIN 0.1
# ------------------------------------------------------------------------------------------------------

set_max_fanout $MAX_FAN_OUT [current_design]
set_max_capacitance $MAX_CAPACITANCE [current_design]
set_load -pin_load $OUTPUT_PINS_CAPACITANCE [all_outputs]

# TODO Explain this in detail
# Explain that doing set_dont_touch on instances did not work for me, in my case PC_reg
set_dont_touch [find / -net PC*]
set_dont_touch [find / -net IR*]
# set_dont_touch [find / -net AC*]
set_dont_touch [find / -net fetch_or_execute]
set_dont_touch [find / -net we]

# TODO: Fix & find out reason why AC net is not present? Need some way to probe this?

# Based on my understanding, setup clock uncertainty will reduce the effective period by the amount while hold clock uncertainty will increase the clock period
# The RTL compiler tries to get a positive slack but includes no way to have a slack margin, i.e. no way to require a minimum slack value. This approach does that by effectively reducing the clock period and requires the RTL compiler to try and meet that period instead
# This sets the setup clock uncertainty to be a percentage of the clock period
set_clock_uncertainty -setup [expr {$CLOCK_PERIOD * $SLACK_MARGIN}] [get_ports $CLK]

# Create the transmitter clock
create_clock    -name $CLK  \
                -period $CLOCK_PERIOD \
                -waveform [list [expr $CLOCK_PERIOD / 2.0] 0] \
                [get_ports $CLK]

# Set input and output delays
set_input_delay $IO_DELAY -clock $CLK [remove_from_collection [all_inputs] $CLK]
set_output_delay $IO_DELAY -clock $CLK [all_outputs]
