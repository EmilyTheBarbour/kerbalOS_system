///////////////////////////////////////////////
////                Low_Kerb_Orbit
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

// load the modules
runOncePath("0:/modules/planning/hohmann.ks").
runOncePath("0:/modules/dynamics/burn_time.ks").
runOncePath("0:/modules/control/auto_stage.ks").
runOncePath("0:/modules/ui/craft_ui.ks").
runOncePath("0:/modules/definitions.ks").
runOncePath("0:/modules/planning/current_maneuver.ks").

// enable system ui
enable_UI().

// setup the parameters for initial flight
set apHeight to 85000.
set turnVel to 150.

// expose current throttle and pitch and lock them
global current_throttle is 0.6.
lock throttle to current_throttle.
global current_pitch is 90.
lock steering to heading(90, current_pitch).

// set the dynamic parameters
set startApHeight to 0.

// start the rocket
print_message("Launch.").
stage.
enable_autostage().

print_message("Waiting until vel of " + turnVel).
// mark the point when we started the turn
when ship:airspeed > turnVel then {
    set startApHeight to ship:apoapsis.
    print_message("Starting turn.").
}.

when missionTime > 60 then {
    print_message("Throttle Up!").
    set current_throttle to 1.
}


// climb until apHeight reached
until ship:apoapsis > ApHeight {
    // keep going straight up until desired turn altitude reached
    if ship:altitude < turnVel {
        set current_pitch to 90.
    }
    else {
        set current_pitch to 90 - ((ship:apoapsis - startApHeight) / (apHeight - startApHeight)) * 90.
    }
}.

print_message("Cutting throttle until circularization burn.").
set current_throttle to 0.

// get our orbital velocity at apoapsis
local start_vel is orbital_speed(ship:apoapsis + ship:orbit:body:radius, ship:orbit:semimajoraxis).

// check what the velocity requirement is for a circular
// orbit at desiredApHeight
local final_vel is orbital_speed_with_radius(apHeight, apHeight).

// calculate dv and burn time
local dv is final_vel - start_vel.
local burn_time is calc_burn_time(dv).

print_message("Estimated AP Vel is " + round(start_vel, 2) + "m/s").
print_message("Insert Burn of " + round(dv, 2) + "m/s will take " + round(burn_time, 1) + "s").

// start the burn at 1/2 burn time before apoapsis
// plus 5 seconds to allow for 10 seconds of slower burn to get a nicer orbit
local start_burn_time is (missionTime + eta:apoapsis) - calc_burn_time(dv / 2).
local end_burn_time is start_burn_time + burn_time.

// register with the UI
create_maneuver(dv, start_burn_time, burn_time).

// get steering ready for burn
lock steering to prograde.

print_message("Waiting for " + round(start_burn_time - missionTime, 1) + "s").
wait 3.
warpTo(start_burn_time - 15).
wait until missionTime > start_burn_time.

print_message("Beginning burn.").
set current_throttle to 1.

// burn for the fast portion
wait until missionTime > end_burn_time.

set current_throttle to 0.
print_message("Complete.").
disable_autostage().