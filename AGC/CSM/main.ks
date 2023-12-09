// kOS config

set CONFIG:CLOBBERBUILTINS to true.

GLOBAL _AGC_DEBUG_INFO IS LEXICON(
    "Programs Loaded", LIST(),
    "Routines Loaded", LIST()
).

GLOBAL _AGC IS LEXICON(
    "doingRoutine", false
).

global _AGC_INPUTQUEUE IS LIST().

LOCAL FUNCTION P___UPDVAR {

}

LOCAL FUNCTION P___UPDISP {

}

LOCAL FUNCTION R___FINISH {
    
}

GLOBAL _UPDLOOP_POINTER_VAR is P___UPDVAR@.
GLOBAL _UPDLOOP_POINTER_DISP is P___UPDISP@.

GLOBAL routine_END is R___FINISH@.

LOCAL ROUTINE_INDEXER IS 0.

_AGC_INIT().
_AGC_MAINLOOP().

FUNCTION _AGC_INIT {
    // main function for the CSM side of the AGC

    // Initilize the memory state first

    // initilizes the AGC

    runOncePath("0:/AGC/CSM/Memory/displayAddressing.ks").
    runOncePath("0:/AGC/CSM/Memory/Memory.ks").

    runOncePath("0:/AGC/DSKY.ks").

    // after the DSKY is initilized, load programs

    runOncePath("0:/AGC/CSM/Routines and Programs/programs.ks").
    runOncePath("0:/AGC/CSM/Routines and Programs/routines.ks").
    runOncePath("0:/AGC/CSM/Routines and Programs/extendedVerbs.ks").

    // load the common functions

    runOncePath("0:/Common/common.ks").

    set _CORE_MEMORY:TIME0 TO TIME:SECONDS.
}

FUNCTION _AGC_MAINLOOP {
    UNTIL FALSE {
        // do ?stuff?
        _AGC_MAIN_UPDATE().
        _UPDLOOP_POINTER_VAR:call.
        _UPDLOOP_POINTER_DISP:call.
        

        wait 0.
    }
}



FUNCTION _AGC_MAIN_UPDATE {
    // update time variables
    _AGC_UPDATER_CLOCK().
    // Check for new routines
    IF _AGC_INPUTQUEUE:length-1 >= ROUTINE_INDEXER AND _DSKY_STATE:PRO {
        
        set _DSKY_STATE:PRO to false. // ensure it is false
        set _DSKY_STATE:NEEDS_INPUT TO FALSE.
        local _request is _AGC_INPUTQUEUE[ROUTINE_INDEXER].
        print _request.
        IF _request:startswith("P") {
            // program request

            local _rqstProgram is _request[1].
            set _rqstProgram to _rqstProgram+_request[2].
            _AGC_PROGRAMUPDATE(_rqstProgram).
        } ELSE IF _request:startswith("R") {
            // routine request
            local _rqstRoutine is _request[1].
            set _rqstRoutine to _rqstRoutine+_request[3].
            set _DSKY_STATE:PRO to true.
            set _AGC:DoingRoutine to true.
            _AGC_ROUTINEUPDATE(_rqstRoutine).
        } ELSE IF _request:contains("V") and _request:contains("N") { // V37N00 format
            IF _request:startswith("FL") {
                // FLASHING
                set _DSKY_STATE:NEEDS_INPUT TO TRUE.
                set _request to _request:remove(0,2).
            }
            local _rqstVerb is 0.
            local _rqstNoun is 0.
            // Indexes 2 and 2 contain the V erb
            // Indexes 4 and 5 contain the N oun

            set _rqstVerb to _request[1].
            set _rqstVerb to _rqstVerb+_request[2].

            set _rqstNoun to _request[4].
            set _rqstNoun to _rqstNoun+_request[5].
            
            local _rqst is "V" + _rqstVerb + "N" + _rqstNoun.
            set _DSKY_STATE:PRO to true.
            EXT_DSKY_GCDISPLAYREQ(_request).
        } ELSE IF _request:startswith("V") {
            local _rqstVerb is 0.
            // Indexes 2 and 2 contain the V erb
            // Indexes 4 and 5 contain the N oun

            set _rqstVerb to _request[1].
            set _rqstVerb to _rqstVerb+_request[2].
            local _rqst is "V" + _rqstVerb + "N00".
            EXT_DSKY_GCDISPLAYREQ(_rqst).
        } 
        ELSE IF _request = "TERM" {
            routine_END:call.
            set _DSKY_STATE:PRO to true.
            set _AGC:DoingRoutine to false.
            // reset 
            // clear the registers 

            EXT_DSKY_GCDISPLAYREQ("V00N00").

            // TODO: redisplay behaviour


            
        }
    }
    IF _DSKY_STATE:PRO {
        // routine has ended

        // do the finish routine function

        set ROUTINE_INDEXER TO MAX(MIN(ROUTINE_INDEXER+1, _AGC_INPUTQUEUE:LENGTH), 0).
        set _DSKY_STATE:PRO TO FALSE.

        IF _AGC_INPUTQUEUE:LENGTH = ROUTINE_INDEXER {
            print "no new routine!".
            // clear the input queue to save on ram
            _AGC_INPUTQUEUE:CLEAR.
            set ROUTINE_INDEXER to 0.
            set routine_END to R___FINISH@.

        }

        // reset the PROCEDE FLAG
    }

    // update DSKY

    DSKY_UPDATE_CYCLE().
    
}

LOCAL FUNCTION _AGC_UPDATER_CLOCK {
    local _t1 is TIMESPAN(TIME:SECONDS- _CORE_MEMORY:TIME0).
    set _CORE_MEMORY:TIME2H TO ABS(FLOOR(_t1:hours)).
    set _CORE_MEMORY:TIME2M TO ABS((60*_CORE_MEMORY:TIME2H)-FLOOR(_t1:minutes)).
    set _CORE_MEMORY:TIME2S TO ABS(((3600*_CORE_MEMORY:TIME2H)+(60*_CORE_MEMORY:TIME2M))-_t1:seconds).
}

LOCAL FUNCTION _AGC_UPDATER_SERVICER {
    
}

// null program subloop funcs

LOCAL FUNCTION _AGC_ROUTINE_UPDATE {

}

LOCAL FUNCTION _AGC_SERVICER_UPDATE {

}

FUNCTION ADD_STEP {
    parameter stepName is "".
    print "added step: " + stepName.
    print _AGC_INPUTQUEUE:LENGTH.
    _AGC_INPUTQUEUE:add(stepName).
}