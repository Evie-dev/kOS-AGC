// Development of the orbit functions for the common.ks file

// thanks to https://orbital-mechanics.space/ for showing code that i could learn this content from as i learn easier when there is code being shown

// deals with the state vector

FUNCTION stateVectorIntegration {
    parameter stateP is ship:body:position, stateV is ship:velocity:orbit.
    local r_vec is stateP.
    local v_vec is stateV.

    local _mu is ship:body:mu.
    local _rad is ship:body:radius.

    local _r is r_vec:mag.
    local _v is v_vec:mag.

    local v_r is VDOT(r_vec/_r, v_vec).
    local v_p is sqrt(_v^2-v_r^2).


    // h 

    local h_vec is vcrs(r_vec, v_vec).

    local _h is h_vec:mag.

    local _i is arcCos(h_vec:y/_h).
    local _K is v(0,0,1).
    local N_vec is vCrs(_K, h_vec).
    local _N is N_vec:mag.
    local _Omega is 2*constant:pi-arcCos(N_vec:x/_N).

    local e_vec is vCrs(v_vec, h_vec) / _mu - r_vec / _r.
    local _e is e_vec:mag.

    local __omega is 2*constant:pi - arcCos(vdot(N_vec, e_vec)/(_N*_e)).

    local nu is arcCos(vdot(r_vec/r, e_vec/_e)).

    local rP is (_h^2/_mu)-(1/1+_e).
    local rA is (_h^2/_mu)-(1/1-_e). // these should be the radius i think
    local _a is (rP+rA)/2.
    return lexicon(
        "Apoapsis", lexicon("r", rA, "a", rA-_rad),
        "Periapsis", lexicon("r", rP, "a", rP-_rad),
        "Altitude", lexicon("r", _r, "a", _r-_rad),
        "Semimajoraxis", _a,
        "Inclination", _i,
        "Eccentricity", _e,
        "TrueAnomaly", nu
    ).
    
}

