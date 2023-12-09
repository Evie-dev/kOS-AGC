// DSKY version 2 with somewhat improved behaviour and a cleaner codebase, please note this is a development file name so i can easily differenciate between DSKY version 1 and DSKY version 2
// the code relating to the formation, button pressing and such will be practically the same to the previous DSKY version however the code should be a lot easier to maintain, understand and use

// My main reasoning for what i can really only describe as a half-rewrite is to make DSKY_READ_WRITE and the display be allowed to have some better integration with how the actual AGC functioned
// I realised fairly quickly that implimenting KEYREL as a properly working behaved function would be rather difficult

// DSKY 2 contains code to handle the usage of the informational display 

clearGuis().
clearscreen.
// DSKY I/O Information


// DSKYdisplayREG contains the information required to DISPLAY what the AGC requires it to on screen, all of these variables relate to visible information
GLOBAL _DSKYdisplayREG is LEXICON(
    // Information lights

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

    // LM specific (Apollo 11-14), the apollo LM DSKY lights were the same between the LM and the CSM which on that note, the CSM display never changed (https://www.ibiblio.org/apollo/yaDSKY.html#gsc.tab=0)
    "ALT", FALSE,
    "VEL", FALSE,
    // these next two are on later models of DSKY used in apollo 15-17
    "PRIORDISP", FALSE,
    "NODAP", FALSE, // I really want to know why they had to know they had no DAP, as it reminds you every 10 minutes about DAP existing

    "COMP_ACTY", FALSE,
    "PROG", "00",
    "VERB", "00",
    "NOUN", "00",
    "R1", "+00000",
    "R2", "+00000",
    "R3", "+88888"
).

GLOBAL _DSKY_STATE IS LEXICON(
    "clock", LEXICON("first", 0, "last", 0, "alive", 0, "update", 0, "refresh", 1.5),
    // first clock cycle (INIT CYCLE), last clock cycle (CURRENT CLOCK CYCLE), time the GC has been active, last time the screens were updated, the refresh rate (in Hz)
    "INHB", LEXICON("V37", FALSE, "INP", "V00N00"), // V37 program inhibit and the data inhibit
    // the data inhibit is used to tell the DSKY that if the AGC requests an update to the displays, which data it can request to update without causing a KEYREL ERR
    "STACK", LIST(), // list of data being requested to be shown by the AGC
    "stackIndexer", 0,
    "ERR", LIST(), // all error codes that have been created
    "PRO", FALSE,
    "FLASH", LEXICON("V", FALSE, "N", FALSE, "O", FALSE), // O is a variable which gets updated every cycle to control the ON/OFF of the flashing
    "NEEDS_INPUT", FALSE,
    "INPUT_INTERRUPT", FALSE,
    "INPUT_MODE", "NO",
    "OUTPUT_MODE", TRUE // enable / disable inputs from the agc
).

// Data test (REMOVED)
// initilize the DSKY GUI structure

// initilize some UI variables for ease of tinkering later

local _displayHeight is 315.
local _displayWidth is 185.


local _buttonHeight is 50. // height of the input buttons
local _buttonWidth is 50. // width of the input buttons
local _CWheight is 40.
local _CWwidth is 90.

local DSKY is gui(200).

local DSKY_CONTAINER is DSKY:addvlayout.

local DSKY_CONTAINER_DISP is DSKY_CONTAINER:addhlayout.

local DISP_CW is DSKY_CONTAINER_DISP:addhbox.
local DISP_SPACING is DSKY_CONTAINER_DISP:addspacing(40).
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
local _ELBANK2 is _EL_UPPER_CONTAINER:addvlayout.



// fillout the EL display

// row 1, COMP ACTY, PROG, program display

    // COMPUTER ACTIVITY, PROG, PROG DISPLAY

    local _EL_COMPACTY is _ELBANK1:addlabel("COMP ACTY").
    local _EL_PROG is _ELBANK2:addlabel("PROG").
    local _EL_PROGDISP IS _ELBANK2:addlabel("00").

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

    local _EL_VERBDISP IS _ELBANK1:addlabel("00").
    local _EL_NOUNDISP IS _ELBANK2:addlabel("00").

    // set the styling

    set _EL_VERBLBL:style:height to 10.
    set _EL_NOUNLBL:style:height to 10.
    set _EL_VERBLBL:style:width to 50.
    set _EL_NOUNLBL:style:width to 50.

    set _EL_VERBDISP:style:height to 50.
    set _EL_NOUNDISP:style:height to 50.
    set _EL_NOUNDISP:style:width to 50.
    set _EL_VERBDISP:style:width to 50.

    // set text size

    set _EL_NOUNDISP:style:fontsize to 40.
    set _EL_VERBDISP:style:fontsize to 40.

// row 3 - Register R1

    local _EL_DISPLAYREG1 is _EL_CONTAINER:addlabel("+88888").
    set _EL_DISPLAYREG1:style:height to 50.
    set _EL_DISPLAYREG1:style:fontsize to 50.

// row 4 - Register R2

    local _EL_DISPLAYREG2 is _EL_CONTAINER:addlabel("+88888").
    set _EL_DISPLAYREG2:style:height to 50.
    set _EL_DISPLAYREG2:style:fontsize to 50.

// row 5 - Register R3

    local _EL_DISPLAYREG3 is _EL_CONTAINER:addlabel("+88888").
    set _EL_DISPLAYREG3:style:height to 50.
    set _EL_DISPLAYREG3:style:fontsize to 50.

// fillout the C&W DISPLAY

// this has 7 vertical rows and 2 horizontal rows

// each row is equal, some are unused however

// row 1 - UPLINK AND TEMP

    local _CW_UPLINKLBL is _CWBANK1:addlabel("UPLINK ACTY").
    local _CW_TEMPLBL is _CWBANK2:addlabel("TEMP").

    // set the styling

    set _CW_UPLINKLBL:style:height to _CWheight.
    set _CW_UPLINKLBL:style:width to _CWwidth.
    set _CW_UPLINKLBL:style:fontsize to 15.
    set _CW_UPLINKLBL:style:wordwrap to true.

    set _CW_TEMPLBL:style:height to _CWheight.
    set _CW_TEMPLBL:style:width to _CWwidth.
    set _CW_TEMPLBL:style:fontsize to 15.

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

// row 6 - BLANK1, ALT (LM ONLY)

    local _CW_BLANK1 is _CWBANK1:addlabel("").
    local _CW_ALT is _CWBANK2:addlabel("ALT").

    set _CW_BLANK1:style:height to _CWheight.
    set _CW_BLANK1:style:width to _CWwidth.
    set _CW_BLANK1:style:fontsize to 15.

    set _CW_ALT:style:height to _CWheight.
    set _CW_ALT:style:width to _CWwidth.
    set _CW_ALT:style:fontsize to 15.

// row 7 - BLANK2, VEL (LM ONLY)

    local _CW_BLANK2 is _CWBANK1:addlabel("").
    local _CW_VEL is _CWBANK2:addlabel("VEL").

    set _CW_BLANK2:style:height to _CWheight.
    set _CW_BLANK2:style:width to _CWwidth.
    set _CW_BLANK2:style:fontsize to 15.

    set _CW_VEL:style:height to _CWheight.
    set _CW_VEL:style:width to _CWwidth.
    set _CW_VEL:style:fontsize to 15.

local DSKY_CONTAINER_INPUT IS DSKY_CONTAINER:addhbox.






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

LOCAL function DSKY_buttonHandler_VERB {
    // verb buttonpress
    // validation functions come later when i plan to release this first segment

    SET _DSKY_STATE:INPUT_MODE TO "V".
    set _DSKYdisplayREG:VERB to "".

}

set _inputVERB:onclick to DSKY_buttonHandler_VERB@.

LOCAL function DSKY_buttonHandler_NOUN {
    // noun buttonpress

    SET _DSKY_STATE:INPUT_MODE to "N".
    set _DSKYdisplayREG:NOUN TO "".
}

set _inputNOUN:onclick to DSKY_buttonHandler_NOUN@.

LOCAL FUNCTION DSKY_buttonHandler_ENTER {
    DSKY_ENTER(). // this could honestly be its own script
}

set _inputENTR:onclick to DSKY_buttonHandler_ENTER@.

LOCAL function DSKY_buttonHandler_PRO {
    // PROCEDE button, has two primary functions:
    // PROCEDE in the routine/program
    // ACCEPT requests from the computer (manuvers, engine burns ect)
    set _DSKY_STATE:PRO TO TRUE.

}

set _inputPRO:onclick to DSKY_buttonHandler_PRO@.

LOCAL FUNCTION DKSY_buttonHandler_KEYREL {
    // key release functionality, will be completed when needed
    // key release basically "releases" the keyboard to the control of the AGC (i.e allows the AGC to display data for you)
    IF _DSKYdisplayREG:KEYREL {
        set _DSKYdisplayREG:KEYREL TO FALSE.
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
    // does nothing for now
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
    print input.
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
        } ELSE {
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
        _AGC_PROGRAMUPDATE("P00"). // goes to P00
    } ELSE IF _VERB = "35" {
        // light test
        DSKY_LIGHTTEST().
    } ELSE IF _VERB = "36" {
        // fresh start whatever that means
    } ELSE IF _VERB = "37" AND NOT(_DSKY_STATE:INHB:V37) {
        // program change
        _AGC_PROGRAMUPDATE(_NOUN).
    } ELSE {
        _extendedVerbs(_VERB).
    }
    IF _canResetInputMode { set _DSKY_STATE:INPUT_MODE to "NO". }
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
    // perform the rest of the updates
    set _DSKY_STATE:clock:last to time:seconds.
    set _DSKY_STATE:clock:alive to abs(_DSKY_STATE:clock:first-_DSKY_STATE:clock:last).
    
    // check to see if the time since we last updated the displays _DSKY_STATE:clock:update is greater than the refresh timer
    IF abs(_DSKY_STATE:clock:last-_DSKY_STATE:clock:update) > _DSKY_STATE:clock:refresh {
        // refresh the displays
        set _DSKY_STATE:FLASH:O to NOT(_DSKY_STATE:FLASH:O). // master flash value - basically controlls all of the flashing functionality of the displays
        // check to see if we are flashing either verb or noun
        print _DSKY_STATE:FLASH:O.

        IF _DSKY_STATE:FLASH:O {
            IF (_DSKY_STATE:FLASH:V or _DSKY_STATE:FLASH:N) {
                IF _DSKY_STATE:FLASH:V {
                    set _EL_VERBDISP:text to "".
                } ELSE { set _EL_VERBDISP:text to _DSKYdisplayREG:VERB. }
                IF _DSKY_STATE:FLASH:N {
                    set _EL_NOUNDISP:text to "".
                } ELSE { set _EL_NOUNDISP:text to _DSKYdisplayREG:NOUN. }
            }
            IF _DSKYdisplayREG:KEYREL { set _CW_KEYREL:text to "KEY REL". }
            IF _DSKYdisplayREG:OPPERR { set _CW_OPPERR:text to "OPP ERR". }

        } ELSE {
            set _EL_NOUNDISP:text to _DSKYdisplayREG:NOUN.
            set _EL_VERBDISP:text to _DSKYdisplayREG:VERB.
            // unflash the warnings that should normally flash if active

            set _CW_KEYREL:text to "".
            set _CW_OPPERR:text to "".



        }

        
        // refresh the three registers
        set _EL_PROGDISP:text to _DSKYdisplayREG:PROG.
        set _EL_DISPLAYREG1:text to _DSKYdisplayREG:R1.
        set _EL_DISPLAYREG2:text to _DSKYdisplayREG:R2.
        set _EL_DISPLAYREG3:text to _DSKYdisplayREG:R3.
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
                    set _return:R1:A to _adInfo[0]:A.
                    set _return:R1:F to _adInfo[0]:F.
                }
                IF _adInfo:length >= 2 {
                    set _return:R2:A to _adInfo[1]:A.
                    set _return:R2:F to _adInfo[1]:F.
                }
                IF _adInfo:length >=3 {
                    set _return:R3:A to _adInfo[2]:A.
                    set _return:R3:F to _adInfo[2]:F.
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
                }

                set vString to _workingValue:tostring.

                IF _workingFormat:contains(".") {
                    // remove the decimal point
                    local _requiredDecimalPlaces is _dp.
                    local _actualDecimalPlaces is 0.
                    IF vString:contains(".") {
                        local _tempstring is vString.
                        set _actualDecimalPlaces to (vString:length-1)-vString:FIND(".").
                        set vString to _tempString:remove(vString:find("."), 1).
                    }
                    local _missingDecimalPlaces is (_requiredDecimalPlaces-_actualDecimalPlaces)-1.
                    IF _missingDecimalPlaces = 1 {
                        set vString to vString+"0".
                    } ELSE IF _missingDecimalPlaces = 2 {
                        set vString to vString+"00".
                    } ELSE IF _missingDecimalPlaces = 3 {
                        set vString to vString+"000".
                    } ELSE IF _missingDecimalPlaces = 4 {
                        set vString to vString+"0000".
                    }
                }

                
                // ensure it conforms to the 5 digit limit

                IF vString:length < 5 {
                    IF vString:length = 4 {
                        set vString to "0"+vString.
                    } ELSE IF vString:length = 3 {
                        set vString to "00"+vString.
                    } ELSE IF vString:length = 2 {
                        set vString to "000" + vString.
                    } ELSE IF vString:length = 1 {
                        set vString to "0000" + vString.
                    } ELSE {
                        set vString to "00000".
                    }
                }

                IF _workingFormat:contains("b") {
                    // add a zero at the location of "b"

                    // start by removing the first zero

                    local _tString2 is vString:remove(0,1).
                    set vString to _tString2.
                    local _tString3 is vString:insert(_workingFormat:find("b"), "0").
                    set vString to _tString3.
                }


                IF _neg {
                    set vString to "- "+vString.
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
        } ELSE IF _VERB = "02" {
            set _DSKYdisplayREG:R1 to _comp2Disp.
            set _DSKYdisplayREG:R2 to "".
            set _DSKYdisplayREG:R3 to "".
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
        } ELSE IF _VERB = 07 {
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
        IF _vrb = "21" {
            set _inputFormat to _addressingInfo:R1:F.
            set _inputAddress to _addressingInfo:R1:A.

            set _inputString to _DSKYdisplayREG:R1.
            PUSH_2_MEM(_inputString, _inputFormat, _inputAddress).
        } ELSE IF _vrb = "22" {
            set _inputFormat to _addressingInfo:R2:F.
            set _inputAddress to _addressingInfo:R2:A.

            set _inputString to _DSKYdisplayREG:R2.
            PUSH_2_MEM(_inputString, _inputFormat, _inputAddress).
        } ELSE IF _vrb = "23" {
            set _inputFormat to _addressingInfo:R3:F.
            set _inputAddress to _addressingInfo:R3:A.

            set _inputString to _DSKYdisplayREG:R3.
            PUSH_2_MEM(_inputString, _inputFormat, _inputAddress).
        } ELSE IF _vrb = "24" {
            // here we dont really care if the 
            local _inputR1 is _DSKYdisplayREG:R1.
            local _formatR1 is _addressingInfo:R1:F.
            local _addressR1 is _addressingInfo:R1:A.

            local _inputR2 is _DSKYdisplayREG:R2.
            local _formatR2 is _addressingInfo:R2:F.
            local _addressR2 is _addressingInfo:R2:A.
            PUSH_2_MEM(_inputR1, _formatR1, _addressR1).
            PUSH_2_MEM(_inputR2, _formatR2, _addressR2).
        } ELSE IF _vrb = "25" {
            local _inputR1 is _DSKYdisplayREG:R1.
            local _formatR1 is _addressingInfo:R1:F.
            local _addressR1 is _addressingInfo:R1:A.

            local _inputR2 is _DSKYdisplayREG:R2.
            local _formatR2 is _addressingInfo:R2:F.
            local _addressR2 is _addressingInfo:R2:A.

            local _inputR3 is _DSKYdisplayREG:R3.
            local _formatR3 is _addressingInfo:R3:F.
            local _addressR3 is _addressingInfo:R3:A.
            PUSH_2_MEM(_inputR1, _formatR1, _addressR1).
            PUSH_2_MEM(_inputR2, _formatR2, _addressR2).
            PUSH_2_MEM(_inputR3, _formatR3, _addressR3).
        }
        set _DSKY_STATE:INPUT_MODE to "NONE".
    }
}

LOCAL FUNCTION PUSH_2_MEM {
    parameter var is "", form is "", addr is "".

    // variable, format, address
    local _dp is 0.
    IF form:contains(".") {
        set _dp to (form:length-1)-form:FIND(".").
    }
    set _outputScalar to var:tonumber*10^(-_dp).


    IF _CORE_MEMORY:haskey(addr) {
        set _CORE_MEMORY[addr] to _outputScalar.
    }
}

LOCAL FUNCTION DSKY_LIGHTTEST {

}

LOCAL FUNCTION _INTERPRET {
    // interprets a code such as V00N00 ect ect
    parameter _codeToInterpret is "V00N00".

    local _rVERB is "00".
    local _rNOUN is "00".

    IF _codeToInterpret:contains("V") {
        local _vIndx is _codeToInterpret:FIND("V")+1.
        set _rVERB to _codeToInterpret[_vIndx].
        set _rVERB to _rVERB+_codeToInterpret[_vIndx+1].
    }
    IF _codeToInterpret:contains("N") {
        local _vIndx is _codeToInterpret:FIND("N")+1.
        set _rNOUN to _codeToInterpret[_vIndx].
        set _rNOUN to _rNOUN+_codeToInterpret[_vIndx+1].
    }

    return lexicon("VERB", _rVERB, "NOUN", _rNOUN).
}


// EXTERNAL DSKY INTERFACING FUNCTIONS

FUNCTION EXT_DSKY_GCDISPLAYREQ {
    parameter disp_req is "", _PRO_OVERRIDE IS FALSE.
    local _orig is disp_req.
    // allows the AGC to display data on the DSKY upon request
    set disp_req to _INTERPRET(disp_req).

    // check to see if the VN set provided is an important display item (i.e V99 ect ect)
    // so we check for priority verbs first

    // check to see which combination we are displaying currently, if these two match or if we are currently keyed to V00N00 we will allow the data to be displayed, otherwise we will activate the KEYREL button
    IF NOT(_PRO_OVERRIDE) and (NOT(_DSKY_STATE:INHB:INP = _orig or _DSKY_STATE:INHB:INP = "V00N00") and NOT(_DSKY_STATE:STACK:CONTAINS(_orig))) {
        _DSKY_STATE:STACK:ADD(_orig).
        print "+".
        set _DSKYdisplayREG:KEYREL to true.
    } ELSE {
        // display the combination by just setting the registers (they will update in the next cycle so its okay)
        // actually dont do this because uh, it may cause problems when this updates every cycle
        // maybe uh something like this
        IF _DSKY_STATE:INPUT_MODE = "NO" {
            // we can display the VN combo
            set _DSKYdisplayREG:VERB to disp_req:VERB.
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

DSKY:show.