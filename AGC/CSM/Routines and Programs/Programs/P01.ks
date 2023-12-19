local P1_start is 0.
FUNCTION P01_INIT {
    set _DSKY_STATE:PRO to true.

    set _UPDLOOP_POINTER_VAR to P01_VARUPDT@.
    EXT_DSKY_PROG("01").
    local P1_start is time:seconds.

    when time:seconds > P1_START+90 then {
        _AGC_PROGRAMUPDATE("02").
    }
}

LOCAL FUNCTION P01_VARUPDT {
    
}