# fpc-triforce-misc
Miscellaneous scripts and tools for FPC to aid our triforce (Amiga, AROS and MorphOS).


## tools/CHOICE.EXE

Well known choice command for windows.

Unfortunately not available (by default) for every windows version out there. Provided here for convenience only.

*Instructions:*
Place the command inside a directory that is part of your path environment variable (or alternatively add this directory to your path)


## tools/PString 

Tools that allows to extract words from given string and allows for additional parameters. Allows for input string to be read. It is a stripped down version of another (experimental) tool i was once working on (don't ask).

*Instructions:*
Place the command inside a directory that is part of your path environment variable (or alternatively add this directory to your path)


## scripts/update-fpc-trunk.bat

A windows batch-script that check-outs/updates the Free Pascal source tree from svn server.

Note that this script is intended to work for my personal setup.

Although it is quite easily to make it work for your setup as well, as long as you have all dependencies in place and replace all the calls in the script that calls external commands are changed to using the (direct) name of the executed tool.

As of the reason: i have one single batch directory that is in my path. That directory contains batch files named after the corresponding tools and which take care of locating the actual tool (so it can be installed anywhere without cluttering the path environment variable).

*Requirements:*
- MS-DOS Choice command line tool
- PString commandline tool
- 7zip command line tool
- svn commandline tools for windows. In particular, svnversion.exe and svn.exe

*Instructions:*
Place the script inside your work directory and when executed the script automatically creates the required subdirectories.

*Customization:*
To do