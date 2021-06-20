# VR_Pinball
Second Year Processing Project @ EPFL (CS-211 course): Virtual Reality Pinball

by Jean-Daniel Rouveyrol and Raoul Gerber

It is not really a pinball, but the game rather consist of a board with a ball and an enemy spawning columns. The goal is to hit the enemy, but their defensive columns will make the ball bounce away and disappear on hit. 

The player cannot directly control the ball, but must rather tilt the board to make it move following gravity.

Tilting the board is meant to be done with a real object (such as seen in the board.jpg) held in front of the webcam, but using the mouse was an alternative in earlier versions of the project. The camera will then detect the board and mimic its movements into the game.

### Launch the game
Getting [Processing](https://processing.org/), a webcam and a flat single-color square surface are necessary. Run from within Processing. The default parameters currently in use require the surface to be green (as seen in the board.jpg), but this could be tweaked to fit any object from your home such as a book. 
