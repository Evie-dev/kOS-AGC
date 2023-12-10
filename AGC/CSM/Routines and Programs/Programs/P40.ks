// P40 - SPS thrusting program

local P40 is lexicon(
    "cc", 0,
    "ic", 0,
    "tf", 0,
    "VaE", 0,
    "V99", FALSE
).

FUNCTION P40_INIT {
    set _DSKY_STATE:PRO to true.
    print "program 40".
    EXT_DSKY_PROG("40").
    set P40:ic to _CORE_MEMORY:TIG.
    set _UPDLOOP_POINTER_VAR to P40_VARUPT@.
    set _UPDLOOP_POINTER_DISP to P40_DISPUPDT@.

    // call automanuver func
    R60_INIT().
    ADD_STEP("V06N40").
    ADD_STEP("TERM").

}

LOCAL FUNCTION P40_VARUPT {
    set P40:cc to _CORE_MEMORY:TIME2.
    local _p40tf is P40:ic-P40:cc.
    IF _p40tf:istype("timespan") { set P40:tf to abs(_p40tf:seconds). }
    ELSE { set P40:tf to _p40tf. }

    IF _CORE_MEMORY:TIME2:SECONDS > _CORE_MEMORY:TIG {
        IF _AGC:PERMIT:ENGINE {
            IF throttle = 1 and _CORE_MEMORY:TIME2:SECONDS > _CORE_MEMORY:TOC {
                lock throttle to 0.
            } ELSE IF NOT(throttle = 1) {
                lock throttle to 1.
            }
            
        }
    }

    // update orbit parameters


    
}

LOCAL FUNCTION P40_DISPUPDT {
    IF ((P40:tf < 35 and P40:tf >30) and NOT(_DSKY_STATE:INHB:BLANK_REGISTERS)) and throttle = 0 {
        set _DSKY_STATE:INHB:BLANK_REGISTERS to true.
    } ELSE IF (_DSKY_STATE:INHB:BLANK_REGISTERS and P40:tf < 30) and throttle = 0 {
        set _DSKY_STATE:INHB:BLANK_REGISTERS to false.
    } 
    ELSE IF P40:tf < 5 and NOT(P40:V99) {
        set P40:V99 to true.
        EXT_DSKY_GCDISPLAYREQ("V99", true). // force V99
        ADD_STEP("V06N40").
        ADD_STEP("TERM").
    } ELSE IF _DSKY_STATE:INHB:INP = "V06N40" {
        // update the display
        EXT_DSKY_GCDISPLAYREQ("V06N40").
    }
}