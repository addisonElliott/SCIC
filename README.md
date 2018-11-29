# SIUE CPU IC (SCIC)
Project of Addison Elliott and Dan Ashbaugh to create IC layout of 32-bit custom CPU used in teaching digital design at SIUE.

# Table of Contents

TODO: Do me!

# Overview

In the introduction class to digital design at SIUE, there is a simple CPU written in Verilog that is used for demonstration purposes. The design is discussed and simulated but never synthesized, whether it be on an FPGA or ASIC. In this project, we took the CPU from this class and created an ASIC design using the Cadence toolset making some minor changes and additions to the CPU itself.

**Note:** The original CPU from the digital design class can be found in the old_files folder of this repository.

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

# Cadence Tools
**Note:** This was run using Dr. Engel's special setup with TCL scripts and such. You must do this using the lab machines with their custom scripts.

# Setup

Begin by logging into a VLSI lab machine in EB3009 and then open a terminal. Run the following commands to get your terminal setup with Dr. Engel's custom scripts. These commands only need to be run once each time you open a Terminal to setup your environment correctly.
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

Finally, one remaining step must be done each time a Terminal is opened. `sb` is a script written by Dr. Engel and is short for **set base** to set the base project. The argument to this script is the name of any project contained in the `verilog.src` folder. To see the current project, you can type `b` for the **base** project. The workflow commands used below use the current "base project" to perform their respective actions on.
```
sb SCIC
```

# Workflow

# Simulation

The first step of any design is to simulate the Verilog code using a testbench to ensure that it is **functionally** working correctly. There is no point in worrying about propagation delay, timing constraints, capacitance, resistances until you know that your design does what it is supposed to in the first place. This is the purpose of running a simulation is to verify that the design does what it is supposed to.

We need to edit the TCL file to set the simulation mode: rtl, syn or pnr. When designing an IC, you typically start with the 'rtl' mode, then run with 'syn' and finally run it with 'pnr'. From left to right, the simulation mode starts with the least amount of information and then begins to add more and more. For example, rtl mode is simulating your Verilog design in the same way that Icarus Verilog simulates your code. It does not know anything about propagation delay between gates, gate size, etc. The 'syn' mode adds a bit more information by including timing delay for the gates and running a timing analysis. Finally, the 'pnr' mode (Place-n-Route) simulation includes delay from wires.

![Image 4](https://github.com/addisonElliott/SCIC/blob/master/images/image4.png?raw=true)

Editing the env.SCIC.tcl file can be done using your favorite text editor (gedit, vim, nano, etc). Change the line `SIM_MODE` to `rtl`. In the remainder of this document, we will tell you to change the SIM_MODE to a different value and you will need to open this file using a text editor and change the value appropriately.

Finally, we are ready to run our simulation on the project. Run the commands below. There is no need to run the *cd* command if you are already at *$PHOME*.
```
cd $PHOME
sim
```

Cadence's simulator software *SimVision* should pop up. There will not be a detailed discussion on using SimVision, since it is fairly self explanatory. You can navigate through the Design Browser on the left to find wires that you want to add to the waveform window. You can add them by right-clicking and select "Send to Waveform Window". Once you have all the wires you want in the Waveform Window, you cans elect the "Play" icon in the toolbar to run the simulation. There is a bar at the bottom that can be dragged to change at what point of time you are viewing. See screenshots below for details on the process described.

![Image 2](https://github.com/addisonElliott/SCIC/blob/master/images/image2.png?raw=true)
![Image 3](https://github.com/addisonElliott/SCIC/blob/master/images/image3.png?raw=true)

# Synthesis

Once the design is logically correct, the next step is synthesizing the design into gates and analyzing this design. This does not include wiring capacitances or resistance because the gates are not placed yet, that is handled in the place & route tool. This synthesis will provide information such as power usage, worst-case timing path, number of gates used, area used and much more. The *SCIC.sdc* file will be used in the synthesis to gather information about clock speed, input/output capacitance and delay and more.

Run these commands from your terminal to launch the RTL compiler:
```
cd $PHOME
sb SCIC
syn
```

The *syn* command is a custom TCL script written by Dr. Engel and a former graduate student that runs the RTL compiler and runs a synthesis script within it. It will begin by parsing the SDC file and afterwards the script will pause to wait for user input. You will read the output in your terminal to ensure there were no errors, and if so type 'resume' in the terminal.

The script will finish running and then a schematic window will appear. You can double click on any of the blocks in the hierarchy to view a schematic for them. Below are some screenshots showing some of the capabilities that this synthesis contains.

TODO: Images here

TODO: Describe how to do a post-synthesis simulation

# Synthesis with Place & Route

TODO: Do this

# Simulating with Icarus Verilog

**Note:** If this is your first time installing [Icarus Verilog](http://iverilog.icarus.com/), then you will need to make sure that the binary path is in your PATH variable. This will allow you to run the commands *iverilog*, *vvp* and *gtkwave* in your repository path. During installation, you will want to check the option to install gtkwave as well. Icarus Verilog must **not** be installed in a path with spaces or else the commands will fail. The following two paths must be added to your PATH variable:
* \<IVERILOG PATH>/bin (e.g. C:/iverilog/bin)
* \<IVERILOG PATH>/gtkwave/bin (e.g. C:/iverilog/gtkwave/bin)

Open a command prompt (cmd.exe for Windows, Terminal on Linux), navigate to this repository and run the following commands:
```
iverilog -o out.o CPU.v memory_controller.v Mux4to1.v RAM.v ROM.v SCIC.v io_controller.v SCIC_tb.v
vvp out.o
gtkwave SCIC.vcd
```
