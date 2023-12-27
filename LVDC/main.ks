// main code for the LVDC





FUNCTION LVDC_MAIN {
    // start by running the required libraries

    runOncePath("0:/common/common.ks").
    runOncePath("0:/LVDC/settings.ks").
    runOncePath("0:/LVDC/flightFunctions.ks").

    LVDC_VARIABLES().

    // launch func
    wait until ag4.
    PRELAUNCH().
    MAIN_LOGIC_LOOP().
}

// variable initilization

local t0 is 0.

FUNCTION LVDC_VARIABLES {
    GLOBAL IU IS LEXICON().

    set IU:case to true. // set this to case sensitive

    // IMPORTANT NOTICE:
    // IN SETTING CASE, I ADVISE USING [""] IN PLACE OF x:y

    // place this into a lexicon to allow for case sensitivity

    // FOR THOSE READING THE REFERENCED DOCUMENTATION ON THE VALUES PRESENTED IN THE SPECIFICATIONS CONTAINED WITHIN THE DOCUMENT TITLED:
    // SATURN V LAUNCH VEHICLE GUIDANCE EQUATIONS (SA-504)
    // 
    // ANY SUBSCRIPTED VALUES WITH MULTIPLE VALUES SHALL BE PRESENTED AS A LIST
    // SHOULD THESE VALUES BE NON NUMERICAL IT SHALL BE PRESENTED AS IU[variableName][subscript]
    //
    // DELTA SHALL BE REPRESENTED AS D[variable]_
    // GENERAL
    IU:add("e",0).
    IU:add("f",0).
    IU:add("C3",-60.7315302). // km^2/s^2
    IU:add("DA",FALSE).
    IU:add("GATE",FALSE).
    IU:add("GATE0",FALSE).
    IU:add("GATE1",FALSE).
    IU:add("GATE2",FALSE).
    IU:add("GATE3",FALSE).
    IU:add("GATE4",FALSE).
    IU:add("GATE5",FALSE).

    IU:add("INH", FALSE).
    IU:add("INH1",FALSE).
    IU:add("INH2",FALSE).

    IU:add("TA1",2700).
    IU:add("TA2",5160).
    IU:add("TB1",100000).
    IU:add("TB2",100000).
    IU:add("TB3",100000).
    IU:add("TB4",100000).
    IU:add("TB5",100000).
    IU:add("TB6",100000).
    IU:add("TB7",100000).
    IU:add("T",LEXICON("LET", 40.671)).
    IU:add("TU",FALSE).
    IU:add("TU10",FALSE).
    IU:add("UP",0).
    IU:add("thetaD",1).
    IU:add("i",1).
    IU:add("omegaN",1).



    // PRE-IGM GUIDANCE

    IU:add("B",LIST(
    LIST(-0.62,40.9),
    LIST(-0.3611, 29.25)
    )).
    IU:add("F",LIST(
        LIST(3.1984, -0.544236, 0.0351605, -0.00116379, 0.0000113886), // F10-F14
        LIST(-10.9607, 0.946620, -0.029406, 0.000207717, -0.000000439036), // F20-F24
        LIST(78.7826, -2.83749, 0.0289710, -0.000178363, 0.000000463029), // F30-F34
        LIST(69.9191, -2.007490, 0.0105367, -0.0000233163, 0.0000000136702) // F40-F44
    )).

    IU:add("t",LEXICON()).

    IU:t:add("o1", 13).
    IU:t:add("o2", 25).
    IU:t:add("o3", 36).
    IU:t:add("o4", 45).
    IU:t:add("o5", 81).
    IU:t:add("o6", 0).
    IU:t:add("AR", 153). // IRL this was 153, however given that BDB stock only burns for around 2 minutes and 10 seconds i will set this to 128
    IU:t:add("S1", 35).
    IU:t:add("S2", 80).
    IU:t:add("S3", 115).
    IU["T"]:add("EO1", 0).
    IU["T"]:add("EO2", 0).
    IU:t:add("c", 0).
    IU:t:add("FAIL", 0).

    IU:add("Dt", LEXICON("t", 1, "f", 0, "LET", 35.1)).

    IU:add("X", LEXICON("XL", 1, "YL", 1, "ZL", 1, "Xi", 90, "Yi", 90, "Zi", 0)). // X


    // variables for kOS controling

    GLOBAL _kOScontrols is lexicon(
        "steering", ship:facing,
        "throttle", 0
    ).
    lock steering to _kOScontrols:steering.
    lock throttle to _kOScontrols:throttle.
}


LOCAL FUNCTION PRELAUNCH {
    // for now i shall simplifiy this
    stage.
    set _kOScontrols:throttle to 1.
    wait 5.
    stage.
    set t0 to time:seconds.
}

FUNCTION MAIN_LOGIC_LOOP {
    UNTIL FALSE {
        set IU:t:c to time:seconds-t0.
        PRE_IGM().
        wait 0.
    }
}

FUNCTION PRE_IGM {
    // IF S_IC_EO {

    //}
    IF IU:t:c > IU:t["o1"] {
        IF IU:t:c >= IU:t["o2"] {
            IF IU["T"]["EO1"] > 0 {
                // freeze time calc
                FREEZE_TIME_CALC().
            }
        }
        IF IU:t:c >= IU:t["o6"] {
            IF IU:t:c > IU:t["AR"] {

            } ELSE {
                PRE_IGM_Xy_STEERING().
            }
        }
    }
    set _kOScontrols:steering to heading(IU["X"]:Xi, IU["X"]:Yi, IU["X"]:Zi).
}

// pre IGM subfunctions

LOCAL FUNCTION S_IC_ENGINE_OUT {
    set IU["T"]["EO1"] to 1.
    set IU:t["FAIL"] to IU:t:c.

}

LOCAL FUNCTION FREEZE_TIME_CALC {
    set IU["T"]["EO1"] to -1. // ensure we only go through this loop once
    IF IU:t["FAIL"] < IU:t["o2"] {
        set IU["Dt"]:f to IU:t["o3"].
    }
    IF IU:t["o2"] < IU:t:c and IU:t:c <= IU:t["o4"] {
        set IU["Dt"]:f to IU["B"][1][1]*IU:t:FAIL+IU["B"][1][2].
    }
    IF IU:t["o4"] < IU:t:c and IU:t:c < IU:t["o5"] {
        set IU["Dt"]:f to IU["B"][2][1]*IU:t:FAIL+IU["B"][2][2].
    }
    IF IU:t["o5"] < IU:t:c {
        set IU["Dt"]:f to 0.
    }
    set IU:t["o6"] to IU:t:c+IU["Dt"]:f.
    set IU:t["AR"] to IU:t["AR"] +(0.25)*(IU:t["AR"]-IU:t["FAIL"]).
}

LOCAL FUNCTION PRE_IGM_Xy_STEERING {
    local tableToRead is 0.

    IF (IU:t:c-IU["Dt"]:f) < IU:t["S1"] { set tableToRead to 0. }
    if IU:t["S1"] <= (IU:t:c-IU["Dt"]:f) and (IU:t:c-IU["Dt"]:f) < IU:t["S2"] { set tableToRead to 1. }
    if IU:t["S2"] <= (IU:t:c-IU["Dt"]:f) and (IU:t:c-IU["Dt"]:f) < IU:t["S3"] { set tableToRead to 2. }
    if IU:t["S3"] <= (IU:t:c-IU["Dt"]:f) { set tableToRead to 3. }


    local pCMD is 0.
    local _n is 0.
    FOR i in IU["F"][tableToRead] {
        set pCMD to pCMD+(IU["F"][tableToRead][_n]*(IU:t:c-IU["Dt"]:f)^_n).
        set _n to _n+1.
    }
    set IU["X"]["Yi"] to 90+pCMD.
}