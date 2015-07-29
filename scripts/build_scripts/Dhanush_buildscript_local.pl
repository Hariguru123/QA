#!/usr/bin/perl
#********************************************************************************************\
# 
#   File Name  :   Dhanush_buildscript_local.pl
#    
#   Description:  This file is taking the SDK path as present script path and build the targets 
#		  based on the user input and copy the output files to present script path/Binaries.
#   	
# *******************************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

system("pwd > path.txt");
open(FH,"<path.txt");

foreach $line(<FH>)
{
	if($line =~ /(.+)\/Scripts/)
	{
		$local_path=$1;
	}
	else
	{
		print "Scripts are not in the correct path";
		exit;

	}

}

#Declaration of Date and Time
currentdate();
my $currentDate = "$year\-$mon\-$mday";
my $currentTime = "$hr\-$min\-$sec";

#local path
$sdk_path=$local_path;

#tool chain path from the user
print "Please enter the toolchain content path:";
chomp($toolchain_path=<STDIN>);

#Declaration of DhanushAON paths
$dhanushaon_path="$sdk_path/AONsensor";
#$toolchain_path="$sdk_path/toolchain";
$dhanushaonenv_path="$dhanushaon_path/build/scripts/dhanushaon_env.sh";
$dhanushaonenv_temp_path="$dhanushaon_path/build/scripts/dhanushtemp.sh";
$dst_reports_dir_AON="$sdk_path/Binaries/DhanushAON/$currentDate/$currentTime";

#Declaration of DhanushNative paths
$dhanushnative_path="$sdk_path/Native";
$dhanushnativeenv_path="$dhanushnative_path/build/scripts/native_env.sh";
$dhanushnativeenv_temp_path="$dhanushnative_path/build/scripts/temp.sh";
$dst_reports_dir_Native="$sdk_path/Binaries/DhanushNative/$currentDate/$currentTime";

#Declaration of DhanushAndroid paths
$dhanushandroid_path="$sdk_path/Android";
$local_path_sourcecode_kernel="$dhanushandroid_path/linux-mti-3.8.13";
$local_path_sourcecode_android="$dhanushandroid_path/MipsGB2.3.5";
$dst_reports_dir_Android="$sdk_path/Binaries/Dhanush-Android/$currentDate/$currentTime";


print "Please select a build target from the following:
1.DhanushAON\n 
2.DhanushNative\n
3.DhanushAndroid\n
4.All \n
Please enter the number:";

START:
chomp($input=<STDIN>);

if($input !~ /^[1-4]$/)
{
	print "Please Enter Valid Number:";
	goto START;
}

if($input eq 1||$input eq 4)
{
	if(!(-d "$sdk_path/AONsensor"))
	{

		print "AONsensor Folder is not present in the location $sdk_path";
		exit;

	}

	print "*****************Dhanush AON BUILD PROCESS****************************\n";
	#delete the output folder with contents and create new output folder 
	system("rm -rf $dhanushaon_path/output"); 
	system("mkdir $dhanushaon_path/output");

	chdir($dhanushaon_path);
	#change the env path to the local path
	change_envfile_path($dhanushaon_path,$dhanushaonenv_path,$dhanushaonenv_temp_path);

	#Build the AON Project
	$status = system(". ./build/scripts/dhanushaon_env.sh>log.txt;make clobber > clobberlog.txt 2> faillog.txt; make BUILD_CONTIKI=1 rel > buildlog.txt 2>> faillog.txt;");
	if ($status) 
	{
		print("Build Failed, please check the log file(faillog.txt) in $dhanushaon_path location \n");
	}
	else
	{
		dircopy("$dhanushaon_path/output", $dst_reports_dir_AON) or die $!;
		print "Dhanush AON Build completed successfully \nDhanush AON output files copied to $dst_reports_dir_AON \n\n";
	}
}

if($input eq 2||$input eq 4)
{
	if(!(-d "$sdk_path/Native"))
	{

		print "Native Folder is not present in the location $sdk_path";
		exit;

	}

	print "*****************Dhanush Native BUILD PROCESS****************************\n";	
	#delete the output folder with contents and create new output folder 
	system("rm -rf $dhanushnative_path/output"); 
	system("mkdir $dhanushnative_path/output");

	chdir($dhanushnative_path);
	#change the env path to the local path
	change_envfile_path($dhanushnative_path,$dhanushnativeenv_path,$dhanushnativeenv_temp_path);

	#Build the Native Project
	$status = system(". ./build/scripts/native_env.sh>log.txt;make clobber >clobber_log.txt 2> faillog.txt;make BUILD_NUC=1 rel> buildlog.txt 2>> faillog.txt;");
	if ($status) 
	{
		print("Build Failed, please check the log file(faillog.txt) in $dhanushnative_path location \n");
	}
	else
	{
		dircopy("$dhanushnative_path/output", $dst_reports_dir_Native) or die $!;
		print "Dhanush Native Build completed successfully \nDhanush Native output files are copied to $dst_reports_dir_Native \n\n";
	}
}

if($input eq 3||$input eq 4)
{

	if(!(-d "$sdk_path/Android"))
	{

		print "Android Folder is not present in the location $sdk_path";
		exit;
	}

	print "*****************Dhanush ANDROID BUILD PROCESS****************************\n";
	#Build the Android Kernel
	chdir($local_path_sourcecode_kernel);
	$status = system("./build.sh > kernel_buildlog.txt 2> faillog.txt");
	if ($status) 
	{
		print("\n Kernel Build Failed, please check the log file(faillog.txt) in $local_path_sourcecode_kernel location \n");
	
	}
	else
	{
		system("mkdir -p $dst_reports_dir_Android");
		fcopy("$local_path_sourcecode_kernel/vmlinux", "$dst_reports_dir_Android") or die $!;
		print "Kernel Build completed successfully \noutput files copied to $dst_reports_dir_Android \n";

	}

	#Build the Android File System
	chdir($local_path_sourcecode_android);
	$status = system("./build.sh > android_buildlog.txt 2> faillog.txt");
	if ($status) 
	{
		print("\n Android Build Failed, please check the log file(faillog.txt) in $local_path_sourcecode_android location \n");
	}
	else
	{
		#copy the output files from out folder to destination location 
		dircopy("$local_path_sourcecode_android/out", $dst_reports_dir_Android) or die $!;
		dircopy("$local_path_sourcecode_android/images", $dst_reports_dir_Android) or die $!;
		print "Android Build completed successfully \noutput files copied to $dst_reports_dir_Android \n";
	}

}

#*****************************************Functions****************************************************************************
sub currentdate()
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
	my $path_string = "export PATH=";
	my $path = "=$toolchain_path/ubuntu64/bin:$toolchain_path/ubuntu64/mips/bin:\$PATH";

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
		elsif($line =~ /$path_string/)
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
	system("rm -rf $dhanush_envpath");
	system("mv $dhanush_env_temppath $dhanush_envpath");
	

}

