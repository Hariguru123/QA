#!/usr/bin/perl

#*****************************************************************************
# 
# File name: CodeMigration_Script.pl
# 
# Location: Need to be run from the working copy of the destination branch
# 
# Description: This script will take the source branch and/or revisons of the source branch 
#              from the user and merge the same to working copy branch 
#             
# Inputs required: 
#		1. Source branch URL
#		2. Destination branch URL
#		3. Revision number range (Starting revision and End revision) or 
#		   specific revision no.
#
# Prerequisites: The destination branch should be checkedout
#
#******************************************************************************

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use MIME::Lite;

#Declaration of mail parameters
$from = 'Build_Server <socplatform-qa@inedasystems.com>';
#$Dev_team = 'Dhanush-SW <dhanush-sw@inedasystems.com>';
$Dev_team = 'Vinay <vinaykumar.medari@incubesol.com>';
#$svnAdmin_team = 'dhanush-swqa <dhanush-swqa@inedasystems.com>';
$svnAdmin_team = 'Vinay <vinaykumar.medari@incubesol.com>';

# Current path where this script resides
system ("pwd >curr.txt");

open (FH, "<curr.txt");

foreach $path (<FH>)
{
	chomp($cPath = $path);
	last;
}

print "\n\n********** Welcome to Code Migration (SVN Merge) script ********** \n";

# User input for merge type
MERGETYPE:
print "\nPlease select the type of merge you want to do\n 
	1 - Complete Merge of one branch to other branch/trunk\n
	2 - Merge of a range of revisions of a branch to other branch/trunk\n
	3 - Merge of specific revisions from a branch to other branch/trunk\n
	[1-3]:";

$merge_type = <STDIN>;

chomp($merge_type);

if (!$merge_type)
{
	print "Didn't enter any merge type, please enter:\n";	
	goto MERGETYPE;
}

# User input for source branch
print "Enter the source branch URL from which you want to do the merge:\n";

SRCBPATH:
$src_branch_path = <STDIN>;

chomp ($src_branch_path);

if (!$src_branch_path)
{
	print "Didn't enter the source branch URL, please enter:\n";	
	goto SRCBPATH;
}
else
{
	# Checking the existance of Source branch URL
	$val = system("svn info $src_branch_path > srcBrPath.txt 2> info_fail.txt");

	if($val)
	{
		print "please enter Valid and existed Source branch URL:\n";
		goto SRCBPATH;
	}
}

# User input for destination branch
print "Mention the destination branch URL:\n";

DESTBPATH:
$dest_branch_path = <STDIN>;

chomp ($dest_branch_path);

if (!$dest_branch_path)
{
	print "Didn't enter the destination branch URL, please enter:\n";	
	goto DESTBPATH;
}

print "\nEnter Issue ID:";
$issue_id = <STDIN>;
chomp ($issue_id);

print "\nEnter Issue Type:";
$issue_type = <STDIN>;
chomp ($issue_type);

$commit_string = "Issue Id: $issue_id - Merging\nIssue Type: $issue_type\nReviewer: ReleaseEngineer\n\nComments: Merging of $src_branch_path to $dest_branch_path\n";

if($merge_type == 1)
{
	
	$cMergeLog = "$cPath/cmerge.log";
	
	system ("svn merge $src_branch_path > $cMergeLog 2> $cPath/cmerge_err.log");

	$filesize = -s "$cPath/cmerge_err.log";
	if($filesize > 0)
	{
		print "\nSVN error occurred while merging..\n";

		$mail_Body = "Hi Team,\n\n\nSVN error occurred while merging the revisons from $startRev to $endRev of the branch \"$src_branch_path\" to the branch $dest_branch_path\n\nPlease find the attached SVN error log file.\n\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $svnAdmin_team, "Merge Failed", $mail_Body, "$cPath/cmerge_err.log");
		print "\nExiting..";
		exit;
	}

	my $conflicts_Status = conflicts_checking("$cMergeLog");

	if($conflicts_Status == 1)
	{
		print "\nConflicts observed while merging tip of the branch to SVN.\n";

		$mail_Body = "Hi Team,\n\n\nConflicts are observed while merging the tip of the branch \"$src_branch_path\" to the branch $dest_branch_path\n\nPlease find the attached conflicts log file.\n\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $svnAdmin_team, "Merge Failed", $mail_Body, "$cPath/cmerge.log");
	}
	elsif($conflicts_Status == 0)
	{
		print "\nNo conflicts occurred, while merging the tip of the branch to SVN.\n";

		system("svn ci -m \"$commit_string\"");

		$mail_Body = "Hi Team,\n\n\nMerging of the tip of the branch \"$src_branch_path\" to the branch $dest_branch_path has finished successfully.\n\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $svnAdmin_team, "Merge Completed", $mail_Body, "$cPath/cmerge.log");
	}
}
elsif($merge_type == 2)
{

	print "Enter the START revision number of Source branch form which you want to merge:\n";
	
	SREVNO:
	$startRev = <STDIN>;
	
	chomp ($startRev);

	if (!$startRev)
	{
		print "Didn't enter the  START revison number of source branch, please enter:\n";	
		goto SREVNO;
	}
	else
	{
		# Checking the existance of Source branch URL with the given revision no.
		$val = system("svn info -r $startRev $src_branch_path > startRev.txt");

		if($val)
		{
			print "please enter the existed revision number on Source branch URL:\n";
			goto SREVNO;
		}

		print "Enter the END revision number of Source branch up to which you want to merge:\n";
	
		EREVNO:
		$endRev = <STDIN>;
	
		chomp ($endRev);

		if (!$endRev)
		{
			print "Didn't enter the  END revison number of source branch, please enter:\n";	
			goto EREVNO;
		}
		else
		{
			# Checking the existance of Source branch URL with the given revision no.
			$val = system("svn info -r $endRev $src_branch_path > startRev.txt");
			if($val)
			{
				print "please enter the existed revision number on Source branch URL:\n";
				goto EREVNO;
			}

			# merging of source branch with a range of revision numbers
			system ("svn merge -r$startRev:$endRev $src_branch_path > $cPath/cmerge.log 2> $cPath/cmerge_err.log");

			$filesize = -s "$cPath/cmerge_err.log";
			if($filesize > 0)
			{
				print "\nSVN error occurred while merging..\n";

				$mail_Body = "Hi Team,\n\n\nSVN error occurred while merging the revisons from $startRev to $endRev of the branch \"$src_branch_path\" to the branch $dest_branch_path\n\nPlease find the attached SVN error log file.\n\n\n\n****This is an Automatically generated email notification from Build server****";
	
				sendMail($Dev_team, $svnAdmin_team, "Merge Failed", $mail_Body, "$cPath/cmerge_err.log");
				print "\nExiting..";
				exit;
			}

			my $conflicts_Status = conflicts_checking("$cPath/cmerge.log");

			if ($conflicts_Status == 1)
			{
				print "\nConflicts observed while merging revisions from $startRev to $endRev..\n";

				$mail_Body = "Hi Team,\n\n\nConflicts are observed while merging the tip of the branch \"$src_branch_path\" to the branch $dest_branch_path\n\nPlease find the attached conflicts log file. \n\n\n\n****This is an Automatically generated email notification from Build server****";
				sendMail($Dev_team, $svnAdmin_team, "Merge Failed", $mail_Body, "$cPath/cmerge.log");
			}
			elsif($conflicts_Status == 0)
			{
				print "\nNo conflicts occurred, merging the revisions from $startRev to $endRev changes in to SVN.\n";

				system("svn ci -m \"$commit_string\"");

				$mail_Body = "Hi Team,\n\n\nMerging of the revisions $startRev to $endRev of the branch \"$src_branch_path\" to the branch $dest_branch_path is finished successfully.\n\n\n\n****This is an Automatically generated email notification from Build server****";
				sendMail($Dev_team, $svnAdmin_team, "Merge Completed", $mail_Body, "$cPath/cmerge.log");
			}
		}
	}	
}	
elsif($merge_type == 3)
{

	print "Please enter the revision number which you want to merge from Source branch:\n";

	@indRev;	
	$i = 0;

	INDREV:
	$indRev[$i] = <STDIN>;

	chomp ($indRev[$i]);

	if (!$indRev[$i])
	{
		print "Didn't enter the revison number of source branch, please enter:\n";	
		goto INDREV;
	}
	else
	{
		# Checking the existance of Source branch URL with the given revision no.
		$val = system("svn info -r $indRev[$i] $src_branch_path >startRev.txt");

		if($val)
		{
			print "please enter the existed revision number on Source branch URL:\n";
			goto INDREV1;
		}
	}

	print "If you want merge any other revisions of source branch, please enter 1\n Otherwise enter 2:\n";

	OTHREV:
	$othRev = <STDIN>;

	chomp ($othRev);

	if (!$othRev)
	{
		print "Didn't enter your choice to enter another revision number, please enter:\n";	
		goto OTHREV;

	}
	elsif ($othRev == 1)
	{
		print "Please enter the revision number which you want to merge from source branch:\n";
		$i++;
		goto INDREV;
	}

	foreach $rev (@indRev)
	{
		system ("svn merge -c$rev $src_branch_path > $cPath/cmerge.log 2> $cPath/cmerge_err.log");

		$filesize = -s "$cPath/cmerge_err.log";
		if($filesize > 0)
		{

			print "\nSVN error occurred while merging..\n";
			$mail_Body = "Hi Team,\n\n\nSVN error occurred while merging the revison $rev of the branch \"$src_branch_path\" to the branch $dest_branch_path\n\nPlease find the attached SVN error log file.\n\n\n\n****This is an Automatically generated email notification from Build server****";
	
			sendMail($Dev_team, $svnAdmin_team, "Merge Failed", $mail_Body, "$cPath/cmerge_err.log");
			print "\nExiting..";
			exit;
		}

		my $conflicts_Status = conflicts_checking("$cPath/cmerge.log");

		if ($conflicts_Status == 1)
		{
			print "\nConflicts observed while merging the $rev..\n";

			$mail_Body = "Hi Team,\n\n\nConflicts are observed while merging the revison $rev of the branch \"$src_branch_path\" to the branch $dest_branch_path\n\nPlease find the attached conflicts log file.\n\n\n\n****This is an Automatically generated email notification from Build server****";
	
			sendMail($Dev_team, $svnAdmin_team, "Merge Failed", $mail_Body, "$cPath/cmerge.log");
		}
		elsif($conflicts_Status == 0)
		{
			print "\nNo conflicts occurred, merging the revision changes in to SVN.\n";
		}
	}

	system("svn ci -m \"$commit_string\"");

	$mail_Body = "Hi Team,\n\n\nMerging of the revisions @indRev of the branch \"$src_branch_path\" to the branch	$dest_branch_path is finished successfully.\n\n\n\n****This is an Automatically generated email notification from Build server****";

	sendMail($Dev_team, $svnAdmin_team, "Merge Completed", $mail_Body, "$cPath/cmerge.log");		

}

#***************************Subroutines ****************************

# send mail subroutine
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

#conflicts checking subroutine
sub conflicts_checking
{

	$CLogFile = $_[0];

	open(my $FH, "<$CLogFile") || die("Can't open file: $file");
	my @lines = <$FH>;
	close($FH);

	$conflictCount = 0;

	foreach $line (@lines)
	{
		if ($line =~ /conflicts/)
		{
			$conflictCount++;
		}
	}

	if($conflictCount > 1)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

