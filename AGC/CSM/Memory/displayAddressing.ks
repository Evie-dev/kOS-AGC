// Display addressing contains information regarding which Memory.ks variables are used for which verb/noun combinations
// Each combination contains a list for R1, R2 and R3

// REVISION: 
// Memory addresses contain lists of lexicons which contain A ddress and F ormat for being read into the DSKY display

GLOBAL _MEMORY_ADDRESSES IS LEXICON(
    "09", LIST(LEXICON("A", "FAILREG", "F", "0XXXX"), LEXICON("A", "FAILREG", "F", "1XXXX"), LEXICON("A", "FAILREG", "F", "2XXXX")),
    "18", LIST(LEXICON("A", "THETAD", "F", "AXX.XX"), LEXICON("A", "THETAD", "F", "BXX.XX"), LEXICON("A", "THETAD", "F", "CXX.XX")),
    "20", LIST(LEXICON("A", "CDUX", "F", "AXX.XX"), LEXICON("A", "CDUX", "F", "BXX.XX"), LEXICON("A", "CDUX", "F", "CXX.XX")),
    "22", LIST(LEXICON("A", "THETAD", "F", "AXX.XX"), LEXICON("A", "THETAD", "F", "BXX.XX"), LEXICON("A", "THETAD", "F", "CXX.XX")),
    "25", LIST(LEXICON("A", "CHCKLIST", "F", "0XXXX"), LEXICON("A", "CHCKLIST", "F", "1XXXX"), LEXICON("A", "CHCKLIST", "F", "2XXXX")),
    "33", LIST(LEXICON("A", "TIG", "F", "00HHH", "ignMax", TRUE), LEXICON("A", "TIG", "F", "000MM"), LEXICON("A", "TIG", "F", "0SS.SS")),
    "36", LIST(LEXICON("A", "TIME2", "F", "00HHH", "ignMax", TRUE), LEXICON("A", "TIME2", "F", "000MM"), LEXICON("A", "TIME2", "F", "0SS.SS")),
    "40", LIST(LEXICON("A", "TTOGO", "F", "MMbSS", "ignMax", true), LEXICON("A", "VGDISP", "F", "XXXX.X", "dispIN", "ft"), LEXICON("A", "DVTOTAL", "F", "XXXX.X", "dispIN", "ft")),
    "42", LIST(LEXICON("A", "HAPO", "F", "XXXX.X", "dispIN", "nmi"), LEXICON("A", "HPER", "F", "XXXX.X", "dispIN", "nmi"), lexicon("A", "VGDISP", "F", "XXXX.X", "dispIN", "ft")),
    "44", LIST(LEXICON("A", "HAPOX", "F", "XXXX.X", "dispIN", "nmi"), LEXICON("A", "HPERX", "F", "XXXX.X", "dispIN", "nmi"), LEXICON("A", "TFF", "F", "MMbSS", "ignMax", true)),
    "45", LIST(LEXICON("A", "VHFCNT", "F", "XXXXX"), LEXICON("A", "TTOGO", "F", "MMbSS", "ignMax", TRUE), LEXICON("A", "+MGA", "F", "XXX.XX")),
    "46", LIST(LEXICON("A", "DAPDATR1", "F", "XXXXX"),LEXICON("A", "DAPDATR2", "F", "XXXXX")),
    "47", LIST(LEXICON("A", "CSMMAS", "F", "XXXXX", "dispIN", "lbs"), LEXICON("A", "LEMMAS", "F", "XXXXX", "dispIN", "lbs")),
    "48", LIST(LEXICON("A", "PACTOFF", "F", "XXX.XX"), LEXICON("A", "YACTOFF", "F","XXX.XX")),
    "60", LIST(LEXICON("A", "GMAX", "F", "XXX.XX"), LEXICON("A", "VPRED", "F", "XXXXX", "dispIN", "ft"), LEXICON("A", "GAMMAEI", "F", "XXX.XX")),
    "61", LIST(LEXICON("A", "LATLNGSPL", "F", "LAT.XX"), LEXICON("A", "LATLNGSPL", "F", "LNG.XX"), LEXICON("A", "HEADSUP", "F", "XXXXX")),
    "62", LIST(LEXICON("A", "VMAGI", "F", "XXXXX", "dispIN", "ft"), LEXICON("A", "HDOT", "F", "XXXXX", "dispIN", "ft"), LEXICON("A", "ALT 1", "F", "XXXX.X", "dispIN", "nmi")),
    "63", LIST(LEXICON("A", "RTGO", "F", "XXXX.X", "dispIN", "nmi"), LEXICON("A", "VIO", "F", "XXXXX", "dispIN", "ft"), LEXICON("A", "TTE", "F", "MMbSS")),
    "64", LIST(LEXICON("A", "D", "F", "XXX.XX", "dispIN", "g"), LEXICON("A", "VMAGI", "F", "XXXXX", "dispIN", "ft"), LEXICON("A", "RTGON64", "F", "XXXX.X", "dispIN", "nmi")),
    "68", LIST(LEXICON("A", "ROLLC", "F", "XXX.XX"), LEXICON("A", "VMAGI", "F", "XXXXX", "dispIN", "ft"), LEXICON("A", "RDOT", "F", "XXXXX", "dispIN", "ft")),
    "81", LIST(LEXICON("A", "DELVLVC", "F", "AXXXX.X", "dispIN", "ft"), LEXICON("A", "DELVLVC", "F", "BXXXX.X", "dispIN", "ft"),LEXICON("A", "DELVLVC", "F", "CXXXX.X", "dispIN", "ft"))
).

GLOBAL _MEM_DATATYPES IS LEXICON(
    "TIME", LIST("TFF", "GETI", "TIME2", "-TPER", "TTOGO", "TIG", "TFE", "TTE"),
    "OCTAL", LIST("DAPDATR1", "DAPDATR2"),
    "VEC", LIST("CDUX","THETAD","DELVLVC", "DELVIMU", "DELVOV", "VGBODY"),
    "LENGTHS", LIST("VGDISP", "DVTOTAL", "DELVLVC","DELVIMU", "DELVOV", "VGBODY", "HAPOX", "HPERX", "HAPO", "HPER", "VMAGI", "HDOT", "ALT 1", "VPRED", "VIO", "RTGON64", "RTGO", "D"),
    "WEIGHTS", LIST("CSMMAS", "LEMMAS"),
    "LATLNG", LIST("LATLNGSPL"),
    "LISTS", LIST("CHCKLIST", "FAILREG")
).


// Memory types: 
// Lengths can be speeds as basically it is you are traveling a certain length, the time period doesnt exactly matter here