clearScreen.

// load the modules
runPath("0:/modules/hohmann.ks").
runPath("0:/modules/burn_time.ks").

// keo-stationary orbit
set KEO_alt to 2863334.06.

lock steering to prograde.

set trans_dv to transfer_delta_v(KEO_alt).
set trans_time to calc_burn_time(trans_dv).
set trans_final_vel to transfer_speed(KEO_alt).

set ins_dv to insertion_delta_v(KEO_alt).
set ins_final_vel to insertion_speed(KEO_alt).

print "------------------------------------------".
print "Transfer dV:  " + round(trans_dv, 2).
print "Insertion dV: " + round(ins_dv, 2).
print "------------------------------------------".

print "Warping to apoapsis for transfer burn...".
warpTo(time:seconds + eta:apoapsis - 15 - trans_time / 2).
print "Burn time expected to be " + round(trans_time, 2) + "s.".
wait until eta:apoapsis < trans_time / 2.

lock throttle to 1.0.

print "performing burn...".
until ship:apoapsis >= KEO_alt {
    print round(ship:apoapsis, 2) + " / " + round(KEO_alt, 2) at(0, terminal:height - 1).
}.

print "burn complete!".
lock throttle to 0.0.
wait 5.

set ins_time to calc_burn_time(ins_dv).

print "Warping to burn...".
warpTo(time:seconds + eta:apoapsis - 15 - ins_time / 2).
print "Burn time expected to be " + round(ins_time, 2) + "s.".
wait until eta:apoapsis < ins_time / 2.

lock throttle to 1.0.
print "Performing burn...".
until ship:periapsis >= KEO_alt {
    print round(ship:periapsis, 2) + " / " + round(KEO_alt, 2) at(0, terminal:height - 1).
}.

print "Burn complete!".
lock throttle to 0.

