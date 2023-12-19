// DSKY version 2.1 with somewhat improved behaviour and a cleaner codebase, please note this is a development file name so i can easily differenciate between DSKY version 1 and DSKY version 2
// the code relating to the formation, button pressing and such will be practically the same to the previous DSKY version however the code should be a lot easier to maintain, understand and use
// DSKY version 2.1 uses images for the display elements!
// For now i recomend you use DSKY version 2 for now unless you are willing to assist in bugtesting

// My main reasoning for what i can really only describe as a half-rewrite is to make DSKY_READ_WRITE and the display be allowed to have some better integration with how the actual AGC functioned
// I realised fairly quickly that implimenting KEYREL as a properly working behaved function would be rather difficult

// DSKY 2 contains code to handle the usage of the informational display 

// AGC toggle

local useImages is true. // ill set this to false for now, feel free to set this to true if you want to see some potato quality DSKY textures lol (actually a lot more than 15, i need a hbox for every character, i think gonna ask the kOS discord on that though)
local MissionEmulation is 11.

// logic for displaying the DSKY seprately on the LM and the CSM

// UPDATE: moved into the main display update loop

local _showing is false. // false by default

clearGuis().
clearscreen.
// DSKY I/O Information


// DSKYdisplayREG contains the information required to DISPLAY what the AGC requires it to on screen, all of these variables relate to visible information
GLOBAL _DSKYdisplayREG is LEXICON(
    // Information lights
    "LAMPS", LEXICON(
        "UPLINK", FALSE,
        "TEMP", FALSE,
        "NOATT", FALSE,
        "GIMBAL_LOCK", FALSE,
        "STBY", FALSE,
        "PROG", FALSE,
        "KEYREL", FALSE,
        "RESTART", FALSE,
        "OPPERR", FALSE,
        "TRACKER", FALSE,
        "PRIODISP", FALSE,
        "ALT", FALSE,
        "NODAP", FALSE,
        "VEL", FALSE
    ),

    "COMP_ACTY", FALSE,
    "PROG", "",
    "VERB", "",
    "NOUN", "",
    "R1", "",
    "R2", "",
    "R3", "",
    "change_lamp", FALSE,
    "change_R1", FALSE,
    "change_R2", FALSE,
    "change_R3", FALSE,

    "LAST_VERB", "00",
    "LAST_NOUN", "00"
).

ON _DSKYdisplayREG:R1 {
    set _DSKYdisplayREG:change_R1 to true.
    preserve.
}

ON _DSKYdisplayREG:R2 {
    set _DSKYdisplayREG:change_R2 to true.
    preserve.
}

ON _DSKYdisplayREG:R3 {
    set _DSKYdisplayREG:change_R3 to true.
    preserve.
}

// display register for lamps - REMOVED

GLOBAL _DSKY_STATE IS LEXICON(
    "clock", LEXICON("first", 0, "last", 0, "alive", 0, "update", 0, "refresh", 1.5),
    // first clock cycle (INIT CYCLE), last clock cycle (CURRENT CLOCK CYCLE), time the GC has been active, last time the screens were updated, the refresh rate (in Hz)
    "INHB", LEXICON("V37", FALSE, "INP", "V00N00", "BLANK_REGISTERS", FALSE), // V37 program inhibit and the data inhibit
    // the data inhibit is used to tell the DSKY that if the AGC requests an update to the displays, which data it can request to update without causing a KEYREL ERR
    "STACK", LIST(), // list of data being requested to be shown by the AGC
    "stackIndexer", 0,
    "ERR", LIST(), // all error codes that have been created
    "PRO", FALSE,
    "STBY", FALSE, // AGC STANDBY MODE
    "FLASH", LEXICON("V", FALSE, "N", FALSE, "O", FALSE), // O is a variable which gets updated every cycle to control the ON/OFF of the flashing
    "NEEDS_INPUT", FALSE,
    "INPUT_INTERRUPT", FALSE,
    "INPUT_MODE", "NO",
    "OUTPUT_MODE", TRUE, // enable / disable inputs from the agc
    "INPUTS", LEXICON("PRO", 0, "ENTR", 0, "KEYREL", 0, "RSET", 0) // how many times has this button been pressed (a way of programs being able to check certain conditions)
).

// Data test (REMOVED)
// initilize the DSKY GUI structure

// initilize some UI variables for ease of tinkering later

local _displayHeight is 315.
local _displayWidth is 150.


local _buttonHeight is 50. // height of the input buttons
local _buttonWidth is 50. // width of the input buttons
local _CWheight is 40.
local _CWwidth is 90.

local DSKY is gui(200).

set DSKY:style:bg to "AGC TEXTURES/DSKY_BACKGROUND".

local DSKY_CONTAINER is DSKY:addvlayout.
local DSKY_TOP_SPACING is DSKY_CONTAINER:addspacing(20).

local DSKY_CONTAINER_DISP is DSKY_CONTAINER:addhlayout.

local _DSKY_DISP_CONTAINER_SPACING is DSKY_CONTAINER_DISP:addspacing(25).
local DISP_CW is DSKY_CONTAINER_DISP:addhlayout.
local DISP_MID_SPACING is DSKY_CONTAINER_DISP:addspacing(50).
local DISP_CONTAINER_EL is DSKY_CONTAINER_DISP:addhbox.

// setup the borders for the displays

set DISP_CW:style:width to _displayWidth.
set DISP_CONTAINER_EL:style:width to _displayWidth.
set DISP_CW:style:height to _displayHeight.
set DISP_CONTAINER_EL:style:height to _displayHeight.


local _CWBANK1 is DISP_CW:addvlayout.
local _CWBANK2 is DISP_CW:addvlayout.

// due to the way the el screens are displayed, its needed to create another vlayout to allow for the register rows and the other display items to be displayed

local _EL_CONTAINER IS DISP_CONTAINER_EL:addvlayout.

local _EL_UPPER_CONTAINER IS _EL_CONTAINER:addhlayout.

local _ELBANK1 is _EL_UPPER_CONTAINER:addvlayout.
local _ELBANK_MID_SPACING IS _EL_UPPER_CONTAINER:addspacing(25).
local _ELBANK2 is _EL_UPPER_CONTAINER:addvlayout.



// fillout the EL display

// row 1, COMP ACTY, PROG, program display

    // COMPUTER ACTIVITY, PROG, PROG DISPLAY
    local _displayNumericalElements  is list().
    local _EL_COMPACTY is _ELBANK1:addlabel("COMP ACTY").
    local _EL_PROG is _ELBANK2:addlabel("PROG").
    //local _EL_PROGDISP IS _ELBANK2:addlabel("00").

    local _EL_PROGDISP is _ELBANK2:addhlayout.

        set _EL_PROGDISP:style:padding:h to 0.
        set _EL_PROGDISP:style:padding:v to 0.

        local _PROGDISP_1 is _EL_PROGDISP:addlabel("").
        local _PROGDISP_2 is _EL_PROGDISP:addlabel("").

        set _PROGDISP_1:style:height to 50.
        set _PROGDISP_1:style:width to 25.
        set _PROGDISP_1:style:padding:h to 0.
        set _PROGDISP_1:style:padding:v to 0.
        set _PROGDISP_1:style:margin:h to 0.
        set _PROGDISP_1:style:margin:v to 0.

        set _PROGDISP_2:style:height to 50.
        set _PROGDISP_2:style:width to 25.
        set _PROGDISP_2:style:padding:h to 0.
        set _PROGDISP_2:style:padding:v to 0.
        set _PROGDISP_2:style:margin:h to 0.
        set _PROGDISP_2:style:margin:v to 0.


    // 13/12/23 - Changed program display to "image" format if "useImages" is true

        // Each display will now need to support image files
        // Due to the dynamicness of the function, and that these numbers can change it is required therefore that to display the values and numbers we must create "slots" for each value capable of being displayed on the DSKY

    // set styling and sizes

    set _EL_COMPACTY:style:height to 50.
    set _EL_COMPACTY:style:width to 50.
    set _EL_COMPACTY:style:align to "center".

    set _EL_PROG:style:height to 10.
    set _EL_PROG:style:width to 50.
    set _EL_PROGDISP:style:height to 50.
    set _EL_PROGDISP:style:width to 50.

    // set font size

    set _EL_PROGDISP:style:fontsize to 40.
    
// add padding

local _EL_r1spacing is _ELBANK1:addspacing(15).

// row 2, VERB NOUN, and their displays

    local _EL_VERBLBL IS _ELBANK1:addlabel("VERB").
    local _EL_NOUNLBL IS _ELBANK2:addlabel("NOUN").

    local _EL_VERBDISP IS _ELBANK1:addhlayout.
    local _EL_NOUNDISP IS _ELBANK2:addhlayout.

        set _EL_VERBDISP:style:padding:h to 0.
        set _EL_VERBDISP:style:padding:v to 0.
        set _EL_NOUNDISP:style:padding:h to 0.
        set _EL_NOUNDISP:style:padding:v to 0.

        // set the skins for the labels

        local _VERBDISP1 is _EL_VERBDISP:addlabel("").
        local _VERBDISP2 is _EL_VERBDISP:addlabel("").

        local _NOUNDISP1 is _EL_NOUNDISP:addlabel("").
        local _NOUNDISP2 is _EL_NOUNDISP:addlabel("").


    // set the styling

    set _EL_VERBLBL:style:height to 10.
    set _EL_NOUNLBL:style:height to 10.
    set _EL_VERBLBL:style:width to 50.
    set _EL_NOUNLBL:style:width to 50.

    set _VERBDISP1:style:height to 50.
    set _VERBDISP1:style:width to 25.
    set _VERBDISP1:style:padding:h to 0.
    set _VERBDISP1:style:padding:v to 0.
    set _VERBDISP1:style:margin:h to 0.
    set _VERBDISP1:style:margin:v to 0.

    set _VERBDISP2:style:height to 50.
    set _VERBDISP2:style:width to 25.
    set _VERBDISP2:style:padding:h to 0.
    set _VERBDISP2:style:padding:v to 0.
    set _VERBDISP2:style:margin:h to 0.
    set _VERBDISP2:style:margin:v to 0.

    set _EL_NOUNLBL:style:height to 10.
    set _EL_NOUNLBL:style:height to 10.
    set _EL_NOUNLBL:style:width to 50.
    set _EL_NOUNLBL:style:width to 50.

    set _NOUNDISP1:style:height to 50.
    set _NOUNDISP1:style:width to 25.
    set _NOUNDISP1:style:padding:h to 0.
    set _NOUNDISP1:style:padding:v to 0.
    set _NOUNDISP1:style:margin:h to 0.
    set _NOUNDISP1:style:margin:v to 0.

    set _NOUNDISP2:style:height to 50.
    set _NOUNDISP2:style:width to 25.
    set _NOUNDISP2:style:padding:h to 0.
    set _NOUNDISP2:style:padding:v to 0.
    set _NOUNDISP2:style:margin:h to 0.
    set _NOUNDISP2:style:margin:v to 0.


    // set text size

    set _EL_NOUNDISP:style:fontsize to 40.
    set _EL_VERBDISP:style:fontsize to 40.

// add the line display

local _EL_LINE1 is _EL_CONTAINER:addhlayout.
    local _line1Spacer is _EL_LINE1:addspacing(12).
    local _line1 is _EL_LINE1:addlabel("").

set _EL_LINE1:style:height to 5.
set _EL_LINE1:style:width to 150.


// row 3 - Register R1

    local _EL_DISPLAYREG1 is _EL_CONTAINER:addhlayout.
    set _EL_DISPLAYREG1:style:height to 50.
    set _EL_DISPLAYREG1:style:fontsize to 40.
    set _EL_DISPLAYREG1:style:width to 125. // 25*5

        // set stlying first
        set _EL_DISPLAYREG1:style:padding:h to 0.
        set _EL_DISPLAYREG1:style:padding:v to 0.
        

        // now add the labels

        local _R1SGN is _EL_DISPLAYREG1:addlabel("").
        local _R11 is _EL_DISPLAYREG1:addlabel("").
        local _R12 is _EL_DISPLAYREG1:addlabel("").
        local _R13 is _EL_DISPLAYREG1:addlabel("").
        local _R14 is _EL_DISPLAYREG1:addlabel("").
        local _R15 is _EL_DISPLAYREG1:addlabel("").

        // here lies a LOT of lines of code that really shouldnt exist because kOS is sometimes really picky about how we do stuff

        set _R1SGN:style:height to 50.
        set _R1SGN:style:width to 25.
        set _R1SGN:style:padding:h to 0.
        set _R1SGN:style:padding:v to 0.
        set _R1SGN:style:margin:h to 0.
        set _R1SGN:style:margin:v to 0.

        set _R11:style:height to 50.
        set _R11:style:width to 25.
        set _R11:style:padding:h to 0.
        set _R11:style:padding:v to 0.
        set _R11:style:margin:h to 0.
        set _R11:style:margin:v to 0.

        set _R12:style:height to 50.
        set _R12:style:width to 25.
        set _R12:style:padding:h to 0.
        set _R12:style:padding:v to 0.
        set _R12:style:margin:h to 0.
        set _R12:style:margin:v to 0.

        set _R13:style:height to 50.
        set _R13:style:width to 25.
        set _R13:style:padding:h to 0.
        set _R13:style:padding:v to 0.
        set _R13:style:margin:h to 0.
        set _R13:style:margin:v to 0.

        set _R14:style:height to 50.
        set _R14:style:width to 25.
        set _R14:style:padding:h to 0.
        set _R14:style:padding:v to 0.
        set _R14:style:margin:h to 0.
        set _R14:style:margin:v to 0.

        set _R15:style:height to 50.
        set _R15:style:width to 25.
        set _R15:style:padding:h to 0.
        set _R15:style:padding:v to 0.
        set _R15:style:margin:h to 0.
        set _R15:style:margin:v to 0.


local _EL_LINE2 is _EL_CONTAINER:addhlayout.
    local _line2Spacer is _EL_LINE2:addspacing(12).
    local _line2 is _EL_LINE2:addlabel("").

set _EL_LINE2:style:height to 5.
set _EL_LINE2:style:width to 125.

// row 4 - Register R2

    local _EL_DISPLAYREG2 is _EL_CONTAINER:addhlayout.
    set _EL_DISPLAYREG2:style:height to 50.
    set _EL_DISPLAYREG2:style:fontsize to 50.
    set _EL_DISPLAYREG2:style:width to 125. // 25*5

        // set stlying first
        set _EL_DISPLAYREG2:style:padding:h to 0.
        set _EL_DISPLAYREG2:style:padding:v to 0.
        

        // now add the labels

        local _R2SGN is _EL_DISPLAYREG2:addlabel("").
        local _R21 is _EL_DISPLAYREG2:addlabel("").
        local _R22 is _EL_DISPLAYREG2:addlabel("").
        local _R23 is _EL_DISPLAYREG2:addlabel("").
        local _R24 is _EL_DISPLAYREG2:addlabel("").
        local _R25 is _EL_DISPLAYREG2:addlabel("").

        set _R2SGN:style:height to 50.
        set _R2SGN:style:width to 25.
        set _R2SGN:style:padding:h to 0.
        set _R2SGN:style:padding:v to 0.
        set _R2SGN:style:margin:h to 0.
        set _R2SGN:style:margin:v to 0.

        set _R21:style:height to 50.
        set _R21:style:width to 25.
        set _R21:style:padding:h to 0.
        set _R21:style:padding:v to 0.
        set _R21:style:margin:h to 0.
        set _R21:style:margin:v to 0.

        set _R22:style:height to 50.
        set _R22:style:width to 25.
        set _R22:style:padding:h to 0.
        set _R22:style:padding:v to 0.
        set _R22:style:margin:h to 0.
        set _R22:style:margin:v to 0.

        set _R23:style:height to 50.
        set _R23:style:width to 25.
        set _R23:style:padding:h to 0.
        set _R23:style:padding:v to 0.
        set _R23:style:margin:h to 0.
        set _R23:style:margin:v to 0.

        set _R24:style:height to 50.
        set _R24:style:width to 25.
        set _R24:style:padding:h to 0.
        set _R24:style:padding:v to 0.
        set _R24:style:margin:h to 0.
        set _R24:style:margin:v to 0.

        set _R25:style:height to 50.
        set _R25:style:width to 25.
        set _R25:style:padding:h to 0.
        set _R25:style:padding:v to 0.
        set _R25:style:margin:h to 0.
        set _R25:style:margin:v to 0.

local _EL_LINE3 is _EL_CONTAINER:addhlayout.
    local _line3Spacer is _EL_LINE3:addspacing(12).
    local _line3 is _EL_LINE3:addlabel("").

set _EL_LINE3:style:height to 5.
set _EL_LINE3:style:width to 125.

// row 5 - Register R3

    local _EL_DISPLAYREG3 is _EL_CONTAINER:addhlayout.
    set _EL_DISPLAYREG3:style:height to 50.
    set _EL_DISPLAYREG3:style:fontsize to 50.
    set _EL_DISPLAYREG3:style:width to 125. // 25*5

        // set stlying first
        set _EL_DISPLAYREG3:style:padding:h to 0.
        set _EL_DISPLAYREG3:style:padding:v to 0.
        

        // now add the labels

        local _R3SGN is _EL_DISPLAYREG3:addlabel("").
        local _R31 is _EL_DISPLAYREG3:addlabel("").
        local _R32 is _EL_DISPLAYREG3:addlabel("").
        local _R33 is _EL_DISPLAYREG3:addlabel("").
        local _R34 is _EL_DISPLAYREG3:addlabel("").
        local _R35 is _EL_DISPLAYREG3:addlabel("").

        set _R3SGN:style:height to 50.
        set _R3SGN:style:width to 25.
        set _R3SGN:style:padding:h to 0.
        set _R3SGN:style:padding:v to 0.
        set _R3SGN:style:margin:h to 0.
        set _R3SGN:style:margin:v to 0.

        set _R31:style:height to 50.
        set _R31:style:width to 25.
        set _R31:style:padding:h to 0.
        set _R31:style:padding:v to 0.
        set _R31:style:margin:h to 0.
        set _R31:style:margin:v to 0.

        set _R32:style:height to 50.
        set _R32:style:width to 25.
        set _R32:style:padding:h to 0.
        set _R32:style:padding:v to 0.
        set _R32:style:margin:h to 0.
        set _R32:style:margin:v to 0.

        set _R33:style:height to 50.
        set _R33:style:width to 25.
        set _R33:style:padding:h to 0.
        set _R33:style:padding:v to 0.
        set _R33:style:margin:h to 0.
        set _R33:style:margin:v to 0.

        set _R34:style:height to 50.
        set _R34:style:width to 25.
        set _R34:style:padding:h to 0.
        set _R34:style:padding:v to 0.
        set _R34:style:margin:h to 0.
        set _R34:style:margin:v to 0.

        set _R35:style:height to 50.
        set _R35:style:width to 25.
        set _R35:style:padding:h to 0.
        set _R35:style:padding:v to 0.
        set _R35:style:margin:h to 0.
        set _R35:style:margin:v to 0.

// fillout the C&W DISPLAY

// this has 7 vertical rows and 2 horizontal rows

// each row is equal, some are unused however

// row 1 - UPLINK AND TEMP

    local _CW_UPLINKACTY is _CWBANK1:addlabel("UPLINK ACTY").
    local _CW_TEMP is _CWBANK2:addlabel("TEMP").

    // set the styling

    set _CW_UPLINKACTY:style:height to _CWheight.
    set _CW_UPLINKACTY:style:width to _CWwidth.
    set _CW_UPLINKACTY:style:fontsize to 15.
    set _CW_UPLINKACTY:style:wordwrap to true.

    set _CW_TEMP:style:height to _CWheight.
    set _CW_TEMP:style:width to _CWwidth.
    set _CW_TEMP:style:fontsize to 15.

// row 2 - no att, gimbal lock

    local _CW_NOATT IS _CWBANK1:addlabel("NO ATT").
    local _CW_GIMBALOCK is _CWBANK2:addlabel("GIMBAL LOCK").

    set _CW_NOATT:style:height to _CWheight.
    set _CW_NOATT:style:width to _CWwidth.
    set _CW_NOATT:style:fontsize to 15.

    set _CW_GIMBALOCK:style:height to _CWheight.
    set _CW_GIMBALOCK:style:width to _CWwidth.
    set _CW_GIMBALOCK:style:fontsize to 15.
    set _CW_GIMBALOCK:style:wordwrap to true.

// row 3 - stby and prog

    local _CW_STBY is _CWBANK1:addlabel("STBY").
    local _CW_PROG is _CWBANK2:addlabel("PROG").

    set _CW_STBY:style:height to _CWheight.
    set _CW_STBY:style:width to _CWwidth.
    set _CW_STBY:style:fontsize to 15.

    set _CW_PROG:style:height to _CWheight.
    set _CW_PROG:style:width to _CWwidth.
    set _CW_PROG:style:fontsize to 15.

// row 4 - KEY REL and RESTART

    local _CW_KEYREL is _CWBANK1:addlabel("KEY REL").
    local _CW_RESTART is _CWBANK2:addlabel("RESTART").

    set _CW_KEYREL:style:height to _CWheight.
    set _CW_KEYREL:style:width to _CWwidth.
    set _CW_KEYREL:style:fontsize to 15.

    set _CW_RESTART:style:height to _CWheight.
    set _CW_RESTART:style:width to _CWwidth.
    set _CW_RESTART:style:fontsize to 15.

// row 5 - opp err and tracker

    local _CW_OPPERR is _CWBANK1:addlabel("OPP ERR").
    local _CW_TRACKER is _CWBANK2:addlabel("TRACKER").

    set _CW_OPPERR:style:height to _CWheight.
    set _CW_OPPERR:style:width to _CWwidth.
    set _CW_OPPERR:style:fontsize to 15.

    set _CW_TRACKER:style:height to _CWheight.
    set _CW_TRACKER:style:width to _CWwidth.
    set _CW_TRACKER:style:fontsize to 15.

// row 6 - PRIO DISP (Apollo 15 onwards), ALT (LM ONLY)

    local _CW_PRIODISP is _CWBANK1:addlabel("").
    local _CW_ALT is _CWBANK2:addlabel("ALT").

    set _CW_PRIODISP:style:height to _CWheight.
    set _CW_PRIODISP:style:width to _CWwidth.
    set _CW_PRIODISP:style:fontsize to 15.

    set _CW_ALT:style:height to _CWheight.
    set _CW_ALT:style:width to _CWwidth.
    set _CW_ALT:style:fontsize to 15.

// row 7 - NO DAP (Apollo 15 onwards), VEL (LM ONLY)

    local _CW_NODAP is _CWBANK1:addlabel("").
    local _CW_VEL is _CWBANK2:addlabel("VEL").

    set _CW_NODAP:style:height to _CWheight.
    set _CW_NODAP:style:width to _CWwidth.
    set _CW_NODAP:style:fontsize to 15.

    set _CW_VEL:style:height to _CWheight.
    set _CW_VEL:style:width to _CWwidth.
    set _CW_VEL:style:fontsize to 15.

local DSKY_DISPLAY_INPUT_SPACING IS DSKY_CONTAINER:addspacing(25).

local DSKY_CONTAINER_INPUT IS DSKY_CONTAINER:addhlayout.






// the DSKY input contains 7 vertical segments and 3 horizontal segments, however the first and last vertical segment only contain two elements

local dskyInputR1 is DSKY_CONTAINER_INPUT:addvlayout.
local dskyInputR2 is DSKY_CONTAINER_INPUT:addvlayout.
local dskyInputR3 is DSKY_CONTAINER_INPUT:addvlayout.
local dskyInputR4 is DSKY_CONTAINER_INPUT:addvlayout.
local dskyInputR5 is DSKY_CONTAINER_INPUT:addvlayout.
local dskyInputR6 is DSKY_CONTAINER_INPUT:addvlayout.
local dskyInputR7 is DSKY_CONTAINER_INPUT:addvlayout.

// Configure the spacing for the 1st and 7th row

local _row1Spacing is dskyInputR1:addspacing(0.5*_buttonHeight).
local _row7spacing is dskyInputR7:addspacing(0.5*_buttonHeight).

// Configure the buttons for row 1

    local _inputVERB is dskyInputR1:addbutton("VERB").
    local _inputNOUN is dskyInputR1:addbutton("NOUN").

    // set the height and width

    set _inputVERB:style:height to _buttonHeight.
    set _inputVERB:style:width to _buttonWidth.
    set _inputNOUN:style:height to _buttonHeight.
    set _inputNOUN:style:width to _buttonWidth.

// Configure the buttons for row 2

    local _inputPLUS is dskyInputR2:addbutton("+").
    local _inputMINUS is dskyInputR2:addbutton("-").
    local _inputZERO is dskyInputR2:addbutton("0").

    // set height and width once more
    
    set _inputPLUS:style:height to _buttonHeight.
    set _inputPLUS:style:width to _buttonWidth.
    set _inputMINUS:style:height to _buttonHeight.
    set _inputMINUS:style:width to _buttonWidth.
    set _inputZERO:style:height to _buttonHeight.
    set _inputZERO:style:width to _buttonWidth.

// configure for row 3

    local _inputSEVEN is dskyInputR3:addbutton("7").
    local _inputFOUR is dskyInputR3:addbutton("4").
    local _inputONE is dskyInputR3:addbutton("1").

    // set height and width (again)

    set _inputSEVEN:style:height to _buttonHeight.
    set _inputSEVEN:style:width to _buttonWidth.
    set _inputFOUR:style:height to _buttonHeight.
    set _inputFOUR:style:width to _buttonWidth.
    set _inputONE:style:height to _buttonHeight.
    set _inputONE:style:width to _buttonWidth.

// configure for row 4

    local _inputEIGHT is dskyInputR4:addbutton("8").
    local _inputFIVE is dskyInputR4:addbutton("5").
    local _inputTWO is dskyInputR4:addbutton("2").

    set _inputEIGHT:style:height to _buttonHeight.
    set _inputEIGHT:style:width to _buttonWidth.
    set _inputFIVE:style:height to _buttonHeight.
    set _inputFIVE:style:width to _buttonWidth.
    set _inputTWO:style:height to _buttonHeight.
    set _inputTWO:style:width to _buttonWidth.

// configure row 5

    local _inputNINE is dskyInputR5:addbutton("9").
    local _inputSIX is dskyInputR5:addbutton("6").
    local _inputTHREE is dskyInputR5:addbutton("3").

    set _inputNINE:style:height to _buttonHeight.
    set _inputNINE:style:width to _buttonWidth.
    set _inputSIX:style:height to _buttonHeight.
    set _inputSIX:style:width to _buttonWidth.
    set _inputTHREE:style:height to _buttonHeight.
    set _inputTHREE:style:width to _buttonWidth.

// configure row 6

    local _inputCLR is dskyInputR6:addbutton("CLR").
    local _inputPRO is dskyInputR6:addbutton("PRO").
    local _inputKEYREL is dskyInputR6:addbutton("KEY REL").

    set _inputCLR:style:height to _buttonHeight.
    set _inputCLR:style:width to _buttonWidth.
    set _inputPRO:style:height to _buttonHeight.
    set _inputPRO:style:width to _buttonWidth.
    set _inputKEYREL:style:height to _buttonHeight.
    set _inputKEYREL:style:width to _buttonWidth.
    set _inputKEYREL:style:wordwrap to true.

// configure row 7

    local _inputENTR is dskyInputR7:addbutton("ENTR").
    local _inputRSET is dskyInputR7:addbutton("RSET").

    set _inputENTR:style:height to _buttonHeight.
    set _inputENTR:style:width to _buttonWidth.
    set _inputRSET:style:height to _buttonHeight.
    set _inputRSET:style:width to _buttonWidth.


// DSKY TEXTURE ASSIGNMENT AS OF 13/12/23

IF useImages {
    ASSIGNTEXTURES().
}

LOCAL FUNCTION ASSIGNTEXTURES {

    // asigns images to the labels and stuff, then disables the text

    // background images!

    set DISP_CONTAINER_EL:style:bg to "AGC textures/EL DISP/BACKGROUND".

    // lets first setup the EL display

    set _EL_COMPACTY:image to "AGC textures/EL DISP/COMP ACTY ON".
    set _EL_VERBLBL:image to "AGC textures/EL DISP/VERB ON".
    set _EL_NOUNLBL:image to "AGC textures/EL DISP/NOUN ON".
    set _EL_PROG:image to "AGC textures/EL DISP/PROG ON".
    set _line1:image to "AGC textures/EL DISP/LINE".
    set _line2:image to "AGC textures/EL DISP/LINE".
    set _line3:image to "AGC textures/EL DISP/LINE".

    // clear the text

    set _EL_COMPACTY:text to "".
    set _EL_VERBLBL:text to "".
    set _EL_NOUNLBL:text to "".
    set _EL_PROG:text to "".

    // set the styling


    set _EL_COMPACTY:style:padding:h to 0.
    set _EL_COMPACTY:style:padding:v to 0.
    set _EL_PROG:style:padding:h to 0.
    set _EL_PROG:style:padding:v to 0.
    set _EL_NOUNLBL:style:padding:h to 0.
    set _EL_NOUNLBL:style:PADDING:V to 0.
    set _EL_VERBLBL:style:padding:h to 0.
    set _EL_VERBLBL:style:PADDING:V to 0.

    // i will come to the register displays at a different time (im coding this at nearly 2am and i dont have the capacity to create 17 hboxes for each slot in the register displays)

    // keyboard
    
    set _inputENTR:image to "AGC textures/KEYBOARD/ENTR".
    set _inputKEYREL:image to "AGC textures/KEYBOARD/KEYREL".
    set _inputCLR:image to "AGC textures/KEYBOARD/CLR".
    set _inputRSET:image to "AGC textures/KEYBOARD/RSET".
    set _inputPRO:image to "AGC textures/KEYBOARD/PRO".
    set _inputVERB:image to "AGC textures/KEYBOARD/VERB".
    set _inputNOUN:image to "AGC textures/KEYBOARD/NOUN".
    

    set _inputMINUS:image to "AGC textures/KEYBOARD/MINUS".
    set _inputPLUS:image to "AGC textures/KEYBOARD/PLUS".
    set _inputZERO:image to "AGC textures/KEYBOARD/ZERO".
    set _inputONE:image to "AGC textures/KEYBOARD/ONE".
    set _inputTWO:image to "AGC textures/KEYBOARD/TWO".
    set _inputTHREE:image to "AGC textures/KEYBOARD/THREE".
    set _inputFOUR:image to "AGC textures/KEYBOARD/FOUR".
    set _inputFIVE:image to "AGC textures/KEYBOARD/FIVE".
    set _inputSIX:image to "AGC textures/KEYBOARD/SIX".
    set _inputSEVEN:image to "AGC textures/KEYBOARD/SEVEN".
    set _inputEIGHT:image to "AGC textures/KEYBOARD/EIGHT".
    set _inputNINE:image to "AGC textures/KEYBOARD/NINE".

    set _inputENTR:style:padding:h to 0.
    set _inputENTR:style:padding:v to 0.

    set _inputKEYREL:style:padding:h to 0.
    set _inputKEYREL:style:padding:v to 0.

    set _inputCLR:style:padding:h to 0.
    set _inputCLR:style:padding:v to 0.

    set _inputRSET:style:padding:h to 0.
    set _inputRSET:style:padding:v to 0.

    set _inputPRO:style:padding:h to 0.
    set _inputPRO:style:padding:v to 0.

    set _inputVERB:style:padding:h to 0.
    set _inputVERB:style:padding:v to 0.

    set _inputNOUN:style:padding:h to 0.
    set _inputNOUN:style:padding:v to 0.

    set _inputPLUS:style:padding:h to 0.
    set _inputPLUS:style:padding:v to 0.

    set _inputMINUS:style:padding:h to 0.
    set _inputMINUS:style:padding:v to 0.

    set _inputZERO:style:padding:h to 0.
    set _inputZERO:style:padding:v to 0.

    set _inputONE:style:padding:h to 0.
    set _inputONE:style:padding:v to 0.

    set _inputTWO:style:padding:h to 0.
    set _inputTWO:style:padding:v to 0.

    set _inputTHREE:style:padding:h to 0.
    set _inputTHREE:style:padding:v to 0.

    set _inputFOUR:style:padding:h to 0.
    set _inputFOUR:style:padding:v to 0.

    set _inputFIVE:style:padding:h to 0.
    set _inputFIVE:style:padding:v to 0.

    set _inputSIX:style:padding:h to 0.
    set _inputSIX:style:padding:v to 0.

    set _inputSEVEN:style:padding:h to 0.
    set _inputSEVEN:style:padding:v to 0.

    set _inputEIGHT:style:padding:h to 0.
    set _inputEIGHT:style:padding:v to 0.

    set _inputNINE:style:padding:h to 0.
    set _inputNINE:style:padding:v to 0.

    // set the text

    set _inputENTR:text to "".
    set _inputKEYREL:text to "".
    set _inputCLR:text to "".
    set _inputRSET:text to "".
    set _inputPRO:text to "".
    set _inputVERB:text to "".
    set _inputNOUN:text to "".

    set _inputMINUS:text to "".
    set _inputPLUS:text to "".
    set _inputZERO:text to "".
    set _inputONE:text to "".
    set _inputTWO:text to "".
    set _inputTHREE:text to "".
    set _inputFOUR:text to "".
    set _inputFIVE:text to "".
    set _inputSIX:text to "".
    set _inputSEVEN:text to "".
    set _inputEIGHT:text to "".
    set _inputNINE:text to "".


    // instrument display

    // row 1
    set _CW_UPLINKACTY:text to "".
    set _CW_TEMP:text to "".

    set _CW_UPLINKACTY:image to "AGC textures/INSTRUMENTATION/OFF/UPLINK ACTY".
    set _CW_TEMP:image to "AGC textures/INSTRUMENTATION/OFF/TEMP".


    // row 2
    set _CW_NOATT:text to "".
    set _CW_GIMBALOCK:text to "".

    set _CW_NOATT:image to "AGC textures/INSTRUMENTATION/OFF/NO ATT".
    set _CW_GIMBALOCK:image to "AGC textures/INSTRUMENTATION/OFF/GIMBAL LOCK".


    // row 3
    set _CW_STBY:text to "".
    set _CW_PROG:text to "".

    set _CW_STBY:image to "AGC textures/INSTRUMENTATION/OFF/STBY".
    set _CW_PROG:image to "AGC textures/INSTRUMENTATION/OFF/PROG".


    // row 4
    set _CW_KEYREL:text to "".
    set _CW_RESTART:text to "". // i hate this specific display module

    set _CW_KEYREL:image to "AGC textures/INSTRUMENTATION/OFF/KEY REL".
    set _CW_RESTART:image to "AGC textures/INSTRUMENTATION/OFF/RESTART".


    // row 5
    set _CW_OPPERR:text to "".
    set _CW_TRACKER:text to "".

    set _CW_OPPERR:image to "AGC textures/INSTRUMENTATION/OFF/OPP ERR".
    set _CW_TRACKER:image to "AGC textures/INSTRUMENTATION/OFF/TRACKER".

    IF _isLM and MissionEmulation >= 11 {
        // LM had a few extra display lamps, but not all LM displays were the same
        // for example Apollo 10's LM had the same lamps as the command module

        // Row 6

        // We can set both Row 6's texts here

        set _CW_PRIODISP:text to "".
        set _CW_ALT:text to "".

        // On Apollo 15 and onwards, the LM instrument display got two new values, PRIO DISP and NO DAP

        IF MissionEmulation >= 15 {
            set _CW_PRIODISP:image to "AGC textures/INSTRUMENTATION/OFF/PRIO DISP".
        } ELSE {
            set _CW_PRIODISP:image to "AGC textures/INSTRUMENTATION/OFF/BLANK".
        }
        IF MissionEmulation >= 11 {
            set _CW_ALT:image to "AGC textures/INSTRUMENTATION/OFF/ALT".
        } ELSE {
            set _CW_ALT:image to "AGC textures/INSTRUMENTATION/OFF/BLANK".
        }


        // Row 7
        set _CW_NODAP:text to "".
        set _CW_VEL:text to "".

        // one again, after apollo 14 NO DAP was added to the instrument lamp displays

        IF MissionEmulation >= 15 {
            set _CW_NODAP:image to "AGC textures/INSTRUMENTATION/OFF/NO DAP".
        } ELSE {
            set _CW_NODAP:image to "AGC textures/INSTRUMENTATION/OFF/BLANK".
        }

        IF MissionEmulation >= 11 {
            set _CW_VEL:image to "AGC textures/INSTRUMENTATION/OFF/VEL".
        } ELSE {
            set _CW_VEL:image to "AGC textures/INSTRUMENTATION/OFF/BLANK".
        }

    } ELSE {
        // Row 6
        set _CW_PRIODISP:text to "".
        set _CW_ALT:text to "".

        set _CW_PRIODISP:image to "AGC textures/INSTRUMENTATION/OFF/BLANK".
        set _CW_ALT:image to "AGC textures/INSTRUMENTATION/OFF/BLANK".


        // Row 7
        set _CW_NODAP:text to "".
        set _CW_VEL:text to "".

        set _CW_NODAP:image to "AGC textures/INSTRUMENTATION/OFF/BLANK".
        set _CW_VEL:image to "AGC textures/INSTRUMENTATION/OFF/BLANK".
    }


    
}

LOCAL function DSKY_buttonHandler_VERB {
    // verb buttonpress
    // validation functions come later when i plan to release this first segment

    // check if we can actually do this
    // (We dont want to be editing V/N while we are currently editing R1 R2 or R3 because that'd be stupid
    IF NOT(LIST("R1", "R2", "R3"):contains(_DSKY_STATE:INPUT_MODE)) {
        set _DSKYdisplayREG:LAST_VERB to _DSKYdisplayREG:VERB.
        SET _DSKY_STATE:INPUT_MODE TO "V".
        set _DSKYdisplayREG:VERB to "".
    }
    

}

set _inputVERB:onclick to DSKY_buttonHandler_VERB@.

LOCAL function DSKY_buttonHandler_NOUN {
    // noun buttonpress
    IF NOT(LIST("R1", "R2", "R3"):contains(_DSKY_STATE:INPUT_MODE)) {
        SET _DSKY_STATE:INPUT_MODE to "N".
        set _DSKYdisplayREG:LAST_NOUN to _DSKYdisplayREG:NOUN.
        set _DSKYdisplayREG:NOUN TO "".
    }
}

set _inputNOUN:onclick to DSKY_buttonHandler_NOUN@.

LOCAL FUNCTION DSKY_buttonHandler_ENTER {
    set _DSKY_STATE:INPUTS:ENTR TO _DSKY_STATE:INPUTS:ENTR+1.
    DSKY_ENTER(). // this could honestly be its own script
}

set _inputENTR:onclick to DSKY_buttonHandler_ENTER@.

LOCAL function DSKY_buttonHandler_PRO {
    set _DSKY_STATE:INPUTS:PRO TO _DSKY_STATE:INPUTS:PRO+1.
    // PROCEDE button, has two primary functions:
    // PROCEDE in the routine/program
    // ACCEPT requests from the computer (manuvers, engine burns ect)#]
    IF _DSKYdisplayREG:VERB = "99" {
        set _DSKYdisplayREG:VERB to _DSKYdisplayREG:LAST_VERB.
        set _AGC:PERMIT:ENGINE TO TRUE.
    }
    set _DSKY_STATE:PRO TO TRUE.

}

set _inputPRO:onclick to DSKY_buttonHandler_PRO@.

LOCAL FUNCTION DKSY_buttonHandler_KEYREL {
    // key release functionality, will be completed when needed
    // key release basically "releases" the keyboard to the control of the AGC (i.e allows the AGC to display data for you)
    IF _DSKYdisplayREG:LAMPS:KEYREL {
        set _DSKYdisplayREG:LAMPS:KEYREL TO FALSE.
        // allow for the next combination of verb noun to be read and display

        // set the V/N combo
        
        IF _DSKY_STATE:STACK:LENGTH > 0 {
            local _newcombo is _DSKY_STATE:STACK[_DSKY_STATE:stackIndexer].

            set _DSKY_STATE:INHB:INP to "V00N00".
            EXT_DSKY_GCDISPLAYREQ(_newcombo).
            _DSKY_STATE:STACK:REMOVE(0).
        }

        

    }
}

set _inputKEYREL:onclick to DKSY_buttonHandler_KEYREL@.

LOCAL FUNCTION DSKY_buttonHandler_CLR {
    // clear the current register
    IF _DSKY_STATE:INPUT_MODE = "V" {
        set _DSKYdisplayREG:VERB to "".
    } ELSE IF _DSKY_STATE:INPUT_MODE = "N" {
        set _DSKYdisplayREG:NOUN TO "".
    } ELSE IF _DSKY_STATE:INPUT_MODE = "R1" {
        set _DSKYdisplayREG:R1 TO "".
    } ELSE IF _DSKY_STATE:INPUT_MODE = "R2" {
        set _DSKYdisplayREG:R2 to "".
    } ELSE IF _DSKY_STATE:INPUT_MODE = "R3" {
        set _DSKYdisplayREG:R3 to "".
    }
}

set _inputCLR:onclick to DSKY_buttonHandler_CLR@.

LOCAL FUNCTION DKSY_buttonHandler_RSET {
    // resets all the indicator lamps

    DISPLAY_INDICATOR_LAMPS(true, false).
}

set _inputRSET:onclick to DKSY_buttonHandler_RSET@.

// regular old buttons

LOCAL FUNCTION DSKY_buttonHandler_PLUS {
    DSKY_INPUT_HANDLER("+").
}

set _inputPLUS:onclick to DSKY_buttonHandler_PLUS@.

LOCAL FUNCTION DSKY_buttonHandler_MINUS {
    DSKY_INPUT_HANDLER("-").
}
set _inputMINUS:onclick to DSKY_buttonHandler_MINUS@.

LOCAL FUNCTION DKSY_buttonHandler_ZERO {
    DSKY_INPUT_HANDLER("0").
}
set _inputZERO:onclick to DKSY_buttonHandler_ZERO@.

LOCAL FUNCTION DKSY_buttonHandler_ONE {
    DSKY_INPUT_HANDLER("1").
}

set _inputONE:onclick to DKSY_buttonHandler_ONE@.

LOCAL FUNCTION DKSY_buttonHandler_TWO {
    DSKY_INPUT_HANDLER("2").
}

set _inputTWO:onclick to DKSY_buttonHandler_TWO@.

LOCAL FUNCTION DKSY_buttonHandler_THREE {
    DSKY_INPUT_HANDLER("3").
}

set _inputTHREE:onclick to DKSY_buttonHandler_THREE@.

LOCAL FUNCTION DKSY_buttonHandler_FOUR {
    DSKY_INPUT_HANDLER("4").
}

set _inputFOUR:onclick to DKSY_buttonHandler_FOUR@.

LOCAL FUNCTION DKSY_buttonHandler_FIVE {
    DSKY_INPUT_HANDLER("5").
}

set _inputFIVE:onclick to DKSY_buttonHandler_FIVE@.

LOCAL FUNCTION DKSY_buttonHandler_SIX {
    DSKY_INPUT_HANDLER("6").
}

set _inputSIX:onclick to DKSY_buttonHandler_SIX@.

LOCAL FUNCTION DKSY_buttonHandler_SEVEN {
    DSKY_INPUT_HANDLER("7").
}

set _inputSEVEN:onclick to DKSY_buttonHandler_SEVEN@.

LOCAL FUNCTION DKSY_buttonHandler_EIGHT {
    DSKY_INPUT_HANDLER("8").
}

set _inputEIGHT:onclick to DKSY_buttonHandler_EIGHT@.

LOCAL FUNCTION DKSY_buttonHandler_NINE {
    DSKY_INPUT_HANDLER("9").
}

set _inputNINE:onclick to DKSY_buttonHandler_NINE@.


// Handling functions

FUNCTION DSKY_INPUT_HANDLER {
    parameter input is "".
    local _validInput is true. // begin by assuming the input is valid
    local _inputLocation is "". // the part of the _DSKYdisplayREG we wish to place this new value in
    local _currentInputValue is "".
    IF _DSKY_STATE:INPUT_MODE = "V" or _DSKY_STATE:INPUT_MODE = "N" {
        
        IF _DSKY_STATE:INPUT_MODE = "V" {
            set _inputLocation to "VERB".
        } ELSE {
            set _inputLocation to "NOUN".
        }
        set _currentInputValue to _DSKYdisplayREG[_inputLocation].
        IF (input = "+" or input = "-") or _currentInputValue:length >= 2 {
            // OPP ERR

            // NOTE: unsure if i should throw an error for simply having the user go over the maximum length of an input
            set _validInput to false.
        }
    } ELSE IF (_DSKY_STATE:INPUT_MODE = "R1" or _DSKY_STATE:INPUT_MODE = "R2") or _DSKY_STATE:INPUT_MODE = "R3" {
        IF _DSKY_STATE:INPUT_MODE = "R1" {
            set _inputLocation to "R1".
        } ELSE IF _DSKY_STATE:INPUT_MODE = "R2" {
            set _inputLocation to "R2".
        } ELSE IF _DSKY_STATE:INPUT_MODE = "R3" {
            set _inputLocation to "R3".
        }
        set _currentInputValue to _DSKYdisplayREG[_inputLocation].
        // MUST: 
        // start with "+" or "-"
        // be 5 (plus sign) characters long

        // IF it is an octal we are entering (determined through LAST VERB, ensure it is also valid)
        
        IF _currentInputValue:startswith("+") or _currentInputValue:startswith("-") {
            // Double check we arent trying to do something dumb like ++ or -- or any combination of +-
            IF input = "+" or input = "-" {
                // OPP ERR
                set _validInput to false.
            } 
            // is it too long?
            IF _currentInputValue:length > 5 {
                // haha no, OPP ERR for you my good friend!
                set _validInput to false.
            }

        } ELSE IF NOT(input = "+" or input = "-") {
            // lol no
            // OPP ERR

            set _validInput to false.
        }
        ELSE {
            // yeah this is valid... i think

        }
    }
    IF _validInput and _DSKYdisplayREG:haskey(_inputLocation) {
        // CONGRATULATIONS! THIS IS A VALID INPUT FOR THE DSKY
        set _DSKYdisplayREG[_inputLocation] to _DSKYdisplayREG[_inputLocation]+input.
    } ELSE {
        // OPP ERR!
    }
}

LOCAL FUNCTION DSKY_ENTER {
    // ENTER FUNCTION
    // DSKY will read the values inputted and then decide what to do with them

    local _VERB is _DSKYdisplayREG:VERB.
    local _NOUN is _DSKYdisplayREG:NOUN.
    local _R1 is _DSKYdisplayREG:R1.
    local _R2 is _DSKYdisplayREG:R2.
    local _R3 is _DSKYdisplayREG:R3.
    local _INPUT_MODE IS _DSKY_STATE:INPUT_MODE.
    local _canResetInputMode is true.

    print "DSKY ENTER".
    print "PROG: " + _DSKYdisplayREG:PROG.
    print "VERB: " + _DSKYdisplayREG:VERB.
    print "NOUN: " + _DSKYdisplayREG:NOUN.
    print "R1: " + _DSKYdisplayREG:R1.
    print "R2: " + _DSKYdisplayREG:R2.
    print "R3: " + _DSKYdisplayREG:R3.

    set _DSKYdisplayREG:CHANGE_R1 to true.
    set _DSKYdisplayREG:CHANGE_R2 to true.
    set _DSKYdisplayREG:CHANGE_R3 to true.


    // First check the verb
    
    // Display Verbs
    IF _VERB = "01" {
        DSKY_READ_WRITE("READ").
        // Display Octal Component in R1
    } ELSE IF _VERB = "02" {
        DSKY_READ_WRITE("READ").
        // Display Octal Component 2 in R1
    } ELSE IF _VERB = "03" {
        DSKY_READ_WRITE("READ").
        // display octal component 3 in r1
    } ELSE IF _VERB = "04" {
        DSKY_READ_WRITE("READ").
        // display octal component 1,2 in R1,R2
    } ELSE IF _VERB = "05" {
        DSKY_READ_WRITE("READ").
        // display octal component 1,2,3 in R1,R2,R3
    } ELSE IF _VERB = "06" {
        // display decimal 1,2,3 in R1,R2,R3
        DSKY_READ_WRITE("READ").
    } ELSE IF _VERB = 07 {
        // I dont think this is used actually
    }
    // 08-10 are not used

    ELSE IF _VERB = "11" {
        // Monitor Octal component 1 in R1
        DSKY_READ_WRITE("READ").
    } ELSE IF _VERB = "12" {
        // Monitor Octal component 2 in R1
        DSKY_READ_WRITE("READ").
    } ELSE IF _VERB = "13" {
        // Monitor Octal component 3 in R1
        DSKY_READ_WRITE("READ").
    } ELSE IF _VERB = "14" {
        // Monitor Octal components 1,2 in R1,R2
        DSKY_READ_WRITE("READ").
    } ELSE IF _VERB = "15" {
        // Monitor Octal components 1,2,3 in R1,R2,R3
        DSKY_READ_WRITE("READ").
    } ELSE IF _VERB = "16" {
        // Monitor Decimal components 1,2,3 in R1,R2,R3
        DSKY_READ_WRITE("READ").
    } ELSE IF _VERB = "17" {
        // Not used i think
    }

    // 18-20 are not used either

    ELSE IF _VERB = "21" {
        // load component 1 into r1
        // which input mode are we currently in? 
        set _canResetInputMode to false.
        IF NOT(_INPUT_MODE = "R1") {
            // we are currently not modifying this register, therefore we should clear it and then change the mode
            set _DSKYdisplayREG:R1 to "".
            set _DSKY_STATE:INPUT_MODE TO "R1".
        } ELSE {
            // already entering into R1, therefore we can call the READ WRITE FUNCTION
            DSKY_READ_WRITE("WRITE").
            // probably good practice to change the input lock to nothing afterwards
        }
    } ELSE IF _VERB = "22" {
        set _canResetInputMode to false.
        // load component 2 into R2
        // again, which mode are we in?
        IF NOT(_INPUT_MODE = "R2") {
            set _DSKYdisplayREG:R2 TO "".
            set _DSKY_STATE:INPUT_MODE TO "R2".
        } ELSE {
            DSKY_READ_WRITE("WRITE").
        }
    } ELSE IF _VERB = "23" {
        set _canResetInputMode to false.
        IF NOT(_INPUT_MODE = "R3") {
            set _DSKYdisplayREG:R3 to "".
            set _DSKY_STATE:INPUT_MODE TO "R3".
        } ELSE {
            DSKY_READ_WRITE("WRITE").
        }
    } ELSE IF _VERB = "24" {
        set _canResetInputMode to false.
        // special handling here!
        IF NOT(_INPUT_MODE = "R1" or _INPUT_MODE = "R2") {
            set _DSKY_STATE:INPUT_MODE TO "R1".
            set _DSKYdisplayREG:R1 to "".
        }
        IF _INPUT_MODE = "R1" {
            set _DSKY_STATE:INPUT_MODE TO "R2".
            set _DSKYdisplayREG:R2 to "".
        } ELSE IF _INPUT_MODE = "R2" {
            // can read and write all variables#
            DSKY_READ_WRITE("WRITE").
        }
    } ELSE IF _VERB = "25" {
        set _canResetInputMode to false.
        // more special handling!
        IF NOT((_INPUT_MODE = "R1" or _INPUT_MODE = "R2" or _INPUT_MODE = "R3")) {
            set _DSKY_STATE:INPUT_MODE TO "R1".
        }
        IF _INPUT_MODE = "R1" {
            set _DSKY_STATE:INPUT_MODE TO "R2".
            set _DSKYdisplayREG:R2 to "".
        } ELSE IF _INPUT_MODE = "R2" {
            set _DSKY_STATE:INPUT_MODE TO "R3".
            set _DSKYdisplayREG:R3 to "".
        } ELSE IF _INPUT_MODE = "R3" {
            set _canResetInputMode to true.
            DSKY_READ_WRITE("WRITE").
        }
    }
    // 26 not used 
    ELSE IF _VERB = "27" {

        // unsure
    }
    //28 Not used
    //29 Not used
    ELSE IF _VERB = "30" {
        // request executive something
    } ELSE IF _VERB = "31" {
        // request waitlist
    } ELSE IF _VERB = "32" {
        // recycle program
    } ELSE IF _VERB = "33" {
        // Proceede without inputs of dsky
    } ELSE IF _VERB = "34" {
        // TERMINATE PROGRAM/FUNCTION
        _AGC_PROGRAMUPDATE("00"). // goes to P00
    } ELSE IF _VERB = "35" {
        // light test
        DSKY_LIGHTTEST().
    } ELSE IF _VERB = "36" {
        // fresh start whatever that means
    } ELSE IF _VERB = "37" AND NOT(_DSKY_STATE:INHB:V37) {
        // V37 needs some extra handling here:

        // what mode are we currently in in regards to input mode?

        // if we have for instance keyed V37E, we should allow for V37E11E for program changes

        IF _DSKY_STATE:INPUT_MODE = "V" {
            // start flashing
            set _DSKY_STATE:FLASH:V to true.
            set _DSKY_STATE:FLASH:N to true. // will need some adjustment based on the fact that there is a potential for inputs being missed potentially?
            set _canResetInputMode to false.
            DSKY_buttonHandler_NOUN().
        } ELSE IF _DSKY_STATE:INPUT_MODE = "N" {
            // we can activate the program - end flashing
            set _DSKY_STATE:FLASH:V to false.
            set _DSKY_STATE:FLASH:N TO FALSE.

            set _DSKY_STATE:INPUT_MODE to "NO". // none

            _AGC_PROGRAMUPDATE(_DSKYdisplayREG:NOUN).
        }
    } ELSE {
        _extendedVerbs(_VERB).
    }
    IF _canResetInputMode {
        set _DSKYdisplayREG:LAST_VERB to _VERB.
        set _DSKY_STATE:INPUT_MODE to "NO". 
    }
}

FUNCTION DSKY_UPDATE_CYCLE {
    // alias for below
    DSKY_REFRESH_CYCLE().
}

FUNCTION DSKY_REFRESH_CYCLE {
    // refresh cycle for the display
    IF _DSKY_STATE:clock:first = 0 {
        // perform first update
        set _DSKY_STATE:clock:first to time:seconds.
        // convert the refresh rate into seconds so we dont use as many opcodes
        set _DSKY_STATE:clock:refresh to 1-(1/_DSKY_STATE:clock:refresh).
    }
    // now are we going to show or hide the DSKY as of current? 
    IF _isCSM {
        IF AG1 { // now a toggle
            IF _showing { hideDSKY(). }
            ELSE { showDSKY(). }
            AG1 OFF.
        }
    } ELSE IF _isLM {
        IF AG2 {
            IF _showing { hideDSKY(). }
            ELSE { showDSKY(). }
            AG2 OFF.
        }
    }

    // perform the rest of the updates
    set _DSKY_STATE:clock:last to time:seconds.
    set _DSKY_STATE:clock:alive to abs(_DSKY_STATE:clock:first-_DSKY_STATE:clock:last).
    
    // check to see if the time since we last updated the displays _DSKY_STATE:clock:update is greater than the refresh timer
    IF abs(_DSKY_STATE:clock:last-_DSKY_STATE:clock:update) > _DSKY_STATE:clock:refresh {
        // refresh the displays
        set _DSKY_STATE:FLASH:O to NOT(_DSKY_STATE:FLASH:O). // master flash value - basically controlls all of the flashing functionality of the displays
        // check to see if we are flashing either verb or noun
        DISPLAY_INDICATOR_LAMPS(). // do the indicator lamps (rather than set this to a trigger)
        IF _DSKY_STATE:FLASH:O {
            IF (_DSKY_STATE:FLASH:V or _DSKY_STATE:FLASH:N) {
                IF _DSKY_STATE:FLASH:V {
                    DISPLAY_VERB("BLANK").
                } ELSE { DISPLAY_VERB(). }
                IF _DSKY_STATE:FLASH:N {
                    DISPLAY_NOUN("BLANK").
                } ELSE { DISPLAY_NOUN(). }
            }
        } ELSE {
            DISPLAY_VERB_NOUN().
        }
        IF LIST("11", "12", "13", "14", "15", "16"):contains(_DSKYdisplayREG:VERB) and _DSKY_STATE:INPUT_MODE = "NO" {
            // refresh the state first

            DSKY_READ_WRITE("READ", _DSKYdisplayREG:VERB, _DSKYdisplayREG:NOUN).
        }
        
        // refresh the three registers
        IF NOT(_DSKY_STATE:INHB:BLANK_REGISTERS) {
            IF _DSKYdisplayREG:change_r1 { DISPLAY_R1(). }
            IF _DSKYdisplayREG:change_r2 { DISPLAY_R2(). }
            IF _DSKYdisplayREG:change_R3 { DISPLAY_R3(). }
        } ELSE {
            DISPLAY_R1("BLANK").
            DISPLAY_R2("BLANK").
            DISPLAY_R3("BLANK").
        }
        DISPLAY_PROG().
        set _DSKY_STATE:clock:update to time:seconds.
    }

}


LOCAL FUNCTION DSKY_READ_ADDRESS_TABLE {
    parameter vrb is _DSKYdisplayREG:VERB, _non is _DSKYdisplayREG:NOUN.
    // reads the address table for the current sets of V/N and returns a DSKY compatable table

    local _v is vrb.
    local _n is _non.

    local _return is LEXICON("R1", LEXICON("A", "ND", "F", "ND"), "R2", LEXICON("A", "ND", "F", "ND"), "R3", LEXICON("A", "ND", "F", "ND")). // ND - None Defined

    IF DEFINED _MEMORY_ADDRESSES {
        // here we can get the memory addresses for the V/N display combo
        IF _MEMORY_ADDRESSES:haskey(_n) {
            local _adInfo is _MEMORY_ADDRESSES[_n].

            IF NOT(_adInfo:empty) {
                IF _adInfo:length >= 1 {
                    IF _adInfo[0]:haskey("A") and _adInfo[0]:haskey("F") {
                        set _return:R1 to _adInfo[0].
                    }
                }
                IF _adInfo:length >= 2 {
                    IF _adInfo[1]:haskey("A") and _adInfo[1]:haskey("F") {
                        set _return:R2 to _adInfo[1].
                    }
                }
                IF _adInfo:length >=3 {
                    IF _adInfo[2]:haskey("A") and _adInfo[2]:haskey("F") {
                        set _return:R3 to _adInfo[2].
                    }
                }
            }

        }

    }
    return _return.
}

LOCAL FUNCTION DSKY_READ_WRITE {
    parameter md is "READ", vrb is _DSKYdisplayREG:VERB, non is _DSKYdisplayREG:NOUN. // for read and write functions

    local _addressingInfo is DSKY_READ_ADDRESS_TABLE(vrb, non).

    // 1. Do read first because its slightly (by slightly i mean a lot) more complex

    IF md = "READ" {
        local _comp1Disp is "".
        local _comp2Disp is "".
        local _comp3Disp is "".
        local _values is 0.
        FOR i in _addressingInfo:keys {
            set _values to _addressingInfo[i].

            // DSKY DISPLAY: 
            // MUST: 
            // start with PLUS or MINUS
            // contain FIVE NUMERIC CHARACTERS
            
            // check if the address key actually exists

            IF _CORE_MEMORY:haskey(_values:A) {
                // yes it does!
                local _workingValue is _CORE_MEMORY[_values:A].
                local _workingFormat is _values:F.
                local _dp is 0.
                local _neg is false.
                
                IF _MEM_DATATYPES:TIME:contains(_values:A) {
                    // its actually a time value, we therefore must figure out what we display
                    local _maxign is false.
                    IF _addressingInfo[i]:haskey("ignMax") { set _maxign to _addressingInfo[i]:ignMax. }
                    set _workingValue to _DSKY_TIMEDECONSTRUCTOR(_workingValue, _workingFormat, _maxign).
                } ELSE IF _MEM_DATATYPES:VEC:contains(_values:A) {
                    set _workingValue to _DSKY_READ_VECTOR(_workingValue, _workingFormat).
                } ELSE IF _MEM_DATATYPES:LATLNG:contains(_values:A) {
                    set _workingValue to _DSKY_READ_LATLNG(_workingValue, _workingFormat).
                } ELSE IF _MEM_DATATYPES:LISTS:CONTAINS(_values:A) {
                    set _workingValue to _DSKY_READ_LIST(_workingValue, _workingFormat).
                }
                // unit conversion!

                // versions pertaining to future of 10/12/23 will store all _CORE_MEMORY data in metric units, this is to make my (and probably anyone insane enough to develop extra programs for this shoddy thing) lives easier
                // it also makes some display operations easier if im honest

                IF _MEM_DATATYPES:LENGTHS:contains(_values:A) {
                    // what are we wanting to display?

                    // we should assume that the _CORE_MEMORY stores its data in metric units, a sin for an AGC i know but its easier for me who is writing this in 2023 not 1963

                    IF _addressingInfo[i]:haskey("dispIN") {
                        // this has a different display input than its _CORE_MEMORY is stored in

                        // Assume that, and this is also a point of note for potential future updates to this emulation software, the following is true:
                        // 1. Assuming things in data units when you dont really know what you're doing is a bad idea
                        // 2. that all units given to _CORE_MEMORY are in metric 
                        // 3. the LVDC used metric (SATURN V LAUNCH VEHICLE GUIDANCE EQUATIONS SA-504 (apollo 9) states such)
                        // 4. the USA did NOT use metric to land on the moon
                        // 5. due to shoddy humour and assumption 4 is true, checkmate liberal
                        // and on that bombshell, back to the code
                        set _workingValue to convertUnit("me", _addressingInfo[i]:dispIN, _workingValue).
                    }
                }


                IF _workingValue:istype("String") {
                    set _workingValue to _workingValue:tonumber.
                }

                IF NOT(_workingValue >= 0) {
                    set _neg to true.
                    set _workingValue to abs(_workingValue).
                }

                local vString is _workingValue:tostring.
                // get the initial string, we can do formatting on this actually

                local vLength is vString:length-1.
                IF _workingFormat:contains(".") {
                    // decimal point
                    // now we figure out what decimal point we must allow for the value to be placed into
                    IF _workingFormat:contains(".") {
                        set _dp to (_workingFormat:length-1)-_workingFormat:FIND(".").
                    }
                    
                    set _workingValue to _workingValue*10^_dp.
                    set _workingValue to ROUND(_workingValue).
                } ELSE {
                    // we need to set the values to a number that actually works here
                    set _workingValue to ROUND(_workingValue).
                }

                set vString to _workingValue:tostring.

                local _prepad is "".

                

                


                // ensure it conforms to the 5 digit limit

                

                FOR i in _workingFormat {
                    
                    IF i = "0" {
                        set _prepad to "0"+_prepad.
                    } ELSE {
                        break.
                    }
                }
                set vString to _prepad+vString.

                // perform post pad

                local _postpad is "".
                IF vstring:length = 1 {
                    set _postpad to "0000".
                } ELSE IF vstring:length = 2 {
                    set _postpad to "000".
                } ELSE IF vstring:length = 3 {
                    set _postpad to "00".
                } ELSE IF vstring:length = 4 {
                    set _postPad to "0".
                }
                set vString to _postpad+vString.

                // blank handling removed from display due to causing errors


                IF _neg {
                    set vString to "-"+vString.
                } ELSE {
                    set vString to "+" + vstring.
                }
                IF i = "R1" {
                    set _comp1Disp to vString.
                } ELSE IF i = "R2" {
                    set _comp2Disp to vString.
                } ELSE IF i = "R3" {
                    set _comp3Disp to vString.
                }

                // logic for where we put what based upon what the verb is



            } ELSE {
                // no it doesnt!
            }

        }
        local _VERB is vrb.
        local _NOUN is non.
        IF _VERB = "00" and _NOUN = "00" {
            set _DSKYdisplayREG:R1 to "".
            set _DSKYdisplayREG:R2 to "".
            set _DSKYdisplayREG:R3 to "".
        }
        ELSE IF _VERB = "01" {
            set _DSKYdisplayREG:R1 to _comp1Disp.
            set _DSKYdisplayREG:R2 to "".
            set _DSKYdisplayREG:R3 to "".
            // Display Octal Component 1 in R1

            set _DSKYdisplayREG:CHANGE_R1 to true.
        } ELSE IF _VERB = "02" {
            set _DSKYdisplayREG:R1 to _comp2Disp.
            set _DSKYdisplayREG:R2 to "".
            set _DSKYdisplayREG:R3 to "".
            set _DSKYdisplayREG:CHANGE_R1 to true.
            // Display Octal Component 2 in R1
        } ELSE IF _VERB = "03" {
            set _DSKYdisplayREG:R1 to _comp3Disp.
            set _DSKYdisplayREG:R2 to "".
            set _DSKYdisplayREG:R3 to "".
            // display octal component 3 in r1
        } ELSE IF _VERB = "04" {
            set _DSKYdisplayREG:R1 to _comp1Disp.
            set _DSKYdisplayREG:R2 to _comp2Disp.
            set _DSKYdisplayREG:R3 to "".
            // display octal component 1,2 in R1,R2
        } ELSE IF _VERB = "05" {
            set _DSKYdisplayREG:R1 to _comp1Disp.
            set _DSKYdisplayREG:R2 to _comp2Disp.
            set _DSKYdisplayREG:R3 to _comp3Disp.

            // display octal component 1,2,3 in R1,R2,R3
        } ELSE IF _VERB = "06" {
            // display decimal 1,2,3 in R1,R2,R3
            set _DSKYdisplayREG:R1 to _comp1Disp.
            set _DSKYdisplayREG:R2 to _comp2Disp.
            set _DSKYdisplayREG:R3 to _comp3Disp.

            // bug sqashed!
        } ELSE IF _VERB = "07" {
            // I dont think this is used actually
        }
        // 08-10 are not used

        ELSE IF _VERB = "11" {
            // Monitor Octal component 1 in R1
            set _DSKYdisplayREG:R1 to _comp1Disp.
            set _DSKYdisplayREG:R2 to "".
            set _DSKYdisplayREG:R3 to "".
        } ELSE IF _VERB = "12" {
            // Monitor Octal component 2 in R1
            set _DSKYdisplayREG:R1 to _comp2Disp.
            set _DSKYdisplayREG:R2 to "".
            set _DSKYdisplayREG:R3 to "".
        } ELSE IF _VERB = "13" {
            // Monitor Octal component 3 in R1
            set _DSKYdisplayREG:R1 to _comp3Disp.
            set _DSKYdisplayREG:R2 to "".
            set _DSKYdisplayREG:R3 to "".
        } ELSE IF _VERB = "14" {
            // Monitor Octal components 1,2 in R1,R2
            set _DSKYdisplayREG:R1 to _comp1Disp.
            set _DSKYdisplayREG:R2 to _comp2Disp.
            set _DSKYdisplayREG:R3 to "".
        } ELSE IF _VERB = "15" {
            // Monitor Octal components 1,2,3 in R1,R2,R3
            set _DSKYdisplayREG:R1 to _comp1Disp.
            set _DSKYdisplayREG:R2 to _comp2Disp.
            set _DSKYdisplayREG:R3 to _comp3Disp.
        } ELSE IF _VERB = "16" {
            set _DSKYdisplayREG:R1 to _comp1Disp.
            set _DSKYdisplayREG:R2 to _comp2Disp.
            set _DSKYdisplayREG:R3 to _comp3Disp.
        } ELSE IF _VERB = "17" {
            // Not used i think
        }

    } ELSE IF md = "WRITE" {
        local _vrb is _DSKYdisplayREG:VERB.
        local _non is _DSKYdisplayREG:NOUN.

        local _inputAddress is "".
        local _inputFormat is "".
        local _inputString is "".

        // Modification from old versions: 
        // the definition of _inputR1, 2 and 3 are moved up here, mostly unused but at the same time it helps me down at the unit conversion section

        local _inputR1 is _DSKYdisplayREG:R1.
        local _formatR1 is _addressingInfo:R1:F.
        local _addressR1 is _addressingInfo:R1:A.
        local _inputR2 is _DSKYdisplayREG:R2.
        local _formatR2 is _addressingInfo:R2:F.
        local _addressR2 is _addressingInfo:R2:A.
        local _inputR3 is _DSKYdisplayREG:R3.
        local _formatR3 is _addressingInfo:R3:F.
        local _addressR3 is _addressingInfo:R3:A.



        // And now we must convert that thing (the unit) back to where it came from 
        // (or so help me)
        // (this is what this code does, helps me)

        // "READ" includes its own FOR loop to help with unit conversion, its already in a for loop so thereFORe we shall create one here too

        // step 1 - unit conversion!

        local _originalInput is "".
        local _modifiedInput is "".

        FOR i in _addressingInfo:keys {
            IF i = "R1" {
                set _originalInput to _inputR1.
            } ELSE IF i = "R2" {
                set _originalInput to _inputR2.
            } ELSE IF i = "R3" {
                set _originalInput to _inputR3.
            }
            IF _originalInput:istype("String") {
                set _originalInput to _originalInput:toscalar(0).
            }
            IF _addressingInfo[i]:haskey("dispIN") {
                // yes, it does
                local _inputIsGivenInUnitsOf is _addressingInfo[i]:dispIN.
                local _outputNeedstoBeIn is "".
                IF _MEM_DATATYPES:LENGTHS:contains(_addressingInfo[i]:A) {
                    // its a length, convert to meters
                    set _outputNeedstoBeIn to "me".
                    
                } ELSE IF _MEM_DATATYPES:WEIGHTS:contains(_addressingInfo[i]:A) {
                    set _outputNeedstoBeIn to "t".
                }
                set _modifiedInput to convertUnit(_inputIsGivenInUnitsOf, _outputNeedstoBeIn, _originalInput).
            } ELSE {
                // no it does not we dont really need to do much here i dont think
                set _modifiedInput to _originalInput. // actually we will do this for sanitys sake
            }
            IF i = "R1" {
                set _inputR1 to _modifiedInput.
            } ELSE IF i = "R2" {
                set _inputR2 to _modifiedInput.
            } ELSE IF i = "R3" {
                set _inputR3 to _modifiedInput.
            }
        }

        IF _vrb = "21" {
            PUSH_2_MEM(_inputR1, _formatR1, _addressR1).
        } ELSE IF _vrb = "22" {
            PUSH_2_MEM(_inputR2, _formatR2, _addressR2).
        } ELSE IF _vrb = "23" {
            PUSH_2_MEM(_inputR3, _formatR3, _addressR3).
        } ELSE IF _vrb = "24" {
            // here we dont really care if the 
            PUSH_2_MEM(_inputR1, _formatR1, _addressR1).
            PUSH_2_MEM(_inputR2, _formatR2, _addressR2).
        } ELSE IF _vrb = "25" {
            PUSH_2_MEM(_inputR1, _formatR1, _addressR1).
            PUSH_2_MEM(_inputR2, _formatR2, _addressR2).
            PUSH_2_MEM(_inputR3, _formatR3, _addressR3).
        }
        set _DSKY_STATE:INPUT_MODE to "NONE".
        set _DSKYdisplayREG:VERB to _DSKYdisplayREG:LAST_VERB.
    }
}


// Display functionality (IN DEVELOPMENT) for using images as "text"

// general method of displaying data
// step 1: what are we displaying?
// step 2: split the display input string into a list to allow for output
// step 3: Do some magic?

LOCAL FUNCTION DISPLAY_PROG {
    parameter displayString is _DSKYdisplayREG:PROG.
    local _toDisplay is list("AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK"). // default to the blank variations of the screen for safechecking
    local _slot1_current is _PROGDISP_1:image.
    local _slot2_current is _PROGDISP_2:image.

    // the program display must always consist of 2 characters, this is why i am doing it first as its easier

    local _displayIndexer is 0.
    
    IF NOT(displayString = "BLANK") {
        FOR i in displayString {
            IF NOT(i = " ") { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/" + i. }
            ELSE { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/BLANK". }
            set _displayIndexer to _displayIndexer+1.
        }
    }


    // do the displaying of the information

    set _PROGDISP_1:image to _toDisplay[0].
    set _PROGDISP_2:image to _toDisplay[1].
}

// will impliment BLANK flashing display at a later date
LOCAL FUNCTION DISPLAY_VERB_NOUN {
    DISPLAY_VERB().
    DISPLAY_NOUN().
}

LOCAL FUNCTION DISPLAY_VERB {
    // display for VERB specificially - a copy of DISPLAY_NOUN but for verb
    parameter displayString is _DSKYdisplayREG:VERB.

    local _toDisplay is list("AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK").
    local _displayIndexer is 0.
    IF NOT(displayString = "BLANK") {
        FOR i in displayString {
            IF NOT(i = " ") { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/" + i. }
            ELSE { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/BLANK". }
            set _displayIndexer to _displayIndexer+1.
        }
    }

    set _VERBDISP1:image to _toDisplay[0].
    set _VERBDISP2:image to _toDisplay[1].
}

LOCAL FUNCTION DISPLAY_NOUN {
    // display for VERB specificially - a copy of DISPLAY_NOUN but for verb
    parameter displayString is _DSKYdisplayREG:NOUN.
    local _toDisplay is list("AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK").
    local _displayIndexer is 0.
    IF NOT(displayString = "BLANK") {
        FOR i in displayString {
            IF NOT(i = " ") { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/" + i. }
            ELSE { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/BLANK". }
            set _displayIndexer to _displayIndexer+1.
        }
    }
    

    set _NOUNDISP1:image to _toDisplay[0].
    set _NOUNDISP2:image to _toDisplay[1].
}


// register display functions

LOCAL FUNCTION REGISTER_DISPLAY {
    parameter r1_disp is _DSKYdisplayREG:R1, r2_disp is _DSKYdisplayREG:R2, r3_disp is _DSKYdisplayREG:R3.

    DISPLAY_R1(r1_disp).
    DISPLAY_R2(r2_disp).
    DISPLAY_R3(r3_disp).
}

LOCAL FUNCTION DISPLAY_R1 {
    parameter displayString is _DSKYdisplayREG:R1.
    IF _DSKYdisplayREG:CHANGE_R1 {
        local _toDisplay is list("AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK").
        local _displayIndexer is 0.
        IF NOT(displayString = "BLANK") {
            FOR i in displayString {
                IF _displayIndexer > _toDisplay:length-1 { break. }
                IF NOT(i = " ") { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/" + i. }
                ELSE { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/BLANK". }
                set _displayIndexer to _displayIndexer+1.
            }
        }

        set _R1SGN:image to _toDisplay[0].
        set _R11:image to _toDisplay[1].
        set _R12:image to _toDisplay[2].
        set _R13:image to _toDisplay[3].
        set _R14:image to _toDisplay[4].
        set _R15:image to _toDisplay[5].
        set _DSKYdisplayREG:CHANGE_R1 to false.
        DISPLAY_LINES().
    }
}

LOCAL FUNCTION DISPLAY_R2 {
    parameter displayString is _DSKYdisplayREG:R2.
    IF _DSKYdisplayREG:CHANGE_R2 {
        local _toDisplay is list("AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK").
        local _displayIndexer is 0.
        IF NOT(displayString = "BLANK") {
            FOR i in displayString {
                IF _displayIndexer > _toDisplay:length-1 { break. }
                IF NOT(i = " ") { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/" + i. }
                ELSE { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/BLANK". }
                set _displayIndexer to _displayIndexer+1.
            }
        }

        set _R2SGN:image to _toDisplay[0].
        set _R21:image to _toDisplay[1].
        set _R22:image to _toDisplay[2].
        set _R23:image to _toDisplay[3].
        set _R24:image to _toDisplay[4].
        set _R25:image to _toDisplay[5].
        set _DSKYdisplayREG:CHANGE_R2 to false.
        DISPLAY_LINES().
    }
}

LOCAL FUNCTION DISPLAY_R3 {
    parameter displayString is _DSKYdisplayREG:R3.
    IF _DSKYdisplayREG:CHANGE_R3 {
        local _toDisplay is list("AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK", "AGC textures/EL DISP/BLANK").
        local _displayIndexer is 0.
        IF NOT(displayString = "BLANK") {
            FOR i in displayString {
                IF _displayIndexer > _toDisplay:length-1 { break. }
                IF NOT(i = " ") { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/" + i. }
                ELSE { set _toDisplay[_displayIndexer] to "AGC textures/EL DISP/BLANK". }
                set _displayIndexer to _displayIndexer+1.
            }
        }

        set _R3SGN:image to _toDisplay[0].
        set _R31:image to _toDisplay[1].
        set _R32:image to _toDisplay[2].
        set _R33:image to _toDisplay[3].
        set _R34:image to _toDisplay[4].
        set _R35:image to _toDisplay[5].
        set _DSKYdisplayREG:CHANGE_R3 to false.
        DISPLAY_LINES().
    }
}

LOCAL FUNCTION DISPLAY_LINES {
    set _LINE1:IMAGE TO "AGC textures/EL DISP/LINE".
    set _LINE2:IMAGE TO "AGC textures/EL DISP/LINE".
    set _LINE3:image to "AGC textures/EL DISP/LINE".
}

LOCAL FUNCTION DISPLAY_INDICATOR_LAMPS {
    parameter setValue is false, newValue is false.

    IF setValue {
        // enables function to be used for resetting all values
        
        set _DSKYdisplayREG:LAMPS:UPLINK to newValue.
        set _DSKYdisplayREG:LAMPS:TEMP to newValue.
        set _DSKYdisplayREG:LAMPS:NOATT to newValue.
        set _DSKYdisplayREG:LAMPS:STBY to newValue.
        set _DSKYdisplayREG:LAMPS:GIMBAL_LOCK to newValue.
        set _DSKYdisplayREG:LAMPS:PROG to newValue.
        set _DSKYdisplayREG:LAMPS:NODAP to newValue.
        set _DSKYdisplayREG:LAMPS:PRIODISP to newValue.
        set _DSKYdisplayREG:LAMPS:OPPERR to newValue.
        set _DSKYdisplayREG:LAMPS:KEYREL to newValue.
        set _DSKYdisplayREG:LAMPS:RESTART to newValue.
        set _DSKYdisplayREG:LAMPS:TRACKER to newValue.
        set _DSKYdisplayREG:LAMPS:ALT to newValue.
        set _DSKYdisplayREG:LAMPS:VEL to newValue.
    }
    // the indicator lamp displays wider function, does all of them because I am a VERY lazy person

    // it is my understanding too that some indicators would flash and some would just be static, getting a button to flash is simple
    // just take the buttons' indicator variable and the overall flash value (_DSKY_STATE:FLASH:O)

    // Row 1
    INDICATORLAMP_UPLINKACTY().
    INDICATORLAMP_TEMP().
    // row 2
    INDICATORLAMP_NOATT().
    INDICATORLAMP_GIMBALLOCK().
    // row 3
    INDICATORLAMP_STBY().
    INDICATORLAMP_PROG().
    // row 4
    INDICATORLAMP_KEYREL().
    INDICATORLAMP_RESTART().
    // row 5
    INDICATORLAMP_OPRERR().
    INDICATORLAMP_TRACKER().
    
    // row 6 and row 7 is where it gets interesting, at least in the handling functions

    
    IF _isLM {

        // row 6

        IF MissionEmulation >= 15 { INDICATORLAMP_PRIODISP(). }
        IF MissionEmulation >= 11 { INDICATORLAMP_ALT(). }

        // row 7

        IF MissionEmulation >= 15 { INDICATORLAMP_NODAP(). }
        IF MissionEmulation >= 11 { INDICATORLAMP_VEL(). }

    }
    
    set _DSKYdisplayREG:change_lamp to false.

}

LOCAL FUNCTION INDICATORLAMP_UPLINKACTY {
    parameter _state is _DSKYdisplayREG:LAMPS:UPLINK.
    IF _state {
        set _CW_UPLINKACTY:image to "AGC textures/INSTRUMENTATION/ON/UPLINK ACTY".
    } ELSE {
        set _CW_UPLINKACTY:image to "AGC textures/INSTRUMENTATION/OFF/UPLINK ACTY".
    }
}

LOCAL FUNCTION INDICATORLAMP_TEMP {
    parameter _state is _DSKYdisplayREG:LAMPS:TEMP.

    IF _state {
        set _CW_TEMP:image to "AGC textures/INSTRUMENTATION/ON/TEMP".
    } ELSE {
        set _CW_TEMP:image to "AGC textures/INSTRUMENTATION/OFF/TEMP".
    }
}

LOCAL FUNCTION INDICATORLAMP_NOATT {
    parameter _state is _DSKYdisplayREG:LAMPS:NOATT.

    IF _state {
        set _CW_NOATT:image to "AGC textures/INSTRUMENTATION/ON/NO ATT".
    } ELSE {
        set _CW_NOATT:image to "AGC textures/INSTRUMENTATION/OFF/NO ATT".
    }
}

LOCAL FUNCTION INDICATORLAMP_GIMBALLOCK {
    parameter _state is _DSKYdisplayREG:LAMPS:GIMBAL_LOCK.

    

    IF _state {
        set _CW_GIMBALOCK:image to "AGC textures/INSTRUMENTATION/ON/GIMBAL LOCK".
    } ELSE {
        set _CW_GIMBALOCK:image to "AGC textures/INSTRUMENTATION/OFF/GIMBAL LOCK".
    }
}

LOCAL FUNCTION INDICATORLAMP_STBY {
    parameter _state is _DSKYdisplayREG:LAMPS:STBY.

    IF _state {
        set _CW_STBY:image to "AGC textures/INSTRUMENTATION/ON/STBY".
    } ELSE {
        set _CW_STBY:image to "AGC textures/INSTRUMENTATION/OFF/STBY".
    }
}

LOCAL FUNCTION INDICATORLAMP_PROG {
    parameter _state is _DSKYdisplayREG:LAMPS:PROG.

    IF _state {
        set _CW_PROG:image to "AGC textures/INSTRUMENTATION/ON/PROG".
    } ELSE {
        set _CW_PROG:image to "AGC textures/INSTRUMENTATION/OFF/PROG".
    }
}

LOCAL FUNCTION INDICATORLAMP_KEYREL {
    parameter _state is (_DSKYdisplayREG:LAMPS:KEYREL) and NOT(_DSKY_STATE:FLASH:O).

    IF _state {
        set _CW_KEYREL:image to "AGC textures/INSTRUMENTATION/ON/KEY REL".
    } ELSE {
        set _CW_KEYREL:image to "AGC textures/INSTRUMENTATION/OFF/KEY REL".
    }
}

LOCAL FUNCTION INDICATORLAMP_RESTART {
    parameter _state is _DSKYdisplayREG:LAMPS:RESTART.

    IF _state {
        set _CW_RESTART:image to "AGC textures/INSTRUMENTATION/ON/RESTART".
    } ELSE {
        set _CW_RESTART:image to "AGC textures/INSTRUMENTATION/OFF/RESTART".
    }
}

LOCAL FUNCTION INDICATORLAMP_OPRERR {
    parameter _state is _DSKYdisplayREG:LAMPS:OPPERR and NOT(_DSKY_STATE:FLASH:O).

    IF _state {
        set _CW_OPPERR:image to "AGC textures/INSTRUMENTATION/ON/OPR ERR".
    } ELSE {
        set _CW_OPPERR:image to "AGC textures/INSTRUMENTATION/OFF/OPR ERR".
    }
}

LOCAL FUNCTION INDICATORLAMP_TRACKER {
    parameter _state is _DSKYdisplayREG:LAMPS:TRACKER.

    IF _state {
        set _CW_TRACKER:image to "AGC textures/INSTRUMENTATION/ON/TRACKER".
    } ELSE {
        set _CW_TRACKER:image to "AGC textures/INSTRUMENTATION/OFF/TRACKER".
    }
}

LOCAL FUNCTION INDICATORLAMP_PRIODISP {
    parameter _state is _DSKYdisplayREG:LAMPS:PRIODISP.
    IF _state {
        set _CW_PRIODISP:image to "AGC textures/INSTRUMENTATION/ON/PRIO DISP".
    } ELSE {
        set _CW_PRIODISP:image to "AGC textures/INSTRUMENTATION/OFF/PRIO DISP".
    }
}

LOCAL FUNCTION INDICATORLAMP_ALT {
    parameter _state is _DSKYdisplayREG:LAMPS:ALT.

    IF _state {
        set _CW_ALT:image to "AGC textures/INSTRUMENTATION/ON/ALT".
    } ELSE {
        set _CW_ALT:image to "AGC textures/INSTRUMENTATION/OFF/ALT".
    }
}

LOCAL FUNCTION INDICATORLAMP_NODAP {
    parameter _state is _DSKYdisplayREG:LAMPS:NODAP.

    IF _state {
        set _CW_NODAP:image to "AGC textures/INSTRUMENTATION/ON/NO DAP".
    } ELSE {
        set _CW_NODAP:image to "AGC textures/INSTRUMENTATION/OFF/NO DAP".
    }
}

LOCAL FUNCTION INDICATORLAMP_VEL {
    parameter _state is _DSKYdisplayREG:LAMPS:VEL.

    IF _state {
        set _CW_VEL:image to "AGC textures/INSTRUMENTATION/ON/VEL".
    } ELSE {
        set _CW_VEL:image to "AGC textures/INSTRUMENTATION/OFF/VEL".
    }
}


FUNCTION COMP_ACTY {
    parameter _state is false.

    IF _state {
        set _EL_COMPACTY:image to "AGC textures/EL DISP/COMP ACTY ON".
    } ELSE {
        set _EL_COMPACTY:image to "AGC textures/EL DISP/COMP ACTY OFF".
    }
}


LOCAL FUNCTION PUSH_2_MEM {
    parameter var is "", form is "", addr is "".
    local _originalValue is var. // for when we do times, it makes it easier, trust me here
    // variable, format, address
    local _dp is 0.
    IF form:contains(".") {
        set _dp to (form:length-1)-form:FIND(".").
    }
    IF NOT(var:istype("Scalar")) {
        set _outputScalar to var:tonumber*10^(-_dp).
    } ELSE {
        set _outputScalar to var*10^(-_dp).
    }
    


    // BUT WE'RE NOT DONE YET! 

    // handling for special formats like vectors and times must be accounted for!

    // it is with times of which i realise why the checklist requests the astronauts to modifiy times using V25

    // vectors are simple however

    IF _MEM_DATATYPES:VEC:contains(addr) {
        // this is a vector
        // what do we modify here
        local _prev is _CORE_MEMORY[addr].
        IF form:startswith("A") {
            // we are modifying the X part of the vector
            set _prev:X to _outputScalar.
        } ELSE IF form:startswith("B") {
            // Y part of the vector
            set _prev:Y to _outputScalar.
        } ELSE IF form:startswith("C") {
            set _prev:Z to _outputScalar.
        }
        set _outputScalar to _prev.
        // and thats vectors, literally all we do here
    } ELSE IF _MEM_DATATYPES:TIME:contains(addr) {
        // oh boy look what you've done to yourself here
        // i warn the reader, the next few lines are probably going to hurt your brain and eyes

        // setup some flags so we know what we are modifying here
        local _modifH is false.
        local _modifM is false.
        local _modifS is false.

        local _prev is _CORE_MEMORY[addr].
        local _prevH is 0.
        local _prevM is 0.
        local _prevS is 0.

        local _newTime is 0.
        local _newHours is 0.
        local _newMinutes is 0.
        local _newSeconds is 0.

        // setup the previous values

        IF NOT(_prev:istype("timespan")) {
            set _prev to timespan(prev).
        }
        // in practice, all of these actually should equal what we were given, but for ease of use i will force the code to use HOURS for the first format
        set _prevH to FLOOR(_prevH:hours).
        set _prevM to _prev:minute.
        set _prevS to _prev:second.




        local _inp is 0.
        local _inpH is "".
        local _inpM is "".
        local _inpS is "".
        // Im unsure if you can modify those with MMbSS however i will allow such cases to ensure that it can be done incase someone decides it needs to be done for a program created for this agc

        // okay, so thats that began

        // now we need to integrate the input values

        set _inp to _originalValue. // do this as a string to ensure that it actually conforms to the format
        // now where do we begin?
        // considering that formats are all 5 or 6 characters long and that scalars are 
        local formIndxr is 0.
        local lastModif is "M".
        FOR i in form {
            IF i = "H" {
                set _inpH to _inpH+_inp[formIndxr].
                set lastModif to "H".
                set _modifH to true.
            } ELSE IF i = "M" {
                set _inpM to _inpM+_inp[formIndxr].
                set lastModif to "M".
                set _modifM to true.
            } ELSE IF i = "S" {
                set _inpS to _inpS+_inp[formIndxr].
                set lastModif to "S".
                set _modifS to true.
            } ELSE IF i = "." {
                IF lastModif = "H" {
                    set _inpH to _impH+".".
                } ELSE IF lastModif = "M" {
                    set _inpM to _inpM+".".
                } ELSE IF lastModif = "S" {
                    set _inpS to _inpS+".".
                }
            }
            set formIndxr to formIndxr+1.
        }

        // now we can setup the values properly

        // convert these into numbers

        set _inpH to _inpH:tonumber(0).
        set _inpM to _inpM:tonumber(0).
        set _inpS to _inpS:tonumber(0).

        IF _modifH {
            set _newHours to _inpH.
        } ELSE {
            set _newHours to _prevH.
        }
        IF _modifM {
            set _newMinutes to _inpM.
        } ELSE {
            set _newMinutes to _prevM.
        }
        IF _modifS {
            set _newSeconds to _inpS.
        } ELSE {
            set _newSeconds to _prevS.
        }

        // now we integrate

        set _newHours to _newHours*3600.
        set _newMinutes to _newMinutes*60.
        set _newSeconds to _newSeconds*1. // sanity check

        set _newTime to _newHours+_newMinutes+_newSeconds.

        set _outputScalar to _newTime.


    }

    IF _CORE_MEMORY:haskey(addr) {
        set _CORE_MEMORY[addr] to _outputScalar.
    }
}

LOCAL FUNCTION DSKY_LIGHTTEST {
    // DSKY LIGHT TEST: 
    // This sets ALL LIGHTS TO THE "ON" POSITION FOR 6 SECONDS
    // DISPLAYS 88 in PROG, VERB and NOUN with V/N FLASHING
    // DISPLAYS +88888 IN THE THREE ROW REGISTERS

    // NOTE: DSKY LIGHT TEST IS ONLY AVAILABLE IN CMC IDLE MODE OR WITHOUT ANYTHING RUNNING
    IF _DSKYdisplayREG:PROG = "00" {
        local _flashStartTime is _CORE_MEMORY:TIME2.

        // set all the possible inputs to "ON"
        
        // start with instrument lamps

        DISPLAY_INDICATOR_LAMPS(true,true).

        set _DSKYdisplayREG:VERB to "88".
        set _DSKYdisplayREG:NOUN to "88".
        set _DSKYdisplayREG:PROG to "88".

        // set the registers

        set _DSKYdisplayREG:R1 to "+88888".
        set _DSKYdisplayREG:R2 to "+88888".
        set _DSKYdisplayREG:R3 to "+88888".


        set _DSKY_STATE:FLASH:V TO TRUE.
        set _DSKY_STATE:FLASH:N to TRUE.
        

        when _CORE_MEMORY:TIME2 > _flashStartTime+6 then {
            // switch all of the instruments off and stop flashing

            set _DSKY_STATE:FLASH:V to false.
            set _DSKY_STATE:FLASH:N to false.

            set _DSKYdisplayREG:PROG TO "00".

            DISPLAY_INDICATOR_LAMPS(true,false).
        }

    }

    
}

LOCAL FUNCTION _INTERPRET {
    // interprets a code such as V00N00 ect ect
    parameter _codeToInterpret is "V00N00".

    local _rVERB is "00".
    local _rNOUN is "00".
    local _rFLASH is false.
    IF _codeToInterpret:contains("FL") { set _rFLASH to true. }
    IF _codeToInterpret:contains("V") {
        local _vIndx is _codeToInterpret:FIND("V")+1.
        set _rVERB to _codeToInterpret[_vIndx].
        set _rVERB to _rVERB+_codeToInterpret[_vIndx+1].
    }
    IF _codeToInterpret:contains("N") {
        local _vIndx is _codeToInterpret:FIND("N")+1.
        set _rNOUN to _codeToInterpret[_vIndx].
        set _rNOUN to _rNOUN+_codeToInterpret[_vIndx+1].
    } ELSE {
        set _rNOUN to _DSKYdisplayREG:NOUN.
    }

    return lexicon("VERB", _rVERB, "NOUN", _rNOUN, "FLASH", _rFLASH).
}



LOCAL FUNCTION _DSKY_TIMEDECONSTRUCTOR {
    // function to help development
    parameter tValue is time:seconds, tFormat is "MMbSS", ignoremaximums is false.

    local _vTS is 0.

    // as timespan

    // general method
    // get the timestamp of the value

    IF tValue:istype("String") { set tValue to tValue:tonumber. }
    IF NOT(tValue:istype("timespan")) { set tValue to timespan(tValue). }

    set _vTS to tValue.

    // we have the timestamp, now we create the following values for the possible variables we could impliment

    local _valHOURS is _vTS:hours.
    local _valHOUR is _vTS:hour.
    local _valMINUTES is _vTS:minutes.
    local _valMINUTE is _vTS:minute.
    local _valSECONDS is _vTS:seconds.
    local _valSECOND is _vTS:second.
    local _valCENTISECONDS is abs(FLOOR(_vTS:seconds)-_vTS:seconds). // with only the decimal place

    local highestValue is "N".
    local hasH is 0.
    local hasM is 0.
    local hasS is 0.
    local hasDECIMAL is false.

    FOR i in tFormat {
        IF (i = "H" or i = "M" or i = "S") {
            IF i = "H" and not(hasH) {
                set hasH to 1.
                set highestValue to "H".
            } ELSE IF i = "M" and not(hasM) {
                set hasM to 1.
                IF NOT(highestValue = "H") { set highestValue to "M". }
            } ELSE IF i = "S" and not(hasS) {
                set hasS to 1.
                IF NOT(highestValue = "M" or highestValue = "H") { set highestValue to "S". }
            }
        }
        IF i = "." and not(hasDECIMAL) { set hasDECIMAL to true. }
    }

    IF hasH+hasM+hasS > 1 {
        // there are two values here
        set ignoremaximums to true.
    }

    // we can safely assume to ignore our maximum values on our largest value unless already specified

    // general rule to be enforced
    // highest value in the format will ignore maximums, other values will not

    local _rH is 0.
    local _rM is 0.
    local _rS is 0.

    IF ignoreMaximums {
        IF highestValue = "H" { 
            set _rH to FLOOR(_valHOURS).
            set _rM to _valMINUTE.
            set _rS to _valSECOND.
        } // no agc component needs a decimal for hours or minutes
        ELSE IF highestValue = "M" {
            set _rM to FLOOR(_valMINUTES).
            set _rS to _valSECOND.
        } ELSE IF highestValue = "S" {
            set _rS to _valSECOND. // we will sortout centiseconds in a moment
        }
    } ELSE {
        set _rH to _valHOUR.
        set _rM to _valMINUTE.
        set _rS to _valSECOND.
    }

    // second pass through the format determines the following:
    // how long each segment needs to be
    // how i integrate the string
    // how long each segment of the string must be

    // for example
    // MMbSS.SS
    // will return a lexicon with the following keys with the values shown
    //
    // key: integration
    // value: LIST("M", "b", "S")  - CS for centiseconds though that doesnt matter with my better implimentation of reading the core memory
    //
    // key: lengths - note it is not length because lexicon already contains a length suffix
    // value: is another lexicon containing H M and S with the key of these values being the length required of the string
    //
    // key: max value
    // a lexicon containing the maximum allowable number in the value

    local _integrationInformation is lexicon(
        "integration", list(),
        "lengths", lexicon("h", 0, "m", 0, "s", 0, "b", 0),
        "maxValue", lexicon("h", 999999, "m", 99999, "s", 99999)
    ).



    FOR i in tFormat {
        IF (i = "H" or i = "M") or (i = "b" or i = "s") {
            IF NOT(_integrationInformation:integration:contains(i)) or i = "b" { _integrationInformation:integration:add(i). }
            IF _integrationInformation:lengths:haskey(i) {
                IF i = "H" {
                    set _integrationInformation:lengths:h to _integrationInformation:lengths:h+1.
                } ELSE IF i = "M" {
                    set _integrationInformation:lengths:m to _integrationInformation:lengths:m+1.
                } ELSE IF i = "S" {
                    set _integrationInformation:lengths:s to _integrationInformation:lengths:s+1.
                } ELSE IF i = "b" {
                    set _integrationInformation:lengths:b to _integrationInformation:lengths:b+1.
                }
                
            }
        } ELSE IF i = "." { break. }
    }
    // setup the maxvalue

    set _integrationInformation:maxvalue:h to (1*10^_integrationInformation:lengths:h)-1.
    set _integrationInformation:maxvalue:m to (1*10^_integrationInformation:lengths:m)-1.
    set _integrationInformation:maxvalue:s to (1*10^_integrationInformation:lengths:s)-1.
    set _rH to min(_rH, _integrationInformation:maxvalue:h).
    set _rM to min(_rM, _integrationInformation:maxvalue:m).
    set _rS to min(_rS, _integrationInformation:maxvalue:s).
    // check that our values arent greater than what is allowed
    set _rH to abs(_rH).
    set _rM to abs(_rM).
    set _rS to abs(_rS).

    set _rH to _rH:tostring.
    set _rM to _rM:tostring.
    set _rS to _rS:tostring.

    IF _rS:toscalar(10) < 10 {
        set _integrationInformation:lengths:b to _integrationInformation:lengths:b+1.
    }

    local _inputvalues is lexicon("h", _rH, "m", _rM, "s", _rS).
    local _outputValues is lexicon("h", "", "m", "", "s", "").

    FOR i in _inputValues:keys {
        local _val is _inputValues[i].
        local _requiredLength is _integrationInformation:lengths[i].
        local _requiredPadding is (_requiredLength-_val:length)-_integrationInformation:lengths:b.
        IF _requiredPadding = 1 {
            set _outputValues[i] to "0"+_val.
        } ELSE IF _requiredPadding = 2 {
            set _outputValues[i] to "00"+_val.
        } ELSE IF _requiredPadding = 3 {
            set _outputValues[i] to "000"+_val.
        } ELSE IF _requiredPadding = 4 {
            set _outputValues[i] to "000"+_val.
        } ELSE IF _requiredPadding = 5 {
            set _outputValues[i] to "00000"+_val.
        } ELSE {
            set _outputValues[i] to _val.
        }
    }
    IF NOT(_outputValues:s = "") {
        set _outputValues:s to _outputValues:s:tonumber.
        set _outputValues:s to _outputValues:s+_valCENTISECONDS.
        set _outputValues:s to _outputValues:s:tostring.
    }

    // integrate into the final string
    local _outputString is "".
    FOR i in _integrationInformation:integration {
        IF i = "H" {
            set _outputString to _outputString+_outputValues:H.
        } ELSE IF i = "M" { set _outputString to _outputString+_outputValues:M. }
        ELSE IF i = "S" { 
            // is "S" < 10?
            IF _outputValues:S:toscalar(10) < 10 {
                set _outputString to _outputString+"0"+_outputValues:S.
            }
            ELSE { set _outputString to _outputString+_outputValues:S. }
        }
        ELSE IF i = "b" { set _outputString to _outputString+"0".} // re added blank handling here because say we wanted 50b30 it would display as 05030 rather than 50030
    }
    return _outputString.

}

LOCAL FUNCTION _DSKY_VALIDATE_OCTAL {
    parameter toValidate is "".
    IF toValidate:istype("Scalar") {
        set toValidate to toValidate:tostring.
    }
    FOR i in toValidate {

    }
}

LOCAL FUNCTION _DSKY_READ_VECTOR {
    parameter vecRead is "", form is "".
    // form can start with A B or C
    // A - X
    // B - Y
    // C - Z

    IF vecRead:istype("Vector") {
        IF form:startswith("A") {
            return vecRead:X.
        } ELSE IF form:startswith("B") {
            return vecRead:Y.
        } ELSE IF form:startswith("C") {
            return vecRead:Z.
        } ELSE IF form:startswith("M") {
            // for MAG
            return vecRead:MAG.
        }
    }
}

LOCAL FUNCTION _DSKY_READ_LATLNG {
    parameter latlngRead is LATLNG(ship:geoposition:lat, ship:geoposition:lng), form is "".

    IF form:startswith("LAT") {
        return latlngRead:lat.
    } ELSE IF form:startswith("lng") {
        return latlngRead:lng.
    }
}

LOCAL FUNCTION _DSKY_READ_LIST {
    parameter listRead is list(), form is "".
    local _indexToRead is form[0]:toscalar(0).

    IF _indexToRead <= listRead:length-1 {
        // we can read this
        return listRead[_indexToRead].
    } ELSE {
        return 0.
    }
}


// EXTERNAL DSKY INTERFACING FUNCTIONS

FUNCTION EXT_DSKY_GCDISPLAYREQ {
    parameter disp_req is "", _PRO_OVERRIDE IS FALSE.
    local _orig is disp_req.
    // allows the AGC to display data on the DSKY upon request
    set disp_req to _INTERPRET(disp_req).

    // check to see if the VN set provided is an important display item (i.e V99 ect ect)
    // so we check for priority verbs first

    IF _orig:contains("V99") {
        // OVERIDE!
        set _DSKYdisplayREG:LAST_VERB to _DSKYdisplayREG:VERB.
        set _DSKYdisplayREG:VERB to disp_req:VERB.
        set _DSKY_STATE:FLASH:V to true.
        set _DSKY_STATE:FLASH:N to true.
    } ELSE IF _orig = "BLANK REGISTERS" {
        // blank the screen, ultimate priority imo i think
        DISPLAY_R1("BLANK").
        DISPLAY_R2("BLANK").
        DISPLAY_R3("BLANK").
    }

    // check to see which combination we are displaying currently, if these two match or if we are currently keyed to V00N00 we will allow the data to be displayed, otherwise we will activate the KEYREL button
    IF NOT(_orig = "BLANK REGISTERS") and (NOT(_PRO_OVERRIDE) and (NOT(_DSKY_STATE:INHB:INP = _orig or _DSKY_STATE:INHB:INP = "V00N00") and NOT(_DSKY_STATE:STACK:CONTAINS(_orig)))) {
        // if the verb doesnt equal 99 we set keyrel flag
        IF NOT(_DSKYdisplayREG:VERB = "99") {
            _DSKY_STATE:STACK:ADD(_orig).
            set _DSKYdisplayREG:KEYREL to true.
        }
        
    } ELSE IF NOT(_orig = "BLANK_REGISTERS") {
        // display the combination by just setting the registers (they will update in the next cycle so its okay)
        // actually dont do this because uh, it may cause problems when this updates every cycle
        // maybe uh something like this
        set _DSKY_STATE:FLASH:V to disp_req:FLASH.
        set _DSKY_STATE:FLASH:N to disp_req:FLASH.
        IF _DSKY_STATE:INPUT_MODE = "NO" or _DSKY_STATE:INPUT_MODE = "NONE" {
            // we can display the VN combo
            IF NOT(_DSKYdisplayREG:VERB = "99") { set _DSKYdisplayREG:VERB to disp_req:VERB. }
            set _DSKYdisplayREG:NOUN to disp_req:NOUN.
            
        }
        set _DSKY_STATE:INHB:INP to _orig.
        DSKY_READ_WRITE("READ", disp_req:VERB, disp_req:NOUN).
    }
}

FUNCTION EXT_DSKY_PROG {
    parameter newProgram is "00". // for when a new program runs
    set _DSKYdisplayREG:PROG to newProgram.
}

FUNCTION showDSKY {
    DSKY:show.
    set _showing to true.
}

FUNCTION hideDSKY { 
    DSKY:hide.
    set _showing to false.
}

showDSKY().