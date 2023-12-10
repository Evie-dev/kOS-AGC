// crew defined manuver
local _automnvTarg is v(0,0,0).
FUNCTION R62_INIT {
    // setup the crew defined manuver
    set _DSKY_STATE:PRO to true.

    // create a triger that when the automanuver flag is set to true we can lock the steering to the desired gimbal angles

    when _AGC:PERMIT:AUTOMNV then {
        set _automnvTarg to _CORE_MEMORY:THETAD.
        lock steering to _automnvTarg. // only needs to be called once
    }
    set routine_END to R62_FINISH@.

    ADD_STEP("FLV06N22").
    ADD_STEP("FLV50N18").
    ADD_STEP("V06N18").
    ADD_STEP("TERM").
}

LOCAL FUNCTION R62_FINISH {
    set _AGC:PERMIT:AUTOMNV to false.
}