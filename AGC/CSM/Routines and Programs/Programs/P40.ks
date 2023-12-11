// P40 - SPS thrusting program

local P40 is lexicon(
    "cc", 0,
    "ic", 0,
    "tf", 0,
    "VaE", 0,
    "V99", FALSE
).

local _doV99 is true. // set this to false to just do the manuver anyway
local _v99time is 5.
local _blankSTARTtime is 35.
local _blankENDtime is 30.
local _ignitionTIME is 0.
// set these at your own pleasure

// due to ksp being ksp i will add a value that isnt used in real life, to ensure i can update the delta v left

local _eVelocity is 0.

FUNCTION P40_INIT {
    set _DSKY_STATE:PRO to true.
    print "program 40".
    EXT_DSKY_PROG("40").
    set P40:ic to _CORE_MEMORY:TIG.
    set _UPDLOOP_POINTER_VAR to P40_VARUPT@.
    set _UPDLOOP_POINTER_DISP to P40_DISPUPDT@.
    // calculate the actual TIG for the burn

    local _tN is _CORE_MEMORY:TIG.
    local _nDV is _CORE_MEMORY:DELVLVC.
    set _eVelocity to _CORE_MEMORY:VTIG+_CORE_MEMORY:DELVLVC.
    print _eVelocity.

    local _ispSPS is 314. // this is the stock variant
    local _thrustSPS is 60. // again, stock
    local _flowSPS is _thrustSPS/(_ispSPS*constant:g0).
    local _m0 is mass.
    local _m1 is _m0/(constant:e^(_nDV:mag/(constant:g0*_ispSPS))).

    local _bt is abs(_m0-_m1)/_flowSPS.

    set _CORE_MEMORY:TIG to _CORE_MEMORY:TIG-(0.5*_bt).
    
    // set the TTOGO triggers

    when _CORE_MEMORY:ttogo < 35 then {
        // blank screen
        set _DSKY_STATE:INHB:BLANK_REGISTERS to true.
    }
    when _CORE_MEMORY:ttogo < 30 then {
        set _DSKY_STATE:INHB:BLANK_REGISTERS to false.
    }
    // v99
    IF _doV99 {
        when _CORE_MEMORY:ttogo < 5 then {
            EXT_DSKY_GCDISPLAYREQ("FLV99N40").
        }
    } ELSE {
        when _CORE_MEMORY:ttogo < 5 then {
            set _AGC:PERMIT:ENGINE to true.
        }
    }

    // call automanuver func
    R60_INIT().
    ADD_STEP("V06N40").
    ADD_STEP("TERM").

}

LOCAL FUNCTION P40_VARUPT {
    
    IF _CORE_MEMORY:TIME2 > _CORE_MEMORY:TIG {
        IF _AGC:PERMIT:ENGINE {
            clearscreen.
            local _currentVEL is _CORE_MEMORY:V. // velocity state vector
            print "v " + _CORE_MEMORY:V:MAG.
            print "v t " + _eVelocity:mag.
            print "DVTOTAL " + _CORE_MEMORY:DVTOTAL.
            print "VGDISP " + _CORE_MEMORY:VGDISP.
            set _CORE_MEMORY:VGDISP to _CORE_MEMORY:DVTOTAL-_CORE_MEMORY:V:MAG.
            IF throttle = 1 and abs(_CORE_MEMORY:VGDISP) > 10 {
                // update VGDISP
                
                 // as a magnitude this is 
            } ELSE IF abs(_CORE_MEMORY:V:MAG-_CORE_MEMORY:DVTOTAL) < 10 {
                // cutoff engines
                lock throttle to 0.
            } ELSE {
                lock throttle to 1.
            }
        }
    }

    
}

LOCAL FUNCTION P40_DISPUPDT {
    EXT_DSKY_GCDISPLAYREQ("FLV06N40", true).
}