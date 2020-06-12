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

declare global function hohmann_transfer {
    // orignal radius, in meters (including the radius of any body
    // you are orbiting, if applicable)
    parameter original_radius.
    // radius of the new circular orbit, in meters (including the radius
    // of any body you are orbiting, if applicable)
    parameter new_radius.

    parameter orbit_body is ship:orbit:body.

    set result to lexicon().

    local r1 is original_radius.
    local r2 is new_radius.
    local u is constant():g * orbit_body:mass.
    
    // calculate dv1
    result:add("dv1", 
        sqrt(u / r1) * (sqrt((2 * r2) / (r1 + r2)) - 1)
    ).

    // calculate dv2
    result:add("dv2",
        sqrt(u / r2) * (1 - sqrt((2 * r1) / (r1 + r2))) 
    ).

    // calculate the time to transfer from 
    // first orbit to final orbit
    result:add("trans_time",
        constant():pi * sqrt(((r1 + r2)^3) / (8 * u))
    ).

    return result.
}.

declare global function intercept_planet {
    parameter intercept_body.
    parameter original_radius is ship:apoapsis + ship:orbit:body:radius.
    parameter new_radius is intercept_body:orbit:apoapsis + intercept_body:orbit:body:radius. 
    parameter orig_body is ship:orbit:body.

    set result to hohmann_transfer(original_radius, new_radius, orig_body).
    local r1 is original_radius.
    local r2 is new_radius.

    // calculate the angular offset required to intercept the body
    result:add("ang_off",
        constant():pi * (1 - ((1) / (2 * sqrt(2))) * sqrt(((r1 / r2) + 1)^3))
    ).

    return result.
}.

declare global function planet_ang_off {
    parameter planet.

    local v1 is ship:orbit:position - ship:orbit:body:position.
    local v2 is planet:position - ship:orbit:body:position.

    return vectorAngle(v1, v2).
}.

set hoh to intercept_planet(mun).
print "Results to intercept Mun".
print "dv1: " + round(hoh["dv1"], 2).
print "dv2: " + round(hoh["dv2"], 2).
print "offset: " + round(constant():radtodeg * hoh["ang_off"], 2).

print "Angle Between Mun and Ship: " + round(planet_ang_off(mun), 2).