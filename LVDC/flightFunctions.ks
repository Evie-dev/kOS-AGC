// A library containing functions for the flight of the saturn V/Saturn IB

// First off we shall cover the prelaunch - in real life this was done by the ground

// Flight functions are not for setting trajectory

FUNCTION LUT_swingArms {
    parameter armNumber is 1, armAction is "retract".

    local _armName is "ServiceArm_" + armNumber:tostring.
    local _action is armAction + " Arm".

    doPartEvent(_armName, _action).
}

FUNCTION LUT_TSM {

}