// extended verbs refer to many things, some are implimented in the DSKY.ks file due to being common between the AGC (CSM) and LGC (LEM AGC)
FUNCTION _extendedVerbs {
    parameter eVerb is "00".

    // V48 - R03
    IF eVerb = "48" {
        // do routine 3
        R03_INIT().
    } ELSE IF eVerb = "49" { // crew defined manuver R62

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