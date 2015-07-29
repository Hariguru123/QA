#!/usr/bin/perl
#*****************************************************************************************************************************************\
# 
#   File Name  :   commit_others.pl
#    
#   Description:   It compares the bugID,CRnumber of the dev requests with user entered bug ID,CR number and then it calls the 	commit script 
#   		   to commit the code and corresponding tasks.	
# ****************************************************************************************************************************************/
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use File::Basename;
use MIME::Lite;
use Archive::Extract;

my $query = new CGI;

#Retrieve the userID and password (User input while submitting the requset) 
my $username_user = $query->param("username");
my $password_user= $query->param("password");

#Retrieve the bugID (User input while submitting the requset) 
my $bugid = $query->param("BugID");

#Retrieve the code review ID(User input while submitting the requset)
my $crnum = $query->param("Code_ReviewID");

#Retrieve the Uploaded compressed file name and Uploaded file handle
my $filename = $query->param("compressedfile");
my $upload_filehandle = $query->upload("compressedfile");

#Retrieve the Uploaded Repository log file name and Uploaded file handle
my $filename2 = $query->param("repologfile");
my $upload_filehandle2 = $query->upload("repologfile");

#Retrieve the check-in comment (User input while submitting the requset)
my $chkin_cmnt = $query->param("Checkin_cmnt");

if($filename =~/(.+)\.tar\.(rar|zip|gz|tar)/)
{
	$cmprsd_file = $1;
}
elsif($filename =~/(.+)\.(rar|zip|gz|tar)/)
{
	$cmprsd_file = $1;
}
my @maild_ids=$query->param("mailids");

open(FHC,"> tmp.log");

$cc_list = join(",",@maild_ids);

print FHC "Cc_list: $cc_list";

close FHC;

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


my($line, $count, $i, $flag, $dev_path, $body);
my $server_code_path="/media/Data/sdk";

system("mkdir -m 0777 $server_code_path");

my $filesize;

my $ci_lock_log="$server_code_path/ci_lock.log";
#checking the reqlogfile is existed or not,please create the log file and write "dev0" to the file if it is not created
if(!(-e $ci_lock_log))
{
	open(FHC,"> $ci_lock_log");
	print FHC "in commit others\n";
	close FHC;
}

our($year, $mon, $mday, $hr, $min, $sec, $wday, $yday, $daylight);

#Declaration of Date and Time
currentdate();
my $currentDate = "$year\-$mon\-$mday";
my $currentTime = "$hr\-$min\-$sec";

my $dev_folder = "$bugid\_$currentDate\_$currentTime";


#create a directory for dev request
system("mkdir -m 0777 $server_code_path/$dev_folder");

my $mail_details="Your Check-in request details:\n
Bug: $bugid
Code Base: $cmprsd_file
Code Review ID: $crnum\n";

copyfile("$server_code_path/$dev_folder");

$repos_log = "$server_code_path/$dev_folder/$filename2";
open(FH_R,"< $repos_log");

@lines=<FH_R>;

foreach $line (@lines)
{
	chomp($line);
	if($line =~/URL:\s(.+)/)
	{
		$str=$1;
		$repository=$str;
		last;
	}
}

close FH_R;

my $pswd = "$username_user.txt";
open(my $RD2, "< $pswd") || die("cannot open file $!");

my @pd=<$RD2>;
chomp($pd[0]);
$password_user=$pd[0];

close($RD2);

my $result=system("svn info $repository --username $username_user --password '$password_user' > log.txt 2> fail.txt");
if($result)
{
	print header;
	print start_html("Get Form");
	print "Please enter the correct repository URL";
	print end_html;
	exit;
}

#untar the uploaded compressed file
$compressed_file = "$server_code_path/$dev_folder/$filename";

chdir("$server_code_path/$dev_folder");

#system("tar -xvzf $filename >& /dev/null &");

# build an Archive::Extract object #
my $ae = Archive::Extract->new(archive => $filename);

# extract to cwd() #
my $ok = $ae->extract;

my $commit_message= "Issue Id:	$bugid-Bug\nIssue Type:	Bug\nReviewer:	$username_user\n\nComments:$chkin_cmnt";

$status = system("svn upgrade $cmprsd_file --username $username_user --password '$password_user' > /usr/lib/cgi-bin/upg.log 2> /usr/lib/cgi-bin/upg_err.log");


system("svn checkout http://insvn01:9090/svn/swdepot/Dhanush/Tools/QA/scripts/checkin-script_multi_req --username socqa --password Yo'\$8'lc9u > /usr/lib/cgi-bin/co.log 2> /usr/lib/cgi-bin/co_err.log");

system("rm -rf checkin-script_multi_req");

system("svn checkout http://insvn01:9090/svn/swdepot/Dhanush/Tools/QA/scripts/checkin-script_multi_req --username socqa --password Yo'\$8'lc9u > /usr/lib/cgi-bin/co.log 2> /usr/lib/cgi-bin/co_err.log");

system("rm -rf checkin-script_multi_req");


$status = system("svn ci $cmprsd_file -m \"$commit_message\" --username $username_user --password '$password_user' > /usr/lib/cgi-bin/ci.log 2> /usr/lib/cgi-bin/err_ci.log");

if($status)
{
	$body = "Dear $username_user,\n\n$mail_details\nYour Check-in request is rejected, because of SVN commit has FAILED.\n\n\n****This is an Automatically generated email notification from Build Server****";

	chdir("$server_code_path");

	sendMail($Dev_team, $build_team, "[$cmprsd_file] Check-in is not done for bug - $bugid because of SVN commit FAIL", $body, "/usr/lib/cgi-bin/err_ci.log");

	#delete the dev folder
	#system("rm -rf $server_code_path/$dev_folder");

	print header;
	print start_html("Get Form");
	print "Check-in request has been discarded because of SVN commit FAIL.. <br><br>";
	print end_html;
	exit;
}
else
{
	chdir("$server_code_path");

	#delete the dev folder
	#system("rm -rf $server_code_path/$dev_folder");

	print header;
	print start_html("Get Form");
	print "Check-in request has been accepted, the submitted code changes were committed to SVN";
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

	#copy the repologfile to dev folder
	my $upload_path2 = "$log_path/$filename2";
	open(my $RD1, "> $upload_path2") || die("cannot open file $!");
	binmode $RD1;
	my @lines1 = <$upload_filehandle2>;
        
	foreach my $line (@lines1)
	{
  		print $RD1 $line;
	}
	close($RD1);
	return;	
}

#*************************************************Functions***********************************************************
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
