// P40 - SPS thrusting program

local P40 is lexicon(
    "cc", 0,
    "ic", 0,
    "tf", 0,
    "VaE", 0,
    "V99", FALSE
).

local _R60procount is 0.
local _doV99 is true. // set this to false to just do the manuver anyway
local _v99time is 5.
local _blankSTARTtime is 35.
local _blankENDtime is 30.
local _ignitionTIME is 0.
// set these at your own pleasure

// due to ksp being ksp i will add a value that isnt used in real life, to ensure i can update the delta v left

local _eVelocity is 0.

// information to be taken when V99 is done
local _v99 is false.
local _v99PRO is -1.
local _cutoffMargin is 3. // 3m/s

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
    print _CORE_MEMORY:VTIG.
    print _CORE_MEMORY:DELVLVC.
    
    print _eVelocity.
    print _CORE_MEMORY:DVTOTAL.
    local _ispSPS is 314. // this is the stock variant
    local _thrustSPS is 60. // again, stock
    local _flowSPS is _thrustSPS/(_ispSPS*constant:g0).
    local _m0 is mass.
    local _m1 is _m0/(constant:e^(_nDV:mag/(constant:g0*_ispSPS))).

    local _bt is abs(_m0-_m1)/_flowSPS.

    set _CORE_MEMORY:TIG to _CORE_MEMORY:TIG-(0.5*_bt).

    // calculate the correct steering angle

    set _CORE_MEMORY:THETAD to _CORE_MEMORY:DELVLVC.
    
    // set the TTOGO triggers

    when _CORE_MEMORY:ttogo < 35 then {
        // blank screen
        IF _DSKYdisplayREG:PROG = "40" {
            set _DSKY_STATE:INHB:BLANK_REGISTERS to true.
        }   
        
    }
    when _CORE_MEMORY:ttogo < 30 then {
        set _DSKY_STATE:INHB:BLANK_REGISTERS to false.
    }
    // v99
    IF _doV99 {
        when _CORE_MEMORY:ttogo < _v99time then {
            set _v99PRO to _DSKY_STATE:INPUTS:PRO.
            IF _DSKYdisplayREG:PROG = "40" { EXT_DSKY_GCDISPLAYREQ("FLV99N40"). }
        }
    } ELSE {
        when _CORE_MEMORY:ttogo < 5 then {
            IF _DSKYdisplayREG:PROG = "40" { set _AGC:PERMIT:ENGINE to true. }
        }
    }
    set _R60procount to _DSKY_STATE:INPUTS:PRO+3.

    // call automanuver func
    R60_INIT().
    when _DSKY_STATE:INPUTS:PRO = _R60procount then {
        ADD_STEP("V06N40").
        ADD_STEP("TERM").
    }
    

}

LOCAL FUNCTION P40_VARUPT {
    local _currentVEL is _CORE_MEMORY:V. // velocity state vector
    IF _CORE_MEMORY:TIME2 > _CORE_MEMORY:TIG {
        IF _AGC:PERMIT:ENGINE {
            clearscreen.
            
            print "v " + _CORE_MEMORY:V:MAG.
            print "v t " + _eVelocity:mag.
            print "DVTOTAL " + _CORE_MEMORY:DVTOTAL.
            print "VGDISP " + _CORE_MEMORY:VGDISP.
            set _CORE_MEMORY:VGDISP to _CORE_MEMORY:DVTOTAL-_CORE_MEMORY:V:MAG.
            IF throttle = 1 and abs(_CORE_MEMORY:VGDISP) > _cutoffMargin {
                // update VGDISP
                
                 // as a magnitude this is 
            } ELSE IF abs(_CORE_MEMORY:V:MAG-_CORE_MEMORY:DVTOTAL) < _cutoffMargin {
                // cutoff engines
                lock throttle to 0.
                // add p00 step
                add_step("P00").
            } ELSE {
                lock throttle to 1.
            }
        }
    }
    IF _AGC:PERMIT:AUTOMNV {
        // calculate P40 steering angle

        set _CORE_MEMORY:THETAD TO _CORE_MEMORY:DELVLVC.
    } 
    
}

LOCAL FUNCTION P40_DISPUPDT {
    IF _DSKY_STATE:INPUTS:PRO >= _R60procount and _DSKY_STATE:INPUTS:PRO >= _v99PRO+1 {
        EXT_DSKY_GCDISPLAYREQ("FLV06N40", true).
    }

    
}