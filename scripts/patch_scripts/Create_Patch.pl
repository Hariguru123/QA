#!/usr/bin/perl
#*************************************************************************************************\
# 
#   File Name  :   Create_Patch.pl
#    
#   Description:  This file is taking Path of the local folder where the user needs patch creation.
#		  Asks user to enter the SVN credentials.
#		  Reads the Patch file name and creates the SVN Patch on given local folder path.
#		  User can submitt this created patch file to the build request process.
#   	
# ************************************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

#Accepting SVN credentials username
print "Please enter the SVN username: ";
$username = <STDIN>;
chomp($username);

#Accepting SVN credentials password
print "Please enter the SVN password: ";
$password = <STDIN>;
chomp($password);

$password =~ s/\$/\"\\\$\"/g;

#Accepting user input to enter local folder path
print "\nEnter the local source code path where you want to create a patch:\n";
$input=<>;
chomp($input);

chdir($input) or die "can not change directory, Please enter correct path";

#Declaration of add files information log
$patch_err_log = "patch_err.log";

#Declaration of conflicts status
$status_log = "status.log";
$error_log = "error.log";

#Declaration of sizes for add and delete
$add_information_log = "$input/add_information.log";
$repository_url_log = "$input/repository_url.log";


#flags for addition and deletion
$add_flag=0;
$del_flag=0;
$var = 0;

#Reading Patch file name.
$val = check_path();
if($val == 0)
{
	print "Please enter proper working copy path of local source code or check for any svn errors..Exiting..\n";
	exit;
}

print "\n\nplease do the svn add --force PATH/* command before the svn patch creation, if you need to add new files recursively in local copy\n";
print "\nplease do the svn delete command before the svn patch creation, if you need to delete any files or folders in local copy\n\n";

print "Enter 'yes' if you had done proper modifications on the local source path, other wise enter 'no':";
$input1=<>;
chomp($input1);
if(($input1 eq "yes")||($input1 eq "YES"))
{
	goto START;
}
else
{
	print "Exiting...\n";
	exit;
}

START:

#Checking conflicts with SVN latest revision and also give the add/del files information
check_conflicts();

#If no additions or deletions done in the code write 0 in to size_log
if(($add_flag==0) && ($del_flag==0))
{
	$st = system("echo $var > $add_information_log 2> $patch_err_log");	
}

print "Please make sure and review that all the files listed in the $status_log are going to be patched.\n";

# Patch creation using svn diff command.
$status = system("svn diff --username $username --password $password > $patch_file 2> $patch_err_log");

$filesize = -s "$patch_err_log";

if($filesize > 0)
{
	print "SVN error occured, please check the $patch_err_log file\n";
	exit;
}

$filesize = -s "$patch_file";

if($filesize == 0)
{
	print "Patch file is empty, local working copy do not have any changes with SVN repository\n";
}
else
{
	print "$patch_file Generated at $input path\n";
}


# ************************************ Functions *************************************

sub check_conflicts
{
	$status = system("svn status -u --username $username --password $password > $status_log 2> $error_log");

	$filesize = -s "$error_log";

	if($filesize > 0)
	{
		print "SVN error occured, please check the $error_log file\n";
		exit;
	}

	my $file = $status_log;
	open(my $RD, "< $file") || die("Can't open file: $file");
	my @lines = <$RD>;
	close($RD);

	$detected = 0;

	$length = @lines;

	foreach $line (@lines)
	{
		chomp($line);

		$b = unpack("x8 A1", $line);
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

	print "\n";
	if($detected == 0)
	{
		print "No conflicts occured against svn repository\n";

		open($AD, "> $add_information_log") || die("Can't open file: $file");

		foreach $line (@lines)
		{
			chomp($line);

			$b = unpack("x0 A1", $line);
			if($b eq 'M')
			{
				$data = unpack("x21 A*", $line);
				print "Modified\t$data\n";
			}
			elsif($b eq 'A')
			{
				$data = unpack("x21 A*", $line);
				chomp($data);
				if(-d "$data")
				{
					print $AD "$data:\tFolderAdded\n";
				}
				elsif(-e "$data")
				{
					print $AD "$data:\tFileAdded\n";
				}
				$add_flag=1;

				print "Added\t$data\n";
			}
			elsif($b eq 'D')
			{
				$data = unpack("x21 A*", $line);
				chomp($data);
				print "\n$data will be deleted from SVN, are you sure you want to delete(yes/no):\n";
AGAIN:
				$accept=<>;
				chomp($accept);
				if($accept eq "yes")
				{

					print $AD "$data:\tDeleted\n";

					$del_flag=1;

					print "Deleted\t$data\n";
				}
				elsif($accept eq "no")
				{
					print "\n Please check the deleted item. Exiting.... \n";
					exit(0);
				}
				else
				{
					print "\n given wrong option. \n";
					goto AGAIN;
				}
			}
			elsif($b eq '?')
			{
				$data = unpack("x21 A*", $line);
				print "File is not under version control\t$data\n";
			}
			elsif($b eq '!')
			{
				$data = unpack("x21 A*", $line);
				print "File is incomplete\t$data\n";
			}
			elsif($b eq 'C')
			{
				$data = unpack("x21 A*", $line);
				print "Conflicted\t$data\n";
			}
			elsif($b eq 'X')
			{
				$data = unpack("x21 A*", $line);
				print "File is from another repository $data\n";
			}

		}
		close($AD);
	}

}

sub check_path
{
	$flag=0;

	$status = system("svn info --username $username --password $password > $status_log 2> $error_log");
	$filesize = -s "$error_log";

	if($filesize > 0)
	{
		print "SVN error occured, please check the $error_log file\n";
		exit;
	}

	my $file = $status_log;
	open(my $RD, "< $file") || die("Can't open file: $file");
	my @lines = <$RD>;
	close($RD);

	my $file = "$repository_url_log";
	open(my $FHL, ">$file") || die("Can't open file: $file");

	$length = @lines;

	foreach $line (@lines)
	{
		chomp($line);
		if($line =~/URL:\s(.+)/)
		{
			$str=$1;
			print $FHL "$str\n";
			
			@elements = split("/",$str);
			$list_size = @elements;
			$ele = $elements[$list_size-1];

			$patch_file = "$ele.patch";
			$flag=1;
			last;
		}
	}
	
	close($FHL);
	return $flag;
}

