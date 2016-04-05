# fpc-triforce-misc
Miscellaneous scripts and tools for FPC to aid our triforce (Amiga, AROS and MorphOS).


## tools/CHOICE.EXE

Well known choice command for windows.

Unfortunately not available (by default) for every windows version out there. Provided here for convenience only.

**Instructions:**

Place the command inside a directory that is part of your path environment variable (or alternatively add this directory to your path)


## tools/PString 

Tools that allows to extract words from given string and allows for additional parameters. Allows for input string to be read. It is a stripped down version of another (experimental) tool i was once working on (don't ask).

**Instructions:**

Place the command inside a directory that is part of your path environment variable (or alternatively add this directory to your path)


## scripts/update-fpc-trunk.bat

A windows batch-script that check-outs/updates the Free Pascal source tree from svn server.

Note that this script is intended to work for my personal setup.

Although it is quite easily to make it work for your setup as well, as long as you have all dependencies in place and replace all the calls in the script that calls external commands are changed to using the (direct) name of the executed tool.

As of the reason: i have one single batch directory that is in my path. That directory contains batch files named after the corresponding tools and which take care of locating the actual tool (so it can be installed anywhere without cluttering the path environment variable).

**Requirements:**
- MS-DOS Choice command line tool
- PString commandline tool
- 7zip command line tool
- svn commandline tools for windows. In particular, svnversion.exe and svn.exe

**Instructions:**

Place the script inside your work directory and when executed the script automatically creates the required subdirectories.

**Customization:**

To do


## binutils

Home for collect-aros and its personalized counterpart collect-aros-custom.

This tool is required by the AROS build-process and is responsible for invoking the actual linking process. As such collect-aros 'becomes' part of the binutils.

The custom version was created out of necessity, as the default used environment variable COMPILER_PATH clashes with those variables used in alternative shells such as mingw, gitbash etc. My custom version uses the BINUTILS_PATH environment variable instead.

Alternative location for collect-aros is available in the aros-archives. In which case you should download the file named [i386-aros-gcc-4.5.2-migw32-bin.zip](http://archives.aros-exec.org/index.php?function=showfile&file=development/cross/i386-aros-gcc-4.5.2-migw32-bin.zip) (just click on the link presented at download), and extract the archive in order to retreive the collect executable).

**Instructions:**

- Download [mingw AROS binutils](http://archives.aros-exec.org/index.php?function=showfile&file=development/cross/i386-aros-binutils-2.19-1-mingw32-bin.zip) from aros-archives. 
- extract the BinUtils archive to a temporary location and copy the following files to a directory that is listed in your path (or ammend your path).
  - i386-aros-as.exe
  - i386-aros-as.exe
  - i386-aros-ld.exe
  - i386-aros-nm.exe
  - i386-aros-objcopy.exe
  - i386-aros-objdump.exe
  - i386-aros-strip.exe
- copy the collect-aros tool into the same directory as where you put the binutils, and make sure the executable is renamed to i386-aros-collect-aros.exe
- when using the 'standard default' collect AROS tool, make sure to set the environment variable COMPILER_PATH. This can be done either systemwide or for a particular user if you so wish.

In theory the binutils are now setup correctly and can be used with FPC.

In order to make FPC 'cross'-aware the following (or similar lines) should be part of your FPC.cfg file:

    # searchpath for tools
    -FD$COMPILER_PATH$
    
    #IFNDEF CPUI386
    #IFNDEF CPUAMD64
    #DEFINE NEEDCROSSBINUTILS
    #ENDIF
    #ENDIF
    
    #IFNDEF WIN32
    #DEFINE NEEDCROSSBINUTILS
    #ENDIF
    
    # binutils prefix for cross compiling
    #IFDEF FPC_CROSSCOMPILING
    #IFDEF NEEDCROSSBINUTILS
    #WRITE A small debug to be able to see if cross-compilation is invoked properly
      -XP$FPCTARGET-
    #ENDIF
    #ENDIF


## FPC 3.0 cross-compilers

Inside directory fpc/3.0.0/bin/i386-win32 are 3 cross-compilers.
- ppcross68k.exe for cross-compiling from fpc 3.0 win32 to Amiga-68k
- ppcross386.exe for cross-compiling from fpc 3.0 win32 to AROS-i386
- ppcrossppc.exe for cross-compiling from fpc 3.0 win32 to MorphOS-powerpc

Attempt to trigger update, as github seems to mess things up for me