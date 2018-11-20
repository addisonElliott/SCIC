#
# This is the encounter script we will use for AMS 0.35 micron
# standard cell (core) designs.
#
# Author:   Created by Addison Elliott
# Date:     20 Nov 2018
#
print $log "Starting Addison's custom enc_hitikit.tcl\n" {color_green}

lappend  auto_path      $BASE_DIR/siue_tcl_pkg
package  require        siue2

set  topcell       $BASENAME
set  dbdir         "$PNR_DIR/db"

# Only one item in our constraint list

set  consList      {pnr}

set  checkedLogTilLine  0

#
# Add the AMS HitKit Menu

addAMSHKMenu2

# Free the previous design

print $log "Executing Encounter freeDesign command ..." {color_blue}
freeDesign

# Load the .conf file

print  $log  "Executing amsDbSetup (loading configuration data)"  {color_blue}
amsDbSetup2

# Set up the grid for floorplanning 

print  $log  "Executing amsUserGrid (setting up grid for floorplanning)" {color_blue}
amsUserGrid2

# Hook up power and ground

print  $log  "Executing amsGlobalConnect (connecting up to vdd! and gnd!)" {color_blue}
amsGlobalConnect2 core

#  Set up stuff for timing analysis

print  $log  "Executing amsSetMMMC (creating timing constraints)" {color_blue}
amsSetMMMC2

print  $log  "Executing amsSetAnalysisView minmax pnr" {color_blue}
amsSetAnalysisView2 minmax pnr

# Create a floorplan and suspend

print    $log  "Executing amsFloorplan (floorplanning)" {color_blue}

amsFloorplan2 core  $UTILIZATION  $CORE_TO_BOUND   $ASPECT

# Place our pins

print    $log  "Executing SIUE Tcl package placePins procedure (pin location specified in env.tcl file)" {color_blue}

placePins

print    $log  "---> Type resume to continue after reviewing the FLOORPLAN!!!!" {color_red}

win
suspend
fit

# Add the end cap cells

print  $log  "Executing amsAddEndCaps (adding bypass capacitors)" {color_blue}
amsAddEndCaps2

# Do a power route

print   $log  "Executing  amsPowerRoute (routing power i.e. gnd! and vdd! and io pins)" {color_blue}
amsPowerRoute2 {gnd!  vdd!}

# Perform a placement

print $log  "Executing amsPlace $PLACEMENT_MODE" {color_blue}
amsPlace2  $PLACEMENT_MODE

# TODO: Added by Addison Elliott
# Now run the first optimization step - pre-CTS (Clock Tree Synthesis) in-place optimization. 
# setOptMode -yieldEffort none
# setOptMode -effort high
# setOptMode -maxDensity 0.95
# setOptMode -drcMargin 0.0
# setOptMode -holdTargetSlack 0.0 -setupTargetSlack 0.0
# setOptMode -simplifyNetlist false
# 
# # Additional commands in another repository to try
# setOptMode -fixDRC true
# setOptMode -fixFanoutLoad true
# setOptMode -optimizeFF true
# 
# clearClockDomains
# setOptMode -noUsefulSkew
# set filename2 [format "constraints/%s_prects.ctsrpt" $BASENAME]
# optDesign -preCTS -drv -outDir $filename2

# Perform Clock Tree Synthesis

print  $log  "Executing amsCts (performing clock tree synthesis using sdc file)" {color_blue}
amsCts2

# Perform a Timing Analysis

print    $log  "Executing amsTA (postCTS timing analysis)" {color_blue}
amsTa2  postCTS

# Optimize the design

print $log "Executing Encounter optDesign -postCTS command" {color_blue}
optDesign -postCTS

# Add filler

print  $log  "Executing amsFillperi (adding filler cells to pad area)" {color_blue}
amsFillperi2

# Route rest (other than clock) of the signals

print  $log  "Executing amsRoute (routing signals using nano)" {color_blue}
amsRoute2 nano

# TODO: Added by Addison Elliott
# Optimize design after routing
# setOptMode -yieldEffort none
# setOptMode -effort high
# setOptMode -maxDensity 0.95
# setOptMode -drcMargin 0.0
# setOptMode -holdTargetSlack 0.0 -setupTargetSlack 0.0
# setOptMode -simplifyNetlist false
# 
# # Additional commands in another repository to try
# setOptMode -fixDRC true
# setOptMode -fixFanoutLoad true
# setOptMode -optimizeFF true
# 
# clearClockDomains
# setOptMode -noUsefulSkew
# set filename2 [format "constraints/%s_postroute.ctsrpt" $BASENAME]
# optDesign -postRoute -drv -outDir $filename2

# Add more filler

print  $log  "### --- Executing amsFillcore (adding filler cells to core)" {color_blue}
amsFillcore2

# Perform another timing analysis

print $log  "Executing amsTA (postRoute timing analysis)" {color_blue}
amsTa2 postRoute

# Verifying geometry and connectivity

print $log  "Executing Encounter verifyGeometry command" {color_blue}
verifyGeometry

print $log  "Executing Encounter verifyConnectivity -type all command" {color_blue}
verifyConnectivity -type all

print    $log  "---> Type resume to continue after making sure there are no DRC or LVS errors!
" {color_red}
win
suspend
fit

# Adding pins to vdd! and gnd! nets
# This is done so as to satisfy Virtuoso DRC/LVS

print $log  "Executing SIUE Tcl package createPowerPins command" {color_blue}

createPowerPins

# Write out the final design
# pnr is the postfix name

print $log  "Executing amsWrite pnr (so _pnr will be appended to name)" {color_blue}
amsWrite pnr

# Write out a SDF file for the minimum and maximum views

print $log  "Executing amsWriteSDF4View {pnr_min pnr_max}" {color_blue}
amsWriteSDF4View {pnr_min  pnr_max}

#
print $log "---> Copying sdf file to the sim_dir/sdf directory" {color_red}

file delete -force ${SDF_DIR}/${BASENAME}_pnr.sdf
file copy -force ${PNR_DIR}/sdf/${BASENAME}_pnr_min.sdf ${SDF_DIR}/${BASENAME}_pnr.sdf

print $log "\nFinshing enc_hitikit.tcl" {color_green}
