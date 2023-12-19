// loads all the routine functions into memory

loadRoutines().

LOCAL FUNCTION loadRoutines {
    print "LOADING ROUTINES".
    
    // special debug info
    local _routinesLoaded is 0.

    local _basePath is path().
    local _file is "".
    local _routineFileDIR is "0:/AGC/CSM/Routines and Programs/Routines".

    // change the directory to the location of programs (0:/AGC/CSM/Routines and Programs/Programs)
    CD(_routineFileDIR).
    list files in _routineFileList.

    // lists the files for the programs

    local _path is "".
    FOR i in _routineFileList {
        set _file to i.
        set _path to _routineFileDIR + "/" + _file.
        runOncePath(_path).
        set _routinesLoaded to _routinesLoaded+1.
        // add to the debug stack

        _AGC_DEBUG_INFO["Routines Loaded"]:add(_file).
        print "AGC LOAD ROUTINE: " + _path.
    }

    // return to the directory

    CD(_basePath).
    print "LOADING ROUTINES COMPLETE!".
}

FUNCTION _AGC_ROUTINEUPDATE {
    parameter calledRoutine is "00".

    IF calledRoutine = "R03" {
        R03_INIT().
    } ELSE IF calledRoutine = "R30" {
        R30_INIT().
    } ELSE IF calledRoutine = "R60" {
        R60_INIT().
    } 
    ELSE IF calledRoutine = "R62" {
        R62_INIT().
    }
}