#
# Tcl file to be sourced by RTL compiler for synthesis
#
# Filename:  rc_sythesis.tcl
# Author:    Dr. George Engel
# Date:	     31 Aug 2012
# Modified:  07 May 2013
#


set startTime [clock seconds]
set tmpVar    [clock format $startTime]
print $log "\nStarting rc_synthesis.tcl script ...(${tmpVar})" {color_red}
print $log "--> Project home directory is ${PHOME}."
print $log "--> Basename is ${BASENAME}"

# Exit script if use just wants to load a saved design

if {${RC_LOAD_DSN} == "true"} {
   print $log "\nLoading ${BASENAME} design"  
   RCload $BASENAME
} else {


#
# Set information level
#

   # set_attribute	information_level	${RC_INFO_LEVEL}
   set_attribute	information_level	9

#
# Point tool to lef descriptions of the cells
# OSU_DIR and STDCELL_TECH defined in env.tcl
#

   set_attribute   lef_library   		$LEFFILE

## Define the search path 

   set_attribute  	lib_search_path    $LIBERTY_DIR

## This defines the library to use

   set_attribute 	library 		{s35_CORELIB_TYP.lib   s35_IOLIB_TYP.lib}

#
# Read in list of verilog files
# VLOG_FILES defined in env.tcl
#

   print $log "\nReading verilog files:\n"
   foreach file ${SYN_VLOG_FILES} {
      print $log "--> $file"
   }

   if {${SYN_VLOG_FILES} != ""} {
      read_hdl -v2001 ${SYN_VLOG_FILES}
   }

   print $log "\nReading VHDL files:\n"

   if {${SYN_VHDL_FILES} != ""} {
      read_hdl -vhdl ${SYN_VHDL_FILES}
   }
   foreach file ${SYN_VHDL_FILES} {
      print $log "--> $file"
   }

## This builds the general schematic

   print $log "\nElaborating design ..."

#
# Preserve instances of LOGIC0 and LOGIC1
#

#  set_attribute      preserve   true  {LOGIC0 LOGIC1}
# set_attribute preserve true {cpu_inst/PC}
# set_attribute preserve true [find / -instance PC]

   elaborate ${BASENAME}

   check_design -unresolved
#
# Read in the SDC constraints
# If file cannot be found then terminate the tcl script
#

   print $log "\nReading ${SDC_DIR}/${BASENAME}.sdc"

   if {[file exists ${SDC_DIR}/${BASENAME}.sdc ] == 1} {
      read_sdc ${SDC_DIR}/${BASENAME}.sdc
   } else {
      print $log "--> Failed to find: ${SDC_DIR}/${BASENAME}.sdc\n\tExiting."
      suspend
      exit
  }

   if {${RC_SUSPEND} == "true"} suspend

   if {${RC_ELAB_ONLY} == "true"} {
      print $log "User wants to stop after elaboration."
      gui_show
   } else {

##
## Synthesize your code .. options in env.tcl
##

set_attribute delete_unloaded_seqs false /
set_attribute optimize_constant_0_flops false /
set_attribute optimize_constant_latches false /

     print $log "\nSynthesizing design with options ..." 
     print $log "--> ${RC_SYNTHESIZE_OPTS}"

     eval synthesize ${RC_SYNTHESIZE_OPTS}

     print $log "\nSaving netlists with options:  ${RC_WRITE_HDL_OPTS}"
     print $log "--> ${PNR_DIR}/netlists/${BASENAME}_syn.v"
     print $log "--> ${SYN_DIR}/netlists/${BASENAME}_syn.v"

set_attribute preserve true [find / -instance PC_reg[*]]
set_attribute auto_ungroup none /

   eval write_hdl -generic > ${SYN_DIR}/netlists/${BASENAME}_syn_test1.v
   eval write_hdl -equation > ${SYN_DIR}/netlists/${BASENAME}_syn_test2.v

# Saving netlists to pnr and syn directories

    eval write_hdl ${RC_WRITE_HDL_OPTS} > ${PNR_DIR}/netlists/${BASENAME}_syn.v
    eval write_hdl ${RC_WRITE_HDL_OPTS} > ${SYN_DIR}/netlists/${BASENAME}_syn.v

#
# Write out sdc file to place and route directory

    print $log "\nCreating ..." 
    print $log "--> ${PNR_DIR}/sdc/${BASENAME}_syn.sdc"

    write_sdc > ${PNR_DIR}/sdc/${BASENAME}_syn.sdc

#
# Write out sdf file

    print $log "\nCreating ... "
    print $log "--> ${SDF_DIR}/${BASENAME}_syn.sdf"

    eval write_sdf ${RC_WRITE_SDF_OPTS} > ${SDF_DIR}/${BASENAME}_syn.sdf

# Write out what we need for encounter and for reading back into RTL compiler

    print $log "\nWriting out encounter design ..."
    print $log "--> ${SYN_DIR}/dsn/${BASENAME}/${BASENAME}"

    write_design -encounter -basename ${SYN_DIR}/dsn/${BASENAME}/${BASENAME}

#
# Write out reports
# 

    print $log "\nWriting out reports ..."
    print $log "--> ${SYN_DIR}/reports/${BASENAME}.timing.rpt"
    print $log "--> ${SYN_DIR}/reports/${BASENAME}.area.rpt"
    print $log "--> ${SYN_DIR}/reports/${BASENAME}.power.rpt"

    eval report timing  ${RC_REPORT_TIMING_OPTS} >  ${SYN_DIR}/reports/${BASENAME}.timing.rpt
    eval report area	>  ${SYN_DIR}/reports/${BASENAME}.area.rpt
    eval report power	>  ${SYN_DIR}/reports/${BASENAME}.power.rpt

    report timing -lint -verbose

    if {${RC_GUI_SHOW} == "true"} gui_show

    if { ${RC_EXIT} == "true"} {
       quit
    }

   }
   set endTime 	[clock seconds]
   print $log "Leaving rc_synthesis.tcl script ..." {color_red}
   PrintElapsedTime $log $startTime $endTime
}
