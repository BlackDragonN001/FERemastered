Allright, here are the first 3 'nasty plants':

1. A small pustule which, when driven over, slightly damages a unit.

2. A 'sticky plant', which will 'capture' a unit and emmit corrosive gas.

3. The antibody dispenser.

Installation:
Copy the whole nasty plants folder into your addon.

Instructions:
Since these effects are based on mines, their placement is a bit tricky...
IMPORTANT: remember to set the mines to team 2 (or team 3 if they should interact with the enemy too)

1. For the pustule, very simple - type 'pusmine' into the editor config field, and place them. That's all!

2. For the sticky plant: type in 'stickstem' to place the center piece. Then type 'stickleaf' and place 5 or so
    leaves around it. Now for the actual effect: type 'stick' and place it (it's invisible, just like the rest of the
    fx mines) in the center of the stickstem centerpiece (that's the 'capture' mine). Then type 'stickgas', and
    do the same (that's the gas emitter).

3. For the antibody dispenser: type 'antistem' to place the plant. Now for the 3 effects:
    - type 'antibody', and when looking straight down at the plant from above, place it in the center
      of it's 'funnel'. (these are the actual antibodies)
    - NOW: add 6 to the height you put the plant on. (use the eyedrop function to find out the height of
       your plant - add 6 to that, and you now have the new height you need). Type 'antidrop', and again
      place it in the center of the funnel where you placed the 'antibody' (this simulates the antibody
      'dropping' from the plant)
    - Type 'antidropb', and place it where you placed the other two (this simulates some 'red juice' falling
       down)

Sorry for all this inconvenience, that's the only way to make this work!

Issues:
These plants have to be indestructible - otherwise the plant prop will be destroyed, but the mines will
keep on making the effects. It is almost impossible to have a plant and it's effect mines be destroyed at
the same time. I also could not enable the collision box - strange effects kept happening. Also, these
plants will not react to pilots on foot, only ships. Perhaps if the plants could be made as units, with
appropriate hardpoints we could overcome those limitations, but as props, this is the only way...

Anyway - Enjoy !


Gray

 


