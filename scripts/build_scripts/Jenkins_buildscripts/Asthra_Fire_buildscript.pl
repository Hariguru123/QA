#!/usr/bin/perl
#*******************************************************************************************************************************
# 
#   File Name  :   Asthra_Fire_buildscript.pl
#    
#   Description:  It builds the Asthra Fire(Advanced) build configuration when executed on jenkins. If build failed, old #                 binaries will be packaged and shared.
#
#*******************************************************************************************************************************

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

print "Building Advanced - DhanushAON, DhanushNative, DhanushBL1, DhanushUBoot, DhanushBL0, DhanushAndroid\n";

#Declaration of local path
$username="socplatform-qa";
$local_path="/media/Data/Jenkins/Adv-trunk";
$subject = "Daily";

$SVN_bin_path = "/media/Data/trunk_wc/SVN_bins";

system("sudo chmod 777 $SVN_bin_path/*");

if(!(-d "$local_path"))
{
	system("mkdir -p $local_path");
}

$toolchain_path="$local_path/toolchain";
$toolchain_mips_path="/home/$username/mips-2013.11";

if(!(-d "$toolchain_path"))
{
	system("cp -r /home/$username/toolchain $local_path");
}

$failed = 0;

#Declaration of Date and Time
currentdate();
my $currentDate = "$year\-$mon\-$mday";
my $currentTime = "$mon\-$mday\-$hr\-$min";

if($subject eq "Daily")
{
	$dst_images_dir = "/home/$username/share/Builds/Daily_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Builds/Daily_images/$currentDate";
}
elsif($subject eq "Release")
{
	$dst_images_dir = "/home/$username/share/Builds/Release_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Builds/Release_images/$currentDate";
	#$buildnumber="$buildnumber\_$currentDate";
	$sub_rel = "$currentTime";
	$buildnumber = "";
}

$share = "/home/$username/share";
$share_path = "/home/$username/share/Builds";

system("sudo chmod -R 777 $share");

#Declaration of scripts local path
$local_path_sourcecode_scripts="$local_path/Scripts";

#Declaration of resources local path
$local_path_sourcecode_resources="$local_path/resources";

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*** Native ***#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#Declaration of Native path
$dhanushnative_path="$local_path/Native";

#Declaration of DhanushNative environment paths
$dhanushnativeenv_path="$dhanushnative_path/build/scripts/native_env.sh";
$dhanushnativeenv_temp_path="$dhanushnative_path/build/scripts/temp.sh";

#Declaration of destination directories
$dst_reports_log_dir_Native="/home/$username/share/error_logs/DhanushNative/$currentDate/$currentTime";
$dst_reports_log_dir_Native1="//192.168.42.46/share/error_logs/DhanushNative/$currentDate/$currentTime";
		
system("rm -rf $toolchain_path/ubuntu64/mips/*");
system("cp -r $toolchain_mips_path/* $toolchain_path/ubuntu64/mips/");	
system("chmod -R 777 $toolchain_path/*");
	
printf "Toolchain Copied Successfully...\n";

print "****************************************** Native BUILD PROCESS ********************************************\n";

#delete the output folder with contents and create new output folder 
system("rm -rf $dhanushnative_path/output"); 
system("mkdir $dhanushnative_path/output");

chdir($dhanushnative_path);

#change the env path to the local path
change_envfile_path($dhanushnative_path,$dhanushnativeenv_path,$dhanushnativeenv_temp_path);

#Build the Native Project
$status = system(". ./build/scripts/native_env.sh > log.txt; make clobber >clobber_log.txt 2> faillog.txt;make BUILD_NUC=1 rel > buildlog.txt 2>> faillog.txt;");
if ($status) 
{
	$failed = 1;
	print("\n Build Failed, Copying Build log in to share folder\n");
		
	system("mkdir -p $dst_reports_log_dir_Native");
	fcopy("faillog.txt", $dst_reports_log_dir_Native);
	fcopy("buildlog.txt", $dst_reports_log_dir_Native);
}
else
{
	print "Native Build completed successfully \n";
	
	#update the destination folder after successfull build	
	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		$dst_reports_dir_Native="/home/$username/share/Builds/Release_Builds/$buildnumber/$currentTime/Native";
		$dst_reports_dir_Native1="//192.168.42.46/share/Builds/Release_Builds/$buildnumber/$currentTime/Native";
	}
	elsif($subject eq "Daily")
	{
		$dst_reports_dir_Native="/home/$username/share/Builds/Daily_Builds/$currentDate/$currentTime/Native";
		$dst_reports_dir_Native1="//192.168.42.46/share/Builds/Daily_Builds/$currentDate/$currentTime/Native";
	}

	#renaming bin
	fcopy("$dhanushnative_path/output/dhanush_wearable.bin", "$dhanushnative_path/output/native.bin");

	#creating share location
	system("mkdir -p $dst_reports_dir_Native");

	#copy the output files to destination location 
	dircopy("$dhanushnative_path/output", $dst_reports_dir_Native);

	#copying images to local path
	fcopy("$dhanushnative_path/output/native.bin", "$local_path");

	fcopy("$dhanushnative_path/output/native.bin", "$SVN_bin_path/native.bin");

	print "Native output files copied to $dst_reports_dir_Native \n";
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*** AONsensor ***#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

$dhanushaon_path="$local_path/AONsensor";

#Declaration of DhanushAON Environment paths
$dhanushaonenv_path="$dhanushaon_path/build/scripts/dhanushaon_env.sh";
$dhanushaonenv_temp_path="$dhanushaon_path/build/scripts/dhanushtemp.sh";

#declaration of destination directories
$dst_reports_log_dir_AON="/home/$username/share/error_logs/DhanushAON/$currentDate/$currentTime";
$dst_reports_log_dir_AON1="//192.168.42.46/share/error_logs/DhanushAON/$currentDate/$currentTime";

print "**************************************** AONsensor BUILD PROCESS ******************************************\n";

#delete the output folder with contents and create new output folder 
system("rm -rf $dhanushaon_path/output"); 
system("mkdir $dhanushaon_path/output");

chdir($dhanushaon_path);
#change the env path to the local path
change_envfile_path($dhanushaon_path,$dhanushaonenv_path,$dhanushaonenv_temp_path);

#Build the AON Project
$status = system(". ./build/scripts/dhanushaon_env.sh > log.txt;./aon_build.sh > buildlog.txt 2> faillog.txt");

if((!(-f "$dhanushaon_path/output/aon.bin") || !(-f "$dhanushaon_path/output/dfu.bin") ) || ($status)) 
{
	$failed = 1;
	print("\n Build Failed, Copying Build log in to share folder\n");

	system("mkdir -p $dst_reports_log_dir_AON");
	fcopy("faillog.txt", $dst_reports_log_dir_AON);
	fcopy("buildlog.txt", $dst_reports_log_dir_AON);
}
else
{
	print "AONsensor Build Completed successfully \n";
	
	#update the destination folder after successfull build

	if(($subject eq "Weekly") || ($subject eq "Release"))
	{		
		$dst_reports_dir_AON="/home/$username/share/Builds/Release_Builds/$buildnumber/$currentTime/AON";
		$dst_reports_dir_AON1="//192.168.42.46/share/Builds/Release_Builds/$buildnumber/$currentTime/AON";
	}
	elsif($subject eq "Daily")
	{
		$dst_reports_dir_AON="/home/$username/share/Builds/Daily_Builds/$currentDate/$currentTime/AON";
		$dst_reports_dir_AON1="//192.168.42.46/share/Builds/Daily_Builds/$currentDate/$currentTime/AON";
	}

	# Create share location
	system("mkdir -p $dst_reports_dir_AON");

	#copy the output files to destination location
	dircopy("$dhanushaon_path/output", $dst_reports_dir_AON);

	#copying bins to local path for nand boot		
	fcopy("$dhanushaon_path/output/aon.bin", "$local_path");

	#copying bins to local path for nand boot		
	fcopy("$dhanushaon_path/output/dfu.bin", "$local_path");

	fcopy("$dhanushaon_path/output/aon.bin", "$SVN_bin_path/aon.bin");

	fcopy("$dhanushaon_path/output/dfu.bin", "$SVN_bin_path/dfu.bin");


	print "AONsensor output files copied to $dst_reports_dir_AON \n";
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*** BL1 ***#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#Declaration of BL1 path
$dhanushBL1_path="$local_path/BL1";

#Declaration of destination directories
$dst_reports_log_dir_BL1="/home/$username/share/error_logs/Dhanush-BL1/$currentDate/$currentTime";
$dst_reports_log_dir_BL11="//192.168.42.46/share/error_logs/Dhanush-BL1/$currentDate/$currentTime";

print "******************************************* BL1 BUILD PROCESS **********************************************\n";

# Replacing the $PATH value with local tool chain path

$srcBuild_ScriptPath = "$dhanushBL1_path/config/config.mk";

$build_ScriptPath = "$dhanushBL1_path/config/config_temp.mk";

open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

my $path_string = "CROSS_COMPILE =";

my $path = "= /home/$username/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin/mips-linux-gnu-";

foreach my $line (<$RD>)
{
	if($line =~ /$path_string/)
	{
		  if($line=~s/=.+\n/$path\n/)
		  {  
			print $RD1 $line;	
		  }
	}
	else
	{
		 print $RD1 $line;
	}
}
close($RD);
close($RD1);
system("rm -rf $srcBuild_ScriptPath");
system("mv $build_ScriptPath $srcBuild_ScriptPath");
system("chmod 777 $srcBuild_ScriptPath");

chdir($dhanushBL1_path);

$status=system("make clean; make > BL1_buildlog.txt 2> BL1_faillog.txt");

if((!(-f "$dhanushBL1_path/out/bl1.bin")) || ($status)) 
{
	$failed = 1;
	print("\n BL1 Build Failed, Copying fail log in to share folder\n");
	system("mkdir -p $dst_reports_log_dir_BL1");

	fcopy("$dhanushBL1_path/BL1_buildlog.txt",$dst_reports_log_dir_BL1);
	fcopy("$dhanushBL1_path/BL1_faillog.txt",$dst_reports_log_dir_BL1);
}
else
{
	print "BL1 Build completed successfully...\n";

	#update the destination folder after successfull build		
	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		$dst_reports_dir_BL1="/home/$username/share/Builds/Release_Builds/$buildnumber/$currentTime/BL1";
		$dst_reports_dir_BL11="//192.168.42.46/share/Builds/Release_Builds/$buildnumber/$currentTime/BL1";
	}
	elsif($subject eq "Daily")
	{
		$dst_reports_dir_BL1="/home/$username/share/Builds/Daily_Builds/$currentDate/$currentTime/BL1";
		$dst_reports_dir_BL11="//192.168.42.46/share/Builds/Daily_Builds/$currentDate/$currentTime/BL1";
	}
	
	system("mkdir -p $dst_reports_dir_BL1");

	#copy the output files to destination location 
	fcopy("$dhanushBL1_path/out/bl1.bin", $dst_reports_dir_BL1);

	#copying bin to local path
	fcopy("$dhanushBL1_path/out/bl1.bin", "$local_path");

	fcopy("$dhanushBL1_path/out/bl1.bin", "$SVN_bin_path/bl1.bin");

	print "output files copied to $dst_reports_dir_BL1 \n";	
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*** U-Boot ***#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#Declaration of U-Boot path
$dhanushUboot_path="$local_path/U-Boot";

#Declaration of destination directories
$dst_reports_log_dir_Uboot="/home/$username/share/error_logs/U-Boot/$currentDate/$currentTime";
$dst_reports_log_dir_Uboot1="//192.168.42.46/share/error_logs/U-Boot/$currentDate/$currentTime";

print "************************************** U-Boot BUILD PROCESS *****************************************\n";

# Replacing the $PATH value with local tool chain path

$srcBuild_ScriptPath = "$dhanushUboot_path/build.sh";

$build_ScriptPath = "$dhanushUboot_path/build_temp.sh";
$count = 0;

open(my $RD, "< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

my $path = "export PATH=$toolchain_path/ubuntu64/mips/bin:\$PATH";

foreach my $line (<$RD>)
{
	print $RD1 $line;
	if($count == 0)
	{
		print $RD1 "$path\n";
	}
	$count++;
}
close($RD);
close($RD1);
system("rm -rf $srcBuild_ScriptPath");
system("mv $build_ScriptPath $srcBuild_ScriptPath");
system("chmod 777 $srcBuild_ScriptPath");

chdir($dhanushUboot_path);

$status=system("./build.sh clean; ./build.sh > U-Boot_buildlog.txt 2> U-Boot_faillog.txt");

if((!(-f "$dhanushUboot_path/u-boot.bin")) || ($status))
{
	$failed = 1;
	print("\n U-Boot Build Failed, Copying fail log in to share folder\n");

	system("mkdir -p $dst_reports_log_dir_Uboot");
	fcopy("$dhanushUboot_path/U-Boot_buildlog.txt",$dst_reports_log_dir_Uboot);
	fcopy("$dhanushUboot_path/U-Boot_faillog.txt",$dst_reports_log_dir_Uboot);
}
else
{
	print "U-Boot Build completed successfully \n";

	#update the destination folder after successfull build		
	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		$dst_reports_dir_Uboot="/home/$username/share/Builds/Release_Builds/$buildnumber/$currentTime/U-Boot";
		$dst_reports_dir_Uboot1="//192.168.42.46/share/Builds/Release_Builds/$buildnumber/$currentTime/U-Boot";
	}	
	elsif($subject eq "Daily")
	{
		$dst_reports_dir_Uboot="/home/$username/share/Builds/Daily_Builds/$currentDate/$currentTime/U-Boot";
		$dst_reports_dir_Uboot1="//192.168.42.46/share/Builds/Daily_Builds/$currentDate/$currentTime/U-Boot";
	}

	system("mkdir -p $dst_reports_dir_Uboot");

	#copy the output files to destination location 
	fcopy("$dhanushUboot_path/u-boot.bin", $dst_reports_dir_Uboot);

	#copying bin to local path
	fcopy("$dhanushUboot_path/u-boot.bin", "$local_path");

	fcopy("$dhanushUboot_path/u-boot.bin", "$SVN_bin_path/u-boot.bin");

	print "output files copied to $dst_reports_dir_Uboot\n";			
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*** BL0 ***#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#Declaration of BL0 path
$dhanushBL0_path="$local_path/BL0";

#Declaration of destination directories
$dst_reports_log_dir_BL0="/home/$username/share/error_logs/Dhanush-BL0/$currentDate/$currentTime";
$dst_reports_log_dir_BL01="//192.168.42.46/share/error_logs/Dhanush-BL0/$currentDate/$currentTime";

print "************************************** BL0 BUILD PROCESS ****************************************\n";

chdir($dhanushBL0_path);

# Replacing the $PATH value with local tool chain path

$srcBuild_ScriptPath = "$dhanushBL0_path/config/config.mk";

$build_ScriptPath = "$dhanushBL0_path/config/config_temp.mk";

open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

my $path_string = "CROSS_COMPILE =";

my $path = "= /home/$username/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin/mips-linux-gnu-";

foreach my $line (<$RD>)
{
	if($line =~ /$path_string/)
	{
		  if($line=~s/=.+\n/$path\n/)
		  {
			print $RD1 $line;
		  }
	}
	else
	{
		 print $RD1 $line;
	}

}
close($RD);
close($RD1);
system("rm -rf $srcBuild_ScriptPath");
system("mv $build_ScriptPath $srcBuild_ScriptPath");
system("chmod 777 $srcBuild_ScriptPath");

$status=system("make clean; make > BL0_buildlog.txt 2> BL0_faillog.txt");

if((!(-f "$dhanushBL0_path/bin/bl0.bin")) || ($status)) 
{
	$failed = 1;
	print("\n BL0 Build Failed, Copying fail log in to share folder\n");

	system("mkdir -p $dst_reports_log_dir_BL0");
	
	fcopy("$dhanushBL0_path/BL0_buildlog.txt",$dst_reports_log_dir_BL0);
	fcopy("$dhanushBL0_path/BL0_faillog.txt",$dst_reports_log_dir_BL0);
}
else
{
	print "BL0 Build Completed Successfully...\n";

	#update the destination folder after successfull build		
	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		$dst_reports_dir_BL0="/home/$username/share/Builds/Release_Builds/$buildnumber/$currentTime/BL0";
		$dst_reports_dir_BL01="//192.168.42.46/share/Builds/Release_Builds/$buildnumber/$currentTime/BL0";
	}
	elsif($subject eq "Daily")
	{
		$dst_reports_dir_BL0="/home/$username/share/Builds/Daily_Builds/$currentDate/$currentTime/BL0";
		$dst_reports_dir_BL01="//192.168.42.46/share/Builds/Daily_Builds/$currentDate/$currentTime/BL0";
	}
	
	system("mkdir -p $dst_reports_dir_BL0");

	#copy the output files to destination location 
	fcopy("$dhanushBL0_path/bin/bl0.bin", $dst_reports_dir_BL0);

	#copying to local path
	fcopy("$dhanushBL0_path/bin/bl0.bin", "$local_path");

	#copying to local path
	fcopy("$dhanushBL0_path/bin/bl0.bin", "$share_path");

	fcopy("$dhanushDFU_path/bin/bl0.bin", "$SVN_bin_path/bl0.bin");

	print "output files copied to $dst_reports_dir_BL0...\n";
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*** Android Full build ***#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#Declaration of Android path
$dhanushandroid_path="$local_path/Android";

fcopy("$dhanushandroid_path/adv_fullbuild.sh", "$local_path/adv_fullbuild.sh");
fcopy("$dhanushandroid_path/adv2_fullbuild.sh", "$local_path/adv2_fullbuild.sh");

#Declaration of Android path
$dhanushandroid_path="$local_path";

#Declaration of Android SGX path
$local_path_sourcecode_SGX = "$dhanushandroid_path/SGX";

#Declaration of Android Kernel path
$local_path_sourcecode_kernel="$dhanushandroid_path/android-linux-mti-unif-3.10.14";

#Declaration of destination directories
$dst_reports_log_dir_Android="/home/$username/share/error_logs/Dhanush-Android/$currentDate/$currentTime";
$dst_reports_log_dir_Android1="//192.168.42.46/share/error_logs/Dhanush-Android/$currentDate/$currentTime";

chdir($dhanushandroid_path);

system("svn upgrade $local_path_sourcecode_kernel --username socqa --password Yo'\$8'lc9u > upg.txt 2> up_err.txt");

system("svn upgrade $local_path_sourcecode_SGX --username socqa --password Yo'\$8'lc9u > upg_sgx.txt 2> up_err_sgx.txt");

#change to the kernel path
chdir($local_path_sourcecode_kernel);

# Replacing the $PATH value with local tool chain path

$srcBuild_ScriptPath = "$local_path_sourcecode_kernel/build.sh";

$build_ScriptPath = "$local_path_sourcecode_kernel/build_temp.sh";

open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

my $path_string = "export PATH=";

my $path = "=/home/$username/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin:\$PATH";

foreach my $line (<$RD>)
{
	if($line =~ /$path_string/)
	{
		  if($line=~s/=.+\n/$path\n/)
		  {  
			print $RD1 $line;
		  }
	}
	else
	{
		 print $RD1 $line;
	}
}
close($RD);
close($RD1);
system("rm -rf $srcBuild_ScriptPath");
system("mv $build_ScriptPath $srcBuild_ScriptPath");
system("chmod 777 $srcBuild_ScriptPath");


# Replacing the $PATH value with local tool chain path

$srcBuild_ScriptPath = "$local_path_sourcecode_SGX/sgx.sh";

$build_ScriptPath = "$local_path_sourcecode_SGX/sgx_temp.sh";

open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

my $path_string = "export MHOME=";
my $path1_str = "export ANDROID_ROOT=";
my $path2_str = "export KERNELDIR=";

my $path = "=$dhanushandroid_path";
my $path1 = "=$dhanushandroid_path/AndroidKK4.4.2";
my $path2 = "=$local_path_sourcecode_kernel";

foreach my $line (<$RD>)
{
	if($line =~ /$path_string/)
	{
		if($line=~s/=.+\n/$path\n/)
		{  
		print $RD1 $line;	
		}
	}
	elsif($line =~ /$path1_str/)
	{
		if($line=~s/=.+\n/$path1\n/)
		{  
			print $RD1 $line;	
		}
	}
	elsif($line =~ /$path2_str/)
	{
		if($line=~s/=.+\n/$path2\n/)
		{  
			print $RD1 $line;	
		}
	}
	else
	{
		 print $RD1 $line;
	}
}
close($RD);
close($RD1);
system("rm -rf $srcBuild_ScriptPath");
system("mv $build_ScriptPath $srcBuild_ScriptPath");
system("chmod 777 $srcBuild_ScriptPath");

#Declaration of DhanushAndroid paths
$local_path_sourcecode_kitkat="$dhanushandroid_path/AndroidKK4.4.2";

$arg = "clean";
$arg3 = "up";
$check = 0;

REPEAT_BUILD:

print "************************************ ANDROID $arg3 BUILD PROCESS **************************************\n";
	
chdir($dhanushandroid_path);

system("chmod 777 adv2_fullbuild.sh");

$status=system("./adv2_fullbuild.sh $arg int $arg3 > Android_buildlog.txt 2> Android_faillog.txt");

if((!(-f "$local_path_sourcecode_kitkat/images/rfs/system.img")) || ($status)) 
{
	print("\n Android Build Failed, Copying Build log in to share folder.\n");

	chdir($local_path_sourcecode_kitkat);
	system("mkdir -p $dst_reports_log_dir_Android");
	dircopy("$local_path_sourcecode_kitkat/logs",$dst_reports_log_dir_Android);
	$failed = 1;
}
else
{
	print "Android Build completed successfully... \n";

	chdir($local_path_sourcecode_kitkat);

	fcopy("$local_path/aon.bin", "$local_path_sourcecode_kitkat/images/boot");

	fcopy("$local_path/native.bin", "$local_path_sourcecode_kitkat/images/boot");

	fcopy("$local_path/dfu.bin", "$local_path_sourcecode_kitkat/images/boot");

	fcopy("$local_path/bl1.bin", "$local_path_sourcecode_kitkat/images/boot");

	fcopy("$local_path/u-boot.bin", "$local_path_sourcecode_kitkat/images/boot");

	fcopy("$local_path/Scripts/mkfs.incdhad1","$local_path_sourcecode_kitkat/images");
	
	fcopy("$local_path/Scripts/mkheader","$local_path_sourcecode_kitkat/images");

	dircopy("$local_path/Scripts/media","$local_path_sourcecode_kitkat/images/media");

	dircopy("$local_path/Scripts/Music","$local_path_sourcecode_kitkat/images/Music");
	
	fcopy("$local_path/resources/logo1.bin","$local_path_sourcecode_kitkat/images/boot");

	#copy the output files to destination location 
	system("tar cvzf $local_path/images_$arg3.tar.gz images");

	#creating share location for images.tar.gz
	system("mkdir -p $dst_images_dir");

	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		#rename images 
		system("mv images images_$arg3\_$sub_rel");

		system("tar cvzf $local_path/images_$arg3\_$sub_rel.tar.gz images_$arg3\_$sub_rel");

		system("mv images_$arg3\_$sub_rel images");

		#copying tar.gz to common images directory
		fcopy("$local_path/images_$arg3\_$sub_rel.tar.gz", "$dst_images_dir/images_$arg3\_$sub_rel.tar.gz");

		#remove images_$sub_rel.tar.gz
		system("rm -rf $local_path/images_$arg3\_$sub_rel.tar.gz");

		fcopy("$local_path/images_$arg3.tar.gz", "$SVN_bin_path/images_$arg3.tar.gz");
	}
	elsif($subject eq "Daily")
	{
		#rename images 
		system("mv images images_$arg3\_$currentTime");

		#copy the output files to destination location 
		system("tar cvzf $local_path/images_$arg3\_$currentTime.tar.gz images_$arg3\_$currentTime");

		system("mv images_$arg3\_$currentTime images");

		#copying tar.gz to common images directory
		fcopy("$local_path/images_$arg3\_$currentTime.tar.gz", "$dst_images_dir/images_$arg3\_$currentTime.tar.gz");

		system("rm -rf $local_path/images_$arg3\_$currentTime.tar.gz");

		fcopy("$local_path/images_$arg3.tar.gz", "$SVN_bin_path/images_$arg3.tar.gz");
	}

	if($check eq 0)
	{
		$check = 1;
		$arg3 = "smp";
		$arg = "no";
		goto REPEAT_BUILD;
	}
}

# Image Packaging...

if(-f "$local_path/images_up.tar.gz")
{
	chdir("$local_path");

	#untar the images.tar.gz
	system("tar -xvzf $local_path/images_up.tar.gz");

	#remove images.tar.gz
	system("rm -rf $local_path/images_up.tar.gz");

	fcopy("$local_path/aon.bin", "$local_path/images/boot");

	fcopy("$local_path/native.bin", "$local_path/images/boot");

	fcopy("$local_path/dfu.bin", "$local_path/images/boot");

	fcopy("$local_path/bl1.bin", "$local_path/images/boot");

	fcopy("$local_path/u-boot.bin", "$local_path/images/boot");

	fcopy("$local_path/Scripts/mkfs.incdhad1","$local_path/images");

	fcopy("$local_path/Scripts/mkheader","$local_path/images");

	dircopy("$local_path/Scripts/media","$local_path/images/media");

	dircopy("$local_path/Scripts/Music","$local_path/images/Music");

	fcopy("$local_path/resources/logo1.bin","$local_path/images/boot");

	#tar the images folder to images.tar.gz
	system("tar cvzf $local_path/images_up.tar.gz images");

	#creating share location for images.tar.gz
	system("mkdir -p $dst_images_dir");

	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		#rename images
		system("mv $local_path/images $local_path/images_up_$sub_rel");

		#tar the images folder to images_$sub_rel.tar.gz
		system("tar cvzf $local_path/images_up_$sub_rel.tar.gz images_up_$sub_rel");

		#remove images_$sub_rel
		system("rm -rf $local_path/images_up_$sub_rel");

		#copying tar.gz to common images directory
		fcopy("$local_path/images_up_$sub_rel.tar.gz", "$dst_images_dir/images_up_$sub_rel.tar.gz");

		#remove images_$sub_rel.tar.gz
		system("rm -rf $local_path/images_up_$sub_rel.tar.gz");

		fcopy("$local_path/images_up.tar.gz", "$SVN_bin_path/images_up.tar.gz");			
	
	}
	elsif($subject eq "Daily")
	{
		#rename images
		system("mv $local_path/images $local_path/images_up_$currentTime");

		#tar the images folder to images_$currentTime.tar.gz
		system("tar cvzf $local_path/images_up_$currentTime.tar.gz images_up_$currentTime");

		#remove images_$currentTime
		system("rm -rf $local_path/images_up_$currentTime");

		#copying tar.gz to common images directory
		fcopy("$local_path/images_up_$currentTime.tar.gz", "$dst_images_dir/images_up_$currentTime.tar.gz");

		system("rm -rf $local_path/images_up_$currentTime.tar.gz");

		fcopy("$local_path/images_up.tar.gz", "$SVN_bin_path/images_up.tar.gz");

		$img_body="\n\nDaily Image copied to $dst_images_dir1.";
	}

	print "Done..\n";
}

if(-f "$local_path/images_smp.tar.gz")
{
	chdir("$local_path");

	#untar the images.tar.gz
	system("tar -xvzf $local_path/images_smp.tar.gz");

	#remove images.tar.gz
	system("rm -rf $local_path/images_smp.tar.gz");

	fcopy("$local_path/aon.bin", "$local_path/images/boot");

	fcopy("$local_path/native.bin", "$local_path/images/boot");

	fcopy("$local_path/dfu.bin", "$local_path/images/boot");

	fcopy("$local_path/bl1.bin", "$local_path/images/boot");

	fcopy("$local_path/u-boot.bin", "$local_path/images/boot");

	fcopy("$local_path/Scripts/mkfs.incdhad1","$local_path/images");

	fcopy("$local_path/Scripts/mkheader","$local_path/images");

	dircopy("$local_path/Scripts/media","$local_path/images/media");

	dircopy("$local_path/Scripts/Music","$local_path/images/Music");

	fcopy("$local_path/resources/logo1.bin","$local_path/images/boot");

	#tar the images folder to images.tar.gz
	system("tar cvzf $local_path/images_smp.tar.gz images");

	#creating share location for images.tar.gz
	system("mkdir -p $dst_images_dir");

	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		#rename images
		system("mv $local_path/images $local_path/images_smp_$sub_rel");

		#tar the images folder to images_$sub_rel.tar.gz
		system("tar cvzf $local_path/images_smp_$sub_rel.tar.gz images_smp_$sub_rel");

		#remove images_$sub_rel
		system("rm -rf $local_path/images_smp_$sub_rel");

		#copying tar.gz to common images directory
		fcopy("$local_path/images_smp_$sub_rel.tar.gz", "$dst_images_dir/images_smp_$sub_rel.tar.gz");

		#remove images_$sub_rel.tar.gz
		system("rm -rf $local_path/images_smp_$sub_rel.tar.gz");

		fcopy("$local_path/images_smp.tar.gz", "$SVN_bin_path/images_smp.tar.gz");

		$img_body="\n\n$subject Image - $sub_rel copied to $dst_images_dir1.";

	}
	elsif($subject eq "Daily")
	{
		#rename images
		system("mv $local_path/images $local_path/images_smp_$currentTime");

		#tar the images folder to images_$currentTime.tar.gz
		system("tar cvzf $local_path/images_smp_$currentTime.tar.gz images_smp_$currentTime");

		#remove images_$currentTime
		system("rm -rf $local_path/images_smp_$currentTime");

		#copying tar.gz to common images directory
		fcopy("$local_path/images_smp_$currentTime.tar.gz", "$dst_images_dir/images_smp_$currentTime.tar.gz");

		system("rm -rf $local_path/images_smp_$currentTime.tar.gz");

		fcopy("$local_path/images_smp.tar.gz", "$SVN_bin_path/images_smp.tar.gz");

		$img_body="\n\nDaily Image copied to $dst_images_dir1.";
	}
	print "Done..\n";
}

if($failed eq "1")
{
	print "Build failed...\n";
	exit 1;
}

#********************************************************* Functions ************************************************************
sub currentdate
{
    ($sec, $min, $hr, $mday, $mon, $year, $wday, $yday, $daylight) = localtime();
    $year += 1900;
    $mon++;

    # Appending 0's if less than 10
    if( $sec < 10 )
    {
        $sec = "0$sec";
    }
    if( $min < 10 )
    {
        $min = "0$min";
    }
    if( $hr < 10 )
    {
        $hr = "0$hr";
    }
    if( $mday < 10 )
    {
        $mday = "0$mday";
    }
    if( $mon < 10 )
    {
        $mon = "0$mon";
    }
}
sub change_envfile_path
{
	$dhanush_envpath=$_[1];	
	$dhanush_env_temppath=$_[2];
	open(my $RD, "+< $dhanush_envpath") || die("Can't open file: $dhanush_envpath");
	open(my $RD1, " > $dhanush_env_temppath") || die("Can't open file: $dhanush_env_temppath");

	$fun_path=$_[0];
	my $src_string = "export SRC_ROOT=";
	my $src_path = "=$fun_path";
	my $toolchain_string = "export DK_ROOT=";
	my $toolchain_repo_path = "=$toolchain_path";

	foreach my $line (<$RD>)
	{
   		if($line =~ /$src_string/)
   		{
        		if($line=~s/=.+\n/$src_path\n/)
        		{  
				print $RD1 $line;	
			}	    
   		}
 		elsif($line =~ /$toolchain_string/)
 		{
  			  if($line=~s/=.+\n/$toolchain_repo_path\n/)
    			  {  
				print $RD1 $line;	
   			  }
  		}
 		else
 		{
   			 print $RD1 $line;
 		}

	}
	close($RD);
	close($RD1);
	system("rm -rf $dhanush_envpath");
	system("mv $dhanush_env_temppath $dhanush_envpath");
}

