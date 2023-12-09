local P1_start is 0.
FUNCTION P01_INIT {
    set _UPDLOOP_POINTER_VAR to P01_VARUPDT@.
    EXT_DSKY_PROG("01").
    set P1_start to time:seconds.
}

LOCAL FUNCTION P01_VARUPDT {
    IF time:seconds > P1_start+45 {
        _AGC_PROGRAMUPDATE("P02").
    }
    
}