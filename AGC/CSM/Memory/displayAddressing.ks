// Display addressing contains information regarding which Memory.ks variables are used for which verb/noun combinations
// Each combination contains a list for R1, R2 and R3

// REVISION: 
// Memory addresses contain lists of lexicons which contain A ddress and F ormat for being read into the DSKY display

GLOBAL _MEMORY_ADDRESSES IS LEXICON(
    "36", LIST(LEXICON("A", "TIME2", "F", "00HHH"), LEXICON("A", "TIME2", "F", "000MM"), LEXICON("A", "TIME2", "F", "0SS.SS")),
    "44", LIST(LEXICON("A", "HAPOX", "F", "XXXX.X"), LEXICON("A", "HPERX", "F", "XXXX.X"), LEXICON("A", "TFF", "F", "MM0SS")),
    "46", LIST(LEXICON("A", "DAPDATR1", "F", "XXXXX"),LEXICON("A", "DAPDATR2", "F", "XXXXX")),
    "47", LIST(LEXICON("A", "CSMMAS", "F", "XXXXX"), LEXICON("A", "LEMMAS", "F", "XXXXX")),
    "62", LIST(LEXICON("A", "VMAGI", "F", "XXXXX"), LEXICON("A", "HDOT", "F", "XXXXX"), LEXICON("A", "ALT 1", "F", "XXXX.X"))
).