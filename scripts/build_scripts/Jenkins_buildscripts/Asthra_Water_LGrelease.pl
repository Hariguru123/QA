#!/usr/bin/perl
#********************************************************************************************************************************
# 
#   File Name  :   Asthra_Water_LGrelease.pl
#    
#   Description:  It will build the corresponding code based on the arguments received.
#	  
# #********************************************************************************************************************************

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

print "Building LG_Release DhanushAON Micro, DhanushNative Micro, DhanushBootLoader, DhanushUI Micro Projects.....";

#Declaration of local path
$username="socplatform-qa";
$local_path="/media/Data/Jenkins/LG";
$subject = "Daily";

$share = "/home/$username/share";

system("sudo chmod -R 777 $share");

$failed = 0;

if(!(-d "$local_path"))
{
	system("mkdir -p $local_path");
}

$toolchain_mips_path="/home/$username/mips-2013.11";

#Declaration of Date and Time
currentdate();
my $currentDate = "$year\-$mon\-$mday";
my $currentTime = "$hr\-$min\-$sec";

if($subject eq "Daily")
{
	$dst_images_dir = "/home/$username/share/Micro_LG_Builds/Daily_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Micro_LG_Builds/Daily_images/$currentDate";
}
elsif($subject eq "Release")
{
	$dst_images_dir = "/home/$username/share/Micro_LG_Builds/Release_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Micro_LG_Builds/Release_images/$currentDate";
	#$buildnumber="$buildnumber\_$currentDate";
	$buildnumber = "";
	$sub_rel = "$currentTime";
}

#Declaration of local path
$dhanushcode_path="$local_path/DHANUSH_M_LR_Internal";
$change_log_src = "$local_path/changelog_DHANUSH_M_LR_Internal.txt";
$toolchain_path = "$local_path/DHANUSH_M_LR_Internal/Tools/toolchain";

#declaration of destination directories
$dst_reports_log_dir_code="/home/$username/share/Micro_LG_error_logs/DHANUSH_M_LR_Internal/$currentDate/$currentTime";
$dst_reports_log_dir_code1="//192.168.42.46/share/Micro_LG_error_logs/DHANUSH_M_LR_Internal/$currentDate/$currentTime";

dircopy("$toolchain_mips_path", "$toolchain_path/mips-2013.11") || die("can not copy directory");

system("chmod -R 777 $dhanushcode_path/*");

print "*****************DHANUSH_M_LR_Internal BUILD PROCESS****************************\n";

chdir($dhanushcode_path);

fcopy("$dhanushcode_path/Tools/Utilities/elf2bin64", "$dhanushcode_path/Tools/Utilities/elf2bin");

#Build the LG release Project
$status = system("make clean > clobberlog.txt 2> faillog.txt; make > buildlog.txt 2>> faillog.txt");

if ($status) 
{
	$failed = 1;
	print("\n Build Failed, Copying Build log in to share folder $dst_reports_log_dir_code1\n");

	system("sudo chmod -R 777 $dst_reports_log_dir_code");
	system("mkdir -p $dst_reports_log_dir_code");
	fcopy("faillog.txt", $dst_reports_log_dir_code);
	fcopy("buildlog.txt", $dst_reports_log_dir_code);
}
else
{
	print "LG-release Build completed successfully \n";
	
	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		system("sudo chmod -R 777 $dst_images_dir");

		#creating share location for images
		system("mkdir -p $dst_images_dir/$sub_rel");

		fcopy("$dhanushcode_path/Output/aonsram.bin", "$dst_images_dir/$sub_rel");

		fcopy("$dhanushcode_path/Output/aontcm.bin", "$dst_images_dir/$sub_rel");

		fcopy("$dhanushcode_path/Output/d_native.bin", "$dst_images_dir/$sub_rel");

		fcopy("$dhanushcode_path/Output/bl1.bin", "$dst_images_dir/$sub_rel");

		fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/d_bl0.bin", "$dst_images_dir/$sub_rel");

		fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/d_ui.bin", "$dst_images_dir/$sub_rel");

		fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/recovery.bin", "$dst_images_dir/$sub_rel");
	}
	elsif($subject eq "Daily")
	{

		system("sudo chmod -R 777 $dst_images_dir");

		#creating share location for images
		system("mkdir -p $dst_images_dir/$currentTime");

		fcopy("$dhanushcode_path/Output/aonsram.bin", "$dst_images_dir/$currentTime");

		fcopy("$dhanushcode_path/Output/aontcm.bin", "$dst_images_dir/$currentTime");

		fcopy("$dhanushcode_path/Output/d_native.bin", "$dst_images_dir/$currentTime");

		fcopy("$dhanushcode_path/Output/bl1.bin", "$dst_images_dir/$currentTime");

		fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/d_bl0.bin", "$dst_images_dir/$currentTime");

		fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/d_ui.bin", "$dst_images_dir/$currentTime");

		fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/recovery.bin", "$dst_images_dir/$currentTime");
	}

	print "LGrelease output files copied to $dst_images_dir1/$currentTime \n";
}

if($failed eq "1")
{
	print "Build failed...\n";
	exit 1;
}


#*****************************************Functions****************************************************************************

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

