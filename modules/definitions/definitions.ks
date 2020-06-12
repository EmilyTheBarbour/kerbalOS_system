print "Definitions Module Loaded.".

///////////////////////////////////////////////
////        MACRO DEFINITION
///////////////////////////////////////////////

// defines a key in the lexicon
// that will be designated for 
// determining if the data being represented
// is "Live" data
global IS_ACTIVE is "IS_ACTIVE_KEY".

///////////////////////////////////////////////
////            Current_Maneuver
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
//                  Functions
// --------------------------------------------
//
//
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

// create the lexicon to store maneuver state
local current_maneuver is lexicon().
set current_maneuver[IS_ACTIVE] to false.
set current_maneuver["delta_v"] to 0.
set current_maneuver["start_time"] to 0.
set current_maneuver["burn_time"] to 0.

// public function protecting the creation 
// of maneuvers
declare global function create_maneuver {
    parameter delta_v.
    parameter start_time.
    parameter burn_time.

    // if a maneuver already exists, do not 
    // override it without it being cleared 
    // manually first
    if current_maneuver[IS_ACTIVE] {
        return false.
    }

    // update our maneuver
    set current_maneuver["delta_v"] to delta_v.
    set current_maneuver["start_time"] to start_time.
    set current_maneuver["burn_time"] to burn_time.
    set current_maneuver[IS_ACTIVE] to true.

    // indicate success
    return true.
}

declare global function is_maneuver {
    return current_maneuver[IS_ACTIVE].
}

// returns a copy (I don't think kOS
// supports construct by copy, so I
// simply create a new lexicon shadowing
// the values)
declare global function get_maneuver {
    
    // return a copy lex that indicates
    // there is no maneuver currently
    if not current_maneuver[IS_ACTIVE] {
        return lexicon(IS_ACTIVE, false).
    }

    // return a copy of the lexicon  
    return lexicon(
        IS_ACTIVE, true,
        "delta_v", current_maneuver["delta_v"],
        "start_time", current_maneuver["start_time"],
        "burn_time", current_maneuver["burn_time"]
    ).
}
