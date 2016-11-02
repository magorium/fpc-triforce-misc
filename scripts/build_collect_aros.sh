#!/bin/bash

###############################################################################
# build_collect_aros v0.2
#
# A (mingw) bash script to create the collect-aros binutil helper
#
# NOTE: 
# The script presents a list of target CPU's to choose from as well as offers
# the option to create a customized version of the tool.
#
# The customization allows you to choose which search location collect-aros 
# needs to use first for locating the other binutils.
#
# By default collect-aros uses the environment variable COMPILER_PATH firstly
# in order to locate the other binutils but, this can be customized to use 
# environment variable BINUTILS_PATH instead.
#
# Either way, if collect aros can't find the binutils at that location or
# the environment varibale is missing/empty then it tries the host-systems 
# paths that are defined inside the PATH environment variable.
#
# As of the reason for customization: 
# The COMPILER_PATH environment variable messes with mingw gcc compiler and i 
# dislike cluttering the PATH environment variable further.
#
# Note that the collect-aros executable gets named correctly based on the 
# chosen target, except when compiled with using a custom named envirnment 
# variable, in which case the suffix "-custom" is added to its name.
# (This suffix has to be manually removed before actual use).
#
# Remember: 
# You can always add the path of your (other) binutils to your %PATH% 
# environment variable instead of using a customized additional search 
# location. It is optional.
###############################################################################
#               INTENDED FOR PERSONAL USE ONLY. USE AT YOUR OWN RISK
###############################################################################

#
# 1 - identify ourselves
#
echo "collect-aros compilation script v0.2"

#
# 2 - go inside collect-aros directory
#
cd collect-aros

#
# 3 - prepare customization and make safety copy if required
#
if [ ! -f misc.c.in ]; then
  cp -u -p misc.c misc.c.in
fi

#
# 4 - ask which cpu needs to be targetted to create collect aros
#
echo "selecting a CPU to use for target"
PS3="select target CPU:"
options=("m68k" "ppc" "i386" "x86_64" "arm" "sparc")
select opt in "${options[@]}"
do
  case $REPLY in
    1 ) TARGET_CPU="m68k"; break ;;
    2 ) TARGET_CPU="ppc"; break ;;
    3 ) TARGET_CPU="i386"; break ;;
    4 ) TARGET_CPU="x86_64"; break ;;
    5 ) TARGET_CPU="arm"; break ;;
    6 ) TARGET_CPU="sparc"; break ;;
    * ) print "invalid choice" ;;
  esac
done

#
# 5 - ask for customization
#
echo ""
echo "By default collect-aros uses the environment variable 'COMPILER_PATH' to"
echo "search for the other binutils (or uses the PATH environment variable in "
echo "order to find them)"
echo ""
echo "Here you are offered to change the name of the environment variable into"
echo "'BINUTILS_PATH'"
PS3="select which environment variable to use:"
options=("default COMPILER_PATH variable" "custom BINUTILS_PATH")
select opt in "${options[@]}"
do
  case $REPLY in
    1 ) BINUTILS_DIR="COMPILER_PATH"; break ;;
    2 ) BINUTILS_DIR="BINUTILS_PATH"; break ;;
    * ) print "invalid choice" ;;
  esac
done

#
# 6 - replace the magic macro in env.h and set the cpu target
#
sed 's,'@aros_target_cpu@','"$TARGET_CPU"',' env.h.in >env.h

#
# 7 - replace the stdard used environment variable string inside misc.c
#
SRC="getenv(['\"]COMPILER_PATH['\"])"
DST="getenv(\""$BINUTILS_DIR"\")"
sed "s,$SRC,$DST,g" misc.c.in >misc.c

#
# 8 - actually make the collect-aros tool:
#
make USER_CFLAGS="-D_WIN32" AROS_HOST_ARCH=mingw32

#
# 9 - strip the compiled file from unnecessary information 
#
strip -s collect-aros.exe

#
# 10 - rename the freshly created file
#
if [ "$BINUTILS_DIR" = "COMPILER_PATH" ]
then
  mv collect-aros.exe $TARGET_CPU-aros-collect-aros.exe
else
  mv collect-aros.exe $TARGET_CPU-aros-collect-aros-custom.exe
fi

#
# 11 - exit
#
echo "collect aros tool was compiled, stripped and renamed"
