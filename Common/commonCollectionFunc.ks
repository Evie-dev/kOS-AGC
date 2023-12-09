FUNCTION addToList {
    parameter l1 is list(), l2 is list().
    local rList is list().
    IF l1:istype("List") and l2:istype("List") {
        local Ll is list().
        local Sl is list().
        IF l1:length > l2:length {
            set Ll to l1.
            set Sl to l2.
        } ELSE {
            set Ll to l2.
            set Sl to l1.
        }
        set rList to Ll.
        FOR i in sL {
            rList:add(i).
        }
    } ELSE IF l1:istype("List") {
        set rList to l1.
        rList:add(l2).
    } ELSE IF l2:istype("List") {
        set rList to l2.
        rList:add(l1).
    }
    return rList.
}