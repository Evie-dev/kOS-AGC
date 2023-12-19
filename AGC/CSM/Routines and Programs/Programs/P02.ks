
FUNCTION P02_INIT {
    set _DSKY_STATE:PRO to true.

    set _UPDLOOP_POINTER_VAR to P02_VARUPDT@.
    EXT_DSKY_PROG("02").
}

LOCAL FUNCTION P02_VARUPDT {
    
    // await the liftoff descrite (message from the LVDC that we are flying and then continue to P11)

    IF NOT(CORE:MESSAGES:QUEUE:EMPTY) {
        local _msg is CORE:MESSAGES:pop.

        IF _msg:content = "SATURN LIFTOFF" {
            // liftoff discrite

            _AGC_PROGRAMUPDATE("11"). // P11 ENTRY
        }
    }
}