# SIUE-DigitalDesign-CPU-IC
Project of Addison Elliott and Dan Ashbaugh to create IC layout of 32-bit custom CPU used in teaching digital design at SIUE.

# Simulating with Icarus
Run:
```
iverilog -o out.o CPU.v memory_controller.v Mux4to1.v RAM.v ROM.v system.v system_tb.v
vvp out.o
gtkwave
```