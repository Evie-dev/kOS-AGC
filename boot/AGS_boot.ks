// AGS boot
// the AGS is the LM's secondary computer, which isnt really talked about therefore i shall explain what it is:
// https://en.wikipedia.org/wiki/Apollo_Abort_Guidance_System

// the AGS, known as the Abort Guidance Computer is a very basic computer which could perform operations in the LM such as perform a Lunar landing abort, lunar ascent, and rendezvous with the CSM

// It was used in three main cases: 

// Apollo 9

// During Apollo 9 the AGS was tested

// Apollo 11: 

// After the fanfair of the landing on the surface, the successful ascent into lunar orbit, the crew found themselves in gimbal lock, thus used the AGS during rendezvous with the CSM

// Apollo 13: 
// during the incident phase of the Apollo 13 flight, the AGS was used to ensure that the crew had a computer, as the AGS was a far less electrically intense system to run and operate, unlike the main LGC (power was very important to the mission getting home safely)

GLOBAL _isCSM is FALSE.
GLOBAL _isAGS is TRUE.
GLOBAL _isLM is FALSE.
GLOBAL _isLVDC is FALSE.