// Digital Autopilot data load routine

// Entered through VERB 48


FUNCTION R03_INIT {
    print "ROUTINE 03!".
    set _DSKY_STATE:PRO to true.

    set routine_END to R03_FINISH@.

    ADD_STEP("FLV06N46").
    ADD_STEP("FLV06N47").
    ADD_STEP("TERM").
}

LOCAL FUNCTION R03_FINISH {
    // due to the way DAPDATR values are stored we must replace the current SCALAR in memory (potentially during input, the text will be converted to a scalar, and DAPDATR is easier when in a string)
    
    // verify the dap datr

    set _CORE_MEMORY:DAPDATR1 to R03_DAPVERIF(_CORE_MEMORY:DAPDATR1).
    set _CORE_MEMORY:DAPDATR2 to R03_DAPVERIF(_CORE_MEMORY:DAPDATR2).

    // setup the DAP

    // DAPDATR1 setup
    local A1 is _CORE_MEMORY:DAPDATR1[0].
    local B1 is _CORE_MEMORY:DAPDATR1[1].
    local C1 is _CORE_MEMORY:DAPDATR1[2].
    local D1 is _CORE_MEMORY:DAPDATR1[3].
    local E1 is _CORE_MEMORY:DAPDATR1[4].

    // DAPDATR2 setup
    
    local A2 is _CORE_MEMORY:DAPDATR2[0].
    local B2 is _CORE_MEMORY:DAPDATR2[1].
    local C2 is _CORE_MEMORY:DAPDATR2[2].
    local D2 is _CORE_MEMORY:DAPDATR2[3].
    local E2 is _CORE_MEMORY:DAPDATR2[4].

    // define the thruster quads

    local _quadA is ship:partstagged("CSM_RCS_A").
    local _quadB is ship:partstagged("CSM_RCS_B").
    local _quadC is ship:partstagged("CSM_RCS_C").
    local _quadD is ship:partstagged("CSM_RCS_D").
    // show actuation toggles
    // potentially could fix for what i mentioned about quadC - yes it is

    doPartEvent(_quadA, "Show Actuation Toggles").
    doPartEvent(_quadB, "Show Actuation Toggles").
    doPartEvent(_quadC, "Show Actuation Toggles").
    doPartEvent(_quadD, "Show Actuation Toggles").


    // setup row 1 for the config



    // The Apollo Coordinate system which was defined in a document titled "PROJECT APOLLO COORDINATE SYSTEM STANDARDS" Dated June 1st 1965 states that the X axis which is set in translation by the DAP is forward/back (in KSP like pressing H/N for translation)
    setPartField(_quadA, "Fore/aft", B1 = 1).
    setPartField(_quadC, "Fore/aft", B1 = 1).
    setPartField(_quadB, "Fore/aft", C1 = 1).
    setPartField(_quadD, "Fore/aft", C1 = 1).

    // set the thruster quad used for ROLL

    // A2 = 0
    // Use B/D

    // A2 = 1
    // Use A/C

    setPartField(_quadB, "Roll", A2 = 0).
    setPartField(_quadD, "Roll", A2 = 0).
    setPartField(_quadA, "Roll", A2 = 1).
    setPartField(_quadC, "Roll", A2 = 1).
    // quad C seems to behave weirdly in tests, i see nothing wrong with the code programitcally speaking, raise an issue if you figure it out :)

    // B-E Use or disuse of each of the thruster quads

    // B2: 
    // 0 - Fail quad A
    // 1 - Use quad A
    setPartField(_quadA, "RCS", B2 = 1, 0).

    // C2: 
    // 0 - Fail quad B
    // 1 - Use quad B
    setPartField(_quadB, "RCS", C2 = 1, 0).

    // D2: 
    // 0 - Fail quad C
    // 1 - Use quad C
    setPartField(_quadC, "RCS", D2 = 1, 0).

    // E2: 
    // 0 - Fail quad D
    // 1 - Use quad D
    setPartField(_quadD, "RCS", E2 = 1, 0).
    print "R03 ENDED".
}

LOCAL FUNCTION R03_DAPVERIF {
    parameter verifWhat is "".
    set verifWhat to verifWhat:tostring.

    IF verifWhat:length = 4 {
        set verifWhat to "0"+verifwhat.
    } ELSE IF verifWhat:length = 3 {
        set verifWhat to "00"+verifWhat.
    } ELSE IF verifWhat:length = 2 {
        set verifWhat to "000" + verifWhat.
    } ELSE IF verifWhat:length = 1 {
        set verifWhat to "0000" + verifWhat.
    } ELSE IF verifWhat:length = 0 {
        set verifWhat to "00000".
    }
    return verifWhat.
}