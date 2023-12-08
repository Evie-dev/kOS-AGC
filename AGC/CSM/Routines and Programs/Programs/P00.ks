// Program 00 - CMC Idling program

FUNCTION P00_INIT {
    // setup idling function

    set _UPDLOOP_POINTER_VAR to P00_VARUPD@.
    set _UPDLOOP_POINTER_DISP to P00_DISPUPD@.

    EXT_DSKY_PROG("00").
}

LOCAL FUNCTION P00_VARUPD {
    // literally does fuck all lol
}

LOCAL FUNCTION P00_DISPUPD {
    // also does fuck all lmfaoo
}