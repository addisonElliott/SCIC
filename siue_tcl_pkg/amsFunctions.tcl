#######################################################
##                                                     #
##  Encounter Command File                             #
##                                                     #
##  Owner: austriamicrosystems                         #
##  HIT-Kit: Digital                                   #
##  version: 07-Aug-2012                               #
##                                                     #
########################################################

package    provide    siue2   1.0

proc amsHelp2 {} {
    global   log

    print $log "#### Available Functions" 
    print $log "---#     - amsDbSetup....................... Setup Database - read Config"  {color_red}
    print $log "---#     - amsUserGrid...................... Sets the grid for the IO-Cells"  {color_red}
    print $log "---#     - amsGlobalConnect type............ connects global nets: " {color_red}
    print $log "---#                                               type = core | both" {color_red}
    print $log "---#     - amsAddEndCaps.................... place Caps" {color_red}
    print $log "---#     - amsSetMMMC ....................... set MultiMode" {color_red}
    print $log "---#     - amsSetAnalysisView cond conslist.. set Analysis Views" {color_red}
    print $log "---#     - amsFillcore ...................... places core filler cells" {color_red}
    print $log "---#     - amsFillperi ...................... places periphery filler cells" {color_red}
    print $log "---#     - amsRoute router................... run routing with: " {color_red}
    print $log "---#                                               router = nano|wroute|wroute2(using 2CPUs)" {color_red}
    print $log "---#     - amsWrite postfix ................. writes GDS, Verilog NL, SPEF, DB" {color_red}
    print $log "---#     - amsWriteSDF4View viewList......... write SDF for all analysis views in list" {color_red}
    print $log "---#     - amsZoomTo x y .................... zooms to coordinates x y"{color_red}
    print $log "#### " {color_red}
} 


# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc addAMSHKMenu2 {} {
   global   log

   # add AMSMenu if Encounter version is higher or equal to 10
   set encVer [string range [getVersion] 0 [expr [string first . [getVersion]]-1]]
   if {$encVer >= 10} {
     uiAdd amsHKMenu -type menu -label "Hit-Kit Utilities" -in main
     uiAdd expCommand -type command -label "Wroute..." -command [list ::Rda_Route::RouteStdCell::create] -in amsHKMenu
     print $log "### austriamicrosystems HitKit-Utilities Menu added";}
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsDbSetup2 {} {
   ##--- Load configuration file

   global     TCL_DIR
   global     ENC_INFO_LEVEL
   global     log
   global     PROCESS_NODE
   global     MESSAGE_LIMIT

#
# Some stuff added by gle
#

   setMessageLimit      $MESSAGE_LIMIT
   setDesignMode        -process    ${PROCESS_NODE}

#
# AMS script (except I used our generic.conf file)
#
   loadConfig   ${TCL_DIR}/conf/generic.conf ${ENC_INFO_LEVEL}
   commitConfig

   setCTSMode -bottomPreferredLayer 2
   setMaxRouteLayer 3

}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsUserGrid2 {} {

   global    log

   ##--- Set user grids

   setPreference ConstraintUserXGrid 0.1
   setPreference ConstraintUserXOffset 0.1
   setPreference ConstraintUserYGrid 0.1
   setPreference ConstraintUserYOffset 0.1
   setPreference SnapAllCorners 1
   setPreference BlockSnapRule 2

   snapFPlanIO -usergrid
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsGlobalConnect2 type {
   global   log

   ##--- Define global power connects

   switch $type {
      "core" {
               set globalNetsList {{vdd! vdd!} {gnd! gnd!}}
               ##--- Define global Power nets - make global connections
             }
      "both" {
               ##--- Define global Power nets - make global connections
               clearGlobalNets
               set globalNetsList {{vdd! vdd!} {gnd! gnd!}}
               set globalNetsList [lappend globalNetsList {vdd3r1! vdd3r1!} {vdd3r2! vdd3r2!} {vdd3o! vdd3o!} {gnd3r! gnd3r!} {gnd3o! gnd3o!}]
             }
     }
     clearGlobalNets
     foreach net $globalNetsList {
        set n [lindex $net 0]
        set p [lindex $net 1]
        globalNetConnect $n -type pgpin -pin $p -inst * -module {}
#        print $log "---# GlobalConnect all $p pins to net $n" {color_red}
     }

     # TODO: Added by Addison Elliott
     # Did it because I saw it in Dr. Engel's amsFunctions folder and on 5710 GitHub page...
#      globalNetConnect vdd! -type tiehi
#      globalNetConnect gnd! -type tielo
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsSetMMMC2 {} {
    global  topcellname
    global  consList
    global  log
    global  PNR_DIR
    global  BASENAME
    global  LIBERTY_DIR

#    print $log "---# Setup MMMC\n---#" {color_red}

# Creating the rc corners 

   create_rc_corner -name ams_rc_corner_typ \
            -preRoute_res {1.0} \
            -postRoute_res {1.0} \
            -preRoute_cap {1.0} \
            -postRoute_cap {1.0} \
            -postRoute_xcap {1.0} 

#    print $log "---#   rc_corner        : ams_rc_corner_typ" {color_red}
    create_rc_corner -name ams_rc_corner_wc \
            -preRoute_res {1.0} \
            -postRoute_res {1.0} \
            -preRoute_cap {1.0} \
            -postRoute_cap {1.0} \
            -postRoute_xcap {1.0} 

#    print $log "---#   rc_corner        : ams_rc_corner_wc" {color_red}
    create_rc_corner -name ams_rc_corner_bc \
            -preRoute_res {1.0} \
            -postRoute_res {1.0} \
            -preRoute_cap {1.0} \
            -postRoute_cap {1.0} \
            -postRoute_xcap {1.0} 

#    print $log "---#   rc_corner        : ams_rc_corner_bc" {color_red}

# Creating the library sets (typical, worst case, and best case)

    set   file1   "$LIBERTY_DIR/s35_CORELIB_BC.lib"
    set   file2   "$LIBERTY_DIR/s35_IOLIB_BC.lib" 

    create_library_set -name libs_min -timing [list $file1  $file2]


    set   file1    "$LIBERTY_DIR/s35_CORELIB_WC.lib" 
    set   file2    "$LIBERTY_DIR/s35_IOLIB_WC.lib" 

    create_library_set -name libs_max -timing [list $file1 $file2]
     
    set   file1    "$LIBERTY_DIR/s35_CORELIB_TYP.lib" 
    set   file2    "$LIBERTY_DIR/s35_IOLIB_TYP.lib" 

    create_library_set -name libs_typ -timing [list $file1 $file2]

#    print $log "---#   lib-sets         : libs_min, libs_max, libs_typ" {color_red}

   foreach cons $consList {
      set filename  "./sdc/${BASENAME}_syn.sdc"
      create_constraint_mode -name $cons -sdc_files $filename
   }
#   print $log "---#   constraint-modes : $consList" {color_red}


# Creating the delay corners

   create_delay_corner -name corner_min -library_set {libs_min} -opcond_library {s35_CORELIB_BC} -opcond {BEST-MIL} -rc_corner {ams_rc_corner_bc}
   create_delay_corner -name corner_max -library_set {libs_max} -opcond_library {s35_CORELIB_WC} -opcond {WORST-MIL} -rc_corner {ams_rc_corner_wc}
   create_delay_corner -name corner_typ -library_set {libs_typ} -opcond_library {s35_CORELIB_TYP} -opcond {TYPICAL} -rc_corner {ams_rc_corner_typ}

#   print $log "---#   delay-corners    : corner_min, corner_max, corner_typ" {color_red}

#   print $log "---#   analysis-views   : " {color_red}

    foreach cons $consList {
       foreach corner {"min" "max" "typ"} {
          set avname [format "%s_%s" $cons $corner]
          set cname [format "corner_%s" $corner]
          create_analysis_view -name $avname -constraint_mode $cons -delay_corner $cname 
#	      print $log "---#          #  Name: $avname  # Constraint-Mode: $cons # Corner: $cname" {color_red}
      }
    }

#    print $log "---#\n---# use following command to show analysis view definitions\n         report_analysis_view \n" {color_red}
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsSetAnalysisView2 {cond consList} {
    
    global   log


    switch $cond {
      "typ"    { 
                 set viewList {}
                 foreach cons $consList {
		            set avname [format "%s_typ" $cons]
                    set viewList [lappend viewList $avname]
                 }
                 set_analysis_view -setup $viewList -hold $viewList
	       } 
      "minmax" { 
		 set maxviewList {}
		 set minviewList {}
                 foreach cons $consList {
		            set maxavname [format "%s_max" $cons]
                    set maxviewList [lappend maxviewList $maxavname]
		            set minavname [format "%s_min" $cons]
                    set minviewList [lappend minviewList $minavname]
                 }
                 set_analysis_view -setup $maxviewList -hold $minviewList
	       } 
      "min"    { 
                 set viewList {}
                 foreach cons $consList {
		            set avname [format "%s_min" $cons]
                    set viewList [lappend viewList $avname]
                 }
		        set_analysis_view -setup $viewList -hold $viewList
	       } 
      "max"    { 
                 set viewList {}
                 foreach cons $consList {
		            set avname [format "%s_max" $cons]
                    set viewList [lappend viewList $avname]
                 }
		        set_analysis_view -setup $viewList -hold $viewList
	       } 
      }
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsAddEndCaps2 {} {
   global   log

   ##-- add CAP cells (bypass capacitors) 
   addEndCap -preCap ENDCAPL -postCap ENDCAPR -prefix ENDCAP
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsFillcore2 {} {
   global   log

   ##-- Add Core Filler cells
   addFiller -cell FILL25 FILL10 FILL5 FILL2 -prefix FILLER
   addFiller -cell FILLRT25 FILLRT10 FILLRT5 FILLRT2 FILLRT1 -prefix FILLERRT
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsFillperi2 {} {
   global   log

   ##-- Add Peri Filler cells
   set fillerList {100_P 50_P 20_P 10_P 5_P 2_P 1_P 01_P}
   foreach fillcell $fillerList {
      addIoFiller -cell PERI_SPACER_$fillcell -prefix pfill
   }
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsRoute2 {routerType} {
   global   log

   changeUseClockNetStatus -noFixedNetWires

#    print $log "Router type is $routerType"

    switch $routerType {
        "nano" { 
               ##-- Run Routing
               ##-- Nano-Route
               setMaxRouteLayer 3
               routeDesign -globalDetail
             }
        "wroute" {
               ##-- WROUTE
             wroute -topLayerLimit 3
             }
        "wroute2" {
               ##-- WROUTE
             wroute -topLayerLimit 3
             }
     }
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsSave2 postfix {
   global topcellname
   global dbdir
   global log

   set filename [format "%s/%s_%s.enc" $dbdir $topcellname $postfix]
   saveDesign $filename
   print    $log  "---> Design saved as $filename ..." {color_red}
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsWrite2 postfix {

   global   dbdir
   global   TCL_DIR
   global   MY_OA_LIB
   global   log
   global   topcellname

   ##-- Save Design
   amsSave2 $postfix
   ##-- Write DEF
   set filename [format "def/%s_%s.def" $topcellname $postfix]
   defOut -floorplan -netlist -routing $filename
   ##-- Write GDS2
   set filename [format "netlists/%s_%s_fe.gds" $topcellname $postfix]
   streamOut $filename -mapFile $TCL_DIR/conf/gds2.map -libName $MY_OA_LIB -structureName $topcellname \
         -attachInstanceName 13 -attachNetName 13 -stripes 1 -units 1000 -mode ALL

   ##-- Verilog Netlist
   set filename [format "netlists/%s_%s.v" $topcellname $postfix]
   saveNetlist $filename
   ##-- Verilog Netlist with FILLCAP cells
   set filename [format "netlists/%s_%s_fillcap.v" $topcellname $postfix]
   saveNetlist $filename -excludeLeafCell -includePhysicalInst \
                         -excludeCellInst { FILLRT1 FILLRT2 FILLRT5 FILLRT10 FILLRT25 FILL1 ENDCAPL ENDCAPR ENDCAP \
                                            PERI_SPACER_100_P PERI_SPACER_50_P PERI_SPACER_20_P PERI_SPACER_10_P PERI_SPACER_5_P PERI_SPACER_2_P    PERI_SPACER_1_P PERI_SPACER_01_P CORNERP \
                                          }

   ##-- Extract detail parasitics
   set filename [format "sdf/%s_%s.rcdb" $topcellname $postfix]
   setExtractRCMode -engine postRoute -effortLevel low
   extractRC
   set filename [format "sdf/%s_%s.spef" $topcellname $postfix]
   rcOut -spef $filename
   
   ##-- run QRC extraction
#   setExtractRCMode -engine postRoute -effortLevel signoff
#   extractRC 
#   set filename [format "sdf/%s_%s_qrc.spef" $topcellname $postfix]
#   rcOut -spef $filename

}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

##--  write SDF for a specific analysis view

proc amsWriteSDF4View2 {viewList} {
   global   topcellname
   global   SDF_DIR
   global   SDFVER

   global log

   set sdfver $SDFVER

   foreach view $viewList {
      set filename [format "sdf/%s_%s.sdf" $topcellname $view]
      print $log "---> Analysis View: $view" {color_red}

      switch $sdfver {
         "2.1"  { write_sdf -version 2.1 -prec 3 -edges check_edge -average_typ_delays \
                     -remashold -splitrecrem -splitsetuphold -force_calculation \
                     -view $view $filename
                }
         "3.0"  { write_sdf -version 3.0 -prec 3 -edges check_edge \
                     -force_calculation -average_typ_delays \
                     -view $view $filename
         ##-- additional for verilog XL: -splitrecrem
                }
      }

      print $log "---> Created SDF: $filename" {color_red}
   }
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

##--  write SDF for a specific analysis view

proc amsWriteSDFbtw2 {minview typview maxview} {
   global   topcellname
   global   SDFVER

   global   log
   print    $log  "---> Executing the amsWriteSDFbtw procedure ..." {color_blue}

   set sdfver $SDFVER

   set filename [format "sdf/%s_all.sdf" $topcellname]

   switch $sdfver {
         "2.1"  { write_sdf -version 2.1 -prec 3 -edges check_edge -average_typ_delays \
                     -remashold -splitrecrem -splitsetuphold -force_calculation \
                     -min_view $minview -typ_view $typview -max_view $maxview $filename
                }
         "3.0"  { write_sdf -version 3.0 -prec 3 -edges check_edge \
                     -force_calculation -average_typ_delays \
                     -min_view $minview -typ_view $typview -max_view $maxview $filename
         ##-- additional for verilog XL: -splitrecrem
                }
   }
      print $log "---> Created SDF: $filename" {color_red}
}

##-- Other useful procedures

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsZoomTo2 {x y {factor 10}} {
   set llx [expr {$x - $factor}]
   set lly [expr {$y - $factor}]
   set urx [expr {$x + $factor}]
   set ury [expr {$y + $factor}]
   zoomBox $llx $lly $urx $ury
}
##-- End of First Encounter TCL command file

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc protoSDF2 {} {
    amsDbSetup2
    amsSetMMMC2
    amsSetAnalysisView2 minmax {func}
    floorplan -r 1.0 0.8 2 2 2 2
    setPlaceMode -fp true -timingDriven false -reorderScan false -doCongOpt false -modulePlan false
    placeDesign -noPrePlaceOpt
    trialRoute -maxRouteLayer 3 -floorplanMode
    extractRC
    amsWriteSDF4View2 {pnr_max prn_min}
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsFloorplan2 {type util iodist {ratio 1.0}} {

   global   log
   global   FP_ROW_SPACING
   global   FP_ROW_TYPE

  ##-- Initialize floorplan
  switch $type {
     "core" {
	      if { ( $FP_ROW_SPACING != "" ) && ( $FP_ROW_TYPE  != "" ) } {
	      	   setFPlanRowSpacingAndType $FP_ROW_SPACING  $FP_ROW_TYPE
              }
              floorPlan -r $ratio $util $iodist $iodist $iodist $iodist
            }
     "peri" {
              floorPlan -r $ratio $util $iodist $iodist $iodist $iodist
              ##--- Load corner io file to add corner cells (if necessary)
              loadIoFile corners.io
              floorPlan -r $ratio $util $iodist $iodist $iodist $iodist

              ##-- Snap IO cells to user grid
              snapFPlanIO -usergrid
            }
  }



  ##-- Place Macros 
  ##-- Create Placement Blockages
  ##createObstruct llx lly urx ury 
  ##-- Cut Rows under Macros, Halos and Blockages
  ##cutCoreRow

}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsPowerRoute2 {pownetsList} {

   global   log
   global   CORE_RING_WIDTH
   global   CORE_RING_OFFSET
   global   CORE_RING_SPACING

   set offset  $CORE_RING_OFFSET
   set spacing $CORE_RING_SPACING
   set width   $CORE_RING_WIDTH

   # foreach power net in the specified list
   # route a ring

   foreach pownet $pownetsList {
       set  name  $pownet
#      print $log "----$name $width $offset----" {color_red}

        addRing \
               -width_left   $width -spacing_left   $spacing -offset_left   $offset -layer_left   MET2 \
	          -width_top    $width -spacing_top    $spacing -offset_top    $offset -layer_top    MET1 \
	          -width_right  $width -spacing_right  $spacing -offset_right  $offset -layer_right  MET2 \
	          -width_bottom $width -spacing_bottom $spacing -offset_bottom $offset -layer_bottom MET1 \
	          -stacked_via_top_layer MET4 \
	          -stacked_via_bottom_layer MET1 \
	          -around core \
	          -jog_distance 0.7 \
	          -threshold 0.7 \
	          -nets $name

        set offset [ expr $offset + $spacing + $width]
   }
   # do followpin routing

   sroute -connect { blockPin padPin corePin floatingStripe }
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsTa2 {state} {
   global   log

   global topcellname
   switch $state {
         "prePlace"  { timeDesign -prePlace -outDir timingReports -expandedViews }
         "preCTS"    { timeDesign -preCTS   -outDir timingReports -expandedViews }
         "postCTS"   { timeDesign -postCTS  -outDir timingReports -expandedViews
                       timeDesign -postCTS -hold -outDir timingReports -expandedViews
                     }
         "postRoute" { timeDesign -postRoute -outDir timingReports -expandedViews
                       timeDesign -postRoute -hold -outDir timingReports -expandedViews
                     }
         "signOff"   { timeDesign -signOff -outDir timingReports -expandedViews
                       timeDesign -signOff -hold -outDir timingReports -expandedViews
                     }
    }
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsPlace2 how {

   global   log

   ##-- Placement
   switch $how {
      "ntd"   { 
                 setPlaceMode -timingdriven false -reorderScan false -congEffort medium \
                              -doCongOpt false -modulePlan false
                 placeDesign -noPrePlaceOpt
              }
      "td"    { 
                 setPlaceMode -timingdriven true -reorderScan false -congEffort medium \
                              -doCongOpt false -modulePlan false
                 placeDesign -noPrePlaceOpt
              }
      "opt"   {
                 setPlaceMode -timingdriven true -reorderScan false -congEffort high \
                              -doCongOpt -modulePlan false
                 placeDesign -inPlaceOpt -prePlaceOpt

                 # TODO: Changed by Addison Elliott
                 # Saw a few different options that I will be trying
#                  setPlaceMode -timingdriven true -reorderScan true -congEffort high \
#                               -doCongOpt false -modulePlan true
#                 setPlaceMode -timingdriven true -reorderScan true -congEffort high \
#                              -doCongOpt false -modulePlan false
#                 setPlaceMode -timingdriven true -reorderScan true -congEffort high \
#                              -doCongOpt true -modulePlan true
#                 setPlaceMode -timingdriven true -reorderScan true -congEffort high \
#                              -doCongOpt true -modulePlan false

                 placeDesign -inPlaceOpt -prePlaceOpt
              }
   }
   amsSave placed
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsCts2 {} {
   global   topcellname
   global   PNR_DIR
   global   BASENAME
   global   CLK_BUF_LIST
   global   log

# Modified by gle to create the clock tree spec from the sdc file

   createClockTreeSpec -output $PNR_DIR/constraints/$BASENAME.ctsch  -bufferList $CLK_BUF_LIST

   set filename [format "constraints/%s.ctsch" $BASENAME]
   ##-- Specify Clock tree
   specifyClockTree -file $filename

   ##-- delete existing buffers
   #deleteClockTree -clk  <clockroot>

   ##-- Run CTS
   set filename1 [format "constraints/%s_cts.guide" $topcellname]
   set filename2 [format "constraints/%s_cts.ctsrpt" $topcellname]
   ckSynthesis -rguide $filename1 -report $filename2

   # TODO: Added by Addison Elliott
   # Other places do not use the ckSynthesis command which is odd...
   # Use -useCTSRouteGuide to use routing guide during CTS.
#    setCTSMode -useCTSRouteGuide
# 
#    # Set routeClkNet to use Nanoroute during CTS.
#    setCTSMode -routeClkNet
# 
#    # Perform clocktree synthesis
#    clockDesign -outDir $filename1
# 
#    # Run the second optimization - post-CTS
#    setOptMode -yieldEffort none
#    setOptMode -effort high
#    setOptMode -maxDensity 0.95
#    setOptMode -drcMargin 0.0
#    setOptMode -holdTargetSlack 0.0 -setupTargetSlack 0.0
#    setOptMode -simplifyNetlist false
# 
#    # Additional commands in another repository to try
#    setOptMode -fixDRC true
#    setOptMode -fixFanoutLoad true
#    setOptMode -optimizeFF true
# 
#    clearClockDomains
#    setOptMode -noUsefulSkew
#    optDesign -postCTS -drv -outDir $filename2

   amsSave2 clkplaced
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsIncrRoute2 {maxerror} {

  global   log
  print    $log  "---> Executing the amsIncrRoute $maxerror procedure ..." {color_blue}

  set fehler  1000
  set filename [getLogFileName]
  clearDrc
  set step 0
  set lastfehler 1000 
  while {$fehler > $maxerror} {
     if { $step < 4 } {
	        print $log "---# amsIncrRoute : start in incrFinal Mode ($step)" {color_red}
            wroute -mode incrFinal -topLayerLimit 3
     } else {
	        print $log "---# amsIncrRoute : start in incrGlobalAndFinal Mode ($step)" {color_red}
            wroute -mode incrGlobalAndFinal -topLayerLimit 3
	        set step 0
     }
     set chan [open $filename]
     while {[gets $chan line] >= 0} {
         if {[scan $line "Total number of violations           =        %d" f] == 1} {
            set fehler $f
         }
     }
     if {$fehler > $lastfehler} {
	       set step [expr $step + 1]
     } else {
        set step 0
        set lastfehler $fehler
	       amsSave2 routedIncr
     }
     close $chan
     if {$fehler > $maxerror} { 
        print $log "---# Still $fehler errors - starting wroute again" {color_red}
     } else { 
        print $log "---# amsIncrRroute stopped with $fehler errors" {color_red}
     }
  }
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsDefIn2 { defFile {rowtype "standard"} {l 2} {t 2} {r 2} {b 2} {addwidth 0} {addheight 0}} {
  
  global   log
  print    $log  "---> Executing the amsDefIn $defFile procedure ..." {color_blue}

  global topcellname

  # open DEF File
  # find diearea
  set chan [open $defFile]
  while {[gets $chan line] >= 0} {
     # units for dividing coordinates
     if {[scan $line " UNITS DISTANCE MICRONS %d" u] == 1} {
            set units $u
	    print $log  "---# DEF Units: $units" {color_red}
     }
     # diearea 
     if {[scan $line " DIEAREA ( %f %f ) ( %f %f )" x1 y1 x2 y2] == 4} {
         set llx [expr ($x1 / $units)]
	 set lly [expr $y1 / $units]
	 set urx [expr $x2 / $units]
	 set ury [expr $y2 / $units]
	 print $log "---# DEF DieArea: $llx:$lly/$urx:$ury" {color_red}
     }
  }
  close $chan
  # calculate core area for rows
  set llxc [expr $llx + $l]
  set llyc [expr $lly + $b]
  set urxc [expr $urx - $r]
  set uryc [expr $ury - $t]
  #floorPlan -b $llx $lly $urx $ury 
  floorPlan -site $rowtype -b $llx $lly $urx $ury \
                                   $llx $lly $urx $ury \
                                   $llxc $llyc $urxc $uryc
  # load def file
  defIn $defFile


  # if the die size should be changed
  if {$addwidth != 0 || $addheight != 0} {
     print $log "---# Adding width: $addwidth" {color_red}
     print "---# Adding height: $addheight" {color_red}
     # write IO-File to get a pin locations file
     set filename [format "%s_save.io" $topcellname]
     saveIoFile -locations $filename

     # new die sizes
     set llx [expr $x1 / $units]
     set lly [expr $y1 / $units]
     set urx [expr ($x2 / $units) + $addwidth]
     set ury [expr ($y2 / $units) + $addheight]
     set llxc [expr $llx + $l]
     set llyc [expr $lly + $b]
     set urxc [expr $urx - $r]
     set uryc [expr $ury - $t]
     floorPlan -site $rowtype -b $llx $lly $urx $ury \
                                 $llx $lly $urx $ury \
                                 $llxc $llyc $urxc $uryc
     # load pin positions
     loadIoFile $filename
 
  }

}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsPortList2 {filename} {

  global   log


  print $log "^---> Write PinList to File: $filename" {color_red}
  deselectAll
  selectIOPin *
  reportSelect
  deselectAll
  print $log "^---> End Write PinList" {color_red}
  print $log "---> Writing Ports to File now: $filename" {color_red}

  set logFile [getLogFileName]

  set pins 0
  set nrofpins 0
  set chan [open $logFile]
  while {[gets $chan line] >= 0} {
     if {[regexp "<CMD" $line] != 1 &&[regexp "^---> Write PinList to File" $line] == 1} {
        set pins 1
        set ochan [open $filename w]
        set nrofpins 0
     }
     if {$pins == 1} {
       if {[scan $line " Name : %s " n] == 1} {
         set pinname $n
       }
       if {[scan $line " Layer : %s " l] == 1} {
         set pinlayer $l
       }
       if {[scan $line " Location : %f %f " x y] == 2} {
         set xCoord $x
         set yCoord $y
         puts $ochan "$pinname $pinlayer $xCoord $yCoord"
         incr nrofpins
       }
     }
     if {[regexp "<CMD" $line] != 1 && [regexp "^---> End Write PinList" $line] == 1} {
        set pins 0
        close $ochan
     }
  }
  print $log "---> ${nrofpins} Ports found" {color_red}

}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amsStat2 projname {
   global topcellname

   global   log
   print    $log  "---> Executing the amsStat $projname procedure ..." {color_blue}


   set statdir [format "%s_%s_stat" $projname $topcellname]
   print "####"
   print "---# Creating Statistics in directory $statdir";
   system mkdir -p $statdir
   print $log "---#    Directory $statdir created" {color_red}
   print $log "---#    running defStat.pl -> $statdir/$statdir.txt" {color_red}
   defOut -floorplan -netlist -routing $statdir/$topcellname.def
   system defStatv2.pl -d $statdir/$topcellname.def \
                       -p $projname \
                       -t s35d4 \
                       $LEF_DIR/CORELIB.lef \
                       $LEF_DIR/IOLIB_4M.lef \
		              ./LEF/*.lef > $statdir/$statdir.txt
   system mv bar.html $statdir
   print $log "---#    Creating Screen Dump $statdir/$topcellname.gif" {color_red}
   fit
   dumpToGIF $statdir/$topcellname.gif
   print  $log "---#    Creating Wire Statistics $statdir/$topcellname.wires" {color_red}
   reportWire -detail $statdir/$topcellname.wires
   print $log   "---# Finished" {color_red}
   print $log   "####"  {color_Red}

}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc amc2 {start {end -1}} {

 global    log

 if {$end == -1} { set end $start }
 for {set i $start} {$i<=$end} {incr i} {
   print $log "---# ---- Step $i -----" {color_blue}
   set step [format "s%d" $i]
   switch -exact $step {
   
      "s0"  { freeDesign }            
      "s1"  { amsDbSetup2 }            
      "s2"  { amsUserGrid2 }           
      "s3"  { amsGlobalConnect2 core } 
      "s4"  { amsSetMMMC2 }      
      "s5"  { amsSetAnalysisView2 minmax {func test} }      
      "s6"  { amsFloorplan2 core 0.8 50 }
      "s7"  { amsAddEndCaps2 }       
      "s9"  { amsPowerRoute2  {{vdd! 20} {gnd! 20}} }
      "s10" { amsPlace2 ntd }       
      "s11" { amsCts2 }             
      "s12" { amsTa2 postCTS }
      "s13" { optDesign -postCTS }
      "s14" { amsFillperi2 }        
      "s15" { amsRoute2 wroute }   
      "s16" { amsFillcore2 }        
      "s17" { amsTa2 postRoute }
      "s18" { amsWrite2 final }
      "s19" { amsWriteSDF4View2 {func_min func_max} }
     } 
  }
  amsCheckLog2
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

proc ha2 {} {
   info body amc
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


proc amsCheckLog2 {} {
   global checkedLogTilLine

   global   log


   set logfilename [getLogFileName]
   system ams_checkEncLogs.pl -e -w -l $checkedLogTilLine $logfilename
   set chan [open $logfilename]
   set i 0
   while {[gets $chan line] >= 0} {
      set i [expr $i + 1]
   }
   set checkedLogTilLine $i
   close $chan
}
