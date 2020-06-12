///////////////////////////////////////////////
////                Auto_Stage
///////////////////////////////////////////////
//
// this module contains a simple, toggleable 
// eventHandle that checks the set of engines 
// on the vessel, and stages if any of them report
// having flamed-out, a.k.a are out of fuel
//
// --------------------------------------------
//                  FIELDS
// --------------------------------------------
//
// There are no public fields.
//
// --------------------------------------------
//                  Functions
// --------------------------------------------
//
// The only publicly accessable functions
// are enable_autostage() and disable_autostage()
// which are self-explainatory
//
// --------------------------------------------
//                  NOTES
// --------------------------------------------
//
// this script operates under the assumption that 
// a stage consists of both a seperator and an engine,
// in that the next stage can be activated by only 
// pressing the spacebar once.
//
///////////////////////////////////////////////
// THIS IS TODO THIS IS TODO THIS IS TODO 
///////////////////////////////////////////////
print "AutoStage Moduled Loaded.".

// get the engine list
local do_autostage is false.
list engines in elist.

// register the eventHandle
when do_autostage then {
    // check if any engines have no fuel
    for e in elist {
        if e:flameout {
            stage.

            until stage:ready { wait 0. }.

            // update the engine list
            list engines in elist.

            // exit autostager
            break.
        }
    }
    preserve.
}

// create public Getter and Setter
declare global function enable_autostage {
    set do_autostage to true.
}.

declare global function disable_autostage {
    set do_autostage to false.
}
