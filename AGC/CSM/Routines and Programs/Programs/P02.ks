
FUNCTION P02_INIT {
    set _DSKY_STATE:PRO to true.

    set _UPDLOOP_POINTER_VAR to P02_VARUPDT@.
    EXT_DSKY_PROG("02").
}

LOCAL FUNCTION P02_VARUPDT {
    
    IF SHIP:STATUS = "FLYING" {
        // first motion!
        // go to P11

        _AGC_PROGRAMUPDATE("P11").
    }
}