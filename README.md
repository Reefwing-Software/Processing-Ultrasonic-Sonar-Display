![version](https://img.shields.io/github/v/tag/Reefwing-Software/Processing-Ultrasonic-Sonar-Display) ![license](https://img.shields.io/badge/license-MIT-green) ![release](https://img.shields.io/github/release-date/Reefwing-Software/Processing-Ultrasonic-Sonar-Display?color="red") ![open source](https://badgen.net/badge/open/source/blue?icon=github)

# Processing Ultrasonic Sonar Display
 Visualisation of ultrasonic obstacle detection

 The PING or its cheaper clone the HC-SR04 are often used in robotics as a means of obstacle detection. For some time now we have been meaning to put together a means of visualising what the sensor is detecting. This is useful in diagnosing the performance of your robot as it moves around its environment.

 [Processing](https://medium.com/r/?url=https%3A%2F%2Fprocessing.org%2F) is a language and IDE designed for visual display. The language is VERY similar to that used for programming the Arduino and is a c variant. It is perfect for displaying data from the Arduino and this is what we used for our sonar display. 

 Processing is available for free and there are versions for Windows, MAC and Linux.

 We wrote three Processing sketches to display the data in different ways. 
 
 - The first is based on the design done by Tony Zhang at [hackster.io](https://medium.com/r/?url=https%3A%2F%2Fwww.hackster.io%2Ffaweiz%2Farduino-radar-69b8fe), We liked his pseudo radar display and wanted to emulate it. Note that we have significantly modified his sketch as it seems to be unnecessarily complicated and includes a bunch of unused code for some reason.
 - The second display is our attempt at a waterfall display, similar to that used on submarines to display sonar data. It turned out more like a depth sounder display, but we like the use of perlin noise to represent the outer limit of the sonar range.
 - The third display is a combination of the first two displays, which we called the Range Display Processing Sketch.

 Note that all three of the sketches use the integer point class which we have also included in this repository.

 A complete description of the hardware and software used is detailed in our [Medium Article](https://reefwing.medium.com/arduino-sonar-display-using-processing-radar-waterfall-ac1ed6f9489).
