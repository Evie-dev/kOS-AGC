// P63 - Entry initilization

// note: this is NOT a moon landing!

FUNCTION P63_INIT {
    // enable automnv
    set _DSKYdisplayREG:PROG to "63".

    set _AGC:PERMIT:AUTOMNV to true.
    set _UPDLOOP_POINTER_VAR to P63_VARUPDT@.
    P63_VARIABLES().
}

LOCAL FUNCTION P63_VARUPDT {
    // this basically runs until 0.05g is detected
    P63_VARIABLES().
    IF _CORE_MEMORY:D > 0.5 { // changed to .5 m/s^2 for more accurate resulting
        P63_EXIT().
    }
}

LOCAL FUNCTION P63_EXIT {
    // exit P63 to another entry program

    _AGC_PROGRAMUPDATE("64").
}