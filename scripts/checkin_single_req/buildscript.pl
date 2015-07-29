#!/usr/bin/perl
#********************************************************************************************************************\
# 
#   File Name  :   buildscript.pl
#    
#   Description:  It will build the corresponding code based on the arguments received.Developer will 
#		  receive a mail if build either passed or failed,with all corresponding logs/ouputs in one location.
#   	
# ********************************************************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

$code_base=$ARGV[0];
$dev_folder=$ARGV[1];
$patch_file=$ARGV[2];
$command_log=$ARGV[3];


#Declaration of Date and Time
currentdate();
my $currentDate = "$year\-$mon\-$mday";
my $currentTime = "$hr\-$min\-$sec";

#Declaration of mail parameters
$from = "\"hgsnarayana.mavilla\@incubesol.com>\"";
$Dev_team = "\" hgsnarayana.mavilla\@incubesol.com\",\"Vinay Kumar <vinaykumar.medari\@incubesol.com>\"";
$build_team = "\" hgsnarayana.mavilla\@incubesol.com\",\"Vinay Kumar <vinaykumar.medari\@incubesol.com>\"";
our $blatCmd = "/home/testuser/blat.exe";
our $SMTP = "192.168.4.225";

#Declaration of repositories
$toolchain_repo_path= "http://192.168.24.194:9090/svn/swdepot/Dhanush/Tools/Native/toolchain";

#Declaration of DhanushAON paths
if($patch_file eq "DhanushAON.patch")
{
	$dhanushaon_path="$code_base/$dev_folder/DhanushAON";
	$toolchain_path="/home/testuser/toolchain";
	$dhanushaonenv_path="$dhanushaon_path/build/scripts/dhanushaon_env.sh";
	$dhanushaonenv_temp_path="$dhanushaon_path/build/scripts/dhanushtemp.sh";
	$dst_reports_dir_AON="/home/testuser/share/output/DhanushAON/$currentDate/$currentTime";
	$dst_reports_dir_AON1="//192.168.26.135/share/output/DhanushAON/$currentDate/$currentTime";
}
#Declaration of DhanushNative paths
elsif($patch_file eq "Native.patch")
{
	$dhanushnative_path="$code_base/$dev_folder/Native";
	$toolchain_path="/home/testuser/toolchain";
	$dhanushnativeenv_path="$dhanushnative_path/build/scripts/native_env.sh";
	$dhanushnativeenv_temp_path="$dhanushnative_path/build/scripts/temp.sh";
	$dst_reports_dir_Native="/home/testuser/share/output/DhanushNative/$currentDate/$currentTime";
	$dst_reports_dir_Native1="//192.168.26.135/share/output/DhanushNative/$currentDate/$currentTime";
}
#Declaration of DhanushAndroid paths
elsif($patch_file eq "Dhanush-Android.patch")
{
	$dhanushandroid_path="$code_base/$dev_folder/Dhanush-Android";
	$local_path_sourcecode_kernel="$dhanushandroid_path/linux-mti-3.8.13";
	$local_path_sourcecode_android="$dhanushandroid_path/MipsGB2.3.5";
	$dst_reports_dir_Android="/home/testuser/share/output/Dhanush-Android/$currentDate/$currentTime";
	$dst_reports_dir_Android1="//192.168.26.135/share/output/Dhanush-Android/$currentDate/$currentTime";
}

if($patch_file eq "DhanushAON.patch")
{

	print "*****************Dhanush AON BUILD PROCESS****************************\n";
	#delete the output folder with contents and create new output folder 
	system("rm -rf $dhanushaon_path/output"); 
	system("mkdir $dhanushaon_path/output");

#temporary
	system("rm -rf $dhanushaonenv_path");
	fcopy("/home/testuser/dhanushaon_env.sh", $dhanushaonenv_path) or die $!;

	chdir($dhanushaon_path);
	#change the env path to the local path
	change_envfile_path($dhanushaon_path,$dhanushaonenv_path,$dhanushaonenv_temp_path);

	#Build the AON Project
	$status = system(". ./build/scripts/dhanushaon_env.sh>log.txt;make clobber > clobberlog.txt 2> faillog.txt; make BUILD_CONTIKI=1 > buildlog.txt 2>> faillog.txt;");

	if ($status) 
	{
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
		$body = "Hi Team, \n Failures observed, while building the dhanush AON code.\n Please find the build log in the share path:$dst_reports_dir_AON1";

#		build($body);
		system("mkdir -p $dst_reports_dir_AON");
		fcopy("$dhanushaon_path/faillog.txt", $dst_reports_dir_AON) or die $!;
		fcopy("$dhanushaon_path/buildlog.txt", $dst_reports_dir_AON) or die $!;
	}
	else
	{
		print "Dhanush AON Build completed successfully \n";
		$body = "Hi Team, \n Dhanush AON Build Successfully completed....\n Please find the output binaries in the share path:$dst_reports_dir_AON1";

		build_passed($body);

		system("mkdir -p $dst_reports_dir_AON");

		#copy the output files to destination location 
		dircopy("$dhanushaon_path/output", $dst_reports_dir_AON) or die $!;
		print "Dhanush AON output files copied to $dst_reports_dir_AON \n";
	}
}

if($patch_file eq "Native.patch")
{
	print "*****************Dhanush Native BUILD PROCESS****************************\n";	
	#delete the output folder with contents and create new output folder 
	system("rm -rf $dhanushnative_path/output"); 
	system("mkdir $dhanushnative_path/output");

	chdir($dhanushnative_path);
	#change the env path to the local path
	change_envfile_path($dhanushnative_path,$dhanushnativeenv_path,$dhanushnativeenv_temp_path);

	#Build the Native Project
	$status = system(". ./build/scripts/native_env.sh>log.txt;make clobber >clobber_log.txt 2> faillog.txt;make BUILD_NUC=1 > buildlog.txt 2>> faillog.txt;");
	if ($status) 
	{
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
		$body = "Hi Team, \n Failures observed, while building the dhanush Native code.\n Please find the build log in the share path:$dst_reports_dir_Native1";
		
		build($body);
		system("mkdir -p $dst_reports_dir_Native");
		fcopy("$dhanushnative_path/faillog.txt", $dst_reports_dir_Native) or die $!;
		fcopy("$dhanushnative_path/buildlog.txt", $dst_reports_dir_Native) or die $!;
	}
	else
	{
		print "Dhanush Native Build completed successfully \n";

		$body = "Hi Team, \n Dhanush Native Build Successfully completed....\n Please find the output binaries in the share path:$dst_reports_dir_Native1";

		build_passed($body);
		system("mkdir -p $dst_reports_dir_Native");

		#copy the output files to destination location 
		dircopy("$dhanushnative_path/output", $dst_reports_dir_Native) or die $!;
		print "Dhanush Native output files copied to $dst_reports_dir_Native \n";
	}
}
if($patch_file eq "Dhanush-Android.patch")
{

	print "*****************Dhanush ANDROID BUILD PROCESS****************************\n";

	#Build the Android Project

	#Build the Android Kernel
	chdir($local_path_sourcecode_kernel);

	$status = system("./build.sh > kernel_buildlog.txt 2> kernel_faillog.txt");
	if ($status) 
	{
		print("\n Kernel Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");

		$body = "Hi Team, \n Failures observed, while building the Dhanush kernel source code.\n Please find the build log in the share path:$dst_reports_dir_Android1";

		build($body);

		system("mkdir -p $dst_reports_dir_Android");
		fcopy("$local_path_sourcecode_kernel/kernel_faillog.txt", $dst_reports_dir_Android) or die $!;
		fcopy("$local_path_sourcecode_kernel/kernel_buildlog.txt", $dst_reports_dir_Android) or die $!;
	}
	else
	{
		print "Kernel Build completed successfully \n";
		system("mkdir -p $dst_reports_dir_Android");

		#copy the output files to destination location 
		fcopy("$local_path_sourcecode_kernel/vmlinux", $dst_reports_dir_Android) or die $!;
		print "output files copied to $dst_reports_dir_Android \n";
	}

	#Build the Android File System
	chdir($local_path_sourcecode_android);

	$status = system("./build.sh > android_buildlog.txt 2> android_faillog.txt");
	if ($status) 
	{
		print("\n Android Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
	
		$body = "Hi Team, \n Failures observed, while building the Dhanush Android code\n Please find the build log in the share path:$dst_reports_dir_Android1";

		build($body);

		system("mkdir -p $dst_reports_dir_Android");
		fcopy("$local_path_sourcecode_android/android_faillog.txt", $dst_reports_dir_Android) or die $!;
		fcopy("$local_path_sourcecode_android/android_buildlog.txt", $dst_reports_dir_Android) or die $!;

	}
	else
	{
		print "Android Build completed successfully \n";
		$body = "Hi Team, \n Dhanush Android Build Successfully completed....\n Please find the output binaries in the share path:$dst_reports_dir_Android1";

		build_passed($body);

		#copy the output files from out folder to destination location 
		dircopy("$local_path_sourcecode_android/out", $dst_reports_dir_Android) or die $!;
		print "output files copied to $dst_reports_dir_Android \n";

		#copy the output files from images folder to destination location 
		dircopy("$local_path_sourcecode_android/images", $dst_reports_dir_Android) or die $!;
		print "output files copied to $dst_reports_dir_Android \n";
	}
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

#********************************************Functions********************************************

sub sendMail
{
    my $body= shift @_;
             
    # Sending mail...
    $blatCmd .= " - @_";
    open(MAIL, "| $blatCmd") || die "Can't open file: $!";
    print MAIL $body;
    print "Mail sent to the team\n";
    close(MAIL);
    
}

sub build
{
	my %data = (
        -f        => $from,
        -to       => $Dev_team,
        -subject  => "\"Build Failed\"",
        -server   => $SMTP,
       -debug    => " ",
        -log      => "blat.log"
   );

   $body = $_[0];

   sendMail($body, %data);

}

sub build_passed
{
	my %data = (
        -f        => $from,
        -to       => $Dev_team,
        -subject  => "\"Build Completed\"",
        -server   => $SMTP,
       -debug    => " ",
        -log      => "blat.log"
   );

   $body = $_[0];

   sendMail($body, %data);

}

