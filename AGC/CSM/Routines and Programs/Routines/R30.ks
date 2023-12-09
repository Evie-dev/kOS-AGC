// 

FUNCTION R30_INIT {
    // update orbit vectors

    set _CORE_MEMORY:HAPOX to FLOOR(apoapsis*0.00054,1).
    set _CORE_MEMORY:HPERX to FLOOR(periapsis*0.00054,1).
    set _CORE_MEMORY:TFF TO ship:orbit:period.
    // set the pro flag to true
    set _DSKY_STATE:PRO to true.
    ADD_STEP("V06N44").
    ADD_STEP("TERM").
}

LOCAL FUNCTION R30_FINISH {

}