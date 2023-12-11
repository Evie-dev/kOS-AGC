// extended verbs refer to many things, some are implimented in the DSKY.ks file due to being common between the AGC (CSM) and LGC (LEM AGC)
FUNCTION _extendedVerbs {
    parameter eVerb is "00".
    // V46 - Permit DAP
    IF eVerb = "46" {
        set _AGC:PERMIT:DAP to TRUE.
        V46().
    }
    // V48 - R03
    ELSE IF eVerb = "48" {
        // do routine 3
        R03_INIT().
    } ELSE IF eVerb = "49" { // crew defined manuver R62
        R62_INIT().
    } ELSE IF eVerb = "69" {
        reboot.
    } 
    ELSE IF eVerb = "75" {
        // shorthand for V37N11E
        _AGC_PROGRAMUPDATE("11").
    } ELSE IF eVerb = "82" {
        // Orbital parameters update and display R30
        R30_INIT().
    }
}

LOCAL FUNCTION V46 {
    // setup the RCS quads in relation to what was inputted onto the DAP
    set _DSKY_STATE:PRO TO TRUE.
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
}