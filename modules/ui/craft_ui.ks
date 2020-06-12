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
print "Craft UI Loaded.".

// include
runOncePath("0:/modules/definitions.ks").

// variables that handle when to draw the UI.
local frame_rate is 2.
local next_draw_time is 0.
local do_draw is false.

local name_pad is 15.   // amount of padding to add to the description of the value
local val_pad is 10.    // amount of padding to add to the value itself
local term_height is 30.
local term_width is name_pad * 2 + val_pad * 2 + 3.

// set the terminal to the derrived size
print "Setting terminal to (" + term_width + "x" + term_height + ").".
set terminal:width to term_width.
set terminal:height to term_height.

// messaging supports showing the last messages sent
local chat_start_line is 13.
local message_count is term_height - chat_start_line - 1.
set messages to queue().

FROM {local x is message_count.} UNTIL x = 0 STEP {set x to x-1.} DO {
    messages:push("").
}

// local variables for printing the seperator
local sep_string is get_seperator_string().

when do_draw and time:seconds > next_draw_time then {
    draw_UI().
    set next_draw_time to time:seconds + 1.0 / frame_rate.
    preserve.
}.

declare local function draw_UI {

    // creating strings of all of the required values
    local max_thrust is     "" + round(ship:maxthrust, 2).
    local avail_thrust is   "" + round(ship:availablethrust, 2).
    local ship_mass is      "" + round(ship:mass, 2).
    local wet_mass is       "" + round(ship:wetmass, 2). 
    local air_speed is      "" + round(ship:airspeed, 2).
    local orbit_speed is    "" + round(ship:orbit:velocity:orbit:mag, 2). 
    local ap_eta is         "" + round(eta:apoapsis, 1).
    local per_eta is        "" + round(eta:periapsis, 1).
    local ap_height is      "" + round(ship:apoapsis / 1000, 2).
    local per_height is     "" + round(ship:periapsis / 1000, 2).
    local ship_alt is       "" + round(ship:altitude / 1000, 2).
    local curr_pitch is     "" + round(current_pitch, 1).
    local ship_Q is         "" + round(ship:q, 2).
    local ship_thot is      "" + round(current_throttle, 2).


    // print the values to the screen
    clearScreen.
    print "Max Thrust:":padright(name_pad) +            max_thrust:padleft(val_pad)     at(0, 0).
    print " | " + "Avail Thrust:":padright(name_pad) +  avail_thrust:padleft(val_pad)   at(name_pad + val_pad, 0).
    print "Ship Mass:":padright(name_pad) +             ship_mass:padleft(val_pad)      at(0, 1).
    print " | " + "Wet Mass:":padright(name_pad) +      wet_mass:padleft(val_pad)       at(name_pad + val_pad, 1).
    print "Air Speed:":padright(name_pad) +             air_speed:padleft(val_pad)      at(0, 2).
    print " | " + "Orbit Speed:":padright(name_pad) +   orbit_speed:padleft(val_pad)    at(name_pad + val_pad, 2).
    print "AP ETA:":padright(name_pad) +                ap_eta:padleft(val_pad)         at(0, 3).
    print " | " + "PERI ETA:":padright(name_pad) +      per_eta:padleft(val_pad)        at(name_pad + val_pad, 3).
    print "AP Height:":padright(name_pad) +             ap_height:padleft(val_pad)      at(0, 4).
    print " | " + "PERI Height:":padright(name_pad) +   per_height:padleft(val_pad)     at(name_pad + val_pad, 4).
    print "Altitude:":padright(name_pad) +              ship_alt:padleft(val_pad)       at(0, 5).
    print " | " + "Curr Pitch:":padright(name_pad) +    curr_pitch:padleft(val_pad)     at(name_pad + val_pad, 5).
    print "Q:":padright(name_pad) +                     ship_Q:padleft(val_pad)         at(0, 6).
    print " | " + "Curr Throttle:":padright(name_pad) + ship_thot:padleft(val_pad)      at(name_pad + val_pad, 6).


    print "T+" + time(missionTime):clock at(0, 9).
    print sep_string at(0, 10).
    local check_maneuver is get_maneuver().
    if check_maneuver[IS_ACTIVE] {
        if missionTime < check_maneuver["start_time"] {
            // create the string for centering
            center_print("Maneuver start in " + round(check_maneuver["start_time"] - missionTime, 1) + "s", 11).
            
        }
        else
        {
            // calculate how many characters to show
            local characters is term_width - round(term_width * ((check_maneuver["start_time"] + check_maneuver["burn_time"]) - missionTime) / check_maneuver["burn_time"], 0).

            // form a string of that many characters
            local s is "".
            FROM {local x is characters.} UNTIL x = 0 STEP {set x to x-1.} DO {
                set s to s + "#".
            }

            // print
            print s at(0, 11).
        }
    }
    else
    {
        center_print("No maneuver scheduled", 11).
    }

    print sep_string at(0, 12).

    // print the messages in reverse order "last in queue should be at the bottom"
    local it is messages:iterator.
    local row is chat_start_line.
    until not it:next {
        print "> " + it:value at(0, row).
        set row to row + 1.
    }.

    print sep_string at(0, term_height - 1).
}.

declare local function center_print {
    parameter string.
    parameter line.

    print string at(term_width / 2 - (string:length / 2), line).
}.

declare global function print_message {
    parameter msg.

    // clear the oldest message
    messages:pop().

    // add the newest message
    messages:push(msg).
}.

declare global function get_seperator_string {
    local result is "".

    from {local i is 0.} until i = terminal:width - 1 step {set i to i + 1.} do {
        set result to result + "-".
    }.

    return result.
}.

declare global function enable_UI {
    print "Enabling UI...".
    set do_draw to true.
}.

declare global function disable_UI {
    print "Disabling UI...".
    set do_draw to false.
}.

print("Hello World!").
