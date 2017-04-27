# Microprocessors
This is a collection of the files required for the EENG 420 Microprocessors Class


The following gives some directions for a more enjoyable experience in the class...


The interface for the provided software left a lot to be desired:
![ScreenShot](https://github.com/acampb311/Microprocessors/blob/master/old.PNG)

It had no syntax coloring and even required what was essentially a second program to interface with the S12. The solution was to use the Atom text editor and the given packages in order to create an acceptable working environment.

https://atom.io/packages/build  
https://atom.io/packages/language-cpu12  
https://atom.io/packages/linter  
https://atom.io/packages/platformio-ide  
https://atom.io/packages/platformio-ide-terminal  

Once the given packages are installed, (you will need python on the path in order to install platformio) you will be able to build, debug, and upload your code to the S12 within one environment. It will be necessary to place the S12 assembler into the current working directory as well. Also, there are issues when the working directory contains spaces in the path.  

The resulting environment:
![ScreenShot](https://github.com/acampb311/Microprocessors/blob/master/new.PNG)
