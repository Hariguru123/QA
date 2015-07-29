#!/usr/bin/perl
#*************************************************************************************************\
# 
#   File Name  :   Create_Patch.pl
#    
#   Description:  This file is taking Path of the local folder where the user needs patch creation.
#		  Asks user to enter the Patch file name amongst the three code bases.
#		  Reads the Patch file name and creates the SVN Patch on given local folder path.
#		  User can submitt this created patch file to the build request process.
#   	
# ************************************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

$username = $ENV{'USER'};

$log_folder="/home/$username/Desktop";


#Accepting user input to enter local folder path
print "\nEnter the local source code path, where you want to create a patch:";
$input=<>;
chomp($input);

chdir ($input) or die "can not change directory, Please enter correct path";

print "\n\nplease do the svn add --force * command before the svn patch creation, if you need to add new files recursively in local copy\n";
print "\nplease do the svn delete command before the svn patch creation, if you need to delete any files or folders in local copy\n\n";

print "Enter 'yes' if you had done svn add or del properly for the required files on the local source path, other wise enter 'no':";
$input1=<>;
chomp($input1);
if($input1 eq "yes")
{
	goto START;
}
else
{
	print "Exiting...\n";
	exit;
}

#Reads user input to enter the patch file name.
START:
print "DhanushAON.patch\t for creating DhanushAON source code\n";
print "Native.patch\t for creating Dhanush Native source code\n";
print "Dhanush-Android.patch\t for creating Dhanush Android source code\n";
print "\nEnter the patch name from the above mentioned names based on your source code:\t";
$patch_file=<>;
chomp($patch_file);

#Patch file name verification.
if($patch_file eq "DhanushAON.patch")
{
	print "\n*********** DhanushAON **********\n";
}
elsif($patch_file eq "Native.patch")
{
	print "\n*********** Native ***********\n";
}
elsif($patch_file eq "Dhanush-Android.patch")
{
	print "\n*********** Dhanush Android ***********\n";
}
else
{
	print "\nPatch name should be given from the below mentioned names\n";
	goto START;
}

#Declaration of add files information log
$patch_err_log = "$log_folder/patch_err.log";

#Declaration of conflicts status
$status_log = "$log_folder/status.log";
$error_log = "$log_folder/error.log";

#Declaration of sizes for add and delete
$size_log = "$input/add_information.log";
$size_error_log = "$log_folder/size_err.log";

#flags for addition and deletion
$add_flag=0;
$del_flag=0;

$var = 0;


#Verifying the local folder path, as entered path is amongst three code bases.
$val = check_path();
if($val == 0)
{
	print "Please enter the proper local source path amongst three code bases..Exiting..\n";
	exit;
}

#$status = system("svn add --force * 2> $patch_err_log");

#$filesize = -s $patch_err_log;
#if($filesize > 0)
#{
#	print "SVN error occured, please check the $patch_err_log file\n";
#	exit;
#}

#Checking conflicts with SVN latest revision and also give the add/del files information
check_conflicts();

#If no additions or deletions done in the code write 0 in to size_log
if(($add_flag==0) && ($del_flag==0))
{
	$st = system("echo $var > $size_log 2> $size_error_log");	
}

print "Please make sure and review that all the files listed in the $status_log are going to be patched.\n";

# Patch creation using svn diff command.
$status = system("svn diff > $patch_file 2> $patch_err_log");

$filesize = -s $patch_err_log;

if($filesize > 0)
{
	print "SVN error occured, please check the $patch_err_log file\n";
	exit;
}

$filesize = -s $patch_file;

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
	$status = system("svn status -u > $status_log 2> $error_log");

	$filesize = -s $error_log;

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
		print "No conflicts occured\n";

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
				if($written==0)
				{
					my $msg = `echo $data:`;
					my $msg1 = `stat -c %s $data`;
					chomp($msg);
					chomp($msg1);
					$txt = $msg.$msg1;
					$st = system("echo $txt > $size_log 2> $size_error_log");
					$written=1;
				}
				else
				{
					my $msg = `echo $data:`;
					my $msg1 = `stat -c %s $data`;
					chomp($msg);
					chomp($msg1);
					$txt = $msg.$msg1;
					$st = system("echo $txt >> $size_log 2> $size_error_log");
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

					if($written==0)
					{
						$st = system("echo Deleted $data > $size_log 2> $size_error_log");
						$written=1;
					}
					else
					{
						$st = system("echo Deleted $data >> $size_log 2> $size_error_log");
					}

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

	}

}

sub check_path
{

	$flag=0;
	$status = system("svn info > $status_log 2> $error_log");

	$filesize = -s $error_log;

	if($filesize > 0)
	{
		print "SVN error occured, please check the $error_log file\n";
		exit;
	}

	my $file = $status_log;
	open(my $RD, "< $file") || die("Can't open file: $file");
	my @lines = <$RD>;
	close($RD);

	$length = @lines;

	foreach $line (@lines)
	{
		chomp($line);
		if($line =~/URL:\s(.+)/)
		{
			$str=$1;
			@elements = split("/",$str);
			$list_size = @elements;
				print "$list_size\n";
				$ele = $elements[$list_size-1];
				print "$ele\n";
				if($ele eq "DhanushAON")
				{
					print "\nApplying Patch on Dhanush AON";
					$flag=1;
					last;
				}
				elsif($ele eq "Dhanush-Android")
				{
					print "\nApplying Patch on Dhanush-Android";
					$flag=1;
					last;
				}
				elsif($ele eq "Native")
				{
					print "\nApplying Patch on Dhanush Native";
					$flag=1;
					last;
				}
		}
	}
	return $flag;
}
