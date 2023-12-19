// P64 - Post 0.05g entry

// Activated automatically upon 0.05g deceleration is sensed

// P64 EXIT LOGIC: 

// IF VI < 27,000 fp/s  at 0.05g P67 will be selected at 0.2g
// ELSE, it is above 27,000fp/s at 0.05g

local _p64_exitCondition is "P67".

local _2700_05g is false.

FUNCTION P64_INIT {
    set _DSKYdisplayREG:PROG to "64".
    // initial setup of our exit condition
    set _UPDLOOP_POINTER_VAR to P64_VARUPDT@.
    IF ship:velocity:orbit:mag < 8229.6 {  // 27k ft
        // at 0.2g we shall go to P67
        set _p64_exitCondition to "P67".
        set _2700_05g to true.
    }

}

LOCAL FUNCTION P64_VARUPDT {
    P64_VARIABLES().
    IF _2700_05g and _CORE_MEMORY:D > 1.962 {
        // 0.2g - exit P64
        P64_EXIT().
    }
}

LOCAL FUNCTION P64_EXIT {
    print "P64 EXITING!".
    IF _2700_05g {
        _AGC_PROGRAMUPDATE("67").
    } ELSE {
        _AGC_PROGRAMUPDATE("67").
    }
}