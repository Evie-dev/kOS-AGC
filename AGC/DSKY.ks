local useImages is true.

set CONFIG:IPU to 840. // 10000 times less than the IRL AGC but should sufice for the kOS-AGC

IF useImages {
    runOncePath("0:/AGC/DSKY/DSKY_images.ks").
} ELSE {
    runOncePath("0:/AGC/DSKY/DSKY_noImages.ks").
}