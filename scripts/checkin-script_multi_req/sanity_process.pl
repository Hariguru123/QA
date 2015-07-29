#!/usr/bin/perl

#*****************************************************************************************************************************************\
# 
#   File Name  :   sanity_process.pl
#    
#   Description:   It compares the bugID,CRnumber of the dev requests with user entered bug ID,CR number and then it calls the 	commit script 
#   		   to commit the code and corresponding tasks.	
# ****************************************************************************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use File::Basename;
use MIME::Lite;

my $query = new CGI;

#Retrieve the userID and password (User input while submitting the requset) 
my $username_user = $query->param("username");
my $password_user= $query->param("password");

#Retrieve the bugID (User input while submitting the requset) 
my $Checkin_ID = $query->param("Checkin_ID");

#result of the sanity tests
my $sanity_result=$query->param("result");

#Retrieve the Uploaded log file name and Uploaded file handle
my $filename = $query->param("ResultLog");
my $upload_filehandle = $query->upload("ResultLog");

#Retrieve the check-in comment (User comment while submitting the requset) 
my $chkin_cmnt = $query->param("Checkin_cmnt");

#mail ids
my @maild_ids=$query->param("mailids");

my @svn_list;

my $svn_names = "/media/Data/svn_names.txt";
if(-e $svn_names)
{
	open(FH,"< $svn_names") || die "$! can not be opened\n";
	@svn_list=<FH>;
	close FH;

	foreach my $a (@svn_list)
	{
		my @new_list = split(" ",$a);

		if($username_user eq "$new_list[0]")
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
my $from = 'Build_Server <socplatform-qa@inedasystems.com>';

#my $Dev_team = 'Dhanush-SW <dhanush-sw@inedasystems.com>';
#my $Dev_team = 'Vinay Kumar <vinaykumar.medari@incubesol.com>';
#my $Dev_team = 'Build_Server <socplatform-qa@inedasystems.com>';
my $Dev_team = $mail_id;

#my $build_team = 'dhanush-swqa <dhanush-swqa@inedasystems.com>';
#my $build_team = 'Vinay Kumar <vinaykumar.medari@incubesol.com>';
#my $build_team = 'Build_Server <socplatform-qa@inedasystems.com>';

my $build_team = "$cc_list";

my($line, $count, $i, $flag, $dev_path, $body);
my $server_path="/media/Data/sdk";

my($bugid_log, $crnum_log, $username_log, $password_log, $request_log, $reqnum, $dev_folder, $filesize);

$dev_path="$server_path";

my $ci_lock_log="$server_path/ci_lock.log";

my $repository_log="repository_url.log";

open(FH,"< $dev_path/builds_success.log")|| die "There are no build requests on build server, first submit the check-in request at build request page in order to check-in your requested code";
foreach $line(<FH>)
{
	chomp($line);
	if($line eq $Checkin_ID)
	{
		$dev_folder = "$Checkin_ID";
		last;
	}
}
close FH;

#checking the reqlogfile is existed or not,please create the log file and write "dev0" to the file if it is not created
if(!(-e $ci_lock_log))
{
	open(FHC,"> $ci_lock_log");
	print FHC "in sanity process\n";
	close FHC;
}


$flag = 0;

if(-d "$dev_path/$dev_folder")
{
	open(FH,"< $dev_path/$dev_folder/details.log");
	foreach $line(<FH>)
	{
		if($line =~ /^BugID:(\d+)\n$/)	
		{
			 $bugid_log=$1;
		}	
		if($line =~ /^Code_Review ID:(\d+)/)	
		{
			 $crnum_log=$1;
		}	
		if($line =~ /^username:(.+)\n$/)
		{
			 $username_log=$1;
		}
		if($line =~ /^password:(.+)/)
		{
			 $password_log=$1;
		}
	}
	close(FH);
						
	if($username_user eq $username_log)
	{
		$flag=1;
	}
	
	$password_log =~ s/\$/\"\\\$\"/g;
	
	$repos_log = "$dev_path/$dev_folder/$repository_log";
	open(FH_R,"< $repos_log");

	@lines=<FH_R>;
	chomp($lines[0]);

	$sourcecode_repo_path=$lines[0];

	close FH_R;

	#To get the code base
	@temp = split("\/","$sourcecode_repo_path");

	$sz = @temp;
	$code_base = $temp[$sz-1];

	if(($flag eq 1) && ($sanity_result eq "Yes"))
	{
		#wait for unlock the commiting is happening otherwise go for a background task
		wait_until_unlock_logfile($ci_lock_log);

		#checking the code based on sanity result
		system("perl /usr/lib/cgi-bin/commitscript.pl $server_path $dev_folder $code_base $bugid_log $username_log $password_log '$chkin_cmnt' '$build_team' >& /dev/null &");
	}
}

my $mail_details="Your Check-in request details:\n
Bug: $bugid_log
Code base: $code_base
Code Review ID: $crnum_log\n";

if(!$flag)
{
	print header;
	print start_html("Get Form");
	print "Entered details are not matched with the Build Requests, Please enter correct details <br><br>";
	print end_html;
	exit;
}
elsif($sanity_result eq "No")
{
	copyfile($dev_path);

	fcopy("$dev_path/$filename", "$filename\_$Checkin_ID");

	$body = "Dear $username_log,\n\n$mail_details\nYour Check-in request is rejected as the Sanity test result of the Image with your code changes is FAILED.\nPlease resolve the issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

	chdir("$server_path");

	sendMail($Dev_team, $build_team, "[$code_base] Check-in is not done for bug - $bugid_log because of Sanity FAIL", $body, "$dev_path/$filename");

	if(($code_base eq "AndroidKK4.4.2") || ($code_base eq "android-linux-mti-unif-3.10.14") || ($code_base eq "SGX"))
	{
		open(FH2,"< $dev_path/$dev_folder/Android.txt");
		@lines = <FH2>;
		close(FH2);

		$android_update_path = $lines[0];
		chomp($android_update_path);

REPEAT:
		if(-e "$android_update_path/revert.txt")
		{
			goto REPEAT;
		}
		
		system("rm -rf $android_update_path/lock.txt");
	}

	#delete the dev folder
	system("rm -rf $dev_path/$dev_folder");

	print header;
	print start_html("Get Form");
	print "Sanity request has been discarded because of sanity FAIL.. <br><br>";
	print end_html;
	exit;
}
elsif($sanity_result eq "Yes")
{	
	copyfile($dev_path);

	print header;
	print start_html("Get Form");
	print "Sanity request has been accepted, the submitted code changes will be check-in to SVN";
	print end_html;
	exit;
}
else
{
	print header;
	print start_html("Get Form");
	print "Sanity request not accepted, Please contact administrator";
	print end_html;
	exit;
}

#********************************************Functions********************************************

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
	return;
}

sub sendMail
{

	my $to = $_[0];
	my $cc=$_[1];
	my $subject=$_[2];
	my $message=$_[3];
	my $attachPath=$_[4];
	my $attachPath1=$_[5];
	my $attachPath2=$_[6];

	my $bcc = 'Build_Server <socplatform-qa@inedasystems.com>';
	my $msg = MIME::Lite->new(
			From     => $from,
			To       => $to,
			Cc       => $cc,
			Bcc	 	 => $bcc,
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

	if($attachPath1 ne "")
	{
		$msg->attach(
			Type => 'application/text',
			Path => $attachPath1
			);
	}

	if($attachPath2 ne "")
	{
		$msg->attach(
			Type => 'application/text',
			Path => $attachPath2
			);
	}

	$msg->send('smtp', "192.168.24.225");
	return;
}

sub copyfile
{

	#copy the patchfile to dev folder
	my $log_path=$_[0];	
	my $upload_path = "$log_path/$filename";
	open(my $RD1, "> $upload_path")|| die("cannot open file $!");
	binmode $RD1;
	my @lines1 = <$upload_filehandle>;
        
	foreach my $line (@lines1)
	{
  		print $RD1 $line;
	}
	close($RD1);
	return;
}
