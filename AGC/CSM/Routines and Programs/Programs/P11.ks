// Program 11 - Boost insertion monitor

// All programs will have the following function:
local _doneOnce is false.
FUNCTION P11_INIT {
    set _DSKY_STATE:PRO to true.

    // this will be global for functions and routines, allowing for a more streamlined useage

    set _UPDLOOP_POINTER_VAR to P11_VARUPDT@.
    set _UPDLOOP_POINTER_DISP to P11_DISPUPDT@.

    // set the verb and noun combos
    
    print "program 11 started!".

    // program 11 running

    EXT_DSKY_PROG("11").
    EXT_DSKY_GCDISPLAYREQ("V06N62").
}


LOCAL FUNCTION P11_VARUPDT {
    // update variables for P11

    // Update the IVM

    set _CORE_MEMORY:VMAGI to ship:velocity:orbit:mag. // IN FEET PER SECOND, zero decimal
    set _CORE_MEMORY:HDOT to verticalspeed. // IN FPS, zero decimal
    set _CORE_MEMORY["ALT 1"] to altitude. // in NMI

    // update the orbit parameters
    set _CORE_MEMORY:HAPOX to apoapsis.
    set _CORE_MEMORY:HPERX to periapsis.
    set _CORE_MEMORY:TFF to ship:orbit:period.
    

}

LOCAL FUNCTION P11_DISPUPDT {
    
    IF periapsis > 70000 and throttle = 0 and NOT(_doneOnce) {
        // begin flashing
        EXT_DSKY_GCDISPLAYREQ("V16N44").
        ADD_STEP("P00").
        ADD_STEP("TERM").
        set _doneOnce to true.
    } ELSE IF NOT(periapsis > 70000 and throttle = 0) { EXT_DSKY_GCDISPLAYREQ("V06N62"). }
}