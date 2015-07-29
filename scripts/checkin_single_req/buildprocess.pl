#!/usr/bin/perl
#*****************************************************************************************************************************************\
# 
#   File Name  :   buildprocess.pl
#    
#   Description:  It creates repository & source code folder based on the patch file and copy the input files to source code folder.After #		  that it calls the merge script with repository,source code folder,patch file and log file as arguements.
#   	
# ****************************************************************************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use strict;
use File::Basename;

#Declare the uploaded file size
$CGI::POST_MAX = 1024 * 5000000;
my $query = new CGI;

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

#Declaration of build server paths
my $server_path="/home/testuser/sdk";
my $server_path_contiki="$server_path/contiki";
my $server_path_android="$server_path/android";
my $server_path_nucleus="$server_path/nucleus";

#create the server path with all permissions
if(!(-d $server_path))
{
	system("mkdir -m 0777 $server_path");
}

#Declaration of the variables
my ($server_code_path, $patchfile_name, $prev_patchfile_name, $next_patchfile_name, $command_log, $prev_command_log, $next_command_log, $reqnum, $line, $x, @file, $i, $y, $z, $buidreq_num);

#accepting command log file
if($filename1 eq "add_information.log")
{
	$command_log = "add_information.log";
	
}
#checking the patch file name and assign the paths
if($filename eq "DhanushAON.patch")
{
	 $server_code_path="$server_path_contiki";
	 $patchfile_name="DhanushAON.patch";
	 
}
elsif($filename eq "Native.patch")
{
         $server_code_path="$server_path_nucleus";
	 $patchfile_name="Native.patch";

}
elsif($filename eq "Dhanush-Android.patch")
{
	 $server_code_path="$server_path_android";
	 $patchfile_name="Dhanush-Android.patch";
}

#create a repository directory for build requests
if(!(-d $server_code_path))
{
	system("mkdir -m 0777 $server_code_path");
}

#create a directory for dev request
START:
if(!(-d "$server_code_path/dev1"))
{		
	#create a directory for dev request
	system("mkdir -m 0777 $server_code_path/dev1");
}
else
{
	sleep(2);
	goto START;
}

#copy the files(given by developer) to above created directory 
copy_files("$server_code_path/dev1");
		
#call the Merge script(In Merge we have build,check-in scripts)
system("perl mergescript.pl $server_code_path dev1 $filename $filename1 >& /dev/null &");

print header;
print start_html("Get Form");
print "Build request has been submitted successfully. Build process is in-progress and you will receive an email after build completion";
print end_html;

		
#***********************************************Functions**********************************************************************
sub copy_files
{
	#copy the patchfile to dev folder
	my $dev_path=$_[0];	
	my $upload_path = "$dev_path/$filename";
	open(my $RD1, "> $upload_path")|| die("cannot open file $!");
	binmode $RD1;
	my @lines1 = <$upload_filehandle>;
        
	foreach my $line (@lines1)
	{
  		print $RD1 $line;
	}
	close($RD1);

	#copy the logfile to dev folder
	my $upload_path1 = "$dev_path/$filename1";
	open(my $RD1, "> $upload_path1")|| die("cannot open file$!");
	binmode $RD1;
	my @lines1 = <$upload_filehandle1>;
        
	foreach my $line (@lines1)
	{
	  print $RD1 $line;
	}
	close($RD1);
	
	#write the bug number and codereview id to the "detailslog" file(created in the dev folder)
	my $details_log="$dev_path/details.log";
	open(my $RD2, "> $details_log")|| die("cannot open file");
	print $RD2 "BugID:$bugid\nCode_Review ID:$crnum";
	close($RD1);


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

	


