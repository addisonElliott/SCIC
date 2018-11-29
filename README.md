# SIUE CPU IC (SCIC)
Project of Addison Elliott and Dan Ashbaugh to create IC layout of 32-bit custom CPU used in teaching digital design at SIUE.

**Note:** This guide contains information based on Addison and Dan's experience with the Cadence tools during the 1 month period spent on the project. As a result, this guide may contain mistakes or incorrect information and pull requests are welcome to fix any issues.

# Table of Contents

TODO: Do me!

# Overview

In the introduction class to digital design at SIUE, there is a simple CPU written in Verilog that is used for demonstration purposes. The design is discussed and simulated but never synthesized, whether it be on an FPGA or ASIC. In this project, we took the CPU from this class and created an ASIC design using the Cadence toolset making some minor changes and additions to the CPU itself.

**Note:** The original CPU from the digital design class can be found in the [old_files](https://github.com/addisonElliott/SCIC/tree/master/old_files) folder of this repository.

**Specifications:**
* 1x 32-bit accumulator (AC)
* 32-bit instructions (1 word)
* Bidirectional I/O port (input = switches, output = LEDs)
* RAM
* ROM
* Non-pipelined implementation. Clocks per instruction (CPI) = 2
* 32-bit adder
* 4-bit opcode, 9 instructions, 16-bit address space
* Behavioral implementation

Instruction format for the CPU is as follows:

        31----28------------16-15----------------0
         Opcode    Unused            Operand

The updated CPU that we worked on contains the following instructions (bolded instructions are new):

| Instruction      | Opcode |            RTL            |
|------------------|--------|---------------------------|
| Add              |   1    | AC <= AC + mem(IR[15:0])  |
| **Shift Left**   |   2    | AC <= AC << mem(IR[15:0]) |
| **Shift Right**  |   3    | AC <= AC >> mem(IR[15:0]) |
| **Load immed.**  |   4    | AC <= IR[15:0]            |
| Load             |   5    | AC <= mem(IR[15:0])       |
| **Or**           |   6    | AC <= AC | mem(IR[15:0])  |
| Store            |   7    | mem(IR[15:0]) <= AC       |
| Branch           |   8    | PC <= IR[15: 0]           |
| **And**          |   9    | AC <= AC & mem(IR[15:0])  |

Address range for the memory controller is as follows:

| Name |    Range    | Size (words) |                Binary Range                |
|------|-------------|--------------|--------------------------------------------|
| ROM  |  0000-001F  |      32      | 0000 0000 0000 0000 -> 0000 0000 0001 1111 |
| RAM  |  0020-003F  |      32      | 0000 0000 0010 0000 -> 0000 0000 0011 1111 |
| I/O  |  0040-005F  |      32      | 0000 0000 0100 0000 -> 0000 0000 0101 1111 |

A detailed explanation of the code is given in the section TODO: ME below.

# Setup

**Note:** This was run using Dr. Engel's special workflow with custom TCL scripts. You must do this using the lab machines with their custom scripts in order for this tutorial to work.

Begin by logging into a VLSI lab machine in EB3009 and then open a terminal. Run the following commands to get your terminal setup with Dr. Engel's custom scripts. These commands only need to be run once each time you open a terminal to setup your environment correctly.
```
cds_ams
cd $PHOME
setup_edi
```

Navigate into *verilog.src* and clone the project repository with the following commands. **Note:** If you are wanting to push changes back to the repository eventually (requires write access), then you must use the following URL rather than the one given below `https://<GITHUB_USERNAME>@github.com/addisonElliott/SCIC.git`.
```
cd verilog.src
git clone https://github.com/addisonElliott/SCIC.git
```

The directory `verilog.src` contains all Verilog projects that are going to be simulated or synthesized using Cadence. This is a custom directory structure setup by Dr. Engel to adhere to his specific workflow. The purpose is to standardize where projects are located for ease of use. Cloning the repository only needs to be done once because afterwards it will be stored on your machine. But, if you want to pull new changes from the repository, you can do so with the command `git pull origin master`. You must be inside the directory to run the git command (or any git commands for that matter).

Next, one more once-per-machine step must be done. There is a TCL and SDC file that is expected to be in a different directory to adhere to Dr. Engel's workflow. Since we wanted to make these files tracked by our GitHub repository, we place these files in the repository and create symbolic links (i.e. symlinks) to these locations. Run the following two commands to create symlinks for the TCL and SDC file in the appropriate directory.
```
ln -s $PHOME/verilog.src/SCIC/env.SCIC.tcl $PHOME/env_files/
ln -s $PHOME/verilog.src/SCIC/SCIC.sdc $PHOME/verilog.src/sdc/
```

If you want to verify that the symlinks were made, take a look at the figure below where I used the `ll` (alias to `ls -l`) command to achieve this. You can see that the output shows a symlink pointing to the repository location.

![Image 1](https://github.com/addisonElliott/SCIC/blob/master/images/image1.png?raw=true)

Once the repository is cloned and setup, one remaining command must be called. This command must be called each time a terminal is opened to set the current base project. `sb` is a script written by Dr. Engel and is short for **set base** to set the base project. The argument to this script is the name of any project contained in the `verilog.src` folder. To see the current project, you can type `b` for the **base** project. The workflow commands used below use the current "base project" to perform their respective actions on.
```
sb SCIC
```

# Workflow

The general workflow for synthesizing a Verilog project to an IC can be seen below. Preceding the RTL simulation is developing the Verilog module, general setup of the project and creating the SDC & environment TCL file. While developing your project, it is *extremely* common to encounter an error in one of the steps, in which case you will correct the error and restart the workflow.

![Cadence Workflow](https://github.com/addisonElliott/SCIC/blob/master/images/CadenceWorkflow.png?raw=true)

# Simulation

The first step of any design is to simulate the Verilog code using a testbench to ensure that it is performing the way it is designed. There are three cases throughout the workflow that a simulation is performed.

1. RTL Simulation (**rtl**)
    * Ideal simulation with no delays included. Used to verify design functionally works
2. Post-Synthesis Simulation (**syn**)
    * Performed after synthesis and includes propagation delay for gates (no wiring delay is included)
3. Post-PNR Simulation (**pnr**)
    * Performed after place & route and includes the wiring delay as well as the propagation delay for gates
    * This is the final simulation and **should** mimic the real-life waveforms present on the chip

The simulation in each case can be ran the same way except for one minor change. The *env.SCIC.tcl* file must be edited to set the simulation mode to the desired mode. Editing the file can be done using your favorite text editor (gedit, vim, nano, etc). Change the line `SIM_MODE` to the desired mode.

![Image 4](https://github.com/addisonElliott/SCIC/blob/master/images/image4.png?raw=true)

Run the following commands to simulate the design. There is no need to run the *cd* command if you are already at *$PHOME*.
```
cd $PHOME
sim
```

Cadence's simulator software *SimVision* should pop up. There will not be a detailed discussion on using SimVision, since it is fairly self explanatory. You can navigate through the Design Browser on the left to find wires that you want to add to the waveform window. You can add them by right-clicking and select "Send to Waveform Window". Once you have all the wires you want in the Waveform Window, you cans elect the "Play" icon in the toolbar to run the simulation. There is a bar at the bottom that can be dragged to change at what point of time you are viewing. See screenshots below for details on the process described.

**Note:** To make your life easier, you can save your current setup in the waveform window by clicking **File -> Save Command Script** and save the file as restore.tcl which will automatically be loaded each time a simulation is ran. This saves you the trouble of having to add the same wires to the waveform window.

See the results section for screenshots of what you **should** see for this step. TODO: Link here

![Image 2](https://github.com/addisonElliott/SCIC/blob/master/images/image2.png?raw=true)
![Image 3](https://github.com/addisonElliott/SCIC/blob/master/images/image3.png?raw=true)

Before running a Post-Synthesis and Post-PNR simulation, you must type the following command to create special testbenches that include delay information. The delay information from the synthesis and place & route step are stored in a Standard Delay Format (SDF) which is loaded in the testbench using the *$sdf_annotate* function. Open up the generated testbenches to see the differences yourself!
```
sdf
```

# Synthesis

After running a RTL simulation to verify the functionality of the project (TODO: Link to results here), the next step is to synthesize the design using the *RTL Compiler* (rc). Synthesizing the design, in this context, means to take Verilog and turn it into a purely structural design in terms of the standard cells available to the process (e.g. AOI22, NAND22, NOR22, inverter, D flip-flop). If the Verilog code is already purely structural, then the synthesize tool will not be able to optimize the design much.

Additionally, the synthesize step will also calculate the worst case timing path, total consumed area for each Verilog module instance, total consumed power for each Verilog module instance and much more. This is the point in the design where you can analyze the design and see if the area, power, timing meets your requirements.

In simple terms, the synthesize step encompasses figuring out all the gates, flip flops and components that are required and how they should be connected to achieve certain constraints. The synthesize step does **not** take into account wiring resistance or capacitance.

One important component for the synthesis step is the *SCIC.sdc* file, which is a TCL script that specifies constraints for the synthesize tool. A detailed explanation of the SDC file can be seen in (TODO: Link here).

The synthesis tool does **a lot** of optimization such as removing unused registers, unused wires and any other unused logic. The tool attempts to meet all constraints in the SDC file first and it's next priority is minimizing area. An example of this that puzzled us at first was the synthesis of an adder. If the clock speed was slow enough then a ripple-carry adder would be used because it minimizes area **and** meets timing constraints. However, as the clock speed reaches a certain point, the ripple-carry adder becomes too slow and the synthesizer optimizes to use a carry lookahead adder.

Another frustration with the synthesis tool with optimization is that it can be difficult to probe the testbench wires because some of the wires may disappear, become high impedance or change due to the fact that the synthesis tool optimized them away. The best way I found to counteract this effect is to use the *set_dont_touch* command on the net in the SDC file, but even then it was a bit buggy with the results.

Run these commands from your terminal to launch the RTL compiler:
```
cd $PHOME
syn
```

The *syn* command is a custom TCL script written by Dr. Engel and a former graduate student that runs the RTL compiler and runs a synthesis script within it. It will begin by parsing the SDC file and afterwards the script will pause to wait for user input. You will read the output in your terminal to ensure there were no errors, and if so type 'resume' in the terminal.

The script will finish running and then a schematic window will appear. You can double click on any of the blocks in the hierarchy to view a schematic for them. In addition, the "Report" menu provides useful options for analyzing various aspects of the design (power, area, timing, etc).

See the results section for screenshots of what you **should** see for this step. The synthesis should only take around 5-10minutes to complete. TODO: Link here Don't forget to run Post-Synthesis simulation to verify the synthesis is working correctly. The simulation should show delays between signals now.

![Image 5](https://github.com/addisonElliott/SCIC/blob/master/images/image5.png?raw=true)

### Reports & Menus

* Report
    * Datapath
        * Information about any datapath elements used, in our design there were none so this does not provide any useful information.
    * DFT
        * **Violations** - Useful for displaying violations such as maximum fanout or capacitance that were not met
        * **Scan Chans** - No idea what this does, no scan chains in design
        * **Fail TDRC** - No idea what this does, no registers that meet criterion in design
        * **Level Sensitive** - No idea what this does, no registers that meet criterion in design
        * **Lockup Elements** - No idea what this does, no registers that meet criterion in design
        * **Pass TDRC** - No idea what this does, shows clock edge for each register
        * **Preserved** - No idea what this does, no registers that meet criterion in design
    * Netlist
        * **Area** - Area by each Verilog module split into cell area and net area summed to total area in square micrometers
![Area](https://github.com/addisonElliott/SCIC/blob/master/images/synthesis_area.png?raw=true)
        * **Mapped Gates** - Lists each gate used, the number of instances in the design and the area these take
![Mapped Gates](https://github.com/addisonElliott/SCIC/blob/master/images/synthesis_mapped_gates.png?raw=true)
        * **Statistics** - Displays area and percentages of sequential, inverter, buffer & combinational logic
![Statistics](https://github.com/addisonElliott/SCIC/blob/master/images/synthesis_statistics.png?raw=true)
        * **Violations** - Displays any DRC violations that occurred during synthesis
    * Power
        * **Detailed Report** - Displays dynamic and static power for each Verilog module
![Power Report](https://github.com/addisonElliott/SCIC/blob/master/images/synthesis_power.png?raw=true)
        * **RTL Power** - Blank for this project, unsure what it does
        * **Library Domains** - Blank for this project, unsure what it does
        * **Power Domains** - Blank for this project, unsure what it does
        * **Instance Power Usage** - Displays a pie chart of the instance power (short circuit power)
![Instance Power Chart](https://github.com/addisonElliott/SCIC/blob/master/images/synthesis_instance_power.png?raw=true)
        * **Net Power Usage** - Displays a pie chart of the net power (charge/discharge capacitances power)
![Net Power Chart](https://github.com/addisonElliott/SCIC/blob/master/images/synthesis_net_power.png?raw=true)
        * **Probability Histogram** - Causes RTL Compiler to crash
        * **Toggle Rate Histogram** - Causes RTL Compiler to crash
    * Timing
        * **Endpoint Histogram** - Displays a histogram with the slack values for each path and number of occurrences
![Timing Histogram](https://github.com/addisonElliott/SCIC/blob/master/images/synthesis_timing_hist.png?raw=true)
        * **Lint Report** - Displays any issues with meeting timing constraints
        * **Worst Path** - Displays slack for worst case path
![Timing Worst Path](https://github.com/addisonElliott/SCIC/blob/master/images/synthesis_timing.png?raw=true)
* Tools
    * **Object Browser** - Allows browsing of the synthesized logic, includes every single net, instance, flip flop and gate that is used and allows for easy traversal.
![Object Browser](https://github.com/addisonElliott/SCIC/blob/master/images/synthesis_object_browser.png?raw=true)
* File
    * **Source Script** - Can be used to load an existing synthesis. For any project, the script you want to load is */opt/home/campus/<USERNAME>/cds/ece484/syn_dir/dsn/\<PROJECT NAME\>/\<PROJECT NAME\>.rc_setup.tcl*
![File Open](https://github.com/addisonElliott/SCIC/blob/master/images/synthesis_file_open.png?raw=true)

# Place & Route

Uses Cadence Encounter tools

Creates floorplan of design and places pins. Review it and type resume.

Next, it optimizes the design and starts to place & route the items. There is a section where it will check the timing 

This can take anywhere from 1-15minutes depending on the design. At the very least, there should be text printing out to the console log. One part of the design is it will try to meet timing constraints and will keep printing out the slack (negative is bad!) and will slowly optimize to try and get it positive (to 0.1ns). If your timing constraints are too much, then this will take awhile and will eventually quit with negative slack. In our case, it will stop around -2.5ns slack. This means the minimum clock speed you can use is the clock period plus the 2.5ns of slack (12.5ns in this instance).

Maybe include comment about set_clock_uncertainty and removing from updated SDC file... Got to see if this affects anything first

Include command for running it, pnr basically

Include comments about routers, wroute vs nano

After awhile, the routing will be done and it will suspend again waiting for the user's response. At this point, you want to look at the console and check for geometry or connectivity violations. You don't want any geometry violations, but a few connectivity violations may be okay depending on the errors. If you have DRC violations in Encounter, then when you get it into IC station, it will likely have LVS or DRC errors as well! But this is not always the case, user discretion is necessary to read and understand the errors.

Show how to use violation browser to check out issues. Say that white Xs are DRC issues. Can zoom in and check them out.

Say how sometimes running a different router type or running route again might fix them. In the case of this project, the best results was doing wroute first and then running nano route afterwards. Show command for how to do that.

TODO: Show images here

TODO: Do this

# Final Steps

TODO: Do this

edi2ic

edi2sch

Must run in this order! edi2ic overwrites the library!

Start icd_ams, open ediLib -> SCIC etc

Run LVS & DRC checks. This is what really matters in the end! If you get issues, you need to figure out why and figure out why!!!

# Code Explanation

TODO: Talk about SCIC.sdc
TODO: Talk about env.SCIC.tcl
TODO: Talk about CPU.v
TODO: Talk about memory_controller.v

# Results

## RTL Simulation

TODO: XXX

## Synthesis

TODO: XXX

## Post-Synthesis Simulation

TODO: XXX

## Place & Route

TODO: XXX

## Post-PNR Simulation

TODO: XXX

Include results of what LVS & DRC errors are present

# Overall List of Commands to Type
```
cds_ams
cd $PHOME
setup_edi
sb SCIC

<Edit env.SCIC.tcl to set SIM_MODE to rtl>
sim

syn
<Follow command prompt and review timing, power & other constraints in GUI that appears once synthesis is done>

# Only needs to be done once
sdf

<Edit env.SCIC.tcl to set SIM_MODE to syn>
sim

# TODO: Edit stuff here at all?

pnr
<Follow command prompt and review layout after finished>
<Quit encounter once layout is complete>

edi2ic
edi2sch

icd_ams
<Go to ediLib, select SCIC, double-click layout>

<Run LVS & DRC on layout to check for errors>
```

# Simulating with Icarus Verilog

Performing a simulation with Icarus Verilog is great because it is an easy-to-install tool that provides cross-platform support. This is good to use when debugging and developing your Verilog project without access to the Cadence toolset.

**Note:** If this is your first time installing [Icarus Verilog](http://iverilog.icarus.com/), then you will need to make sure that the binary path is in your PATH variable. This will allow you to run the commands *iverilog*, *vvp* and *gtkwave* in your repository path. During installation, you will want to check the option to install gtkwave as well. Icarus Verilog must **not** be installed in a path with spaces or else the commands will fail. The following two paths must be added to your PATH variable:
* \<IVERILOG PATH>/bin (e.g. C:/iverilog/bin)
* \<IVERILOG PATH>/gtkwave/bin (e.g. C:/iverilog/gtkwave/bin)

Open a command prompt (cmd.exe for Windows, Terminal on Linux), navigate to this repository and run the following commands:
```
iverilog -o out.o CPU.v memory_controller.v Mux4to1.v RAM.v ROM.v SCIC.v io_controller.v SCIC_tb.v
vvp out.o
gtkwave SCIC.vcd
```