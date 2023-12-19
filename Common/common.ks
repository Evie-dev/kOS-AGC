FUNCTION addToList {
    parameter list1 is list(), list2 is list().
    local returnList is list().
    IF NOT(list1:istype("List")) { returnList:add(list1). }
    ELSE { set returnList to list1. }
    IF NOT(list2:istype("List")) {
        returnList:add(list2).
    } ELSE { for i in list2 { returnList:add(i). }}
    return returnList.
}

FUNCTION removeFromList {
    parameter listItem is list(), itemsToRemove is list().
    local returnList is list().
    FOR i in listItem {
        IF NOT(itemsToRemove:contains(i)) { returnList:add(i). }
    }
    return returnList.
}

FUNCTION compareList {
    parameter listtoCheck is list(), checkAgainst is list(), excludeFromCheck is list().

    local returnData is lexicon(
        "isEqual", true,
        "NumberofDifferences", 0,
        "differences", list()
    ).

    local longestList is list().
    local shortestList is list().
    local excludeList is list().

    IF listtoCheck:length < checkAgainst:length {
        set longestList to checkAgainst.
        set shortestList to listtoCheck.
    } ELSE {
        set longestList to listtoCheck.
        set shortestList to checkAgainst.
    }
    set excludeList to excludeFromCheck.

    FOR i in longestList {
        IF NOT(exclusionList:contains(i)) {
            IF NOT(shortestList:contains(i)) {
                set returnData:isEqual to false.
                set returnData:NumberofDifferences to returnData:NumberofDifferences+1.
                returnData:differences:add(i).
            }
        }
    }

    return returnData.

}



// functions relating to parts and part actions

function getParts {
    parameter forParts is list(), returnSingle is false.
    // accepts a list, part or string
    local returnList is list().
    IF forParts:istype("List") {
        FOR i in forParts {
            set returnlist to addToList(returnList, getParts(i)).
        }
    } ELSE IF forParts:istype("String") {
        set returnList to ship:partstagged(forParts).
    } ELSE IF forParts:istype("Part") {
        returnList:add(forParts).
    }
    IF returnSingle AND NOT(returnList:empty) {
        set returnList to returnList[0].
    }
    return returnList.
}

FUNCTION isPart {
    parameter ofPart is false.
    return ofPart:istype("Part").
}

// has action ect


// partHasEvent 
FUNCTION partHasEvent {
    parameter forPart is false, eventName is "", byIndex is false.
    IF NOT(isPart(forPart)) OR NOT(eventName:istype("String")) { return false. }
    ELSE {
        local doByIndex is false.
        IF byIndex:istype("Boolean") {
            set doByIndex to byIndex.
        } ELSE IF byIndex:istype("Scalar") {
            set doByIndex to byIndex = min(forPart:allmodules:length-1, max(-1, byIndex)).
        }
        IF doByIndex {
            local mIndex is 0.
            IF byIndex:istype("Scalar") {
                set mIndex to byIndex.
                IF forPart:getmodulebyindex(mIndex):hasevent(eventName) { return true. }
            } ELSE {
                FOR i in forPart:modules {
                    IF forPart:getmodulebyindex(mIndex):hasevent(eventName) { return true. }
                    set mIndex to mIndex+1.
                }
            }
            
        } ELSE {
            FOR i in forPart:modules {
                IF forPart:getmodule(i):hasevent(eventName) { return true. }
            }
        }
    }
    return false.
}

FUNCTION partHasAction {
    parameter forpart is false, actionName is list().
    IF NOT(isPart(forPart)) OR NOT(actionName:istype("String")) { return false. }
    ELSE {
        FOR i in forPart:modules {
            IF forPart:getmodule(i):hasaction(actionName) { return true. }
        }
    }
    return false.
}

FUNCTION partHasField {
    parameter forPart is false, fieldName is list().
    IF NOT(isPart(forPart)) OR NOT(fieldName:istype("String")) { return false. }
    ELSE {
        FOR i in forPart:modules {
            IF forPart:getmodule(i):hasfield(fieldName) { return true. }
        }
    }
    return false.
}

// read part field value
// example reading the thrust limiter value

FUNCTION getPartField {
    parameter forPart is false, fieldName is"", byIndex is false.
    local returnValue is "".
    IF NOT(isPart(forPart)) OR NOT(fieldName:istype("String")) { return false. }
    ELSE {
        local doByIndex is false.
        IF byIndex:istype("Boolean") {
            set doByIndex to byIndex.
        } ELSE IF byIndex:istype("Scalar") {
            set doByIndex to byIndex = min(forPart:allmodules:length-1, max(-1, byIndex)).
        }
        IF doByIndex {
            local mIndex is 0.
            IF byIndex:istype("Scalar") {
                set mIndex to byIndex.
                IF forPart:getmodulebyindex(mIndex):hasfield(fieldName) { set returnValue to forPart:getmodulebyindex(mIndex):getfield(fieldName). }
            } ELSE {
                FOR i in forPart:modules {
                    IF forPart:getmodulebyindex(mIndex):hasfield(fieldName) { 
                        set returnValue to forPart:getmodulebyindex(mIndex):getfield(fieldName).
                        break.
                    }
                    set mIndex to mIndex+1.
                }
            }
            
        } ELSE {
            FOR i in forPart:modules {
                IF forPart:getmodule(i):hasfield(fieldName) { 
                    set returnValue to forPart:getmodule(i):getfield(fieldName). 
                    break.
                }
            }
        }
    }
    return returnValue.
}

// do actions and events

FUNCTION doPartEvent {
    parameter forPart is list(), eventName is false, byIndex is false.
    // doesnt require a single part therefore we can do this through a list
    IF NOT(forPart:istype("Part")) {
        set forPart to getParts(forPart).
        FOR i in forPart {
            doPartEvent(i, eventName, byIndex).
        }
    } ELSE {
        local doByIndex is false.
        IF byIndex:istype("Boolean") {
            set doByIndex to byIndex.
        } ELSE IF byIndex:istype("Scalar") {
            set doByIndex to byIndex = min(forPart:allmodules:length-1, max(-1, byIndex)).
        }
        IF doByIndex {
            local mIndex is 0.
            IF byIndex:istype("Scalar") {
                set mIndex to byIndex.
                IF forPart:getmodulebyindex(mIndex):hasevent(eventName) { forPart:getmodulebyindex(mIndex):doevent(eventName). }
            } ELSE {
                FOR i in forPart:modules {
                    IF forPart:getmodulebyindex(mIndex):hasevent(eventName) { forPart:getmodulebyindex(mIndex):doevent(eventName). }
                    set mIndex to mIndex+1.
                }
            }
            
        } ELSE {
            FOR i in forPart:modules {
                IF forPart:getmodule(i):hasevent(eventName) { forPart:getmodule(i):doevent(eventName). }
            }
        }
    }
}

// TODO - not used too often
FUNCTION doPartAction {
    parameter forPart is list(), actionName is false, actionValue is false, byIndex is false.
    set forPart to 1.
    set actionName to 1.
    set actionValue to 1.
    set forPart to actionName+actionValue.
    set actionName to forPart. //errors be damned
    return false.
}

FUNCTION setPartField {
    parameter forPart is list(), fieldName is false, fieldValue is 0, byIndex is false.
    IF NOT(forPart:istype("Part")) {
        set forPart to getParts(forPart).
        FOR i in forPart {
            setPartField(i, fieldName, fieldValue, byIndex).
        }
    } ELSE {
        local doByIndex is false.
        IF byIndex:istype("Boolean") {
            set doByIndex to byIndex.
        } ELSE IF byIndex:istype("Scalar") {
            set doByIndex to byIndex = min(forPart:allmodules:length-1, max(-1, byIndex)).
        }
        IF doByIndex {
            local mIndex is 0.
            IF byIndex:istype("Scalar") {
                set mIndex to byIndex.
                IF forPart:getmodulebyindex(mIndex):hasfield(fieldName) { forPart:getmodulebyindex(mIndex):setfield(fieldName, fieldValue). }
            } ELSE {
                FOR i in forPart:modules {
                    IF forPart:getmodulebyindex(mIndex):hasfield(fieldName) { forPart:getmodulebyindex(mIndex):setfield(fieldName, fieldValue). }
                    set mIndex to mIndex+1.
                }
            }
            
        } ELSE {
            FOR i in forPart:modules {
                IF forPart:getmodule(i):hasfield(fieldName) { forPart:getmodule(i):setfield(fieldName, fieldValue). }
            }
        }
    }
}

FUNCTION getPartMassLEX {
    parameter forParts is list().
    local rLex is lexicon(
        "Mass", 0,
        "WetMass", 0,
        "DryMass", 0,
        "fuelMass", LEXICON("t", 0, "c", 0)
    ).
    IF NOT(forParts:istype("Part")) {
        set forParts to getParts(forParts).
        FOR i in forParts {
            local part_rLex is getPartMassLEX(i).
            set rLex:Mass to part_rLex:Mass+rLex:Mass.
            set rLex:WetMass to part_rLex:WetMass+rLex:wetMass.
            set rLex:DryMass to part_rLex:DryMass+rLex:DryMass.
        }
    } ELSE {
        set rLex:Mass to forParts:Mass.
        set rLex:WetMass to forParts:WetMass.
        set rLex:DryMass to forParts:DryMass.
    }
    set rLex:fuelMass:t to rLex:wetmass-rLex:drymass.
    set rLex:fuelMass:c to rLex:mass-rLex:drymass.
    return rLex.
}

FUNCTION getPartResourcesLEX {
    parameter forParts is list().
    local rLex is lexicon().
    IF forParts:istype("Part") {
        FOR i in forParts:resources {
            local resourceSpecificLexicon is LEXICON(
                "Name", i:Name,
                "Amount", i:Amount,
                "MaxAmount", i:Capacity
            ).
            rLex:add(i:Name, resourceSpecificLexicon).
        }
    } ELSE {
        set forParts to getParts(forParts).
        FOR i in forParts {
            local partResources is getPartResourcesLEX(i).
            FOR _i in partResources:keys {
                IF rLex:haskey(_i) {
                    set rLex[_i]:Amount to rLex[_i]:Amount+partResources[_i]:Amount.
                    set rLex[_i]:MaxAmount to rLex[_i]:MaxAmount+partResources[_i]:MaxAmount.
                } ELSE {
                    rLex:add(_i, partResources[_i]).
                }
            }
        }
    }
    return rLex.
}

FUNCTION setTankResourceState {
    parameter prt is LIST(), setState is "Enable", resourceName is LIST().
    IF NOT(resourceName:istype("list")) { set resourceName to LIST(resourceName). }
    IF setState:istype("Boolean") {
        IF setState { set setState to "Enable". }
        ELSE { set setState to "Disable". }
    }
    IF NOT(setState = "Enable" or setState = "Disable") { return. }
    set prt to getParts(prt).
    FOR i in prt {
        setRscState(i, setState, resourceName).
    }
}

local function setRscState {
    parameter prt is "none", setState is "Enable", resourceName is LIST().
    local ii is 0.
    FOR i in prt:resources {
        IF NOT(prt:resources[ii]:name = "ELECTRICCHARGE") {
            IF resourceName:empty {
                set prt:resources[ii]:Enabled to setState = "Enable".
            } ELSE IF resourceName:contains(prt:resources[ii]:Name) {
                set prt:resources[ii]:Enabled to setState = "Enable".
            }
        }
        set ii to ii+1.
    }
}

FUNCTION getLogTimingPrefix {
    parameter byModule is "Null".
    local lPrefix is "[" + time:clock.
    IF NOT(byModule = "Null") {
        set lPrefix to lPrefix+"/"+byModule.
    }
    set lPrefix to lPrefix+"] ".
    return lPrefix.
}

FUNCTION convertTimeLEX {
    parameter inputTime is 0.
    // if the input is lexicon, the output will be scalar, if the input is scalar the output will be lexicon
    local outputTime is 0.
    IF inputTime:istype("Lexicon") {
        local tempOutput is LEXICON("H", 0, "M", 0, "S", 0).
        FOR i in timeConversionLexiconAliases:H {
            IF inputTime:haskey(i) {
                set tempOutput:H to inputTime[i].
                break.
            }
        }
        FOR i in timeConversionLexiconAliases:M {
            IF inputTime:haskey(i) {
                set tempOutput:M to inputTime[i].
                break.
            }
        }
        FOR i in timeConversionLexiconAliases:S {
            IF inputTime:haskey(i) {
                set tempOutput:S to inputTime[i].
                break.
            }
        }
        set outputTime to outputTime+(tempOutput:H*3600)+(tempOutput:M*60)+tempOutput:S.
        IF inputTime:haskey("Sign") {
            IF inputTime:Sign = "-" {
                set outputTime to -outputTime.
            }
        }
    }
    return outputTime.
}

FUNCTION localGravity {
    parameter atAltitude is altitude.
    return body:mu/(body:radius+atAltitude)^2.
}

FUNCTION getHoverThrottle {
    return localGravity()/(max(maxthrust, 0.001)/mass).
}

// orbit library

FUNCTION addRadius {
    parameter r is altitude, ofBody is body.
    return r+ofBody:radius.
}

FUNCTION getSMA {
    parameter r1 is apoapsis, r2 is periapsis, isAltitude is true.
    IF isAltitude {
        set r1 to addRadius(r1).
        set r2 to addRadius(r2).
    }
    return (r1+r2)/2.
}

FUNCTION getApoapsis {
    parameter r1 is 4000, r2 is 3000, r3 is 4650. //accepts three values for Apoapsis, Periapsis and Altitude in an hypothetical orbit, for cases where we are unsure if the input is actually valid
    local r1r is 0.
    IF r1 > r2 { set r1r to r1. }
    ELSE { set r1r to r2. }
    IF r3 > r1r { set r1r to r3. }
    return r1r.
}

FUNCTION getPeriapsis {
    parameter r1 is 4000, r2 is 3000, r3 is 4650. //accepts three values for Apoapsis, Periapsis and Altitude in an hypothetical orbit, for cases where we are unsure if the input is actually valid
    local r2r is 0.
    IF r1 < r2 { set r2r to r1. }
    ELSE { set r2r to r2. }
    IF r3 < r2r { set r2r to r3. }
    return r2r.
}

FUNCTION getAltitude {
    parameter r1 is 4000, r2 is 3000, r3 is 3500.
    local r3r is 0.
    // if two values are equal, we can simply return one of the two values which are equal
    // for this there are 3 values, which means we have values a b and c
    // a = b
    // a = c
    // b = c
    IF (r1 = r2) or (r1 = r3) or (r2 = r3) {
        IF (r1 = r2) or (r1 = r3) { return r1. }
        ELSE { return r2. }
    }
    local r1r is getApoapsis(r1,r2,r3).
    local r2r is getPeriapsis(r1,r2,r3).
    // we have three values, two of which will be equal to either r1r or r2r, the third value which is equal to neither will be our altitude value
    // r3r shall be LESS THAN r1r and GREATER THAN r2r
    // the simplest way is an if statement, HOWEVER we can use a list and itterate through said list to save on file size
    local rList is LIST(r1,r2,r3).
    FOR i in rList {
        IF i < r1r and i > r2r {
            set r3r to i.
            break.
        }
    }
    return r3r.
}

FUNCTION getElements {
    parameter r1 is apoapsis, r2 is periapsis, r3 is altitude.
    local r1r is getApoapsis(r1,r2,r3).
    local r2r is getPeriapsis(r1,r2,r3).
    local r3r is getAltitude(r1,r2,r3).
    return list(r1r,r2r,r3r).
}

FUNCTION getOrbVel {
    parameter r1 is apoapsis, r2 is periapsis, r3 is altitude, hypothetical is true.
    local __v is 0.
    IF hypothetical {
        set r1 to getApoapsis(r1,r2,r3).
        set r2 to getPeriapsis(r1,r2,r3).
        set r3 to getAltitude(r1,r2,r3).
    }
    local a is getSMA(r1, r2).
    set r3 to addRadius(r3).

    local vSQR is body:mu*((2/r3)-(1/a)).
    set __v to SQRT(vSQR).
    return __v.
}

FUNCTION getRadialVel {
    parameter r1 is apoapsis, r2 is periapsis, r3 is altitude, hypothetical is true.
    local __v is 0.
    local __vv is 0.
    local r0 is 0.
    IF hypothetical {
        set r1 to getApoapsis(r1,r2,r3).
        set r2 to getPeriapsis(r1,r2,r3).
        set r3 to getAltitude(r1,r2,r3).
    }
    // check to see if we aren't checking the radial velocity at apoapsis or periapsis
    IF (r1 = r3) or (r2 = r3) or (r1 = r2) {
        return 0.
    }
    // initial setup of variables
    local v_r2 is getOrbVel(r1,r2,r2,false).
    set r to addRadius(r3).
    set __v to getOrbVel(r1,r2,r3,false).
    set r1 to addRadius(r1).
    set r2 to addRadius(r2).

    local srm is r2*v_r2.
    local fpa is arccos(srm/(__v*r0)).

    set __vv to __v*sin(fpa).

    return __vv.
}

FUNCTION getFlightPathAngle {
    parameter r1 is apoapsis, r2 is periapsis, r3 is altitude, hypothetical is true.
    IF hypothetical {
        set r1 to getApoapsis(r1,r2,r3).
        set r2 to getPeriapsis(r1,r2,r3).
        set r3 to getAltitude(r1,r2,r3).
    }
    IF (r1 = r3) or (r2 = r3) or (r1 = r2) {
        return 0.
    }
    local __v is getOrbVel(r1,r2,r3,false).
    local v_r2 is getOrbVel(r1,r2,r2,false).
    set r2 to addRadius(r2).
    set r1 to addRadius(r1).

    local srm is r2*v_r2.
    return arccos(srm/(__v*r)).
}


// https://orbital-mechanics.space/classical-orbital-elements/orbital-elements-and-the-state-vector.html

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

    local nu is arcCos(vdot(r_vec/_r, e_vec/_e)).

    local rA is (_h^2/_mu)*(1/1+_e).
    local rP is (_h^2/_mu)*(1/1-_e). // these should be the radius i think
    local _a is (rP+rA)/2.
    return lexicon(
        "Apoapsis", lexicon("r", rA, "a", rA-_rad),
        "Periapsis", lexicon("r", rP, "a", rP-_rad),
        "Altitude", lexicon("r", _r, "a", _r-_rad),
        "mu", _mu,
        "Semimajoraxis", _a,
        "Inclination", _i,
        "Eccentricity", _e,
        "TrueAnomaly", nu
    ).
}


// In the below segment i used https://orbital-mechanics.space/time-since-periapsis-and-keplers-equation/elliptical-orbit-example.html and looked at https://github.com/nuggreat/kOS-scripts/blob/Documented-Scripts/impact%20ETA/claculated_impact_eta.ks for extra guidance

FUNCTION radius_to_true_anom {
    parameter forRadius is altitude+body:radius, forSMA is ship:orbit:semimajoraxis, forEccentricity is ship:orbit:eccentricity.

    local _ta is arcCos((-forSMA*forEccentricity^2 + forSMA - forRadius)/ (forEccentricity*forRadius)).

    return lexicon(
        "PEtoAP", _ta,
        "APtoPE", 360-_ta
    ).
}

FUNCTION getMeanAnomaly {
    // returns the mean anomaly from the eccentric and true anomalies
    parameter forEccentricity is ship:orbit:eccentricity, forTA is getElements():TrueAnomaly.
    local e_anom_degrees is arctan2(sqrt((1-forEccentricity)/(1+forEccentricity))*tan(forTA/2), forEccentricity*cos(forTA)).
    local _maDEG is e_anom_degrees-(forEccentricity*sin(e_anom_degrees)*constant:radtodeg).
    return mod(_maDEG+360, 360).
}

FUNCTION time_of_flight_between_tas {
    parameter forEccentricity is ship:orbit:eccentricity, forPeriod is ship:orbit:period, startTA is ship:orbit:trueanomaly, endTA is radius_to_true_anom(ship:orbit:periapsis+ship:body:radius):APtoPE. // by default tells us the time to PERIAPSIS

    local M_1 is getMeanAnomaly(forEccentricity, startTA).
    local M_2 is getMeanAnomaly(forEccentricity, endTA).

    local TFF is forPeriod*((M_2-M_1)/360).

    return MOD(TFF+forPeriod, forPeriod).
}

FUNCTION timeToRadius {
    parameter targetRadius is ship:periapsis+body:radius.

    set targetRadius to max(ship:orbit:periapsis, targetRadius).
    local _ta is ship:orbit:trueanomaly.

    // return the SHORTEST time

    local _timeASCENDING is time_of_flight_between_tas(ship:orbit:eccentricity, ship:orbit:period, _ta, radius_to_true_anom(targetRadius):PEtoAP).
    local _timeDESCENDING is time_of_flight_between_tas(ship:orbit:eccentricity, ship:orbit:period, _ta, radius_to_true_anom(targetRadius):APtoPE).

    return lexicon(
        "ASCENDING", _timeASCENDING,
        "DESCENDING", _timeDESCENDING
    ).
}


FUNCTION isLanded {
    return SHIP:STATUS = "SPLASHED" or SHIP:STATUS = "LANDED" OR SHIP:STATUS = "PRELAUNCH".
}

FUNCTION inFlight {
    return NOT(ship:status = "SPLASHED" or SHIP:STATUS = "LANDED" or SHIP:STATUS = "PRELAUNCH").
}