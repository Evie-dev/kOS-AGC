// P67 - Final phase of entry - runs till aproximately 10k, while setting up triggers for the deployment of the parachutes


FUNCTION P67_INIT {
    set _DSKYdisplayREG:PROG to "67".
    // triggers for parachute deployments: 
    set _UPDLOOP_POINTER_VAR to P67_VARUPDT@.
    when altitude < 8000 then {
        doPartEvent("CM_COVER", "Decouple").
    }

    when altitude < 7500 then {
        doPartEvent("CM_DROUGE", "Deploy Chute").
    }
    when altitude < 5500 then {
        doPartEvent("CM_MAIN", "Deploy Chute").
        doPartEvent("CM_DROUGE", "Cut Chute").
    }
}

LOCAL FUNCTION P67_VARUPDT {
    P67_VARIABLES().
}