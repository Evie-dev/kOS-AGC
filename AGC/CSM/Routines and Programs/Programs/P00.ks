// Program 00 - CMC Idling program

FUNCTION P00_INIT {
    // setup idling function

    set _UPDLOOP_POINTER_VAR to P00_VARUPD@.
    set _UPDLOOP_POINTER_DISP to P00_DISPUPD@.

    EXT_DSKY_PROG("00").

    // clear all the displays DIRECTLY
    set _DSKYdisplayREG:VERB TO "".
    set _DSKYdisplayREG:NOUN TO "".
    set _DSKYdisplayREG:R1 to "".
    set _DSKYdisplayREG:R2 TO "".
    SET _DSKYdisplayREG:R3 TO "".
    set _DSKY_STATE:INHB:INP to "V00N00".
    _AGC_INPUTQUEUE:CLEAR.
}

LOCAL FUNCTION P00_VARUPD {
    // literally does fuck all lol
}

LOCAL FUNCTION P00_DISPUPD {
    // also does fuck all lmfaoo
}