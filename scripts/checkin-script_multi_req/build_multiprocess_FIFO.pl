#!/usr/bin/perl
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use File::Basename;
use Socket;

#Declare the uploaded file size
$CGI::POST_MAX = 1024 * 5000000;
my $query = new CGI;
my $ip_addr = $ENV{REMOTE_ADDR};

#Retrieve the userID and password (User input while submitting the requset) 
my $username = $query->param("username");
my $password = $query->param("password");

#Retrieve the bugID (User input while submitting the requset) 
my $bugid = $query->param("BugID");

#Retrieve the code review ID(User input while submitting the requset)
my $crnum = $query->param("Code_ReviewID");

#Retrieve the Uploaded patch file name and Uploaded file handle
my $filename = $query->param("patchfile");
my $upload_filehandle = $query->upload("patchfile");

#Retrieve the Uploaded log file name and Uploaded file handle
my $filename1 = $query->param("logfile");
my $upload_filehandle1 = $query->upload("logfile");

#Retrieve the Uploaded log file name and Uploaded file handle
my $filename2 = $query->param("repologfile");
my $upload_filehandle2 = $query->upload("repologfile");

#Android build type
my $androidbuild = $query->param("androidbuild");

#code base name
my @maild_ids=$query->param("mailids");

open(FHC,"> tmp.log");

$cc_list = join(",",@maild_ids);

print FHC "Cc_list: $cc_list";

close FHC;

my $build_team = "$cc_list";

my $code_base;
if($filename=~/^(.+).patch/)
{  
	$code_base="$1";
}

#Declaration of build server paths
my $server_path="/media/Data/sdk";
my $build_req_path="/media/Data/trunk_wc/build_requests";

#create the server path with all permissions
if(!(-d $server_path))
{
	system("mkdir -m 0777 $server_path");
}

#create the build request path with all permissions
if(!(-d $build_req_path))
{
	system("mkdir -m 0777 $build_req_path");
}

my $command_log;
#accepting command log file
if($filename1 eq "add_information.log")
{
	$command_log = "add_information.log";
}

my $patchfile_name="$code_base.patch";


our($year, $mon, $mday, $hr, $min, $sec, $wday, $yday, $daylight);

#Declaration of Date and Time
currentdate();
my $currentDate = "$year\-$mon\-$mday";
my $currentTime = "$hr\-$min\-$sec";

my $dev_folder = "$bugid\_$currentDate\_$currentTime";


#create a directory for dev request
system("mkdir -m 0777 $server_path/$dev_folder");

#copy the files(given by developer) to above created directory 
copy_files("$server_path/$dev_folder");

$again = 0;

#call the Merge script(In Merge we have build,check-in scripts)
system("perl mergescript_multiple.pl $server_path $dev_folder $code_base $filename1 $filename2 $androidbuild $again '$build_team' >& /dev/null &");


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

sub copy_files
{
	#copy the patchfile to dev folder
	my $dev_path=$_[0];	
	my $upload_path = "$dev_path/$filename";
	open(my $RD1, "> $upload_path") || die("cannot open file $!");
	binmode $RD1;
	my @lines1 = <$upload_filehandle>;
        
	foreach my $line (@lines1)
	{
  		print $RD1 $line;
	}
	close($RD1);

	#copy the logfile to dev folder
	my $upload_path1 = "$dev_path/$filename1";
	open(my $RD1, "> $upload_path1") || die("cannot open file$!");
	binmode $RD1;
	my @lines1 = <$upload_filehandle1>;
        
	foreach my $line (@lines1)
	{
	  print $RD1 $line;
	}
	close($RD1);

	#copy the repologfile to dev folder
	my $upload_path2 = "$dev_path/$filename2";
	open(my $RD1, "> $upload_path2") || die("cannot open file $!");
	binmode $RD1;
	my @lines1 = <$upload_filehandle2>;
        
	foreach my $line (@lines1)
	{
  		print $RD1 $line;
	}
	close($RD1);
	
	#write the bug number and codereview id to the "detailslog" file(created in the dev folder)
	my $pswd = "$username.txt";
	open(my $RD2, "< $pswd") || die("cannot open file $!");

	my @pd=<$RD2>;
	chomp($pd[0]);
	$password=$pd[0];

	close($RD2);

	my $details_log="$dev_path/details.log";
	open(my $RD2, "> $details_log") || die("cannot open file $!");
	print $RD2 "BugID:$bugid\nCode_Review ID:$crnum\nusername:$username\npassword:$password";
	close($RD2);
}

print header;
print start_html("Get Form");
print "build request has been submitted successfully";
print end_html;
