// ensure files are on local machine
print "Copying modules to harddrive...".
copyPath("0:/modules", "modules").

// includes
runOncePath("0:/modules/science.ks").
runOncePath("0:/modules/definitions.ks").

// intro sequence
runPath("0:/modules/low_kerb_orbit.ks").

