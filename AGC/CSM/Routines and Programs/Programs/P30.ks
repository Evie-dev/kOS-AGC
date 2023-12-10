// External Delta V program (FOR MANUVER NODES)

// IMPORTANT NOTE ABOUT THE SCOPE OF P30
// P30 does not EXECUTE manuvers, it only setsup the timings for the manuvers

local P30 is lexicon(
    "TN", 0, // time of node
    "TB", 0 // time of burn
).

FUNCTION P30_INIT {
    set _DSKY_STATE:PRO to true.
    EXT_DSKY_PROG("30").
    // TEMPORARY FEATURE
    // IF WE HAVE A NODE ALREADY SET THE CODE WILL JUST USE IT RATHER THAN GO THROUGH P27 BECAUSE IM UNSURE HOW THAT WORKS AS OF CURRENT

    IF hasNode {
        local _p30NodeInput is nextnode.
        
        // setup the variables for the burn

        local _dv is _p30NodeInput:deltav.
        // input this into memory
        local _ICDUang is _dv.
        local _GETN is abs(_DSKY_STATE:clock:first-_p30NodeInput:TIME).

        // input these angles and times and such

        // what is our current mass? 

        local _m0 is mass. // at burn start
        local _mDELTA is 0. // mass lost due to the thrusting of engines
        local _m1 is 0. // mass after the thrusting of engines

        local _SPS is ship:partstagged("CSM_SPS")[0].

        local _spsISP is _SPS:ISP.
        local _spsTHRUST is _SPS:possiblethrust.
        local _spsFLOW is _spsTHRUST/(_spsISP*constant:g0).

        set _m1 to (_m0*constant:e^((-1*_p30nodeInput:deltav:mag)/(_spsISP*constant:g0))).
        // this is the mass lost during the burn

        set _mDELTA to abs(_m0-_m1).

        local _bd is _mDELTA/_spsFLOW.
        local _iT is _GETN-(0.5*_bd).
        local _iUT is abs(_p30NodeInput:TIME-(0.5*_bd)).
        print "NT: " + (_p30NodeInput:TIME-_iUT).

        // ground time of ignition is: 
        print "BT "+  _bd.
        set _CORE_MEMORY:TIG to abs(_iT).
        set _CORE_MEMORY:TOC to _iT+_bd. // TIG+burn duration
        set _CORE_MEMORY:THETAD to _p30NodeInput:deltav.
        local _fpsX is _dv:X*3.28084.
        local _fpsY is _dv:Y*3.28084.
        local _fpsZ is _dv:Z*3.28084.
        set _CORE_MEMORY:DELVLVC to v(_fpsX, _fpsY, _fpsZ).
        set _CORE_MEMORY:VGDISP to _CORE_MEMORY:DELVLVC:MAG.
        local _dvtotal is VELOCITYAT(ship, _iUT):ORBIT:MAG+_p30NodeInput:deltav:mag.
        set _CORE_MEMORY:DVTOTAL to _dvtotal*3.28084.
        set _CORE_MEMORY:HAPO to _p30NodeInput:orbit:apoapsis*0.00054.
        set _CORE_MEMORY:HPER to _p30NodeInput:orbit:apoapsis*0.00054.
    }
    ADD_STEP("FLV06N33").
    ADD_STEP("FLV06N81").
    ADD_STEP("FLV16N45").
    ADD_STEP("P00").
}

LOCAL FUNCTION P30_VARUPDT {

}

LOCAL FUNCTION P30_DISPUPDT {

}