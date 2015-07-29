#!/usr/bin/perl

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

$rel_name = $ARGV[0];
$branchName = $ARGV[1];

#$source_path = "/media/Data/test";
#$dest_path = "/media/Data/test";

print "Enter the path, where the compiled Native folder is available(source path) for SDK packaging:";
chomp($source_path=<STDIN>);

if(!(-d $source_path))
{
	print "source path: $source_path does not exist\n";
	print "Exiting...\n\n";
	exit;
}

print "Enter the path, where the SDK folder want to be created(destination path) for SDK packaging:";
chomp($dest_path=<STDIN>);

print "Enter 'yes', if you have copied latest Native compiled folder to the source path: ";
chomp($accept=<STDIN>);

if(($accept ne "yes") && ($accept ne "YES"))
{
	print "\nPlease copy latest Native compiled folder to the source path...\n";
	print "\nExiting...\n\n";
	exit;
}

print "Enter 'yes', if you have copied latest images.tar.gz to the source path: ";
chomp($accept=<STDIN>);

if(($accept ne "yes") && ($accept ne "YES"))
{
	print "\nPlease copy latest images.tar.gz to the source path...\n";
	print "\nExiting...\n\n";
	exit;
}

print "Enter 'yes', if you have copied latest Toolchain to the source path: ";
chomp($accept=<STDIN>);

if(($accept ne "yes") && ($accept ne "YES"))
{
	print "\nPlease copy latest Toolchain to the source path...\n";
	print "\nExiting...\n\n";
	exit;
}

print "Enter 'yes', if you have copied latest SDK scripts to the source path: ";
chomp($accept=<STDIN>);

if(($accept ne "yes") && ($accept ne "YES"))
{
	print "\nPlease copy latest SDK scripts to the source path...\n";
	print "\nExiting...\n\n";
	exit;
}

print "Enter 'yes', if you have copied latest Utilies folder to the source path: ";
chomp($accept=<STDIN>);

if(($accept ne "yes") && ($accept ne "YES"))
{
	print "\nPlease copy latest Utilies folder to the source path...\n";
	print "\nExiting...\n\n";
	exit;
}

$local_path = "/home/socplatform-qa/Wearable";

$local_path_scripts = "$source_path/SDK_Scripts";

#source path locations
$src_path_Native = "$source_path/Native";

#destination path locations
$dest_path_Native = "$dest_path/DHANUSH_ADVANCED_SDK/Wearable";

system("mkdir -p $dest_path/DHANUSH_ADVANCED_SDK/Wearable");
system(" mkdir -p $dest_path/DHANUSH_ADVANCED_SDK/Sensor");
system(" mkdir -p $dest_path/DHANUSH_ADVANCED_SDK/Kernel");
system(" mkdir -p $dest_path/DHANUSH_ADVANCED_SDK/Bootloaders");
system("mkdir -p $dest_path/DHANUSH_ADVANCED_SDK/Docs");
system("mkdir -p $dest_path/DHANUSH_ADVANCED_SDK/Scripts");
system("mkdir -p $dest_path/DHANUSH_ADVANCED_SDK/Android");
system("mkdir -p $dest_path/DHANUSH_ADVANCED_SDK/Tools");

fcopy("$local_path/makefile", "$dest_path_Native/makefile");
fcopy("$local_path/native_env.sh", "$dest_path_Native/native_env.sh");
dircopy("$local_path/build", "$dest_path_Native/build");

dircopy("$src_path_Native/Dhanush_Workspace", "$dest_path_Native/DhanushGUI_Workspace");


system("mkdir -p $dest_path_Native/sdk");
dircopy("$src_path_Native/api/inc", "$dest_path_Native/sdk/inc");

system("mkdir -p $dest_path_Native/applications");
dircopy("$src_path_Native/applications/dhanush_wearable", "$dest_path_Native/applications/dhanush_wearable");
dircopy("$src_path_Native/applications/IfxmModules", "$dest_path_Native/applications/IfxmModules");
fcopy("$src_path_Native/applications/makefile", "$dest_path_Native/applications/makefile");

system("mkdir -p $dest_path_Native/app_framework/inc");
fcopy("$src_path_Native/app_framework/inc/AFW.h", "$dest_path_Native/app_framework/inc/AFW.h");
fcopy("$src_path_Native/app_framework/inc/AFWCommon.h", "$dest_path_Native/app_framework/inc/AFWCommon.h");
fcopy("$src_path_Native/app_framework/inc/AFW_Background_Worker.h", "$dest_path_Native/app_framework/inc/AFW_Background_Worker.h");

dircopy("$local_path/app_framework/inc/ui", "$dest_path_Native/app_framework/inc/ui");

fcopy("$src_path_Native/platforms/os/nucleus/bsp/dhanush/toolset/csgnu_mips.dhanush.link_ram.ld", "$dest_path_Native/sdk/link_ram.ld");

system("mkdir -p $dest_path_Native/sdk/libs");

system("cp $src_path_Native/output/*.lib $dest_path_Native/sdk/libs");

system("rm -rf $dest_path_Native/sdk/libs/app_framework.lib");
system("rm -rf $dest_path_Native/sdk/libs/app_framework_ifxm_modules.lib");
system("rm -rf $dest_path_Native/sdk/libs/native_libs.lib");

system("mkdir -p $dest_path_Native/app_framework/libs");
fcopy("$src_path_Native/output/app_framework.lib", "$dest_path_Native/app_framework/libs/app_framework.lib");

print "\n*******************..Wearable packaging is done..*******************\n";

print "\nDo You Want BRANCH(copy) Android Kitkat source code to $branchName/SDK/Android. (yes/no):";
chomp($acpt=<STDIN>);

if(($acpt eq "yes") || ($acpt eq "YES"))
{
	$commit_string = "Branching Android KitKat 4.4.2 source code to SDK/Android";
	$destination_path_repo="http://insvn01:9090/svn/swdepot/Dhanush/SW/Branches/$rel_name/$branchName/SDK/Android";
	$source_path_repo = "http://insvn01:9090/svn/swdepot/Dhanush/SW/Branches/$rel_name/$branchName/Android/AndroidKK4.4.2";

	#system("svn copy $source_path_repo $destination_path_repo --username socqa --password Yo'\$8'lc9u -m \"$commit_string\"");
	#print "\nCopied Android Source Code.. Branching is Done..\n";

	chdir("$dest_path/DHANUSH_ADVANCED_SDK/Android") || die "can not change directory $!\n";
	#system("svn checkout $destination_path_repo/AndroidKK4.4.2 --username socqa --password Yo'\$8'lc9u > co.log 2> co_error.log");
	
}
elsif(($acpt eq "no") || ($acpt eq "NO"))
{
	$source_path_repo = "http://insvn01:9090/svn/swdepot/Dhanush/SW/Branches/$rel_name/$branchName/Android/AndroidKK4.4.2";

	print "\nDo not copying android kitkat source code to $branchName/SDK/Android.\n";
	chdir("$dest_path/DHANUSH_ADVANCED_SDK/Android") || die "can not change directory $!\n";
	#system("svn checkout $source_path_repo --username socqa --password Yo'\$8'lc9u > co.log 2> co_error.log");
}

print "Enter 'yes', if you have copied latest Docs folder to the source path: ";
chomp($accept=<STDIN>);

if(($accept eq "yes") || ($accept eq "YES"))
{
	dircopy("$source_path/Docs", "$dest_path/DHANUSH_ADVANCED_SDK/Docs") || die "can not copy directory $!\n";
}
else
{
	print "\nScript does not copy Docs folder to DHANUSH_ADVANCED_SDK/Docs...\n";
}

chdir("$source_path");
system("tar -xvzf images.tar.gz ");

fcopy("images/boot/aon.bin", "$dest_path/DHANUSH_ADVANCED_SDK/Sensor/aon.bin") || die "can not copy file $!\n";

fcopy("images/boot/bl1.bin","$dest_path/DHANUSH_ADVANCED_SDK/Bootloaders/bl1.bin") || die "can not copy file $!\n";
fcopy("images/boot/u-boot.bin","$dest_path/DHANUSH_ADVANCED_SDK/Bootloaders/u-boot.bin") || die "can not copy file $!\n";

fcopy("images/boot/vmlinux.bin", "$dest_path/DHANUSH_ADVANCED_SDK/Kernel/vmlinux.bin") || die "can not copy file $!\n";
fcopy("images/modules/wlcore.ko","$dest_path/DHANUSH_ADVANCED_SDK/Kernel/wlcore.ko") || die "can not copy file $!\n";
fcopy("images/modules/wlcore_sdio.ko","$dest_path/DHANUSH_ADVANCED_SDK/Kernel/wlcore_sdio.ko") || die "can not copy file $!\n";
fcopy("images/modules/wl12xx.ko","$dest_path/DHANUSH_ADVANCED_SDK/Kernel/wl12xx.ko") || die "can not copy file $!\n";
fcopy("images/modules/tty_hci.ko","$dest_path/DHANUSH_ADVANCED_SDK/Kernel/tty_hci.ko") || die "can not copy file $!\n";
fcopy("images/modules/st_drv.ko","$dest_path/DHANUSH_ADVANCED_SDK/Kernel/st_drv.ko") || die "can not copy file $!\n";

fcopy("images/modules/pvrsrvkm.ko","$dest_path/DHANUSH_ADVANCED_SDK/Kernel/pvrsrvkm.ko") || die "can not copy file $!\n";
fcopy("images/modules/dc_incdhad1.ko","$dest_path/DHANUSH_ADVANCED_SDK/Kernel/dc_incdhad1.ko") || die "can not copy file $!\n";

fcopy("images/boot/dfu.bin","$dest_path/DHANUSH_ADVANCED_SDK/Tools/dfu.bin") || die "can not copy file $!\n";

dircopy("images/sgx_bin", "$dest_path/DHANUSH_ADVANCED_SDK/Android/sgx_bin") || die "can not copy directory $!\n";

dircopy("$source_path/Toolchain", "$dest_path/DHANUSH_ADVANCED_SDK/Toolchain") || die "can not copy directory $!\n";

dircopy("$source_path/Utilities", "$dest_path/DHANUSH_ADVANCED_SDK/Tools/Utilities") || die "can not copy directory $!\n";

dircopy("$local_path_scripts", "$dest_path/DHANUSH_ADVANCED_SDK/Scripts") || die "can not copy directory $!\n";

fcopy("$source_path/Release_Note.pdf","$dest_path/DHANUSH_ADVANCED_SDK/Release_Note.pdf") || die "can not copy file... $!\n";
fcopy("$source_path/readme.rtf","$dest_path/DHANUSH_ADVANCED_SDK/readme.rtf") || die "can not copy file $!\n";

system("rm -rf images");

fcopy("$source_path/images.tar.gz","$dest_path/DHANUSH_ADVANCED_SDK/images.tar.gz") || die "can not copy file $!\n";

print "\n\n*******************..DHANUSH_ADVANCED_SDK packaging is Done..******************\n\n";

