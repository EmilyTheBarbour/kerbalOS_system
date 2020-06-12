///////////////////////////////////////////////
////                Burn_Time
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

print "Burn Time module loaded.".

declare global function calc_burn_time {
    // calculates the ammount of time for the vehicle to burn
    // given a required delta v
    parameter dV.

    // get all the engines
    list engines in engList.

    // get the active engine
    set activeEng to engList[0].
    for eng in engList {
        if eng:ignition {
            set activeEng to eng.
            break.
        }.
    }.

    // set up the equation
    local f is activeEng:maxthrust * 1000.
    local m is ship:mass * 1000.
    local e is constant():e.
    local p is activeEng:isp.
    local g is 9.80665.

    // return the time 
    return g * m * p * (1 - e^(-dV / (g * p))) / f.
}.

