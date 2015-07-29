#! /bin/bash

#Enable below line for debugging this script
#set -x 

#Usage and Help
# ./build.sh   -   For complete AON and Native builds
# Binaries will be generated in ./Output folder

# Start user modified settings
export SRC_PATH=`pwd`
export TOOLCHAIN=$SRC_PATH/Tools/toolchain
export TOOLPATH=$TOOLCHAIN/ubuntu64/mips/bin
# End user modified settings

mkdir $SRC_PATH/Output

#AON build
cd $SRC_PATH/AON
./build.sh clean
./build.sh
cp output/*.bin $SRC_PATH/Output

#Building Native
cd $SRC_PATH/Native

cp $SRC_PATH/Native/native.bin $SRC_PATH/Output/native.bin
cp $SRC_PATH/Tools/Utilities/SPI_Utility/dictionary.bin $SRC_PATH/Output/dictionary.bin

#UI
cd $SRC_PATH/Tools/Utilities/UIResourceGenerator
./gen_UI_bin.sh MSDK1

cp $SRC_PATH/Tools/Utilities/UIResourceGenerator/d_ui.bin $SRC_PATH/Output/d_ui.bin

#Boot loader
cd $SRC_PATH/Bootloader
cp *.bin $SRC_PATH/Output
cp spiutil.elf $SRC_PATH/Output

