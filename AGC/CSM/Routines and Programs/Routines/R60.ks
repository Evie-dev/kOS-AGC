// R60 = AUTOMANUVER ROUTINE
local _automnvTarg is v(0,0,0).
FUNCTION R60_INIT {
    print "ROUTINE 60".
    set _DSKY_STATE:PRO to true.
    // create a triger that when the automanuver flag is set to true we can lock the steering to the desired gimbal angles

    set routine_END to R60_FINISH@.
    ADD_STEP("FLV06N18").
    ADD_STEP("FLV50N18").
    ADD_STEP("V06N18").
    ADD_STEP("TERM").
}

LOCAL FUNCTION R60_FINISH {
}