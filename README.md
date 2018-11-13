# SIUE CPU IC (SCIC)
Project of Addison Elliott and Dan Ashbaugh to create IC layout of 32-bit custom CPU used in teaching digital design at SIUE.

# Simulating and Synthesizing with Cadence Tools
**Note:** This was run using Dr. Engel's special setup with TCL scripts and such. You must do this using the lab machines with their custom scripts.

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

Next, one more once-per-machine step must be done. There is a TCL and SDC file that is expected to be in a different directory to adhere to Dr. Engel's workflow. Since we wanted to make these files tracked by our GitHub repository, we place these files in the repository and create symbolic links (A.K.A. symlinks) to these locations. Run the following two commands to create symlinks for the TCL and SDC file in the appropriate directory.
```
ln -s $PHOME/verilog.src/SCIC/env.SCIC.tcl $PHOME/env_files/
ln -s $PHOME/verilog.src/SCIC/SCIC.sdc $PHOME/verilog.src/sdc/
```

If you want to verify that the symlinks were made, take a look at the figure below where I used the `ll` (alias to `ls -l`) command to achieve this. You can see that the output shows a symlink pointing to the repository location.
**TODO: Place image here Screenshot-1.png**

XXX
```
cd $PHOME
sb SIUE-DigitalDesign-CPU-IC
sim
```

XXX

# Simulating with Icarus Verilog
**Note:** If this is your first time installing [Icarus Verilog](http://iverilog.icarus.com/), then you will need to make sure that the binary path is in your PATH variable. This will allow you to run the commands *iverilog*, *vvp* and *gtkwave* in your repository path. During installation, you will want to check the option to install gtkwave as well. Icarus Verilog must **not** be installed in a path with spaces or else the commands will fail. The following two paths must be added to your PATH variable:
* <IVERILOG PATH>/bin (e.g. C:/iverilog/bin)
* <IVERILOG PATH>/gtkwave/bin (e.g. C:/iverilog/gtkwave/bin)

Once you have cloned the repository somewhere locally, there is a small change that must be made to the ROM. Open ROM.v and you should see there are blocks of code that contain the command *\$readmemh* that load in programs to the ROM. Each block of code should contain two *\$readmemh* commands, one for Icarus and one for the Cadence tools. Uncomment the Icarus command and comment the Cadence command. This is also where you can select **which** program you want to run.

* Icarus - `$readmemh("programs/simple_counter.mem", memory, 0, 31);`
* Cadence - `$readmemh("\$PHOME/verilog.src/SDDC/programs/simple_counter.mem", memory, 0, 31);`

Open a command prompt (cmd.exe for Windows, Terminal on Linux), navigate to this repository and run the following commands:
```
iverilog -o out.o CPU.v memory_controller.v Mux4to1.v RAM.v ROM.v system.v io_controller.v system_tb.v
vvp out.o
gtkwave system.vcd
```