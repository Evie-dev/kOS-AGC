// Digital Autopilot data load routine

// Entered through VERB 48


FUNCTION R03_INIT {
    print "ROUTINE 03!".
    set _DSKY_STATE:PRO to true.

    set routine_END to R03_FINISH@.

    ADD_STEP("FLV04N46").
    ADD_STEP("FLV06N47").
    ADD_STEP("FLV06N48"). // gimbal angles
    ADD_STEP("TERM").
}

LOCAL FUNCTION R03_FINISH {
    // due to the way DAPDATR values are stored we must replace the current SCALAR in memory (potentially during input, the text will be converted to a scalar, and DAPDATR is easier when in a string)
    
    // verify the dap datr

    set _CORE_MEMORY:DAPDATR1 to R03_DAPVERIF(_CORE_MEMORY:DAPDATR1).
    set _CORE_MEMORY:DAPDATR2 to R03_DAPVERIF(_CORE_MEMORY:DAPDATR2).

    
    print "R03 ENDED".
}

LOCAL FUNCTION R03_DAPVERIF {
    parameter verifWhat is "".
    set verifWhat to verifWhat:tostring.

    IF verifWhat:length = 4 {
        set verifWhat to "0"+verifwhat.
    } ELSE IF verifWhat:length = 3 {
        set verifWhat to "00"+verifWhat.
    } ELSE IF verifWhat:length = 2 {
        set verifWhat to "000" + verifWhat.
    } ELSE IF verifWhat:length = 1 {
        set verifWhat to "0000" + verifWhat.
    } ELSE IF verifWhat:length = 0 {
        set verifWhat to "00000".
    }
    return verifWhat.
}