

// Core memory addresses, variables and related functionality with regards to the displays in the registers


GLOBAL _CORE_MEMORY is LEXICON(
    // state vectors
    "R", v(0,0,0), // position state vector
    "V", v(0,0,0), // velocity state vector
    "RTIG", v(0,0,0),
    "VTIG", v(0,0,0),
    


    "CDUX", v(0,0,0),
    "THETAD", v(0,0,0),

    "-TPER", 0,
    "TIG", 0,
    "TOC", 0, // time of cutoff (Im unsure what was used by the atual AGC at the moment, but if anyone has any ideas i am open to the suggestion of which)
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
    "+MGA", 0
).

GLOBAL _MEM_DATATYPES IS LEXICON(
    "TIME", LIST("TFF", "GETI", "TIME2", "-TPER", "TTOGO", "TIG"),
    "OCTAL", LIST("DAPDATR1", "DAPDATR2"),
    "VEC", LIST("CDUX","THETAD","DELVLVC", "DELVIMU", "DELVOV", "VGBODY"),
    "LENGTHS", LIST("VGDISP", "DVTOTAL", "DELVLVC","DELVIMU", "DELVOV", "VGBODY", "HAPOX", "HPERX", "HAPO", "HPER", "VMAGI", "HDOT", "ALT 1"),
    "WEIGHTS", LIST("CSMMAS", "LEMMAS")
).