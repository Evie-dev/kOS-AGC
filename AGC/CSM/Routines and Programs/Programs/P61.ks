// P61 - Entry prepraration
// Through experimentation it seems like the BDB CM under default conditions has a L/D of about 0.015, which i will aim for a NOMINAL of 0.018 (10x less than irl apollo)

// Given that in an ideal world, i would be able to pull all the required information out of KSP, and this is not said ideal world, and i dont have the actual multiple years NASA spent studying this, for the purposes of re-entry guidance i shall be focuising less on the
// Realism specifics aspect, however am willing to attempt to get it to "good enough" to be "safe"

// As well as this, you will notice that the display for P61 (V06N61) will be wrong until you have performed CM/CSM sep

// I can go about this in two seprate ways: 
// Prevent N61 from showing during P61
// Use trajectories 
//
// I shall use trajectories for now however, though that will probably change, with this in mind it is notable that when you seprate the CSM/CM you will experience errors, therefore i will recalculate this after P62

// We now need to "calculate" multiple values

// GMAX
// VPRED
// GAMMA EI

// As in real life, entry interface "starts" at 122km (121920m)
// 0.05g altitiude is aproximate to 297,431ft (90km)


FUNCTION P61_INIT {

    set _DSKYdisplayREG:PROG to "61".
    P61_VARIABLES().

    ADD_STEP("FLV06N61").
    ADD_STEP("FLV06N60").
    ADD_STEP("FLV16N63").
    ADD_STEP("P62").


}

LOCAL FUNCTION P61_VARUPDT {
}

