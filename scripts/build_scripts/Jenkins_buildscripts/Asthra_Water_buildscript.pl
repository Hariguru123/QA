#!/usr/bin/perl
#********************************************************************************************************************************
# 
#   File Name  :   Asthra_Water_buildscript.pl
#    
#   Description:  It builds the Dhanush Micro trunk - AONsensor, Native and Bootloader codes are available.
# #********************************************************************************************************************************

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

print "Building Micro Trunk - AONsensor, BootLoader, Native and UI Projects....\n";


#Declaration of local path
$username="socplatform-qa";
$local_path="/media/Data/Jenkins/Micro-trunk";
$subject = "Daily";

if(!(-d "$local_path"))
{
	system("mkdir -p $local_path");
}

#Declaration of toolchain path
$toolchain_path="$local_path/toolchain";

if(!(-d "$toolchain_path"))
{
	system("cp -r /home/$username/toolchain $local_path");
}

#Declaration of Date and Time
currentdate();
my $currentDate = "$year\-$mon\-$mday";
my $currentTime = "$hr\-$min\-$sec";

if($subject eq "Daily")
{
	$dst_images_dir = "/home/$username/share/Micro_Builds/Daily_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Micro_Builds/Daily_images/$currentDate";
}
elsif($subject eq "Release")
{
	$dst_images_dir = "/home/$username/share/Micro_Builds/Release_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Micro_Builds/Release_images/$currentDate";
	#$buildnumber="$buildnumber\_$currentDate";
	$sub_rel = "$currentTime";
	$buildnumber = "";
}

$share = "/home/$username/share";

system("sudo chmod -R 777 $share");

$failed = 0;
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*** AONsensor ***#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#Declaration of toolchain path
$aon_toolchain_path="$toolchain_path/ubuntu64/mips/bin";

#Declaration of local path
$dhanushaon_path="$local_path/AONsensor";
$sourcecode_repo_path = "http://insvn01:9090/svn/swdepot/Dhanush/SW/Micro-trunk/AONsensor";

#Declaration of DhanushAON Environment paths
$dhanushaonenv_path="$dhanushaon_path/build/dhanushaon_env.sh";
$dhanushaonenv_temp_path="$dhanushaon_path/build/dhanushtemp.sh";

#declaration of destination directories
$dst_reports_log_dir_AON="/home/$username/share/Micro_error_logs/DhanushAON/$currentDate/$currentTime";
$dst_reports_log_dir_AON1="//192.168.42.46/share/Micro_error_logs/DhanushAON/$currentDate/$currentTime";

print "*********************************************** AONsensor BUILD PROCESS *********************************************\n";

#delete the output folder with contents and create new output folder 
system("rm -rf $dhanushaon_path/output"); 
system("mkdir $dhanushaon_path/output");

chdir($dhanushaon_path);

#change the env path to the local path
change_envfile_path($aon_toolchain_path,$dhanushaonenv_path,$dhanushaonenv_temp_path);

#Build the AON Project
$status = system(". ./build/dhanushaon_env.sh > log.txt; make clean > clobberlog.txt 2> faillog.txt; make > buildlog.txt 2>> faillog.txt");

if (($status) || (!(-f "$dhanushaon_path/output/aonsram.bin") || !(-f "$dhanushaon_path/output/aontcm.bin") || !(-f "$dhanushaon_path/output/d_aflash.bin")))
{
	print("\n Build Failed, Copying Build log in to share folder\n");
	$failed = 1;
	system("mkdir -p $dst_reports_log_dir_AON");
	fcopy("faillog.txt", $dst_reports_log_dir_AON);
	fcopy("buildlog.txt", $dst_reports_log_dir_AON);
}
else
{
	print "AONsensor Build completed successfully \n";
		
	#update the destination folder after successfull build

	if(($subject eq "Weekly") || ($subject eq "Release"))
	{		
		$dst_reports_dir_AON="/home/$username/share/Micro_Builds/Release_Builds/$buildnumber/$currentTime/AON";
		$dst_reports_dir_AON1="//192.168.42.46/share/Micro_Builds/Release_Builds/$buildnumber/$currentTime/AON";
	}
	elsif($subject eq "Daily")
	{
		$dst_reports_dir_AON="/home/$username/share/Micro_Builds/Daily_Builds/$currentDate/$currentTime/AON";
		$dst_reports_dir_AON1="//192.168.42.46/share/Micro_Builds/Daily_Builds/$currentDate/$currentTime/AON";
	}
			
	# Create share location
	system("mkdir -p $dst_reports_dir_AON");

	#copy the output files to destination location
	dircopy("$dhanushaon_path/output", $dst_reports_dir_AON);

	#copying bins to local path
	fcopy("$dhanushaon_path/output/aonsram.bin", "$local_path");

	fcopy("$dhanushaon_path/output/aontcm.bin", "$local_path");

	fcopy("$dhanushaon_path/output/d_aflash.bin", "$local_path");

	print "AONsensor output files copied to $dst_reports_dir_AON \n";
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*** Native ***#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

native_build:

$sourcecode_repo_path="http://insvn01:9090/svn/swdepot/Dhanush/SW/Micro-trunk/Beta_Advance_Native";

#Declaration of local path
$dhanushnative_path="$local_path/Beta_Advance_Native";

#Declaration of DhanushNative environment paths
$dhanushnativeenv_path="$dhanushnative_path/build/scripts/native_env.sh";
$dhanushnativeenv_temp_path="$dhanushnative_path/build/scripts/temp.sh";

#Declaration of destination directories
$dst_reports_log_dir_Native="/home/$username/share/Micro_error_logs/DhanushNative/$currentDate/$currentTime";
$dst_reports_log_dir_Native1="//192.168.42.46/share/Micro_error_logs/DhanushNative/$currentDate/$currentTime";

print "********************************************** Native BUILD PROCESS **********************************************\n";

#delete the output folder with contents and create new output folder 
system("rm -rf $dhanushnative_path/output"); 
system("mkdir $dhanushnative_path/output");

chdir($dhanushnative_path);

#change the env path to the local path
change_envfile_path($dhanushnative_path,$dhanushnativeenv_path,$dhanushnativeenv_temp_path);

#Build the Native Project
$status = system(". ./build/scripts/native_env.sh > log.txt; make BUILD_NUC=1 clobber >clobber_log.txt 2> faillog.txt;make BUILD_NUC=1 rel > buildlog.txt 2>> faillog.txt;");
if ($status) 
{
	print("\n Build Failed, Copying Build log in to share folder\n");

	system("mkdir -p $dst_reports_log_dir_Native");
	fcopy("faillog.txt", $dst_reports_log_dir_Native);
	fcopy("buildlog.txt", $dst_reports_log_dir_Native);
	$failed = 1;
}
else
{
	$status = system("$toolchain_path/ubuntu64/mips/bin/mips-sde-elf-objcopy -O binary output/audioplayer_testapp.elf output/d_native.bin >> buildlog.txt 2>> faillog.txt");

	if (!(-f "$dhanushnative_path/output/d_native.bin"))
	{
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");

		system("mkdir -p $dst_reports_log_dir_Native");
		fcopy("faillog.txt", $dst_reports_log_dir_Native);
		fcopy("buildlog.txt", $dst_reports_log_dir_Native);
		$failed = 1;
	}
	else
	{
		print "Native Build completed successfully...\n";

		#update the destination folder after successfull build	
		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			$dst_reports_dir_Native="/home/$username/share/Micro_Builds/Release_Builds/$buildnumber/$currentTime/Native";
			$dst_reports_dir_Native1="//192.168.42.46/share/Micro_Builds/Release_Builds/$buildnumber/$currentTime/Native";
		}
		elsif($subject eq "Daily")
		{
			$dst_reports_dir_Native="/home/$username/share/Micro_Builds/Daily_Builds/$currentDate/$currentTime/Native";
			$dst_reports_dir_Native1="//192.168.42.46/share/Micro_Builds/Daily_Builds/$currentDate/$currentTime/Native";
		}
				
		#creating share location
		system("mkdir -p $dst_reports_dir_Native");

		#copy the output files to destination location 
		dircopy("$dhanushnative_path/output", $dst_reports_dir_Native);

		#copying images to local path
		fcopy("$dhanushnative_path/output/d_native.bin", "$local_path");
	}
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*** Bootloader ***#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
Bootldr_build:

#Declaration of local path
$dhanushbootldr_path="$local_path/BootLoader";
$sourcecode_repo_path="http://insvn01:9090/svn/swdepot/Dhanush/SW/Micro-trunk/BootLoader";

$dhanushBL1_path="$local_path/BootLoader/BL1";
$dhanushBL0_path="$local_path/BootLoader/BL0";
$dhanushelf_util_path="$local_path/BootLoader/elf_util_code";
$dhanushrecovery_path="$local_path/BootLoader/recovery_code";

#Declaration of Dhanushbootldr environment paths
$dhanushbl1env_path="$dhanushBL1_path/build_bl1.sh";
$dhanushbl1env_temp_path="$dhanushBL1_path/temp_bl1.sh";

$dhanushbl0env_path="$dhanushBL0_path/config/config.mk";
$dhanushbl0env_temp_path="$dhanushBL0_path/temp_bl0config.mk";

$dhanushelf_utilenv_path="$dhanushelf_util_path/config/config.mk";
$dhanushelf_utilenv_temp_path="$dhanushelf_util_path/temp_elfconfig.mk";

$dhanushrecoveryenv_path="$dhanushrecovery_path/config/config.mk";
$dhanushrecoveryenv_temp_path="$dhanushrecovery_path/temp_recconfig.mk";

#Declaration of destination directories
$dst_reports_log_dir_bootldr="/home/$username/share/Micro_error_logs/DhanushBootLoader/$currentDate/$currentTime";
$dst_reports_log_dir_bootldr1="//192.168.42.46/share/Micro_error_logs/DhanushBootLoader1/$currentDate/$currentTime";

print "********************************************* BootLoader BUILD PROCESS **********************************************\n";

#change the env path to the local path
$srcBuild_ScriptPath = "$dhanushBL1_path/build_bl1.sh";

$build_ScriptPath = "$dhanushBL1_path/build_bl1_temp.sh";

open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

my $path_string = "export PATH=";

my $path = "= $toolchain_path/ubuntu64/mips/bin:\$PATH";

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

change_envfile_path($dhanushBL0_path,$dhanushbl0env_path,$dhanushbl0env_temp_path);

change_envfile_path($dhanushelf_util_path,$dhanushelf_utilenv_path,$dhanushelf_utilenv_temp_path);

change_envfile_path($dhanushrecovery_path,$dhanushrecoveryenv_path,$dhanushrecoveryenv_temp_path);

#Build the BootLoader Project

chdir($dhanushbootldr_path);

system("rm -rf $dhanushbootldr_path/output"); 

$status = system("./BuildBootLoader_For_M2.sh > buildlog.txt 2> faillog.txt");

if (($status) || (!(-f "$dhanushbootldr_path/output/d_bl0.bin") || !(-f "$dhanushbootldr_path/output/bl1.bin") || !(-f "$dhanushbootldr_path/output/recovery.bin") || !(-f "$dhanushbootldr_path/output/SPI_DUMP.bin")))
{
	print("\n bootldr Build Failed, Copying Build log in to share folder\n");
		
	system("mkdir -p $dst_reports_log_dir_bootldr");
	fcopy("faillog.txt", $dst_reports_log_dir_bootldr);
	fcopy("buildlog.txt", $dst_reports_log_dir_bootldr);
	$failed = 1;
}
else
{
	print "BootLoader Build completed successfully \n";

	#update the destination folder after successfull build	
	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		$dst_reports_dir_bootldr="/home/$username/share/Micro_Builds/Release_Builds/$buildnumber/$currentTime/BootLoader";
		$dst_reports_dir_bootldr1="//192.168.42.46/share/Micro_Builds/Release_Builds/$buildnumber/$currentTime/BootLoader";
	}
	elsif($subject eq "Daily")
	{
		$dst_reports_dir_bootldr="/home/$username/share/Micro_Builds/Daily_Builds/$currentDate/$currentTime/BootLoader";
		$dst_reports_dir_bootldr1="//192.168.42.46/share/Micro_Builds/Daily_Builds/$currentDate/$currentTime/BootLoader";
	}

	#creating share location
	system("mkdir -p $dst_reports_dir_bootldr");

	#copy the output files to destination location 
	dircopy("$dhanushbootldr_path/output", $dst_reports_dir_bootldr);

	#copying images to local path
	fcopy("$dhanushbootldr_path/output/d_bl0.bin", "$local_path");
	fcopy("$dhanushbootldr_path/output/bl1.bin", "$local_path");
	fcopy("$dhanushbootldr_path/output/recovery.bin", "$local_path");
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*** UI build ***#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
UI_build:

$sourcecode_repo_path="http://insvn01:9090/svn/swdepot/Dhanush/SW/Micro-trunk/Tools/SPI_FONT_BIN_GEN";

#Declaration of local path
$dhanushUI_path="$local_path/SPI_FONT_BIN_GEN/v3/output";
$dhanushSPI_path="$local_path/SPI_FONT_BIN_GEN";

#Declaration of destination directories
$dst_reports_log_dir_UI="/home/$username/share/Micro_error_logs/Dhanush-UI/$currentDate/$currentTime";
$dst_reports_log_dir_UI1="//192.168.42.46/share/Micro_error_logs/Dhanush-UI/$currentDate/$currentTime";

print "**************************************** SPI_FONT_BIN_GEN(UI bin) BUILD PROCESS **************************************\n";

chdir($dhanushUI_path);

system("rm -rf $dhanushUI_path/a.out");
system("rm -rf $dhanushUI_path/d_ui.bin");

$status = system("gcc test.c gen_lcd_bitmap_bin.a > buildlog.txt 2> faillog.txt; ./a.out >> buildlog.txt 2>> faillog.txt");

if(!(-f "$dhanushUI_path/d_ui.bin"))
{
	print("\n SPI_FONT_BIN_GEN(UI bin) Build Failed, Copying fail log in to share folder\n");

	system("mkdir -p $dst_reports_log_dir_UI");

	fcopy("$dhanushUI_path/buildlog.txt",$dst_reports_log_dir_UI);
	fcopy("$dhanushUI_path/faillog.txt",$dst_reports_log_dir_UI);
	$failed = 1;
}
else
{
	print "SPI_FONT_BIN_GEN(UI bin) Build completed successfully \n";

	#update the destination folder after successfull build		
	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		$dst_reports_dir_UI="/home/$username/share/Micro_Builds/Release_Builds/$buildnumber/$currentTime/UI";
		$dst_reports_dir_UI1="//192.168.42.46/share/Micro_Builds/Release_Builds/$buildnumber/$currentTime/UI";
	}
	elsif($subject eq "Daily")
	{
		$dst_reports_dir_UI="/home/$username/share/Micro_Builds/Daily_Builds/$currentDate/$currentTime/UI_$repo_print";
		$dst_reports_dir_UI1="//192.168.42.46/share/Micro_Builds/Daily_Builds/$currentDate/$currentTime/UI_$repo_print";
	}

	system("mkdir -p $dst_reports_dir_UI");

	#copy the output files to destination location 
	fcopy("$dhanushUI_path/d_ui.bin", "$dst_reports_dir_UI");

	#copying bin to local path
	fcopy("$dhanushUI_path/d_ui.bin", "$local_path");

	print "output files copied to $dst_reports_dir_UI \n";
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*** Packaging ***#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
build_end:

if(($subject eq "Weekly") || ($subject eq "Release"))
{
	#creating share location for images
	system("mkdir -p $dst_images_dir/$sub_rel");

	#copy the output files to destination location 
	fcopy("$local_path/aonsram.bin", "$dst_images_dir/$sub_rel") or die $!;
	fcopy("$local_path/aontcm.bin", "$dst_images_dir/$sub_rel") or die $!;
	fcopy("$local_path/d_aflash.bin", "$dst_images_dir/$sub_rel") or die $!;

	fcopy("$local_path/d_native.bin", "$dst_images_dir/$sub_rel") or die $!;

	fcopy("$local_path/d_bl0.bin", "$dst_images_dir/$sub_rel") or die $!;
	fcopy("$local_path/bl1.bin", "$dst_images_dir/$sub_rel") or die $!;
	fcopy("$local_path/recovery.bin", "$dst_images_dir/$sub_rel") or die $!;

	fcopy("$local_path/d_ui.bin", "$dst_images_dir/$sub_rel") or die $!;
}
elsif($subject eq "Daily")
{
	#creating share location for images
	system("mkdir -p $dst_images_dir/$currentTime");

	#copy the output files to destination location 
	fcopy("$local_path/aonsram.bin", "$dst_images_dir/$currentTime") or die $!;
	fcopy("$local_path/aontcm.bin", "$dst_images_dir/$currentTime") or die $!;
	fcopy("$local_path/d_aflash.bin", "$dst_images_dir/$currentTime") or die $!;

	fcopy("$local_path/d_native.bin", "$dst_images_dir/$currentTime") or die $!;

	fcopy("$local_path/d_bl0.bin", "$dst_images_dir/$currentTime") or die $!;
	fcopy("$local_path/bl1.bin", "$dst_images_dir/$currentTime") or die $!;
	fcopy("$local_path/recovery.bin", "$dst_images_dir/$currentTime") or die $!;

	fcopy("$local_path/d_ui.bin", "$dst_images_dir/$currentTime") or die $!;
}

print "Dhanush Micro Trunk binaries are copied to $dst_images_dir.\n";

if(($subject eq "Weekly") || ($subject eq "Release"))
{
	#To continue release numbers reading release number from local file
	open(my $RF, ">/home/$username/release_micro.txt") || die("Can't open file: /home/$username/release_micro.txt");

	$rel_number = $rel_number+1;
	if($rel_number < 10)
	{
		print $RF "00$rel_number";
	}
	elsif($rel_number < 100)
	{
		print $RF "0$rel_number";
	}
	else
	{
		print $RF "$rel_number";
	}
	close($RF);
}

if($failed eq "1")
{
	print "Build failed...\n";
	exit 1;
}

#****************************************************** Functions ***************************************************************
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
	my $src_string = "export TOOL_CHAIN=";
	my $src_path = "=$fun_path";
	my $toolchain_string = "export DK_ROOT=";
	my $toolchain_repo_path = "=$toolchain_path";
	my $codesourcery_string = "CROSS_COMPILE =";
	my $codesourcery_path ="= /home/$username/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin/mips-linux-gnu-";

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
 		elsif($line =~ /$codesourcery_string/)
 		{
  			  if($line=~s/=.+\n/$codesourcery_path\n/)
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

sub read_last_revision
{
    my $file = $_[0];
    open($Read, "< $file") || die("Can't open file: $file");
    my @lines = <$Read>;
    close($RD);

    my $failed = 0;

    foreach my $line (@lines)
    {
        chomp($line);
	if($line =~/Last Changed Rev: (\d+)/)
	{
		$revision = $1;
		last;
	}
    }
    return $revision;
}

sub change_configfile_path
{
	$dhanush_envpath=$_[1];	
	$dhanush_env_temppath=$_[2];
	open(my $RD, "+< $dhanush_envpath") || die("Can't open file: $dhanush_envpath");
	open(my $RD1, " > $dhanush_env_temppath") || die("Can't open file: $dhanush_env_temppath");

	$fun_path=$_[0];
	my $src_string = "export BABEL_CONFIG_FILE=";
	my $src_path = "=$fun_path";
	
	foreach my $line (<$RD>)
	{
   		if($line =~ /$src_string/)
   		{
        		if($line=~s/=.+\n/$src_path\n/)
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

