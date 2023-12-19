// P62 - Preentry (CM/CSM SEP)

FUNCTION P62_INIT {
    // set the program
    set _DSKYdisplayREG:PROG to "62".

    set _UPDLOOP_POINTER_VAR to P62_VARUPDT@.
    _CHECKLISTCODES(41).
    P62_VARIABLES().
    ADD_STEP("FLV50N25").
    ADD_STEP("FLV06N61").
    ADD_STEP("V06N22").
    ADD_STEP("P63"). // autoadvance to P63 - Entry init
}

LOCAL FUNCTION P62_VARUPDT {
    P62_VARIABLES().
}