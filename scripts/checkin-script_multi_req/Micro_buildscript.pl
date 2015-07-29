#!/usr/bin/perl
#********************************************************************************************************************\
# 
#   File Name  :   Micro_buildscript.pl
#    
#   Description:  It will build the corresponding code based on the arguments received.Developer will 
#		  receive a mail if build either passed or failed,with all corresponding logs/ouputs in one location.
#   	
# ********************************************************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use MIME::Lite;

$server_path=$ARGV[0];
$dev_folder=$ARGV[1];
$patch_file=$ARGV[2];
$utrunk=$ARGV[3];
$username =$ARGV[4];
$password =$ARGV[5];
$build_team=$ARGV[6];

my $image_log="$server_path/image.log";

$code_base_name = $patch_file;
$code_base="$server_path";

$repository_info = "$code_base/$dev_folder/repository_info.log";

$patch_file = "$patch_file.patch";

$local_path = "/media/Data/trunk_wc";

$bins_path = "$local_path/SVN_bins/Micro-trunk";

$dst_images_dir = "$local_path/build_requests/Micro-trunk";
$dst_images_dir1 = "//192.168.42.46/build_requests/Micro-trunk";

if(!(-d "$dst_images_dir"))
{
	system("sudo mkdir -p $dst_images_dir");
}
system("sudo chmod -R 777 $dst_images_dir");


if(!(-d "$bins_path"))
{
	system("sudo mkdir -p $bins_path");
}
system("sudo chmod -R 777 $bins_path");


$codebase_devfolder = "$code_base/$dev_folder";

open(FH,"< $code_base/$dev_folder/details.log") || die("Can't open file: $code_base/$dev_folder/details.log in build script");
my($bugid,$crnum,$username);
foreach $line(<FH>)
{
	if($line =~ /^BugID:(\d+)\n$/)	
	{
		 $bugid=$1;
	}	
	if($line =~ /^Code_Review ID:(\d+)/)	
	{
		 $crnum=$1;
	}	
	if($line =~ /^username:(.+)\n$/)	
	{
		 $username=$1;
	}
}
close(FH);

$mail_details="Your Check-in request details:\n
Bug: $bugid
Code base: $code_base_name
Code Review ID: $crnum\n";

my @svn_list;
my $mail_id;

my $svn_names = "/media/Data/svn_names.txt";
if(-e $svn_names)
{
	open(FH,"< $svn_names") || die "$! can not be opened\n";
	@svn_list=<FH>;
	close FH;

	foreach my $a (@svn_list)
	{
		my @new_list = split(" ",$a);

		if($username eq "$new_list[0]")
		{
			$mail_id = "$new_list[1]";
			last;
		}
	}
}

if($mail_id eq "")
{
	$mail_id = 'Build_Server <socplatform-qa@inedasystems.com>';
}

#Declaration of mail parameters
$from = 'Build_Server <socplatform-qa@inedasystems.com>';

#$Dev_team = 'Dhanush-SW <dhanush-sw@inedasystems.com>';
#$Dev_team = 'Vinay Kumar <vinaykumar.medari@incubesol.com>';
#$Dev_team = 'Build_Server <socplatform-qa@inedasystems.com>';
$Dev_team = $mail_id;

#$build_team = 'dhanush-swqa <dhanush-swqa@inedasystems.com>';
#$build_team = 'Vinay Kumar <vinaykumar.medari@incubesol.com>';
#$build_team = 'Build_Server <socplatform-qa@inedasystems.com>';

$details = "$code_base_name\_$dev_folder\_$username";

#checking the image.log is existed or not. if not, creating the log file and writing "build started" to the file.
if(!(-e $image_log))
{
	open(FH,"> $image_log") || die("Can't open file: $image_log in build script");
	print FH "build started";
	close FH;
}

$dst_reports_log_dir="$dst_images_dir/error_logs/$details";
$dst_reports_log_dir1="$dst_images_dir1/error_logs/$details";

#Declaration of AONsensor paths
if($patch_file eq "AON.patch")
{
	$name="AON";
	$name1="AON";
}
#Declaration of DhanushNative paths
elsif($patch_file eq "Native.patch")
{
	$name="NATIVE";
	$name1="Native";
}

$passed_subj="[$name] Build is PASSED with code changes of bug - $bugid";
$failed_subj="[$name] Build is FAILED with code changes of bug - $bugid";

chdir("$codebase_devfolder/$utrunk") || die("\n can not change to directory $codebase_devfolder/$utrunk");

system("cp -r /home/socplatform-qa/toolchain/ubuntu64/mips $codebase_devfolder/$utrunk/Tools/toolchain/ubuntu64/mips");


print "********************************* Micro-trunk MSDK1 BUILD PROCESS **********************************\n";

$status = system("./build.sh MSDK1 > $code_base/$dev_folder/MSDK1_buildlog.txt 2> $code_base/$dev_folder/MSDK1_faillog.txt");

if((!(-f "Output/aonsram.bin") || !(-f "Output/aontcm.bin") || !(-f "Output/d_native.bin") || !(-f "Output/d_aflash.bin") || !(-f "Output/bl1.bin")) || ($status)) 
{
	print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");

	system("mkdir -p -m 0777 $dst_reports_log_dir");

	fcopy("$code_base/$dev_folder/MSDK1_faillog.txt", $dst_reports_log_dir) || die("Can't copy file: $code_base/$dev_folder/faillog.txt to $dst_reports_log_dir");

	fcopy("$code_base/$dev_folder/MSDK1_buildlog.txt", $dst_reports_log_dir) || die("Can't copy file: $code_base/$dev_folder/buildlog.txt to $dst_reports_log_dir");

	$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir1\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

	sendMail($Dev_team, $build_team, $failed_subj, $body, "");

	delete_folder();
}
else
{
	print "Micro-trunk Build completed successfully \n";

	#creating share location for images
	system("mkdir -p $dst_images_dir/$details/MSDK1");

	#wait for unlock the image.log
	wait_until_unlock_logfile($image_log);

	#lock the image.log untill the updates completed.
	open(FH1,"> $image_log") || die("Can't open file: $image_log in MSDK1 build script");
	print FH1 "preparing images tar...";

	#copy the output files to destination location 
	dircopy("Output", "$dst_images_dir/$details/MSDK1");
	dircopy("Tools/Utilities/SPI_Utility", "$dst_images_dir/$details/MSDK1/SPI_Utility");

	#unlock
	close(FH1);
	system("chmod 777 $image_log");
}


print "********************************* Micro-trunk MSDK2 BUILD PROCESS **********************************\n";

$status = system("./build.sh MSDK2 > $code_base/$dev_folder/MSDK2_buildlog.txt 2> $code_base/$dev_folder/MSDK2_faillog.txt");

if((!(-f "Output/aonsram.bin") || !(-f "Output/aontcm.bin") || !(-f "Output/d_native.bin") || !(-f "Output/d_aflash.bin") || !(-f "Output/bl1.bin")) || ($status)) 
{
	print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");

	system("mkdir -p -m 0777 $dst_reports_log_dir");

	fcopy("$code_base/$dev_folder/MSDK2_faillog.txt", $dst_reports_log_dir) || die("Can't copy file: $code_base/$dev_folder/faillog.txt to $dst_reports_log_dir");

	fcopy("$code_base/$dev_folder/MSDK2_buildlog.txt", $dst_reports_log_dir) || die("Can't copy file: $code_base/$dev_folder/buildlog.txt to $dst_reports_log_dir");

	$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir1\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

	sendMail($Dev_team, $build_team, $failed_subj, $body, "");

	delete_folder();
}
else
{
	print "Micro-trunk Build completed successfully \n";

	#creating share location for images
	system("mkdir -p $dst_images_dir/$details/MSDK2");

	#wait for unlock the image.log
	wait_until_unlock_logfile($image_log);

	#lock the image.log untill the updates completed.
	open(FH1,"> $image_log") || die("Can't open file: $image_log in MSDK2 build script");
	print FH1 "preparing images tar...";

	#copy the output files to destination location 
	dircopy("Output", "$dst_images_dir/$details/MSDK2");
	dircopy("Tools/Utilities/SPI_Utility", "$dst_images_dir/$details/MSDK2/SPI_Utility");

	#unlock
	close(FH1);
	system("chmod 777 $image_log");

	$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the image available at \"$dst_images_dir1/$details\" and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

	sendMail($Dev_team, $build_team, $passed_subj, $body, "");

	#sanity tests
	open($BS,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
	print $BS "$dev_folder\n";
	close $BS;

}

system("sudo chmod -R 777 $dst_images_dir");

#*****************************************Functions****************************************************************************

sub delete_folder
{
	#delete the dev folder 
	system("rm -rf $code_base/$dev_folder");
}

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

sub sendMail
{

	my $to = $_[0];
	my $cc=$_[1];
	my $subject=$_[2];
	my $message=$_[3];
	my $attachPath=$_[4];
	my $bcc = 'Build_Server <socplatform-qa@inedasystems.com>';
	
	$msg = MIME::Lite->new(
                 From     => $from,
                 To       => $to,
                 Cc       => $cc,
				 Bcc	  => $bcc,				 
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

sub wait_until_unlock_logfile	
{

	my $log_path=$_[0];
	START:	
	open(FH,"< $log_path");
	while($! eq "Permission denied")
	{
		sleep(2);
		goto START;
	}
	close(FH);
}


