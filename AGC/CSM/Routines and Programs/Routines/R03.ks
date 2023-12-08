// Digital Autopilot data load routine

// Entered through VERB 48


FUNCTION R03_INIT {
    print "ROUTINE 03!".
    set _DSKYdisplayREG:PRO to true.
    ADD_STEP("V06N46").
    ADD_STEP("V06N47").
    ADD_STEP("V36").
    ADD_STEP("TERM").
}

LOCAL FUNCTION R03_FINISH {

}