// Display addressing contains information regarding which Memory.ks variables are used for which verb/noun combinations
// Each combination contains a list for R1, R2 and R3

// REVISION: 
// Memory addresses contain lists of lexicons which contain A ddress and F ormat for being read into the DSKY display

GLOBAL _MEMORY_ADDRESSES IS LEXICON(
    "18", LIST(LEXICON("A", "THETAD", "F", "AXX.XX"), LEXICON("A", "THETAD", "F", "BXX.XX"), LEXICON("A", "THETAD", "F", "CXX.XX")),
    "20", LIST(LEXICON("A", "CDUX", "F", "AXX.XX"), LEXICON("A", "CDUX", "F", "BXX.XX"), LEXICON("A", "CDUX", "F", "CXX.XX")),
    "22", LIST(LEXICON("A", "THETAD", "F", "AXX.XX"), LEXICON("A", "THETAD", "F", "BXX.XX"), LEXICON("A", "THETAD", "F", "CXX.XX")),
    "33", LIST(LEXICON("A", "TIG", "F", "00HHH", "ignMax", TRUE), LEXICON("A", "TIG", "F", "000MM"), LEXICON("A", "TIG", "F", "0SS.SS")),
    "36", LIST(LEXICON("A", "TIME2", "F", "00HHH", "ignMax", TRUE), LEXICON("A", "TIME2", "F", "000MM"), LEXICON("A", "TIME2", "F", "0SS.SS")),
    "40", LIST(LEXICON("A", "TTOGO", "F", "MMbSS", "ignMax", true), LEXICON("A", "VGDISP", "F", "XXXX.X"), LEXICON("A", "DVTOTAL", "F", "XXXX.X")),
    "42", LIST(LEXICON("A", "HAPO", "F", "XXXX.X"), LEXICON("A", "HPER", "F", "XXXX.X"), lexicon("A", "VGDISP", "F", "XXXX.X")),
    "44", LIST(LEXICON("A", "HAPOX", "F", "XXXX.X"), LEXICON("A", "HPERX", "F", "XXXX.X"), LEXICON("A", "TFF", "F", "MMbSS", "ignMax", true)),
    "45", LIST(LEXICON("A", "VHFCNT", "F", "XXXXX"), LEXICON("A", "TTOGO", "F", "MMbSS", "ignMax", TRUE), LEXICON("A", "+MGA", "F", "XXX.XX")),
    "46", LIST(LEXICON("A", "DAPDATR1", "F", "XXXXX"),LEXICON("A", "DAPDATR2", "F", "XXXXX")),
    "47", LIST(LEXICON("A", "CSMMAS", "F", "XXXXX"), LEXICON("A", "LEMMAS", "F", "XXXXX")),
    "48", LIST(LEXICON("A", "PACTOFF", "F", "XXX.XX"), LEXICON("A", "YACTOFF", "F","XXX.XX")),
    "62", LIST(LEXICON("A", "VMAGI", "F", "XXXXX"), LEXICON("A", "HDOT", "F", "XXXXX"), LEXICON("A", "ALT 1", "F", "XXXX.X")),
    "81", LIST(LEXICON("A", "DELVLVC", "F", "AXXXX.X"), LEXICON("A", "DELVLVC", "F", "BXXXX.X"),LEXICON("A", "DELVLVC", "F", "CXXXX.X"))
).