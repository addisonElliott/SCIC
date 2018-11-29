#
# Default setting for env.tcl files
#

# **************************************************************************
# 
# Probably no reason to change any of the variables below
# but they may if they wish to ...
#
# $$$$$$$$$$$$$$    COMPILATION, ELABORATION, and SIMULATION SECTION   $$$$$$$$$
#
# ***************************************************************************
#
# Set variables to point to all the important locations
#
#
# Point to local and global encounter scripts
#

set	    LOCAL_TCL	    ${PHOME}/my_tcl
set	    TCL_DIR		    ${PHOME}/tcl_dir
set	    ENC		        ${TCL_DIR}/enc
set    	   SRC		        ${PHOME}/verilog.src

set 	STDCELL_TECH 	s35d4 ;   	   	;       # Select the technology to use
set 	SIM_DIR		    ${PHOME}/sim_dir 		; # Simvision directory
set	    SYN_DIR		    ${PHOME}/syn_dir		; # Synthesis directory
set	    PNR_DIR		    ${PHOME}/pnr_dir		; # Place and route directory
set	    SDC_DIR		    ${PHOME}/verilog.src/sdc ; # SDC and IO files
set	    SDF_DIR		    ${SIM_DIR}/sdf			; # Location of sdf files
set	    FP_DIR		    ${PNR_DIR}/fp			; # Location of floorplan files
set	    DSN_DIR		    ${PNR_DIR}/dsn			; # Where encounter designs get saved

# Here is where the AMS HitKit lives
	
set     AMS_DIR         $env(AMS_DIR)	
set     LIBERTY_DIR     "${AMS_DIR}/liberty/s35_3.3V"
set     LEF_DIR         "${AMS_DIR}/cds/HK_S35/LEF/${STDCELL_TECH}"

# Usually we don't have VHDL files

set	    RTL_VHDL_FILES  ""
set 	SYN_VHDL_FILES	""

# **************************************************************************
# Use procedures from the SIUE package
# TCL_DIR defined in env.tcl
#
# *************************************************************************

set   	 SIUE_TCL_PKG	${TCL_DIR}/siue_tcl_pkg
lappend  auto_path      ${SIUE_TCL_PKG}
package  require        siue   

#
# If you have used `include then you may need the following
#

set	    INC_DIR		    ${SRC}/include  ;		# Where to look for include files

#
# Point to place and route directory netlists

set	    PNR_NET_DIR	    ${PHOME}/pnr_dir/netlists ;	# Location of pnr netlists

# 
# Standard cell libary related stuff
#
	
set 	STD_CELLS_DIR	"${AMS_DIR}/verilog"
set	    STD_CELLS_LIB   "${STD_CELLS_DIR}/s35d4"
set 	STD_CELLS	    "${STD_CELLS_LIB}/s35_CORELIB.v ${STD_CELLS_LIB}/s35_IOLIB.v"
set 	UDP     	    "${STD_CELLS_DIR}/udp.v"
#
# Location of hdl.var and cds.lib files

set     HDL_VAR		    ${PHOME}/hdl.var 		; # Point to hdl.var file to use
set     CDS_LIB		    ${PHOME}/cds.lib 		; # Point to hdl.var file to use

set 	ERR_MAX		    10				; # Maximum number of errors to report
set 	MESSAGE_LIMIT	10				; # Message limit

# Verilog Compilation command
# Don't include -logfile option ... it will be added automatically
# -incdir option tells the tool where to load for include files

set	    NCVLOG_CMD	    ncvlog
set	    NCVLOG_OPTS	    "-cdslib ${CDS_LIB} \
			            -hdlvar  ${HDL_VAR} \
                        -errormax ${ERR_MAX} \
                        -update \
                        -linedebug \
                        -status \
			            -incdir ${INC_DIR}"

# VHDL Compilation command

set	    NCVHDL_CMD	    ncvlog
set	    NCVHDL_OPTS	    "-cdslib ${CDS_LIB} \
			            -hdlvar  ${HDL_VAR} \
                        -errormax ${ERR_MAX} \
                        -update \
                        -linedebug \
                        -status "

# Elaboration Command

set	    NCELAB_CMD	    ncelab
set	    NCELAB_OPTS	    "-cdslib ${CDS_LIB} \
			            -hdlvar ${HDL_VAR} \
			            -errormax ${ERR_MAX} \
			            -access +wc \
			            -status \
			            -pulse_int_r 0"

# Simulation Command
# -input allows you to load a tcl file when you start the simulator
# Use either -gui or -batch

#if {$SIM_MODE == "rtl"} {
#  set 	input_tcl 	""
#} else {
#  set     input_tcl       "-input ${PHOME}/$LOCAL_TCL/simvision.tcl" 
#}

set      input_tcl      "-input $LOCAL_TCL/simvision.tcl -input $SIM_DIR/restore.tcl"
 
set	    NCSIM_CMD	    ncsim
set	    NCSIM_OPTS	    "-gui \
			            -cdslib ${CDS_LIB} \
			            -hdlvar ${HDL_VAR} \
			            -errormax ${ERR_MAX} \
			            -status \
			            ${input_tcl}"

# **************************************************************************
# 
# Probably no reason to change any of the variables below
# but you may if they wish to ...
#
# $$$$$$$$$$$$$$$$$$$    RTL Compiler Section $$$$$$$$$$$$$$$$$$$$$$$$$$$$
#
# ***************************************************************************

set	    RC_EXIT				false	; # true, false ... automatic exit from rc
set	    RC_INFO_LEVEL			0	; # The higher the number the more info you get
set	    RC_SUSPEND			true 	; # Pauses a few times to let you read the log info
set 	RC_GUI_SHOW			true    ; # Bring up gui at end

#
# Desired command options
#

set     RC_WRITE_SDF_OPTS      "-delimiter / \
          			            -edges check_edge \
          			            -nonegchecks \
          			            -version \"OVI 3.0\" \
          			            -timescale \"ns\" "

set 	RC_SYNTHESIZE_OPTS	    "-to_mapped"

#
# Sometimes you may want the synthesis tool to work harder
#

# set 	RC_SYNTHESIZE_OPTS	"-to_mapped -effort high"

set 	RC_WRITE_HDL_OPTS	"-mapped -v2001"

set	    RC_REPORT_TIMING_OPTS	""
# set	RC_REPORT_TIMING_OPTS	"-numpaths 500"


# **************************************************************************
# 
# Probably no reason to change any of the variables below
# but they may if they wish to ...
#
# $$$$$$$$$$$$$$   ENCOUNTER PLACE AND ROUTE SECTION  $$$$$$$$$$$$$$$$$$$$
#
# ***************************************************************************

# LEFFILE and TIMELIB variables now account for hierarchical designs

# set     TIMELIB   "${STD_CELLS_LIB}/stdcells.lib"

set TIMELIB "$LIBERTY_DIR/s35_CORELIB_TYP.lib \
             $LIBERTY_DIR/s35_CORELIB_BC.lib \
             $LIBERTY_DIR/s35_CORELIB_WC.lib \
             $LIBERTY_DIR/s35_IOLIB_TYP.lib \
             $LIBERTY_DIR/s35_IOLIB_BC.lib \
             $LIBERTY_DIR/s35_IOLIB_WC.lib "

foreach module ${MODULE_LIST} {
   set  TIMELIB   "${TIMELIB} ${PNR_DIR}/dsn/${module}/library/${module}.lib"
}

set     LEFFILE   "${LEF_DIR}/s35d4.lef ${LEF_DIR}/CORELIB.lef ${LEF_DIR}/IOLIB_4M.lef"


foreach module ${MODULE_LIST} {
   set  LEFFILE   "${LEFFILE} ${PNR_DIR}/dsn/${module}/library/${module}.lef"
}

set	    QRC_TECH_FILE	"${AMS_DIR}/assura/s35d4/s35d4/RCX-typical/qrcTechFile"
set  	QRC_LAYER_MAP	"${AMS_DIR}/cds/HK_S35/LEF/s35d4/qrclay.map"
set     CAPTABLE        "-typical ${AMS_DIR}/cds/HK_S35/LEF/encounter/s35d4-typical.capTable \
                         -worst ${AMS_DIR}/cds/HK_S35/LEF/encounter/s35d4-worst.capTable"
set     OA_REFLIB       "TECH_S35D4 CORELIB IOLIB_4M"
set 	NOISE_LIB	    ""

#set	    PWRNET		    "vdd\! vdd3r1\! vdd3r2\! vdd3o\!"
#set	    GNDNET		    "gnd\! gnd3r\! gnd3o\!"

set	    PWRNET		    "vdd!"
set	    GNDNET		    "gnd!"

set	    PG_PWR_PIN	    "vdd!"
set	    PG_GND_PIN	    "gnd!"
set	    IN_TRAN_DELAY	"200ps"

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# For creating floorplans.
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Following line is for nangate45nm

#set	FP_SITE			"FreePDK45_38x28_10R_NP_162NW_34O"

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
#  Minimum route layer to be used for I/O pins
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

set 	MIN_ROUTE_LAYER		4

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
#  List of clk buffers
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

#set     CLK_BUF_LIST    {BUF12 BUF15 BUF2 BUF4 BUF6 BUF8 CLKBU12 CLKBU15 CLKBU2 CLKBU4 CLKBU6 CLKBU8 CLKIN0 \
#CLKIN1 CLKIN10 CLKIN12 CLKIN15 CLKIN2 CLKIN3 CLKIN4 CLKIN6 CLKIN8 DLY12 \
#DLY22 DLY32 DLY42 INV0 INV1 INV10 INV12 INV15 INV2 INV3 INV4 INV6 INV8 \
#}

set     CLK_BUF_LIST    {BUF12 BUF15 BUF2 BUF4 BUF6 BUF8 CLKBU12 CLKBU15 CLKBU2 CLKBU4 CLKBU6 CLKBU8 CLKIN0 \
CLKIN1 CLKIN10 CLKIN12 CLKIN15 CLKIN2 CLKIN3 CLKIN4 CLKIN6 CLKIN8 \
INV0 INV1 INV10 INV12 INV15 INV2 INV3 INV4 INV6 INV8 \
}

# ******************************************************************
#
# Some additional information needed for hierarchical designs
#
# *******************************************************************

set     BLOCK_DIRS      ""
foreach   module  ${MODULE_LIST}  {
   set  BLOCK_DIRS  "${BLOCK_DIRS} -blockdir ${DSN_DIR}/${module}/${module}.enc.dat"
}

#
# We also need to set the "halo" paramters
#

set   BLOCK_HALO          30
set   BLOCK_RING_SPACE    5
set   BLOCK_RING_WIDTH    5

# 
# Add support for spacing between rows when floorplanning
#

set	FP_ROW_SPACING		""
set	FP_ROW_TYPE		""

#
# Placment mode 
# 
# --> ntd is not timing driven
# --> td is timing driven
# --> opt is optimum
#
# opt seems to work the best

set	PLACEMENT_MODE		"opt"

set	ROUTER_TO_USE		"wroute"

set   ALT_ROUTER_TO_USE	"nano"		; # Alternate router to use when running route multiple times to remove DRC violations
set	MAX_ROUTE_COUNT	3			   ; # Maximum number of times to rerun routing to remove DRC violations

# Some more defines

set	    ENC_EXIT		    false	; # true, false ... automatic exit from encounter
set	    SUSPEND_AFTER_FP 	true 	; # Pause
set	    ENC_INFO_LEVEL		0	    ; # Used by the loadConfig command
set	    PROCESS_NODE		250	    ; # 250 nm process

# Select the SDF version that we would like ... either 2.1 or 3.0

set     SDFVER              "2.1"

#
# *************************************************************************
# Check to make sure we have all the needed directories
# Create any missing subdirectories
#
# *************************************************************************
 
CheckDirectoriesExist



