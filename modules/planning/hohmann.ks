///////////////////////////////////////////////
////                Craft_UI
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

print "Hohmann Module Loaded.".

declare global function orbital_speed {
    // takes in the radius the ship will be at when it starts the burn
    // and the size of the semi_major axes the ship's orbit is following
    parameter radius. // in meters
    parameter semi_major. // in meters 

    // setup the parameters
    local g is constant():g.
    local u is g * ship:orbit:body:mass.
    local r is radius.
    local a is semi_major.

    // get the orbital velocity at radius traveling along 
    // orbit with semi_major of a
    return sqrt(u * ((2 / r) - (1 / a))). // in m/s
}

declare global function orbital_speed_with_radius {
    parameter radius.
    parameter semi_major.

    return orbital_speed(radius + ship:orbit:body:radius,
        semi_major + ship:orbit:body:radius).
}

declare global function transfer_speed {
    // given the ships current semi_major axes (apopasis)
    // calculate the speed needed to create the transfer 
    // orbit whose apoapsis is desired_radius
    parameter desired_radius. // in meters

    local r is ship:apoapsis.
    local a is (ship:apoapsis + desired_radius) / 2.

    return orbital_speed(r, a).
}

declare global function transfer_delta_v {
    parameter desired_radius.

    // speed once the burn is finished
    local v_peri is transfer_speed(desired_radius).
    // speed before the burn
    local v_curr is orbital_speed(ship:apoapsis, ship:apoapsis).

    return v_peri - v_curr.
}.

declare global function insertion_speed {
    // calculates the final speed of the vehicle
    // to be in a circular orbit at the desired radius
    parameter desired_radius. // in meters

    local r is desired_radius.
    local a is desired_radius.

    return orbital_speed(r, a).
}

declare global function insertion_delta_v {
    parameter desired_radius. // in meters

    local a is (ship:apoapsis + desired_radius) / 2.
    local v_trans is orbital_speed(desired_radius, a).
    local v_final is insertion_speed(desired_radius).

    return v_final - v_trans.
}

