FUNCTION print1 {
    print "1".
}

FUNCTION print2 {
    print "2".
}

local _pointer is 0.
print _pointer.
set _pointer to print1@.
_pointer:call.
set _pointer to print2@.
_pointer:call.