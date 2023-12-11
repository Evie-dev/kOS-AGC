// 

FUNCTION R30_INIT {
    // update orbit vectors
    set _DSKY_STATE:PRO to true.

    // using the state vectors in the AGC's memory we calculate the orbit

    local _cORB is stateVectorIntegration(_CORE_MEMORY:R, _CORE_MEMORY:V).
    print _cORB.
    set _CORE_MEMORY:HAPOX to _cORB:apoapsis:a.
    set _CORE_MEMORY:HPERX to _cORB:periapsis:a.
    set _CORE_MEMORY:TFF to 2*constant:pi/sqrt(_cORB:mu)*_cORB:semimajoraxis^(3/2).

    
    // set the pro flag to true
    set _DSKY_STATE:PRO to true.
    ADD_STEP("V06N44").
    ADD_STEP("TERM").
}

LOCAL FUNCTION R30_FINISH {
}