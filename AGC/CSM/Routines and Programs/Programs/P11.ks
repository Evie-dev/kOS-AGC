// Program 11 - Boost insertion monitor

// All programs will have the following function:

FUNCTION P11_INIT {
    // this will be global for functions and routines, allowing for a more streamlined useage

    set _UPDLOOP_POINTER_VAR to P11_VARUPDT@.
    set _UPDLOOP_POINTER_DISP to P11_DISPUPDT@.

    // set the verb and noun combos
    
    print "program 11 started!".

    EXT_DSKY_PROG("11").

    EXT_DSKY_VERB("06").
    EXT_DSKY_NOUN("62").
}


LOCAL FUNCTION P11_VARUPDT {
    // update variables for P11

    // Update the IVM

    set _CORE_MEMORY:VMAGI to FLOOR(SHIP:velocity:ORBIT:MAG*3.28084). // IN FEET PER SECOND, zero decimal
    set _CORE_MEMORY:HDOT to FLOOR(verticalSpeed*3.28084). // IN FPS, zero decimal
    set _CORE_MEMORY["ALT 1"] to FLOOR(altitude*0.00054,1). // in NMI

}

LOCAL FUNCTION P11_DISPUPDT {
    EXT_DSKY_REGISTERS(_CORE_MEMORY:VMAGI, "R1", "XXXXX").
    EXT_DSKY_REGISTERS(_CORE_MEMORY:HDOT, "R2", "XXXXX").
    EXT_DSKY_REGISTERS(_CORE_MEMORY["ALT 1"], "R3", "XXXX.X").
}