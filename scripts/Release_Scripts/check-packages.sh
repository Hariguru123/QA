#!/bin/sh
dpkg --list git gnupg flex bison gperf build-essential zip curl libc6-dev x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386 libncurses5-dev:amd64

echo ""
echo "If any of the above packages are missing then please install the missing packages using \"sudo apt-get install <package_name>\""
echo ""
echo "Python Version (Recomended is 2.6 / 2.7)"
echo "----------------------------------------"
python --version
echo ""
echo "Make Version (Recomended is 3.81 / 3.82)"
echo "----------------------------------------"
make --version
echo ""
if [ -z $USE_CCACHE ];then
	echo "USE_CCACHE Flag : 0"
else
	echo "USE_CCACHE Flag : $USE_CCACHE"
fi
echo "-------------------"
echo "If USE_CCACHE Flag is not set try setting it using \"export USE_CCACHE=1\""
echo ""
echo "Set CCACHE Size"
echo "---------------"
echo "Set CCACHE to 50GB using \"<android_root>/prebuilts/misc/linux-x86/ccache/ccache -M 50G\""
echo ""
echo "ULIMITS : `ulimit -n`"
echo "--------------"
echo "If ULIMITS IS < 1024 try increasing it with \"ulimits -S -n 1024\""
echo ""
echo "Java Version (Recomended is JDK 7)"
echo "----------------------------------"
if [ -z `which java` ]; then
	echo "Java Not Installed"
else 
	java -version
fi

echo ""
echo "Memory Available"
echo "----------------"
cat /proc/meminfo | head -1
echo "If running inside virtual machine recomended RAM to build ANDROID is 16GB RAM/SWAP and 30GB Storage"
echo ""
echo "System Info (Recomended is Ubuntu 12.04 LTS 64-bit, Also verified on Ubuntu 14.04 LTS 64 bit)"
echo "---------------------------------------------------------------------------------------------"
uname -a
echo ""
