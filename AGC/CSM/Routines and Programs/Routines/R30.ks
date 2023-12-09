// 

FUNCTION R30_INIT {
    // update orbit vectors

    set _CORE_MEMORY:HAPOX to FLOOR(apoapsis*0.00054,1).
    set _CORE_MEMORY:HPERX to FLOOR(periapsis*0.00054,1).
    set _CORE_MEMORY:TFF_M to FLOOR(TIMESPAN(ship:orbit:period):MINUTES).
    set _CORE_MEMORY:TFF_S to FLOOR(ship:orbit:period-FLOOR(60*_CORE_MEMORY:TFF_M)).
    local _m is _CORE_MEMORY:TFF_M:tostring.
    local _s is _CORE_MEMORY:TFF_S:tostring.
    print _m.
    print _s.
    set _CORE_MEMORY:TFF to _m + "0" + _s.
    // set the pro flag to true
    set _DSKY_STATE:PRO to true.
    ADD_STEP("V06N44").
    ADD_STEP("TERM").
}

LOCAL FUNCTION R30_FINISH {

}