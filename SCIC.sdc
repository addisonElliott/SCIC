# SDC Parameters
# ------------------------------------------------------------------------------------------------------
# Name of clock in Verilog code
set CLK "clock"

# Maximum fanout allowed for all gates, buffers will be added if this fanout is exceeded
# Since we want such a fast clock speed, this fanout needs to be large for slack to be met in PNR stage
set MAX_FAN_OUT 1000

# Maximum capacitance a gate can have as its load in pF
# Since we want such a fast clock speed, this capacitance needs to be large for slack to be met in PNR stage
set MAX_CAPACITANCE 1.5

# Capacitance load on the output pins in pF
set OUTPUT_PINS_CAPACITANCE 1.0

# Delay in ns from the clock edge to the input/output pins arriving
set IO_DELAY 0.25

# Clock period in ns
set CLOCK_PERIOD 10

# Percentage of clock period to add to the minimum slack required
# In other words, the RTL compiler will attempt to get a worst-case slack of SLACK_MARGIN * CLOCK_PERIOD
set SLACK_MARGIN 0.10
# ------------------------------------------------------------------------------------------------------

set_max_fanout $MAX_FAN_OUT [current_design]
set_max_capacitance $MAX_CAPACITANCE [current_design]
set_load -pin_load $OUTPUT_PINS_CAPACITANCE [all_outputs]

# set_dont_touch is used to signal that a particular instance or net should not be altered
# This was added for some of the CPU wires because they were being optimized away during synthesis due to certain bits not being used
# The optimization is fine to do except that we want to view these wires in our post-synthesis testbench and this cannot be done if they are optimized away (or optimized to be high impedance)
# The arguments for the command are the wires that connect to the registers themselves. For example, the RTL compiler will turn a register named XY
# into a register named XY_reg and a wire named XY that connects to the register. However, sometimes it optimizes and does not connect the wire to the
# register. So, the registers themselves are preserved but the wires that connect to them are not which makes it difficult to do a post-synthesis simulation
# The only issue with this is that it is not fully consistent. One example is the AC register. Since we directly assign data_out to be AC, the RTL compiler will
# remove the AC wires completely before even reading the SDC file. So, the only way this will work is by checking the data_out wire for the value of AC.
# Further experimentation is warranted to determine if there is another alternative to preserve AC wires
set_dont_touch [find / -net PC*]
set_dont_touch [find / -net IR*]
# set_dont_touch [find / -net AC*]
set_dont_touch [find / -net fetch_or_execute]
set_dont_touch [find / -net we]

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
