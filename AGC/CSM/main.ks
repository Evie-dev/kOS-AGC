// kOS config

GLOBAL _AGC_DEBUG_INFO IS LEXICON(
    "Programs Loaded", LIST(),
    "Routines Loaded", LIST()
).

GLOBAL _AGC IS LEXICON(
    "doingRoutine", false,
    "currentRoutineStep", "V00N00",
    "FLAG_PRO", FALSE,
    "STEER_VEC", ship:facing:vector,
    "PERMIT", LEXICON(
        "DAP", FALSE,
        "AUTOMNV", FALSE,
        "ENGINE", FALSE
    )
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
// set routine_END to R___FINISH@.
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
    runOncePath("0:/Common/unitConversion.ks").

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
    _AGC_UPDATE_STATE_VECTOR(). // updates the state vector of the spacecraft
    // Check for new routines
    IF _AGC_INPUTQUEUE:length-1 >= ROUTINE_INDEXER AND _DSKY_STATE:PRO {
        
        set _DSKY_STATE:PRO to false. // ensure it is false
        set _DSKY_STATE:NEEDS_INPUT TO FALSE.
        local _request is _AGC_INPUTQUEUE[ROUTINE_INDEXER].
        set _AGC:currentRoutineStep to _request.
        local _procededVERB is _DSKYdisplayREG:VERB.
        local _procededNOUN is _DSKYdisplayREG:NOUN.

        IF _procededVERB = "99" {
            // set engine to ENABLE
            set _AGC:PERMIT:ENGINE to true.
        } ELSE IF _procededVERB = "50" {
            // please perform (something)
            IF _procededNOUN = "18" {
                // enable automanuver
                set _AGC:PERMIT:AUTOMNV to true.
            }
        }

        IF _request:startswith("P") {
            // program request

            local _rqstProgram is _request[1].
            set _rqstProgram to _rqstProgram+_request[2].
            _AGC_PROGRAMUPDATE(_rqstProgram).
        } ELSE IF _request:startswith("R") {
            // routine request
            local _rqstRoutine is _request.
            set _DSKY_STATE:PRO to true.
            set _AGC:DoingRoutine to true.
            print "routine request: " + _rqstRoutine.
            _AGC_ROUTINEUPDATE(_rqstRoutine).
        } ELSE IF _request:contains("V") and _request:contains("N") { // V37N00 format
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
            EXT_DSKY_GCDISPLAYREQ(_request, true).
        } ELSE IF _request:startswith("V") {
            local _rqstVerb is 0.
            // Indexes 2 and 2 contain the V erb
            // Indexes 4 and 5 contain the N oun

            set _rqstVerb to _request[1].
            set _rqstVerb to _rqstVerb+_request[2].
            local _rqst is "V" + _rqstVerb + "N00".
            EXT_DSKY_GCDISPLAYREQ(_rqst,true).
        } 
        ELSE IF _request = "TERM" {
            routine_END:call.
            set _DSKY_STATE:PRO to true.
            set _AGC:DoingRoutine to false.
            // reset 
            // clear the registers 

            

            // TODO: redisplay behaviour


            
        }
    }
    IF _DSKY_STATE:PRO {
        // routine has ended

        // do the finish routine function

        set ROUTINE_INDEXER TO MAX(MIN(ROUTINE_INDEXER+1, _AGC_INPUTQUEUE:LENGTH), 0).
        set _DSKY_STATE:PRO TO FALSE.

        IF _AGC_INPUTQUEUE:LENGTH = ROUTINE_INDEXER {
            // clear the input queue to save on ram
            _AGC_INPUTQUEUE:CLEAR.
            set ROUTINE_INDEXER to 0.
            EXT_DSKY_GCDISPLAYREQ("V00N00",true).
            set routine_END to R___FINISH@.

        }

        // are we currently awaiting a request for an automanuver?
        IF _DSKYdisplayREG:VERB = "99" {
            set _AGC:PERMIT:ENGINE to TRUE.
            set _DSKY_STATE:FLASH:V to FALSE.
            set _DSKY_STATE:FLASH:N to FALSE.
            set _DSKYdisplayREG:VERB to _DSKYdisplayREG:LAST_VERB.
        }

        // reset the PROCEDE FLAG
    }

    // update DSKY

    DSKY_UPDATE_CYCLE().
    
}

LOCAL FUNCTION _AGC_UPDATE_STATE_VECTOR {
    set _CORE_MEMORY:V to ship:velocity:orbit.
    set _CORE_MEMORY:R to ship:body:position.
}

LOCAL FUNCTION _AGC_UPDATER_CLOCK {
    local _t1 is TIMESPAN(TIME:SECONDS- _CORE_MEMORY:TIME0).
    set _CORE_MEMORY:TIME2 to _t1.
    // setup variable clock functions
    local _tig is _CORE_MEMORY:TIG.
    local _t2 is _CORE_MEMORY:TIME2.
    IF _tig:istype("timespan") { set _tig to _tig:seconds. }
    IF _t2:istype("timespan") { set _t2 to _t2:seconds.}
    local ttogo is abs(_tig-_t1:seconds).
    set _CORE_MEMORY:TTOGO to TIMESPAN(ttogo).
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
    _AGC_INPUTQUEUE:add(stepName).
}

FUNCTION INSERT_STEP {
    parameter stepName is "", stepsFromNow is 0.
    local _currentIndex is ROUTINE_INDEXER.
    set stepsFromNow to stepsFromNow+1.
    print "step inserted".
    _AGC_INPUTQUEUE:insert(min(_currentIndex+stepsFromNow, _AGC_INPUTQUEUE:LENGTH-1), stepName).
}

FUNCTION _DAP_GETVECHMASS {
    local _rMass is 0.

    IF _CORE_MEMORY:DAPDATR1:startswith("1") {
        // CSM ONLY
        set _rMass to _CORE_MEMORY:CSMMAS.
    } ELSE IF _CORE_MEMORY:DAPDATR1:startswith("2") {
        set _rMass to _CORE_MEMORY:CSMMAS.
        set _rMass to _rMass+_CORE_MEMORY:LEMMAS.
    }

    set _rMass to _rMass*0.453592.
}