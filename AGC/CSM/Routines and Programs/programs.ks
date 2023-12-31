// loads all the program functions into memory

loadPrograms().

local _programList is LIST().

LOCAL FUNCTION loadPrograms {
    print "LOADING PROGRAMS".
    
    // special debug info
    local _programsLoaded is 0.

    local _basePath is path().
    local _file is "".
    local _programFileDIR is "0:/AGC/CSM/Routines and Programs/Programs".

    // change the directory to the location of programs (0:/AGC/CSM/Routines and Programs/Programs)
    CD(_programFileDIR).
    list files in _programFileList.

    // lists the files for the programs

    local _path is "".
    FOR i in _programFileList {
        set _file to i.
        set _path to _programFileDIR + "/" + _file.
        runOncePath(_path).
        set _programsLoaded to _programsLoaded+1.
        // add the loaded program to the agc debug info
        _AGC_DEBUG_INFO["Programs Loaded"]:add(_file).

        // Program files will always begin with "P" and the next TWO numbers will be its program list number



        print "AGC LOAD PROGRAM: " + _path.
    }

    // return to the directory

    CD(_basePath).
    print "LOADING PROGRAMS COMPLETE!".
}

local _validPrograms is list(
    "00", "01", "02", "11", "15", "27", "30", "40", "61", "62", "63", "64", "65", "66", "67"
).
local _pINIT is P____INIT@.

FUNCTION _AGC_PROGRAMUPDATE {
    parameter newProgram is "00".
    set _pINIT to P____INIT@.
    // allows the updating of the program based on the program list
    local _newProgramSet is true.
    IF newProgram = "00" {
        // CMC - IDLE
        set _pINIT to P00_INIT@.
    }
    ELSE IF newProgram = "01" {
        // prelaunch / service init
        set _pINIT to P01_INIT@.
    } ELSE IF newProgram = "02" {
        set _pINIT to P02_INIT@.
    } ELSE IF newProgram = "11" {
        set _pINIT to P11_INIT@.
    } ELSE IF newProgram = "15" {
        // TLI monitor function
    } 
    ELSE IF newProgram = "27" {
        set _pINIT to P27_INIT@.
    }
    ELSE IF newProgram = "30" {
        set _pINIT to P30_INIT@.
    } ELSE IF newProgram = "40" {
        set _pINIT to P40_INIT@.
    } ELSE IF newProgram = "61" {
        set _pINIT to P61_INIT@.
    } ELSE IF newProgram = "62" {
        set _pINIT to P62_INIT@.
    } ELSE IF newProgram = "63" {
        set _pINIT to P63_INIT@.
    } ELSE IF newProgram = "64" {
        set _pINIT to P64_INIT@.
    } ELSE IF newProgram = "65" {
        set _pINIT to P65_INIT@.
    } ELSE IF newProgram = "66" {
        set _pINIT to P66_INIT@.
    } ELSE IF newProgram = "67" {
        set _pINIT to P67_INIT@.
    } ELSE {
        set _newProgramSet to false.
    }
    IF _newProgramSet {
        _CLEAR_WAITLIST().
    }
    _pINIT:call.
}

LOCAL FUNCTION P____INIT {

}