// External Delta V program (FOR MANUVER NODES)

// IMPORTANT NOTE ABOUT THE SCOPE OF P30
// P30 does not EXECUTE manuvers, it only setsup the timings for the manuvers

local proCount is 0.

FUNCTION P30_INIT {
    set _DSKY_STATE:PRO to true.
    EXT_DSKY_PROG("30").
    // USE P27 TO INPUT NODE DATA
    set proCount to _DSKY_STATE:INPUTS:PRO+2. // this will be the number of times procede has been pressed when we can start calculating resultant orbit data for the given information
    // P30 begins by setting up two displays
    set _UPDLOOP_POINTER_VAR to P30_VARUPDT@.
    
    ADD_STEP("FLV06N33").
    ADD_STEP("FLV06N81").
    
}

LOCAL FUNCTION P30_VARUPDT {
    IF _DSKY_STATE:INPUTS:PRO = proCount-1 {
        // we can now calculate and display the data relating to the new orbit parameters AFTER the burn

        // 1. Place the state vector information into the memory
        local _rtig is positionat(ship, _CORE_MEMORY:TIG+_CORE_MEMORY:TIME0).
        local _vtig is velocityAt(ship, _CORE_MEMORY:TIG+_CORE_MEMORY:TIME0):orbit.
        // add the impulsive deltav to vtig

        // input into memory
        set _DSKY_STATE:PRO to true.
        set _CORE_MEMORY:RTIG TO _rtig.
        set _CORE_MEMORY:VTIG TO _vtig.

        // now we can calculate "stuff"
        // our future orbit is stuff in this case

        local _futurorbinfo is stateVectorIntegration(_CORE_MEMORY:RTIG, _CORE_MEMORY:VTIG+_CORE_MEMORY:DELVLVC).

        // input these values into memory

        set _CORE_MEMORY:DVTOTAL to (_vtig+_CORE_MEMORY:DELVLVC):mag.
        set _CORE_MEMORY:HAPO to _futurorbinfo:apoapsis:a.
        set _CORE_MEMORY:HPER to _futurorbinfo:periapsis:a.
        set _CORE_MEMORY:VGDISP to _CORE_MEMORY:DVTOTAL-_vtig:mag.
        
        ADD_STEP("FLV06N42").
        ADD_STEP("FLV16N45").
        ADD_STEP("P00").
        set proCount to 0. // reset the pro count so we dont do something really dumb and keep adding steps
    }
}

LOCAL FUNCTION P30_DISPUPDT {

}