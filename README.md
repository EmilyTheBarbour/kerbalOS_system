# KerbalOS Navigation and Control Libraries
this repository contains all of the various scripts 
that are used on most of my space-flights in kerbal
space program. 

This was done with both KerbalOS + RemoteTech to enforce
the requirement that behavior either had to be pre-planned,
or that an existing infrastructure is available to relay
communications.

# Folder Definitions
below is a quick summary of all of the folders within this repository

* `/boot/` - this is a pre-generated folder by kOS that houses
any file that is intended to be pre-loaded on a spacecraft before
flight begins. 
* `/modules/` - this houses the modular libraries written to support
various different functionality I might want for a particular spaceflight. More ship-specific implementation is often done in `/boot/`, which is really just a sequence of library calls for that particular mission.

  * `control/` - this houses any scripts intended to directly interface with a ships controls
  * `dynamics/` - houses either rudamentory dynamics models, or helper equations related to the dynamics of a spacecraft
  * `flight_plan/` - houses flight subroutines that can be used to get most craft to a specific place, such as low-kerbin-orbit, for example
  * `ui/` - houses scripts related to data presentation and system readouts
  * `vessel/` - houses scripts that interact with the game side of kerbal space program, such as obtaining and transmitting science

