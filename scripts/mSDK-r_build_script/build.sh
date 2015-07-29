#! /bin/bash

SRC_PATH=`pwd`

#AON build
cd $SRC_PATH/AON
./build.sh clean
./build.sh
cp output/*.bin $SRC_PATH/Output


#Native image1 build

cd $SRC_PATH/Native
cp dictionary.bin $SRC_PATH/Output

. ./native_env_msdk.sh
make clobber rel
cp output/msdk3image1/d_dhanush_wearable.bin $SRC_PATH/Output/native1.bin
cp sdk/bin/native2.bin $SRC_PATH/Output/native2.bin


#UI build

cd $SRC_PATH/Tools/Utilities/UIResourceGenerator
./gen_UI_bin.sh MSDK3_160
cp d_ui.bin $SRC_PATH/Output


#Bootloader build

cd $SRC_PATH/Bootloader
cp *.bin $SRC_PATH/Output
cp spiutil.elf $SRC_PATH/Output

