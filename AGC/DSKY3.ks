// apollo DSKY terminal code

// DSKY gui creation
clearGuis().
clearscreen.
// DSKY I/O Information

GLOBAL _DSKYdisplayREG is LEXICON(
    "PROG", "00",
    "VERB", "00",
    "NOUN", "00",
    "R1", "+00000",
    "R2", "+00000",
    "R3", "+88888"
).

GLOBAL _DSKY_STATE IS LEXICON(
    "firstClock", 0,
    "aliveTime", 0,
    "lastClock", 0,
    "lastUpdate", 0,
    "REFRESH_RATE", 1.5, // in Hz
    "PRO", FALSE,
    "FLASH", FALSE,
    "NEEDS_INPUT", FALSE,
    "INPUT_INTERRUPT", FALSE,
    "INPUT_MODE", "NO"
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


// create interfacing functions

// due to the  fact that both the LM and the CSM will be using this all I/O functionality will be tied in and common to both DSKY displays
// this means that the following AGC functions are built in to the DSKY program according to the following: https://www.ibiblio.org/apollo/CMC_data_cards_15_Fabrizio_Bernardini.pdf

// Verbs:
// 00 - Not used
// 01 - Display Octal component 1 in R1
// 02 - Display Octal component 2 in R1
// 03 - Display Octal component 3 in R1
// 04 - Display octal components 1,2 in R1 and R2
// 05 - Display octal components 1,2,3 in R1,R2 and R3
// 06 - Display Decimal in R1 or in R1,R2 or in R1,R2,R3
// 07 - Not really needed here tbh

// 11 - Monitor Octal component 1 in R1
// 12 - Monitor Octal component 2 in R1
// 13 - Monitor Octal component 3 in R1
// 14 - Monitor octal components 1,2 in R1 and R2
// 15 - Monitor octal components 1,2,3 in R1,R2 and R3
// 16 - Monitor Decimals in R1 R2 and R3

// 21 - Load Component 1 into R1 (modify data)
// 22 - Load Component 2 into R1 (modify data)
// 23 - Load Component 3 into R1 (modify data)

// however before that can be implimented we must create code for actually displaying and taking inputs


// functions regarding buttons can be LOCAL however functions regarding INPUT to the displays must be GLOBAL

// button handler


// start with special buttons like VERB, NOUN, ENTER ect ect

LOCAL function DSKY_buttonHandler_VERB {
    // verb buttonpress
    // validation functions come later when i plan to release this first segment

    set _DSKY_STATE:INPUT_MODE to "V".
    set _DSKYdisplayREG:VERB to "".
    print "VERB MODE".
}

set _inputVERB:onclick to DSKY_buttonHandler_VERB@.

LOCAL function DSKY_buttonHandler_NOUN {
    // noun buttonpress

    set _DSKY_STATE:INPUT_MODE to "N".
    set _DSKYdisplayREG:NOUN to "".
    print "NOUN MODE".
}

set _inputNOUN:onclick to DSKY_buttonHandler_NOUN@.

LOCAL FUNCTION DSKY_buttonHandler_ENTER {
    // certain verbs have special conditions too, such as V37E (V stands for VERB in this case and E for enter) upon pressing ENTER it will automatically allow you to input your NOUN, rather than having to go V37N63E for example you could do V37E63E

    // special verbs 

    // VERB 21 - Modify R1

    local _vrb is _DSKYdisplayREG:VERB.
    local _noun is _DSKYdisplayREG:NOUN.
    IF _vrb = "06" {
        IF _MEMORY_ADDRESSES:haskey(_noun) {
            // clear all three rows
            DSKY_clearRegisters().
            DSKY_READ_WRITE("READ").
            DKSY_display_REFRESH().

        }
    } ELSE IF _vrb = "16" {

    } 
    ELSE IF _vrb = "21" {
        IF _DSKY_STATE:INPUT_MODE = "V" {
            set _DSKY_STATE:INPUT_MODE to "R1".
            set _DSKYdisplayREG:R1 to "".
            set _EL_DISPLAYREG1:text to _DSKYdisplayREG:R1.
        } ELSE IF _DSKY_STATE:INPUT_MODE = "R1" {
            // write to memory
            DSKY_READ_WRITE("WRITE").
            // ???
        }
        
    } ELSE IF _vrb = "22" {
        IF _DSKY_STATE:INPUT_MODE = "V" {
            set _DSKY_STATE:INPUT_MODE to "R2".
            set _DSKYdisplayREG:R2 to "".
            set _EL_DISPLAYREG2:text to _DSKYdisplayREG:R2.
        } ELSE IF _DSKY_STATE:INPUT_MODE = "R2" {
            // write to memory
            DSKY_READ_WRITE("WRITE").
            // ???
        }
    } ELSE IF _vrb = "23" {
        IF _DSKY_STATE:INPUT_MODE = "V" {
            set _DSKY_STATE:INPUT_MODE to "R3".
            set _DSKYdisplayREG:R3 to "".
            set _EL_DISPLAYREG3:text to _DSKYdisplayREG:R3.
        } ELSE IF _DSKY_STATE:INPUT_MODE = "R2" {
            // write to memory
            DSKY_READ_WRITE("WRITE").
            // ???
        }
    } ELSE IF _vrb = "34" {
        // prog zero 
        _AGC_PROGRAMUPDATE("00").
    } 
    ELSE IF _vrb = "35" {
        // lights test

        // clear all of the functions

        set _DSKYdisplayREG:PROG to "".
        set _DSKYdisplayREG:VERB to "".
        set _DSKYdisplayREG:NOUN to "".
        set _DSKYdisplayREG:R1 to "".
        set _DSKYdisplayREG:R2 to "".
        set _DSKYdisplayREG:R3 to "".

        DSKY_displayDriver_PROG("88").
        DSKY_displayDriver_NOUN("88").
        DSKY_displayDriver_VERB("88").
        DSKY_displayDriver_R1("+88888").
        DKSY_displayDriver_R2("+88888").
        DSKY_displayDriver_R3("+88888").
    } ELSE IF _vrb = "36" {
        set _DSKYdisplayREG:PROG to "".
        set _DSKYdisplayREG:VERB to "".
        set _DSKYdisplayREG:NOUN to "".
        set _DSKYdisplayREG:R1 to "".
        set _DSKYdisplayREG:R2 to "".
        set _DSKYdisplayREG:R3 to "".

        DKSY_display_REFRESH().
    } ELSE IF _vrb = "37" {
        // program change

        _AGC_PROGRAMUPDATE(_DSKYdisplayREG:NOUN).

    } ELSE {
        _extendedVerbs(_DSKYdisplayREG:VERB).
    }
    // the handler for the special VERBS will go here eventually


}

set _inputENTR:onclick to DSKY_buttonHandler_ENTER@.

LOCAL function DSKY_buttonHandler_PRO {
    // PROCEDE button, has two primary functions:
    // PROCEDE in the routine/program
    // ACCEPT requests from the computer (manuvers, engine burns ect)

    set _DSKY_STATE:PRO to true.

}

set _inputPRO:onclick to DSKY_buttonHandler_PRO@.

LOCAL FUNCTION DKSY_buttonHandler_KEYREL {
    // key release functionality, will be completed when needed
    // key release basically "releases" the keyboard to the control of the AGC (i.e allows the AGC to display data for you)
}

set _inputKEYREL:onclick to DKSY_buttonHandler_KEYREL@.

LOCAL FUNCTION DSKY_buttonHandler_CLR {
    // gather which line we are currently editing and clear it and then refresh the display of that element
    local _inptMode is _DSKY_STATE:INPUT_MODE.
    IF _inptMode = "V" {
        set _DSKYdisplayREG:VERB to "".
        set _EL_VERBDISP:text to _DSKYdisplayREG:VERB.
    } ELSE IF _inptMode = "N" {
        set _DSKYdisplayREG:NOUN to "".
        set _EL_NOUNDISP:text to _DSKYdisplayREG:NOUN.
    } ELSE IF _inptMode = "R1" {
        set _DSKYdisplayREG:R1 to "".
        set _EL_DISPLAYREG1:text to _DSKYdisplayREG:R1.
    } ELSE IF _inptMode = "R2" {
        set _DSKYdisplayREG:R2 to "".
        set _EL_DISPLAYREG2:text to _DSKYdisplayREG:R2.
    } ELSE IF _inptMode = "R3" {
        set _DSKYdisplayREG:R3 to "".
        set _EL_DISPLAYREG3:text to _DSKYdisplayREG:R3.
    }
}

set _inputCLR:onclick to DSKY_buttonHandler_CLR@.

LOCAL FUNCTION DKSY_buttonHandler_RSET {

}

set _inputRSET:onclick to DKSY_buttonHandler_RSET@.

// regular old buttons

LOCAL FUNCTION DSKY_buttonHandler_PLUS {
    DKSY_INPUT_DRIVER("+").
}

set _inputPLUS:onclick to DSKY_buttonHandler_PLUS@.

LOCAL FUNCTION DSKY_buttonHandler_MINUS {
    DKSY_INPUT_DRIVER("-").
}
set _inputMINUS:onclick to DSKY_buttonHandler_MINUS@.

LOCAL FUNCTION DKSY_buttonHandler_ZERO {
    DKSY_INPUT_DRIVER("0").
}
set _inputZERO:onclick to DKSY_buttonHandler_ZERO@.

LOCAL FUNCTION DKSY_buttonHandler_ONE {
    DKSY_INPUT_DRIVER("1").
}

set _inputONE:onclick to DKSY_buttonHandler_ONE@.

LOCAL FUNCTION DKSY_buttonHandler_TWO {
    DKSY_INPUT_DRIVER("2").
}

set _inputTWO:onclick to DKSY_buttonHandler_TWO@.

LOCAL FUNCTION DKSY_buttonHandler_THREE {
    DKSY_INPUT_DRIVER("3").
}

set _inputTHREE:onclick to DKSY_buttonHandler_THREE@.

LOCAL FUNCTION DKSY_buttonHandler_FOUR {
    DKSY_INPUT_DRIVER("4").
}

set _inputFOUR:onclick to DKSY_buttonHandler_FOUR@.

LOCAL FUNCTION DKSY_buttonHandler_FIVE {
    DKSY_INPUT_DRIVER("5").
}

set _inputFIVE:onclick to DKSY_buttonHandler_FIVE@.

LOCAL FUNCTION DKSY_buttonHandler_SIX {
    DKSY_INPUT_DRIVER("6").
}

set _inputSIX:onclick to DKSY_buttonHandler_SIX@.

LOCAL FUNCTION DKSY_buttonHandler_SEVEN {
    DKSY_INPUT_DRIVER("7").
}

set _inputSEVEN:onclick to DKSY_buttonHandler_SEVEN@.

LOCAL FUNCTION DKSY_buttonHandler_EIGHT {
    DKSY_INPUT_DRIVER("8").
}

set _inputEIGHT:onclick to DKSY_buttonHandler_EIGHT@.

LOCAL FUNCTION DKSY_buttonHandler_NINE {
    DKSY_INPUT_DRIVER("9").
}

set _inputNINE:onclick to DKSY_buttonHandler_NINE@.

// input driver

LOCAL FUNCTION DKSY_INPUT_DRIVER {
    parameter input is "+".
    // the INPUT driver manages most of the inputs to the display drivers (basically checks which mode we are in)

    IF _DSKY_STATE:INPUT_MODE = "V" or _DSKY_STATE:INPUT_MODE = "N" {
        // check for potential invalid configuration (e.g +/- in the context of V/N operations)

        IF _DSKY_STATE:INPUT_MODE = "V" {
            set input to _DSKYdisplayREG:VERB+input.
            DSKY_displayDriver_VERB(input).
        } ELSE {
            set input to _DSKYdisplayREG:NOUN+input.
            DSKY_displayDriver_NOUN(input).
        }
    } ELSE IF _DSKY_STATE:INPUT_MODE = "R1" or _DSKY_STATE:INPUT_MODE = "R2" or _DSKY_STATE:INPUT_MODE = "R3" {
        IF _DSKY_STATE:INPUT_MODE = "R1" {
            DSKY_displayDriver_R1(input).
        } ELSE IF _DSKY_STATE:INPUT_MODE = "R2" {
            DKSY_displayDriver_R2(input).
        } ELSE IF _DSKY_STATE:INPUT_MODE = "R3" {
            DSKY_displayDriver_R3(input).
        }
    }
    print input.
}

// display drivers

FUNCTION DSKY_displayDriver_PROG {
    parameter displayValue is "00".
    // validates and passes on the result to the program display
    // due to the way inputs are taken, theres no real need to validate if its a numerical value or not, however we will check if its a string

    IF NOT(displayValue:istype("String")) and displayValue:istype("scalar") {
        IF displayValue < 10 {
            set displayValue to "0" + displayValue:tostring.
        } ELSE {
            set displayValue to displayValue:tostring. 
        }
        
    }
    
    IF displayValue:length = 2 { // TODO: validate against a PROGRAM LIST file
        set _DSKYdisplayREG:PROG to displayValue.
    }
}

FUNCTION DSKY_displayDriver_VERB {
    parameter displayValue is "00".

    // displays the result onto the verb/noun display unit

    IF displayValue:istype("Scalar") {
        set displayValue to displayValue:tostring.
    }

    IF displayValue:length > 2 {
        // throw an error here
    } ELSE {
        set _DSKYdisplayREG:VERB to displayValue. // when hitting enter, this value must be a valid 2 length value, we allow inputs of lengths of 1 so you can display a value while typing it in
    }
}

FUNCTION DSKY_displayDriver_NOUN {
    parameter displayValue is "00".

    // displays the result onto the verb/noun display unit

    IF displayValue:istype("Scalar") {
        set displayValue to displayValue:tostring.
    }

    IF displayValue:length > 2 {
        // throw an error here
    } ELSE {
        set _DSKYdisplayREG:NOUN to displayValue. // when hitting enter, this value must be a valid 2 length value, we allow inputs of lengths of 1 so you can display a value while typing it in
    }
}

FUNCTION DSKY_displayDriver_R1 {
    parameter displayValue is 0, computerData is true.
    // display inputs usually begin with + or - in the agc register
    IF displayValue:istype("Scalar") {
        set displayValue to displayValue:tostring.
    }
    local _currentData is _DSKYdisplayREG:R1.
    
    IF displayValue = "+" or displayValue = "-" {
        IF _currentData:startswith("+") or _currentData:startswith("-") {
            // throw an error
        } ELSE {
            set _DSKYdisplayREG:R1 to _DSKYdisplayREG:R1+displayValue.
            // refresh the display
        }
    } ELSE {
        IF NOT(_currentData:startswith("+") or _currentData:startswith("-")) and NOT(displayValue:startswith("+") or displayValue:startswith("-")) {
            // throw an error
        } ELSE {
            set _DSKYdisplayREG:R1 to _DSKYdisplayREG:R1+displayValue.
        }
    }
}

FUNCTION DKSY_displayDriver_R2 {
    parameter displayValue is 0, computerData is true.
    // display inputs usually begin with + or - in the agc register
    IF displayValue:istype("Scalar") {
        set displayValue to displayValue:tostring.
    }
    local _currentData is _DSKYdisplayREG:R2.
    
    IF displayValue = "+" or displayValue = "-" {
        IF _currentData:startswith("+") or _currentData:startswith("-") {
            // throw an error
        } ELSE {
            set _DSKYdisplayREG:R2 to _DSKYdisplayREG:R2+displayValue.
            // refresh the display
        }
    } ELSE {
        IF NOT(_currentData:startswith("+") or _currentData:startswith("-")) and NOT(displayValue:startswith("+") or displayValue:startswith("-")) {
            // throw an error
        } ELSE {
            set _DSKYdisplayREG:R2 to _DSKYdisplayREG:R2+displayValue.
        }
    }
}

FUNCTION DSKY_displayDriver_R3 {
    parameter displayValue is 0, computerData is true.
    // display inputs usually begin with + or - in the agc register
    IF displayValue:istype("Scalar") {
        set displayValue to displayValue:tostring.
    }
    local _currentData is _DSKYdisplayREG:R3.
    
    IF displayValue = "+" or displayValue = "-" {
        IF _currentData:startswith("+") or _currentData:startswith("-") {
            // throw an error
        } ELSE {
            set _DSKYdisplayREG:R3 to _DSKYdisplayREG:R3+displayValue.
            // refresh the display
        }
    } ELSE {
        IF NOT(_currentData:startswith("+") or _currentData:startswith("-")) and NOT(displayValue:startswith("+") or displayValue:startswith("-")) {
            // throw an error
        } ELSE {
            set _DSKYdisplayREG:R3 to _DSKYdisplayREG:R3+displayValue.
        }
    }
}

FUNCTION DSKY_clearRegisters {
    set _DSKYdisplayREG:R1 to "".
    set _DSKYdisplayREG:R2 to "".
    set _DSKYdisplayREG:R3 to "".
}

FUNCTION DKSY_display_REFRESH {
    parameter prog is true, vn is true, registers is true.
    if prog { DSKY_displayRefresh_PROG(). }
    IF vn { DSKY_displayRefresh_VN(). }
    IF registers { DSKY_displayRefresh_REGISTER(). }
    set _DSKY_STATE:lastUpdate to time:seconds.
}

LOCAL FUNCTION DSKY_displayRefresh_PROG {
    IF NOT(_EL_PROGDISP:text = _DSKYdisplayREG:PROG) {
        set _EL_PROGDISP:text to _DSKYdisplayREG:PROG.
    }
}

LOCAL FUNCTION DSKY_displayRefresh_VN {
    IF NOT(_EL_NOUNDISP:text = _DSKYdisplayREG:NOUN) {
        set _EL_NOUNDISP:text to _DSKYdisplayREG:NOUN.
    }
    IF NOT(_EL_VERBDISP:text = _DSKYdisplayREG:VERB) {
        set _EL_VERBDISP:text to _DSKYdisplayREG:VERB.
    }
}

LOCAL FUNCTION DSKY_displayRefresh_REGISTER {
    IF NOT(_EL_DISPLAYREG1:text = _DSKYdisplayREG:R1) {
        set _EL_DISPLAYREG1:text to _DSKYdisplayREG:R1.
    }
    IF NOT(_EL_DISPLAYREG2:text = _DSKYdisplayREG:R2) {
        set _EL_DISPLAYREG2:text to _DSKYdisplayREG:R2.
    }
    IF NOT(_EL_DISPLAYREG3:text = _DSKYdisplayREG:R3) {
        set _EL_DISPLAYREG3:text to _DSKYdisplayREG:R3.
    }
}


// AGC/LGC RW code

LOCAL FUNCTION DSKY_READ_ADDRESS_TABLE {
    // reads the address table for the current sets of V/N and returns a DSKY compatable table

    local _v is _DSKYdisplayREG:VERB.
    local _n is _DSKYdisplayREG:NOUN.

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
    parameter md is "READ". // for read and write functions

    local _addressingInfo is DSKY_READ_ADDRESS_TABLE().

    // 1. Do read first because its slightly (by slightly i mean a lot) more complex

    IF md = "READ" {
        local _r1disp is "".
        local _r2disp is "".
        local _r3disp is "".
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
                }


                IF _neg {
                    set vString to "- "+vString.
                } ELSE {
                    set vString to "+" + vstring.
                }
                IF i = "R1" {
                    DSKY_displayDriver_R1(vString).
                } ELSE IF i = "R2" {
                    DKSY_displayDriver_R2(vString).
                } ELSE IF i = "R3" {
                    DSKY_displayDriver_R3(vString).
                }

            } ELSE {
                // no it doesnt!
            }

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

        } ELSE IF _vrb = "22" {
            set _inputFormat to _addressingInfo:R2:F.
            set _inputAddress to _addressingInfo:R2:A.

            set _inputString to _DSKYdisplayREG:R2.
        } ELSE IF _vrb = "23" {
            set _inputFormat to _addressingInfo:R3:F.
            set _inputAddress to _addressingInfo:R3:A.

            set _inputString to _DSKYdisplayREG:R3.
        }
        local _dp is 0.
        IF _inputFormat:contains(".") {
            set _dp to (_inputFormat:length-1)-_inputFormat:FIND(".").
        }
        set _outputScalar to _inputString:tonumber*10^(-_dp).


        IF _CORE_MEMORY:haskey(_inputAddress) {
            set _CORE_MEMORY[_inputAddress] to _outputScalar.
        }
    }

    
}

// DSKY INTERACTION FOR EXTERNAL

FUNCTION EXT_DSKY_VERB {
    parameter newVerb is "00".

    DSKY_displayDriver_VERB(newVerb).
}

FUNCTION EXT_DSKY_NOUN {
    parameter newNoun is "00".

    DSKY_displayDriver_NOUN(newNoun).
}

FUNCTION EXT_DSKY_PROG {
    parameter newProgram is "00".

    DSKY_displayDriver_PROG(newProgram).
}

FUNCTION EXT_DSKY_ENTR {
    DSKY_buttonHandler_ENTER().
}

FUNCTION EXT_DSKY_REGISTERS {
    parameter newData is "+00000",newRegister is "R1", newFormat is "XXXXX".

    local _workingValue is newData.
    local _workingFormat is newFormat.
    local _dp is 0.
    local _finalZero is false.
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
        local _dp2 is 0.
        // where is the decimal point of what we are working with
        IF vString:contains(".") {
            set _dp2 to (vString:length-1)-vString:FIND(".").
        }
        local _dp3 is abs(_dp-_dp2).
        set _workingValue to _workingValue*10^_dp3.
        set _workingValue to ROUND(_workingValue).
    }
    set vString to _workingValue:tostring.


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

    IF _neg {
        set vString to "-"+vString.
    } ELSE {
        set vString to "+" + vstring.
    }
    // clear the register in particular first
    IF newRegister = "R1" {
        set _DSKYdisplayREG:R1 to "".
        DSKY_displayDriver_R1(vString).
    } ELSE IF newRegister = "R2" {
        set _DSKYdisplayREG:R2 to "".
        DKSY_displayDriver_R2(vString).
    } ELSE IF newRegister = "R3" {
        set _DSKYdisplayREG:R3 to "".
        DSKY_displayDriver_R3(vString).
    }
}

FUNCTION DSKY_UPDATE_CYCLE {
    // updates the DSKY
    IF _DSKY_STATE:firstClock = 0 {
        // the clock has NOT been set yet
        set _DSKY_STATE:firstClock to time:seconds.
        
    } ELSE {
        set _DSKY_STATE:lastClock to time:seconds.
        set _DSKY_STATE:aliveTime to abs(_DSKY_STATE:lastClock-_DSKY_STATE:firstClock).

        IF abs(_DSKY_STATE:lastUpdate-_DSKY_STATE:lastClock) > (1-(1/_DSKY_STATE:REFRESH_RATE)) AND NOT _DSKY_STATE:INPUT_INTERRUPT {
            IF _DSKY_STATE:NEEDS_INPUT {
                // V/N flashing functionality

                set _DSKY_STATE:FLASH TO NOT(_DSKY_STATE:FLASH).

                IF _DSKY_STATE:FLASH {
                    set _EL_NOUNDISP:text to _DSKYdisplayREG:NOUN.
                    set _EL_VERBDISP:text to _DSKYdisplayREG:VERB.
                } ELSE {
                    set _EL_NOUNDISP:text to "".
                    set _EL_VERBDISP:text to "".
                }
                DKSY_display_REFRESH(true, false, true).
            } ELSE {
                IF _DSKYdisplayREG:VERB = 16 {
                    DSKY_clearRegisters().
                    DSKY_READ_WRITE().
                }
                DKSY_display_REFRESH(true,true,true).
            }
            

        }
    }
}

DSKY:show.