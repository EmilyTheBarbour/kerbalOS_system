///////////////////////////////////////////////
////                Science
///////////////////////////////////////////////
//
// This lexicon holds information related to 
// either a currently executing maneuver, or
// a planned maneuver. 
//
// --------------------------------------------
//                  FIELDS
// --------------------------------------------
//
// * IS_ACTIVE [bool] -> describes whether the
//      current maneuver stored is valid
//
// * delta_v [double] -> describes the desired
//      dv for this current maneuver
//
// * start_time [double] -> describes the time
//      when the maneuver is scheduled to start.
//      this is a timestamp in MISSIONTIME, i.e
//      start_time=90 indicates a maneuver planned
//      for 90 seconds after launch
//
// * burn_time [double] -> describes the intended
//      length of the maneuver, in seconds.
//
// --------------------------------------------
//                  NOTES
// --------------------------------------------
//
// The end time of the burn can be extrapolated 
// to be equal to:
//      
//      end_time = start_time + burn_time
//
// this will be in seconds since the start of the 
// mission, otherwise known as MISSIONTIME.
//
///////////////////////////////////////////////
// THIS IS TODO THIS IS TODO THIS IS TODO 
///////////////////////////////////////////////

print "Science Module Loaded.".

runOncePath("0:/modules/craft_ui.ks").

// part names for getting all parts 
// on the ship
local SCIENCE_JR_NAME is "science.module". 
local GOO_CONTAINER_NAME is "GooExperiment".
local ACCELEROMETER_NAME is "sensorAccelerometer".
local BAROMETER_NAME is "sensorBarometer".
local GRAVIMETER_NAME is "sensorGravimeter".
local THERMOMETER_NAME is "sensorThermometer".
local ATMOSPHERE_SCAN_NAME is "sensorAtmosphere".

// form the lists of all the parts
local science_jr_list is    ship:partsnamed(SCIENCE_JR_NAME).
local goo_list is           ship:partsnamed(GOO_CONTAINER_NAME).
local accel_list is         ship:partsnamed(ACCELEROMETER_NAME).
local bar_list is           ship:partsnamed(BAROMETER_NAME).
local grav_list is          ship:partsnamed(GRAVIMETER_NAME).
local therm_list is         ship:partsnamed(THERMOMETER_NAME).
local atmo_list is          ship:partsnamed(ATMOSPHERE_SCAN_NAME).

// create the iterators for each of the parts
local parts_iter is lexicon().
set parts_iter[SCIENCE_JR_NAME] to          science_jr_list:iterator.
set parts_iter[GOO_CONTAINER_NAME] to       goo_list:iterator.
set parts_iter[ACCELEROMETER_NAME] to       accel_list:iterator.
set parts_iter[BAROMETER_NAME] to           bar_list:iterator.
set parts_iter[GRAVIMETER_NAME] to          grav_list:iterator.
set parts_iter[THERMOMETER_NAME] to         therm_list:iterator.
set parts_iter[ATMOSPHERE_SCAN_NAME] to     atmo_list:iterator.

print "Ship Science Configuration:".
print "-------------------------------".
print science_jr_list:length + " " + SCIENCE_JR_NAME.
print goo_list:length + " " + GOO_CONTAINER_NAME.
print accel_list:length + " " + ACCELEROMETER_NAME.
print bar_list:length + " " + BAROMETER_NAME.
print grav_list:length + " " + GRAVIMETER_NAME.
print therm_list:length + " " + THERMOMETER_NAME.
print atmo_list:length + " " + ATMOSPHERE_SCAN_NAME.
print "-------------------------------".

// handles whether to automatically transmit any science results to KSC
local auto_transmit is false.

declare global function do_all_science_once {
    print_message("Collecting all science! Transmitting? " + auto_transmit).

    ag1 on.
    wait 1.

    for sc in parts_iter:keys {
        if not parts_iter[sc]:next {
            print "There are no more " + sc + " Remaining...".
        }
        else {
            local m is parts_iter[sc]:value:getmodule("ModuleScienceExperiment").
            m:deploy.

            if auto_transmit {
                wait until m:hasdata.
                m:transmit.
            }
        }
    }

    ag1 off.
}.
