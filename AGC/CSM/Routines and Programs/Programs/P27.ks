// uplink data program

// processes commands and data insertions (this is important here for this implimentation of the agc) into memory

// what are we? CSM or LM

local _testing is false.

FUNCTION P27_INIT {
    set _DSKY_STATE:PRO to true.
    // all programs should do this

    IF hasnode {
        // input the two needed variables from the node into memory
        // time of the node (TIG) - well not actually but ok lol
        // the impulsive delta v at tig
        // then we can remove the node because we dont need it anymore

        local _nd is nextNode.

        // because of the unit conversion feature all we need to do is just input the TIG and run with it

        local _tig is _nd:time-_CORE_MEMORY:TIME0.
        local _dv is _nd:deltav.
        local _v0 is velocityAt(ship, _nd:time-1):orbit.
        local _v1 is velocityAt(ship, _nd:time):orbit.
        local _vD is _dv.
        set _CORE_MEMORY:TIG to _tig.
        set _CORE_MEMORY:DELVLVC to _dv.
        // thats all that is needed now in the newer versions
        IF NOT(_testing) { remove nextNode. }
        // dont remove the node during testing - makes stuff easier
        print "Time of ignition".
        print timespan(_CORE_MEMORY:TIG):hour + " Hours".
        print timespan(_CORE_MEMORY:TIG):minute + " Minutes".
        print timespan(_CORE_MEMORY:TIG):second + " Seconds".
        print "delta v: " + _CORE_MEMORY:DELVLVC:mag.
    }
}