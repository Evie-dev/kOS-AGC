// Core memory addresses, variables and related functionality with regards to the displays in the registers


GLOBAL _CORE_MEMORY is LEXICON(
    "THETAD1", 0,
    "THETAD2", 0,
    "THETAD3", 0,

    "TIG", 0,

    "VMAGI", 0,
    "HDOT", 0,
    "ALT 1", 0,
    "HAPOX", 0,
    "HPERX", 0,
    "TFF", 0,
    "TIME0", 0,
    "TIME2", 0,
    "DAPDATR1", "00000",
    "DAPDATR2", "00000",
    "CSMMAS", 25582,
    "LEMMAS", 19054
).

GLOBAL _MEM_DATATYPES IS LEXICON(
    "TIME", LIST("TFF", "GETI", "TIME2"),
    "OCTAL", LIST()
).