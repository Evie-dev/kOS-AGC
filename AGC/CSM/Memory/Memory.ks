// Core memory addresses, variables and related functionality with regards to the displays in the registers


GLOBAL _CORE_MEMORY is LEXICON(
    // state vectors
    "R", v(0,0,0), // position state vector
    "V", v(0,0,0), // velocity state vector
    "RTIG", v(0,0,0),
    "VTIG", v(0,0,0),
    "ALMCADR", LIST(0,0,0),
    "FAILREG", LIST(0,0,0),
    "CHCKLIST", LIST(0,0,0), // checklist codes


    "CDUX", v(0,0,0),
    "THETAD", v(0,0,0),

    "-TPER", 0,
    "TIG", 0,
    "TOC", 0, // time of cutoff (Im unsure what was used by the atual AGC at the moment, but if anyone has any ideas i am open to the suggestion of which) (revision: keeping just incase i need it later)
    "TFF", 0,
    "TTOGO", 0,

    "VMAGI", 0,
    "HDOT", 0,
    "ALT 1", 0,

    "HAPOX", 0,
    "HPERX", 0,
    "HAPO", 0,
    "HPER", 0,

    

    "TIME0", 0,
    "TIME2", 0,


    "DAPDATR1", "00000",
    "DAPDATR2", "00000",

    "CSMMAS", 25582,
    "LEMMAS", 19054,

    "PACTOFF", 0,
    "YACTOFF", 0,

    "VGDISP", 0,
    "DVTOTAL", 0,
    "DELVLVC", v(0,0,0),
    "DELVIMU", v(0,0,0),
    "DELVOV", v(0,0,0),
    "VGBODY", v(0,0,0),

    // stuff i dont know about that much
    "VHFCNT", 0, // MARKS
    "+MGA", 0,


    // entry variables
    "LATLNGSPL", LATLNG(0,0),
    "HEADSUP", 1, // +1 is heads up lift down, -1 is heads down lift up

    "GMAX", 0, // unused for now (im unsure how to calculate it)
    "VPRED", 0, // predicted at EI
    "GAMMAEI", 0, // also unsure how to calculate

    "RTGO", 0,
    "VIO", 0,
    "TFE", 0,
    "TTE", 0,

    "D", 0,
    "RDOT", 0,
    "RTGON64", 0

).

// Information on all the variables contained here

// R - Current Position state vector (ship:position)
// V - Current Velocity state vector (ship:velocity:orbit)
// RTIG - Position at TIG
// VTIG - velocity at TIG
// ALRMCADR - Alarm info
// FAILREG - program alarms (1202)
// CHCKLIST - checklist codes requested by programs
// CDUX - current gimbal angles
// THETAD - AUTOMNV target gimbal angle
// -TPER - time to perigee
// TIG - time of of ignition
// TFF - time of flight
// TTOGO - 