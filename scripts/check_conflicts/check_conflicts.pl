#!/usr/bin/perl 

#*********************************************************************************\
# 
#   File Name  :  check_conflicts.pl
#    
#   Description:  This file is checking conflicts in linux on the given input path 
#				  with SVN latest version .You should give the proper local SVN
#				  working copy path to check conflicts.
# 
#   Example O/P:  Conflicted state occured or No conflicts occured.
 	
# ********************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
$username = $ENV{'USER'};

#maintaining logs on the User Desktop
$log_folder="/home/$username/Desktop";

#Input from the user for local SVN working copy path
print "\nEnter the local source code path:";
$input=<>;

chomp($input);

#Changing the directory to local SVN working copy path
chdir ($input) or die "can not change directory, Please enter correct path";

#Declarations of Logs
$status_log = "$log_folder/svn_status.log";
$error_log = "$log_folder/error.log";

#Command to check SVN conflicts
$status = system("svn status -u 2>&1 > $status_log | tee $error_log");

$filesize = -s $error_log;

#if any svn error occured, report to user
if($filesize > 0)
{
	print "SVN error occured, please check the $error_log file\n";
	exit;
}

#To Identify the svn conflict files in the log
my $file = $status_log;
open(my $RD, "< $file") || die("Can't open file: $file");
my @lines = <$RD>;
close($RD);

$detected = 0;

$length = @lines;

for($a=0;$a<($length-1);$a++)
{
	$line  = $lines[$a];

	chomp($line);

	$b = unpack("x8 A1", $line);
#if * mark found, conflict occured and printing on the screen.
	if($b eq '*')
	{
		if($detected == 0)
		{
			print "\nConflicted state occured, please update the code\n";
			print "Below are the conflicted files \n\n";
			$detected = 1;
		}
		$data = unpack("x21 A*", $line);
		print "$data\n";
	}
}

#Confirming no Conflicts occured and printing on the screen.
print "\n";
if($detected == 0)
{
	print "No conflicts occured\n";
}

