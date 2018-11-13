# SIUE-DigitalDesign-CPU-IC
Project of Addison Elliott and Dan Ashbaugh to create IC layout of 32-bit custom CPU used in teaching digital design at SIUE.

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