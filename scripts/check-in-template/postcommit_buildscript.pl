#!/usr/bin/perl
#********************************************************************************************************************\
# 
#   File Name  :   postcommit_buildscript.pl
#    
#   Description:  It will build the corresponding code based on the arguments received.Developer will 
#		  receive a mail if build either passed or failed,with all corresponding logs/ouputs in one location.
#   	
# ********************************************************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use MIME::Lite;


$input=$ARGV[0];
$devfolder=$ARGV[1];
if($input eq 1)
{
	print "Building DhanushAON Project.....";
	$build = "DhanushAON";
}
elsif($input eq 2)
{
	print "Building DhanushNative Project.....";
	$build = "DhanushNative";
}
elsif($input eq 3)
{
	print "Building DhanushAndroid Project.....";
	$build = "DhanushAndroid";
}
elsif($input eq 4)
{
	print "Building DhanushAON,DhanushNative,DhanushAndroid Projects.....";
	$build = "All";
}
else
{
	print "Please Pass the arguments (1-4)";
	exit;
}


#Declaration of Date and Time
currentdate();
my $currentDate = "$year\-$mon\-$mday";
my $currentTime = "$hr\-$min\-$sec";

#Declaration of mail parameters
$from = 'Build_Server <socplatform-qa@inedasystems.com>';
$Dev_team = 'Narayana <hgsnarayana.mavilla@incubesol.com>';
$build_team = 'Vinay Kumar <vinaykumar.medari@incubesol.com>';

#Declaration of local path
$username="socplatform-qa";
$local_path="/home/$username/$devfolder";

#Declaration of logs
$co_log  = "$local_path/checkout.log";
$co_error_log = "$local_path/co_error.log";
$repository_info = "$local_path/repository_info.log";
$local_info = "$local_path/local_info.log";
$change_log_tc = "$local_path/changelog_toolchain.txt";

#Declaration of mail Configuration path
$mail_path="$local_path/mail.txt";

#Declaration of AONsensor paths
if(($build eq "DhanushAON") || ($build eq "All"))
{

	#Declaration of repositories
	$toolchain_repo_path= "http://insvn01:9090/svn/swdepot/Dhanush/Tools/Native/toolchain";
	$sourcecode_repo_path="http://insvn01:9090/svn/swdepot/Dhanush/SW/Adv-trunk/AONsensor";

	#Declaration of local path
	
	$local_path="/home/$username/$devfolder";
	$dhanushaon_path="/home/$username/$devfolder/AONsensor";
	$toolchain_path="/home/$username/toolchain";
	$change_log_src = "$local_path/changelog_AONsensor.txt";

	#Declaration of DhanushAON Environment paths
	$dhanushaonenv_path="$dhanushaon_path/build/scripts/dhanushaon_env.sh";
	$dhanushaonenv_temp_path="$dhanushaon_path/build/scripts/dhanushtemp.sh";

	#declaration of destination directories
	$dst_reports_dir_AON="/home/$username/share/output/DhanushAON/$currentDate/$currentTime";
	$dst_reports_dir_AON1="//192.168.42.46/share/output/DhanushAON/$currentDate/$currentTime";
	$dst_reports_log_dir_AON="/home/$username/share/error_logs/DhanushAON/$currentDate/$currentTime";
	$dst_reports_log_dir_AON1="//192.168.42.46/share/error_logs/DhanushAON/$currentDate/$currentTime";

	#function to check the revision and check out
	$message = "tool chain";
	checking_revision_and_checkout($toolchain_path, $toolchain_repo_path, $change_log_tc, $message);

	$message = "Dhanush AON Source";
	checking_revision_and_checkout_4_srccode($dhanushaon_path, $sourcecode_repo_path, $change_log_src, $message);

	

	print "*****************AONsensor BUILD PROCESS****************************\n";
	#delete the output folder with contents and create new output folder 
	system("rm -rf $dhanushaon_path/output"); 
	system("mkdir $dhanushaon_path/output");

	chdir($dhanushaon_path);
	#change the env path to the local path
	change_envfile_path($dhanushaon_path,$dhanushaonenv_path,$dhanushaonenv_temp_path);

	#Build the AON Project
	$status = system(". ./build/scripts/dhanushaon_env.sh > log.txt;make clobber > clobberlog.txt 2> faillog.txt; make BUILD_CONTIKI=1 rel > buildlog.txt 2>> faillog.txt");

	if ($status) 
	{
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
		$repo_print = read_last_revision($repository_info);
		$body = "Hi Team,\n\n\nFailures observed while building the dhanush AON code for the svn revision:$repo_print.
		\n\nPlease find the build log in the share path:\"$dst_reports_log_dir_AON1\".
		\n\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $build_team, "Build Failed", $body, "");

		system("mkdir -p $dst_reports_log_dir_AON");
		fcopy("faillog.txt", $dst_reports_log_dir_AON) or die $!;
		fcopy("buildlog.txt", $dst_reports_log_dir_AON) or die $!;
	}
	else
	{
		print "AONsensor Build completed successfully \n";
		
		$repo_print = read_last_revision($repository_info);

		$body = "Hi Team,\n\n\nDhanush AON Build Successfully completed for the svn revision: $repo_print.
		\n\nPlease find the output binaries in the share path: \"$dst_reports_dir_AON1\".
		\n\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $build_team, "Build Completed", $body, "");

		system("mkdir -p $dst_reports_dir_AON");

		#copy the output files to destination location 
		dircopy("$dhanushaon_path/output", $dst_reports_dir_AON) or die $!;

		print "AONsensor output files copied to $dst_reports_dir_AON \n";
	
	}

}

if(($build eq "DhanushNative") || ($build eq "All"))
{

	#Declaration of repositories
	$toolchain_repo_path= "http://insvn01:9090/svn/swdepot/Dhanush/Tools/Native/toolchain";
	$sourcecode_repo_path="http://insvn01:9090/svn/swdepot/Dhanush/SW/Adv-trunk/Native";

	#Declaration of local path
	
	$local_path="/home/$username/$devfolder";
	$dhanushnative_path="/home/$username/$devfolder/Native";
	$toolchain_path="/home/$username/toolchain";
	$change_log_src = "$local_path/changelog_Native.txt";

	#Declaration of DhanushNative environment paths
	$dhanushnativeenv_path="$dhanushnative_path/build/scripts/native_env.sh";
	$dhanushnativeenv_temp_path="$dhanushnative_path/build/scripts/temp.sh";

	#Declaration of destination directories
	$dst_reports_dir_Native="/home/$username/share/output/DhanushNative/$currentDate/$currentTime";
	$dst_reports_dir_Native1="//192.168.42.46/share/output/DhanushNative/$currentDate/$currentTime";
	$dst_reports_log_dir_Native="/home/$username/share/error_logs/DhanushNative/$currentDate/$currentTime";
	$dst_reports_log_dir_Native1="//192.168.42.46/share/error_logs/DhanushNative/$currentDate/$currentTime";
		
	#function to check the revision and check out
	$message = "tool chain";
	checking_revision_and_checkout($toolchain_path, $toolchain_repo_path, $change_log_tc, $message);

	$message = "Dhanush Native Source";
	checking_revision_and_checkout_4_srccode($dhanushnative_path, $sourcecode_repo_path, $change_log_src, $message);

	print "*****************Native BUILD PROCESS****************************\n";	
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
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
		
		$repo_print = read_last_revision($repository_info);
		
		$body = "Hi Team,\n\n\nFailures observed while building the dhanush Native code for the svn revision:$repo_print.
		\n\nPlease find the build log in the share path:\"$dst_reports_log_dir_Native1\".
		\n\n\n\n****This is an Automatically generated email notification from Build server****";
		
		sendMail($Dev_team, $build_team, "Build Failed", $body, "");
		
		system("mkdir -p $dst_reports_log_dir_Native");
		fcopy("faillog.txt", $dst_reports_log_dir_Native) or die $!;
		fcopy("buildlog.txt", $dst_reports_log_dir_Native) or die $!;
	}
	else
	{
		print "Native Build completed successfully \n";

		$repo_print = read_last_revision($repository_info);

		$body = "Hi Team,\n\n\nDhanush Native Build Successfully completed for the svn revision: $repo_print.
		\n\nPlease find the output binaries in the share path: \"$dst_reports_dir_Native1\".
		\n\n\n\n****This is an Automatically generated email notification from Build server****";
		
		sendMail($Dev_team, $build_team, "Build Completed", $body, "");
		
		system("mkdir -p $dst_reports_dir_Native");

		#copy the output files to destination location 
		dircopy("$dhanushnative_path/output", $dst_reports_dir_Native) or die $!;

		print "Native output files copied to $dst_reports_dir_Native \n";
	}
}
if(($build eq "DhanushAndroid") || ($build eq "All"))
{

	#Declaration of repositories
	$sourcecode_repo_path_kernel="http://insvn01:9090/svn/swdepot/Dhanush/SW/Adv-trunk/Android/linux-mti-3.8.13";
	$sourcecode_repo_path_android="http://insvn01:9090/svn/swdepot/Dhanush/SW/Adv-trunk/Android/MipsGB2.3.5";

	#Declaration of local path
	
	$local_path="/home/$username/$devfolder";
	$dhanushandroid_path="/home/$username/$devfolder/Android";
	$change_log_src = "$local_path/changelog_kernel.txt";
	$change_log_android_src = "$local_path/changelog_Android.txt";

	#Declaration of DhanushAndroid paths
	$local_path_sourcecode_kernel="$dhanushandroid_path/linux-mti-3.8.13";
	$local_path_sourcecode_android="$dhanushandroid_path/MipsGB2.3.5";
	
	#Declaration of destination directories
	$dst_reports_dir_Android="/home/$username/share/output/Dhanush-Android/$currentDate/$currentTime";
	$dst_reports_dir_Android1="//192.168.42.46/share/output/Dhanush-Android/$currentDate/$currentTime";
	$dst_reports_log_dir_Android="/home/$username/share/error_logs/Dhanush-Android/$currentDate/$currentTime";
	$dst_reports_log_dir_Android1="//192.168.42.46/share/error_logs/Dhanush-Android/$currentDate/$currentTime";

	#function to check the revision and check out
	$message = "Dhanush Kernel Source";
	checking_revision_and_checkout_4_srccode($local_path_sourcecode_kernel, $sourcecode_repo_path_kernel, $change_log_src, $message);

	$message = "Dhanush Android Source";
	checking_revision_and_checkout_4_srccode($local_path_sourcecode_android, $sourcecode_repo_path_android, $change_log_android_src, $message);

	print "*****************ANDROID BUILD PROCESS****************************\n";

	#Build the Android Project

	#Build the Android Kernel

	chdir($local_path_sourcecode_kernel);

	$status = system("./build.sh > kernel_buildlog.txt 2> kernel_faillog.txt");
	if ($status) 
	{
		print("\n Kernel Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");

		$repo_print = read_last_revision($repository_info);

		$body = "Hi Team,\n\n\nFailures observed while building the kernel code for the svn revision:$repo_print.
		\n\nPlease find the build log in the share path:\"$dst_reports_log_dir_Android1\".
		\n\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $build_team, "Build Failed", $body, "");

		system("mkdir -p $dst_reports_log_dir_Android");
		fcopy("kernel_faillog.txt", $dst_reports_log_dir_Android) or die $!;
		fcopy("kernel_buildlog.txt", $dst_reports_log_dir_Android) or die $!;
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

		$repo_print = read_last_revision($repository_info);
			
		$body = "Hi Team,\n\n\nFailures observed while building the Android code for the svn revision:$repo_print.
		\n\nPlease find the build log in the share path:\"$dst_reports_log_dir_Android1\".
		\n\n\n\n****This is an Automatically generated email notification from Build server****";
		
		sendMail($Dev_team, $build_team, "Build Failed", $body, "");

		system("mkdir -p $dst_reports_log_dir_Android");
		fcopy("android_faillog.txt", $dst_reports_log_dir_Android) or die $!;
		fcopy("android_buildlog.txt", $dst_reports_log_dir_Android) or die $!;

	}
	else
	{
		print "Android Build completed successfully \n";
		$repo_print = read_last_revision($repository_info);

		$body = "Hi Team,\n\n\nDhanush Android Build Successfully completed for the svn revision: $repo_print.
		\n\nPlease find the output binaries in the share path: \"$dst_reports_dir_Android1\".
		\n\n\n\n****This is an Automatically generated email notification from Build server****";
		
		sendMail($Dev_team, $build_team, "Build Completed", $body, "");

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

my $to = $_[0];
my $cc=$_[1];
my $subject=$_[2];
my $message=$_[3];
my $attachPath=$_[4];

 $msg = MIME::Lite->new(
                 From     => $from,
                 To       => $to,
                 Cc       => $cc,
                 Subject  => $subject,
                 Data     => $message
                 );
                 
 #$msg->attr("content-type" => "text/html");  


if($attachPath ne ""){

	$msg->attach(
		Type => 'application/text',
		Path => $attachPath
		)
	or die "Error attaching the file: $!\n";
}

 $msg->send('smtp', "192.168.24.225");

 print "Email Sent Successfully by test script\n";

}

sub read_last_revision($)
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

sub checking_revision_and_checkout()
{
	$local_code_path = $_[0];
	$repository_code_path = $_[1];
	$change_log = $_[2];
	$text = $_[3];

	print "\nFinding Out revision numbers of $text ... \n";
	system("svn info $repository_code_path --username socqa --password Yo'\$8'lc9u > $repository_info");

	#Checking the code 
	if(-d "$local_code_path")
	{
		system("svn upgrade $local_code_path --username socqa --password Yo'\$8'lc9u");
		system("svn info $local_code_path --username socqa --password Yo'\$8'lc9u > $local_info");
		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		if($repo > $local)
		{
			print"Check out needed as Working copy is older than Repository revision\n\n";
			chdir($local_code_path);

			#Generating Change log from previous revision
			system("svn diff -r $local:$repo --username socqa --password Yo'\$8'lc9u > $change_log");

			print "Update $text from SVN... \n";
			system("svn update $local_code_path --username socqa --password Yo'\$8'lc9u 2>&1 > $co_log | tee $co_error_log");

			$body = "Hi Team, \n    Failures observed, while updating the $text code\n Please find the attachment\n\n This is an Automatically generated email notification";

			checkout($body);
			print "Updated successfully ... \n";
		}
		else
		{
			print"Working copy is same as Repository revision\n\n";
		}
	}
	else
	{
		print "Checkout the $text from SVN... \n";
		chdir($local_path);
		system("svn checkout $repository_code_path 2>&1 --username socqa --password Yo'\$8'lc9u > $co_log | tee $co_error_log");

		$body = "Hi Team, \n    Failures observed, while checking out the $text code\n Please find the attachment\n\n This is an Automatically generated email notification";

		checkout($body);
	}

}

sub checking_revision_and_checkout_4_srccode()
{
	$local_code_path = $_[0];
	$repository_code_path = $_[1];
	$change_log = $_[2];
	$text = $_[3];
	
	print "\nFinding Out revision numbers of $text ... \n";
	system("svn info $repository_code_path --username socqa --password Yo'\$8'lc9u > $repository_info");

	#Checking the code 
	if(-d "$local_code_path")
	{
		system("svn info $local_code_path --username socqa --password Yo'\$8'lc9u > $local_info");

		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		chdir($local_code_path);

		#Generating Change log from previous revision
		system("svn diff -r $local:$repo --username socqa --password Yo'\$8'lc9u > $change_log");

		#remove the folders and files in the local path
		if(-d "$local_code_path")
		{
		  system("rm -rf $local_code_path");
		}	
	}
	print "Checkout the $text from SVN... \n";
	chdir($local_path);
	system("svn checkout $repository_code_path 2>&1 --username socqa --password Yo'\$8'lc9u > $co_log | tee $co_error_log");

	$body = "Hi Team, \n    Failures observed, while checking out the $text code\n Please find the attachment\n\n This is an Automatically generated email notification";

	checkout($body);

}


sub checkout()
{

	$result=checkoutfailed($co_log,$co_error_log);
	if($result!=1)
	{
		#chdir($local_path);
		print "Checkout failed and sending the mail to build team\n";

	   	sendMail($build_team, $Dev_team, 'checkout failed', $_[0], $co_error_log);

		exit;

	}

}

sub checkoutfailed()
{
    my $checkoutfile = $_[0];
    open(my $RD, "< $checkoutfile") || die("Can't open file: $file");
    my @lines = <$RD>;
    close($RD);
  
    foreach my $line (@lines)
    {
        chomp($line);
	$checkedout=0;
	if($line =~ /Checked out revision/i )
	{	
		$checkedout=1;
	}
	elsif($line =~ /Updated to revision/i)
	{
		$checkedout=1;
	}
    }
  
    if($checkedout!=1)
    {	
       my $errorfile = $_[1];
       open(my $RD1, "< $errorfile") || die("Can't open file: $file");
       my @lines1 = <$RD1>;
       close($RD1);
  
       foreach my $line (@lines1)
       {
          chomp($line);
	  $error=0;
	  if($line =~ /could not connect to server/i )
	  {	
		print "Network Problem while checked out the source \n";
		$error=1;		
		last;
	  }
       }
       if($error!=1)
       {
	    print "checkout is not properly done \n";
	
       }
	return 0;
  
     } 
     else
     {
	print "checkout is completed successfully\n";
	return 1;
     }
}

