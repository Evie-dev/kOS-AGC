// DSKY variables for input/output

GLOBAL DSKY_registerState is LEXICON(
    "Program", "88",
    "VERB", "88",
    "NOUN", "88",
    "R1", "+88888",
    "R2", "+88888",
    "R3", "+88888",

    // special hidden variables

    "DTM", "R", // R ead and W rite
    "REG", "VERB" // VERB NOUN R1 R2 R3
).

// register get and set

FUNCTION registerWrite {
    parameter data is "0".
    local writeToRegister is DSKY_registerState:REG.

    IF writeToRegister = "VERB" or writeToRegister = "NOUN" {

    } ELSE IF DSKY_registerState:DTM = "W" {

    }
}

FUNCTION registerR1 {
    parameter getSetDisplay is "S", param is 0.
    IF getSetDisplay = "S" {
        // setting
        set DSKY_registerState:R1 to validateRegister(param).
    } ELSE IF getSetDisplay = "G" {
        return DSKY_registerState:R1.
    } ELSE IF getSetDisplay = "D" {
        // check if we can display the value given
        IF param:istype("Scalar") and NOT(DSKY_registerState:R1:length = 6) {
            set DSKY_registerState:R1 to DSKY_registerState:R1+param:tostring.
        } ELSE IF param:istype("String") and NOT(DSKY_registerState:R1:length = 6) {
            set DSKY_registerState:R1 to DSKY_registerState:R1+param:tostring.
        }
    }
}

FUNCTION registerR2 {
    parameter getSetDisplay is "S", param is 0.
    IF getSetDisplay = "S" {
        // setting
        set DSKY_registerState:R2 to validateRegister(param).
    } ELSE IF getSetDisplay = "G" {
        return DSKY_registerState:R2.
    } ELSE IF getSetDisplay = "D" {
        // check if we can display the value given
        IF param:istype("Scalar") and NOT(DSKY_registerState:R2:length = 6) {
            set DSKY_registerState:R2 to DSKY_registerState:R2+param:tostring.
        } ELSE IF param:istype("String") and NOT(DSKY_registerState:R2:length = 6) {
            set DSKY_registerState:R2 to DSKY_registerState:R2+param:tostring.
        }
    }
}

FUNCTION registerR3 {
    parameter getSetDisplay is "S", param is 0.
    IF getSetDisplay = "S" {
        // setting
        set DSKY_registerState:R3 to validateRegister(param).
    } ELSE IF getSetDisplay = "G" {
        return DSKY_registerState:R3.
    } ELSE IF getSetDisplay = "D" {
        // check if we can display the value given
        IF param:istype("Scalar") and NOT(DSKY_registerState:R3:length = 6) {
            set DSKY_registerState:R3 to DSKY_registerState:R3+param:tostring.
        } ELSE IF param:istype("String") and NOT(DSKY_registerState:R3:length = 6) {
            set DSKY_registerState:R3 to DSKY_registerState:R3+param:tostring.
        }
    }
}

FUNCTION registerVRB {
    parameter getSetDisplay is "S", param is 0.
    set param to param:tostring.
    IF getSetDisplay = "G" {
        return DSKY_registerState:VERB.
    } ELSE IF getSetDisplay = "S" {
        IF param:length = 2 {
            // this is valid!

        }
    }
    
}

FUNCTION registerNON {

}

FUNCTION validateRegister {
    parameter validating is "-8". // should return as "-00008"
    IF validating:istype("Scalar") {
        local wasPositive is validating >= 0.
        set validating to validating:tostring.
        IF wasPositive {
            validating:insert("+", 0).
        }
        UNTIL validating:length = 6 {
            validating:insert("0", 1).
        }
    }
    return validating.
}



local DSKYgui is gui(300, 300).

// only a basic display for now my main focus is backend functionality rather than making it look good


// Display registers

local DisplayPRGM is DSKYgui:addvlayout.
local DisplayVERBNOUN is DSKYgui:addvlayout.

local DisplayR1 is DSKYgui:addvlayout.
local DisplayR2 is DSKYgui:addvlayout.
local DisplayR3 is DSKYgui:addvlayout.

local KeypadR1 is DSKYgui:addvlayout.
local KeypadR1C is DSKYgui:addhlayout.
local KeypadR2 is DSKYgui:addvlayout.
local KeypadR2C is DSKYgui:addhlayout.
local keypadR3 is DSKYgui:addvlayout.
local keypadR3C is DSKYgui:addhlayout.

// add the buttons

// Row 1 will contain verb, plus, numbers 7-9, clear and enter

local btn_verb is KeypadR1C:addbutton("VERB").
local btn_plus is KeypadR1C:addbutton("+").
local btn_seven is KeypadR1C:addbutton("7").
local btn_eight is KeypadR1C:addbutton("8").
local btn_nine is KeypadR1C:addbutton("9").
local btn_clear is KeypadR1C:addbutton("CLR").
local btn_enter is KeypadR1C:addbutton("ENTR").

// set the presses

set btn_verb:onclick to { set DSKY_registerState:MOD to "V". }.
set btn_plus:onclick to { registerWrite("+"). }.
set btn_seven:onclick to { registerWrite("7"). }.
set btn_eight:onclick to { registerWrite("8"). }.
set btn_nine:onclick to { registerWrite("9"). }.



// Row 2 contains minus, numbers 4-6 and PROCEDE

local btn_minus is KeypadR2C:addbutton("-").
local btn_four is KeypadR2C:addbutton("4").
local btn_five is KeypadR2C:addbutton("5").
local btn_six is KeypadR2C:addbutton("6").
local btn_pro is KeypadR2C:addbutton("PRO").

// set the presses

set btn_minus:onclick to { registerWrite("-"). }.
set btn_four:onclick to { registerWrite("4"). }.
set btn_five:onclick to { registerWrite("5"). }.
set btn_six:onclick to { registerWrite("6"). }.


// Row 3 contains NOUN, numbers 0-3, key release and reset

local btn_noun is keypadR3C:addbutton("NOUN").
local btn_zero is keypadR3C:addbutton("0").
local btn_one is keypadR3C:addbutton("1").
local btn_two is keypadR3C:addbutton("2").
local btn_three is keypadR3C:addbutton("3").
local btn_keyrelease is keypadR3C:addbutton("KEY REL").
local btn_reset is keypadR3C:addbutton("RSET").

// set the presses

set btn_noun:onclick to { set DSKY_registerState:MOD to "N". }.
set btn_zero:onclick to { registerWrite("0"). }.
set btn_one:onclick to { registerWrite("1"). }.
set btn_two:onclick to { registerWrite("2"). }.
set btn_three:onclick to { registerWrite("3"). }.


DSKYgui:show().




wait until false.