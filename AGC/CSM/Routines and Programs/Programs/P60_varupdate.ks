// this file contains functions relating to P61-P67 as variables displayed in the nouns updated during these programs can overlap values, therefore we should just update them in a single file

// In order to ensure accesability is easier, all variables will have PUBLIC facing FUNCTIONS for each PROGRAM i.e P63_VARIABLES ect ect
// we assume that P61 has its first run in earth/kerbin soi

local _ei_altitude is 121920.
local _05g_altitude is 90656.

local _p61_firstrun is true.

FUNCTION P61_VARIABLES {
    IF _p61_firstrun {
        set _ei_altitude to _ei_altitude+body:radius.
        set _05g_altitude to _05g_altitude+body:radius.
        Predict_TFE().
        Predict_VIO().
        set _p61_firstrun to false.
    }
    update_impact().

    update_gmax(). // N61
    update_vpred(). // N61
    update_gammaei(). // N61

    Update_RTOGO(). // N63
    Update_VIO(). // N63
    update_TFE(). // N63
}

FUNCTION P62_VARIABLES {
    update_impact().
    update_GimbalAngles().
}

FUNCTION P63_VARIABLES {
    update_DragAccel().
    update_inertialVelocity().
    Update_RTOGO_N64().

    Update_ROLLC().
    update_AltitudeRate().

    Update_RTOGO(). // N63
    Update_VIO(). // N63
    update_TFE(). // N63


    update_GimbalAngles().
    update_Attitude().
    
}


// P64 implimentation skipped for now
FUNCTION P64_VARIABLES {
    update_impact().
    update_DragAccel().
    update_inertialVelocity().
    Update_RTOGO_N64().

    Update_ROLLC().
    update_AltitudeRate().

    Update_RTOGO(). // N63
    Update_VIO(). // N63
    update_TFE(). // N63


    update_GimbalAngles().
    update_Attitude().
}

FUNCTION P65_VARIABLES {

}

FUNCTION P66_VARIABLES {

}

FUNCTION P67_VARIABLES {
    update_DragAccel().
    update_inertialVelocity().
    Update_RTOGO_N64().

    Update_ROLLC().
    IF altitude > 19800 or airspeed > 300 { update_AltitudeRate(). }
}


// here we have the PRIVATE update variables


// Impact Latitude/Impact Longitude

LOCAL FUNCTION update_impact {
    IF addons:tr:available {
        if addons:tr:hasimpact {
            set _CORE_MEMORY:LATLNGSPL to LATLNG(addons:tr:impactpos:lat, addons:tr:impactpos:lng).
        }
    }
}

LOCAL FUNCTION update_gmax {
    set _CORE_MEMORY:GMAX to 0.
}

LOCAL FUNCTION update_vpred {
    // update altitude from 400k
    local _etaEI is timetoradius(_ei_altitude):DESCENDING.
    local EIta is alt_to_ta(ship:orbit:semimajoraxis, ship:orbit:eccentricity, body, 121920)[1].
    local _etaEI2 is time_betwene_two_ta(ship:orbit:eccentricity, ship:orbit:period, ship:orbit:trueanomaly, EIta).
    print "EI eta: " + _etaEI.
    set _CORE_MEMORY:VPRED to velocityAt(ship, time:seconds+_etaEI2):orbit:mag.
}

LOCAL FUNCTION update_gammaei {
    set _CORE_MEMORY:GAMMAEI to 0.
}

LOCAL FUNCTION update_GimbalAngles {
    set _CORE_MEMORY:CDUX to (SHIP:srfretrograde+R( 0,_CORE_MEMORY:HEADSUP*-20, MAX(0, _CORE_MEMORY:HEADSUP)+1*180)).
}

LOCAL FUNCTION update_Attitude {
    set _CORE_MEMORY:THETAD to _CORE_MEMORY:CDUX.
}

LOCAL FUNCTION update_DragAccel {
    
    IF kuniverse:timewarp:rate = 0 { set _CORE_MEMORY:D to (ship:SENSORS:ACC-ship:sensors:grav):mag. }
}

LOCAL FUNCTION update_inertialVelocity {
    set _CORE_MEMORY:VMAGI to _CORE_MEMORY:V:mag.
}


LOCAL FUNCTION Update_splashRange {

}

LOCAL FUNCTION Update_ROLLC {

}

LOCAL FUNCTION update_AltitudeRate {
    set _CORE_MEMORY:RDOT to ship:verticalspeed.
}




// in N63 there are two possible intepretations
// RTGO is the delta between current R and R of 0.05g altitude
// TTGO is the range from 0.05g altitude to the splash altitude
// Id say both are correct
// however i will go for the first one as RTOGON64 is range to splash

LOCAL FUNCTION Update_RTOGO {
    set _CORE_MEMORY:RTGO to (altitude+body:radius)-_05g_altitude.
}

LOCAL FUNCTION Predict_TFE {
    // first run variable
    local EIta is alt_to_ta(ship:orbit:semimajoraxis, ship:orbit:eccentricity, body, 90656)[1].
    local _etaEI2 is time_betwene_two_ta(ship:orbit:eccentricity, ship:orbit:period, ship:orbit:trueanomaly, EIta).
    set _CORE_MEMORY:TFE to _CORE_MEMORY:TIME2+_etaEI2.
}

LOCAL FUNCTION Update_TFE {
    set _CORE_MEMORY:TTE to _CORE_MEMORY:TIME2-_CORE_MEMORY:TFE.
}

LOCAL FUNCTION Predict_VIO {
    local EIta is alt_to_ta(ship:orbit:semimajoraxis, ship:orbit:eccentricity, body, 90656)[1].
    local _etaEI2 is time_betwene_two_ta(ship:orbit:eccentricity, ship:orbit:period, ship:orbit:trueanomaly, EIta).
    set _CORE_MEMORY:VIO to velocityAt(ship, time:seconds+_etaEI2):orbit:mag.
}

LOCAL FUNCTION Update_VIO {
    // honestly, dont do this lmao
}

LOCAL FUNCTION Update_RTOGO_N64 {
    // range to splash

    set _CORE_MEMORY:RTGON64 to _CORE_MEMORY:LATLNGSPL:distance.
}


// for testing only

FUNCTION alt_to_ta {//returns a list of the true anomalies of the 2 points where the craft's orbit passes the given altitude
	PARAMETER sma,ecc,bodyIn,altIn.
	LOCAL rad IS altIn + bodyIn:RADIUS.
	LOCAL taOfAlt IS ARCCOS((-sma * ecc^2 + sma - rad) / (ecc * rad)).
	RETURN LIST(taOfAlt,360-taOfAlt).//first true anomaly will be as orbit goes from PE to AP
}

FUNCTION time_betwene_two_ta {//returns the difference in time between 2 true anomalies, traveling from taDeg1 to taDeg2
	PARAMETER ecc,periodIn,taDeg1,taDeg2.
	
	LOCAL maDeg1 IS ta_to_ma(ecc,taDeg1).
	LOCAL maDeg2 IS ta_to_ma(ecc,taDeg2).
	
	LOCAL timeDiff IS periodIn * ((maDeg2 - maDeg1) / 360).
	
	RETURN MOD(timeDiff + periodIn, periodIn).
}

FUNCTION ta_to_ma {//converts a true anomaly(degrees) to the mean anomaly (degrees) NOTE: only works for non hyperbolic orbits
	PARAMETER ecc,taDeg.
	LOCAL eaDeg IS ARCTAN2(SQRT(1-ecc^2) * SIN(taDeg), ecc + COS(taDeg)).
	LOCAL maDeg IS eaDeg - (ecc * SIN(eaDeg) * CONSTANT:RADtoDEG).
	RETURN MOD(maDeg + 360,360).
}