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

FUNCTION _AGC_PROGRAMUPDATE {
    parameter newProgram is "00".
    // allows the updating of the program based on the program list

    IF newProgram = "00" {
        // CMC - IDLE
        P00_INIT().
    }
    ELSE IF newProgram = "01" {
        // prelaunch / service init
        P01_INIT().
    } ELSE IF newProgram = "02" {
        P02_INIT().
    } ELSE IF newProgram = "11" {
        P11_INIT().
    }
}