#!/usr/bin/perl
#*****************************************************************************************************************************************\
# 
#   File Name  :   MergeScript.pl
#    
#   Description:  It will take the inputs from the CGI script and start the merge process with the latest svn copy.Developer will receive a #		  mail if merge process is failed or patch file is empty and it will call the build script.
#   	
# ****************************************************************************************************************************************/
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

$code_base=$ARGV[0];
$dev_folder=$ARGV[1];
$patch_file=$ARGV[2];
$command_log=$ARGV[3];

#Declaration of PATCH and MERGE logs
$merge_log = "$code_base/$dev_folder/merge.log";
$status_log = "$code_base/$dev_folder/status_merge.log";
$patch_err_log = "$code_base/$dev_folder/patch_error.log";
$error_log = "$code_base/$dev_folder/status_error.log";

#Declaration of mail parameters
$from = "\"hgsnarayana.mavilla\@incubesol.com>\"";
$Dev_team = "\" hgsnarayana.mavilla\@incubesol.com\",\"Vinay Kumar <vinaykumar.medari\@incubesol.com>\"";
$build_team = "\" hgsnarayana.mavilla\@incubesol.com\",\"Vinay Kumar <vinaykumar.medari\@incubesol.com>\"";
our $blatCmd = "/home/testuser/blat.exe";
our $SMTP = "192.168.4.225";

#Declaration of checkout logs
$co_log  = "$code_base/$dev_folder/checkout.log";
$co_error_log = "$code_base/$dev_folder/co_error.log";
$repository_info = "$code_base/$dev_folder/repository_info.log";
$local_info = "$code_base/$dev_folder/local_info.log";
$change_log_tc = "$code_base/$dev_folder/changelog_toolchain.txt";
$change_log_src = "$code_base/$dev_folder/changelog_dhanush_aon.txt";
my $local_path="$code_base/$dev_folder";

#Declaration of repositories
$toolchain_repo_path= "http://192.168.24.194:9090/svn/swdepot/Dhanush/Tools/Native/toolchain";

if($patch_file eq "DhanushAON.patch")
{
	$sourcecode_repo_path="http://192.168.24.194:9090/svn/swdepot/Dhanush/SourceCode/DhanushAON";
	$local_path_sourcecode="$code_base/$dev_folder/DhanushAON";
	$message = "Dhanush AON Source";
	$name = "DhanushAON";
}
elsif($patch_file eq "Native.patch")
{
	$sourcecode_repo_path="http://192.168.24.194:9090/svn/swdepot/Dhanush/SourceCode/Native";
	$local_path_sourcecode="$code_base/$dev_folder/Native";
	$message = "Dhanush Native Source";
	$name = "Native";
}
elsif($patch_file eq "Dhanush-Android.patch")
{
	$sourcecode_repo_path="http://192.168.24.194:9090/svn/swdepot/Dhanush/SourceCode/Dhanush-Android";
	$local_path_sourcecode="$code_base/$dev_folder/Dhanush-Android";
	$local_path_sourcecode_kernel="$code_base/$dev_folder/Dhanush-Android/linux-mti-3.8.13";
	$local_path_sourcecode_android="$code_base/$dev_folder/Dhanush-Android/MipsGB2.3.5";
	$message = "Dhanush Android Source";
	$name = "Dhanush-Android";
}

#Declaration of tool chain path
$local_path_toolchaincode="/home/testuser/toolchain";
$toolchain_repo_path= "http://192.168.24.194:9090/svn/swdepot/Dhanush/Tools/Native/toolchain";

my $ER;
#SVN checkout
chdir("$code_base/$dev_folder") or die "can not change directory to $code_base\/$dev_folder, Please enter correct path";


#function to check the revision and check out, need to use from common tool chain folder in the build script
$message_tc = "tool chain";
checking_revision_and_checkout($local_path_toolchaincode, $toolchain_repo_path, $change_log_tc, $message_tc);

checking_revision_and_checkout_4_srccode($local_path_sourcecode, $sourcecode_repo_path, $change_log_src, $message);

chdir("$local_path_sourcecode") or die "can not change directory to $local_path_sourcecode, Please enter correct path";

check_conflicts();   # needed only at the first revision, other wise conflict state shows at every stage.

open($ER,">$merge_log") || die("$merge_log file can not be opened\n");

if(-e "$code_base/$dev_folder/$patch_file")
{
	$filesize = -s "$code_base/$dev_folder/$patch_file";

	if($filesize == 0)
	{
		print $ER "Patch file is empty, can not apply a patch\n";
		print $ER "merge failure\n";
		$body = "Hi Team, \n Failures observed, while applying the patch..\n Please find the attached merge log";
		patch_result($body);
		system("rm -rf $code_base/$dev_folder");
		exit;
	}
}

add_delete_files();

$status = system("patch -p0 < $code_base/$dev_folder/$patch_file > $patch_err_log");

$ret = check_conflict_on_patch($patch_err_log);

if($ret)
{
	print $ER "merge failure\n";
	$body = "Hi Team, \n Failures observed, while applying the patch..\n Please find the attached merge log";
	patch_result($body);
	system("rm -rf $code_base/$dev_folder");
	exit;
}
else
{
	print $ER "merge successful\n";
}

close($ER);

#call build script and update the last_mem that it is ready for commit and do the svn adds need full.
system("perl /usr/lib/cgi-bin/buildscript.pl $code_base $dev_folder $patch_file $command_log");

system("rm -rf $code_base/$dev_folder");

#sanity tests

#svn commit


#********************************************Functions********************************************
sub check_conflicts
{

	$status = system("svn status -u --username socqa --password Yo'\$8'lc9u > $status_log 2> $error_log");

	$filesize = -s $error_log;

	if($filesize > 0)
	{
		print $ER "SVN error occured, please check the $error_log file\n";
		exit;
	}

	my $file = $status_log;
	open(my $RD, "< $file") || die("Can't open file: $file");
	my @lines = <$RD>;
	close($RD);

	$written=0;
	$detected = 0;

	$length = @lines;

	for($a=0;$a<($length-1);$a++)
	{
		$line  = $lines[$a];

		chomp($line);

		$b = unpack("x8 A1", $line);
		if($b eq '*')
		{
			if($detected == 0)
			{
				print $ER "\nConflicted state occured, please update the code\n";
				print $ER "Below are the conflicted files \n\n";
				$detected = 1;
			}
			$data = unpack("x21 A*", $line);
			print "$data\n";
		}
	}

	print "\n";
	if($detected == 0)
	{
		#print "No conflicts occured against svn repository\n";

		for($a=0;$a<($length-1);$a++)
		{
			$line  = $lines[$a];

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
				print "Added\t$data\n";
			}
			elsif($b eq 'D')
			{
				$data = unpack("x21 A*", $line);
				print "Deleted\t$data\n";
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

sub add_delete_files
{

	my $file = "$code_base/$dev_folder/$command_log";
	open(my $RD, "< $file") || die("Can't open file: $file");
	my @lines = <$RD>;
	close($RD);

	$length = @lines;

	foreach $a (@lines)
	{
		chomp($a);

		if($a =~/(.+):(\d+)/)
		{
			$name = $1;
			
			if($2 == 4096)
			{
				if(-d "$name")
				{
					print "Directory $name exists\n";
				}
				else
				{
					push(@add_items, $name);
					system("mkdir $name");
					print "Added\t$name\n";
				}
			}
			elsif($2 == 0)
			{
				if(-e "$name")
				{
					print "File $name exists\n";
				}
				else
				{
					push(@add_items, $name);
					system("touch $name");
					print "Added\t$name\n";
				}
			}
		}
		elsif($a =~/Deleted (.+)/)
		{
			$name = $1;

			if(-d "$name")
			{
				push(@del_items, $name);
				system("rm -rf $name");
				print "Deleted\t$name\n";
			}
			elsif(-e "$name")
			{
				push(@del_items, $name);
				system("rm -rf $name");
				print "Deleted\t$name\n";
			}
			else
			{
				print "$name already deleted\n";
			}
		}
	}
}


sub check_conflict_on_patch
{

$re = 0;
#Hunk #1 FAILED at 1.
#1 out of 1 hunk FAILED -- saving rejects to file file2.txt.rej

	$file = $_[0];

	open(my $FH, "< $file") || die("Can't open file: $file");
	my @lines = <$FH>;
	close($FH);

	foreach $line (@lines)
	{
		if($line =~/^Hunk \#\d+ FAILED at \d+./)
		{
			print $ER "\n Conflicts occured while applying patch(merging).\n";
			print $ER "\n Sending mail and attachment with a new patch file generated on server\n";
			$re = 1;
			last;
		}
		elsif($line =~/^\d+ out of \d+ hunk \w+ -- saving rejects to /)
		{
			print $ER "\n Conflicts occured while applying patch(merging).\n";
			print $ER "\n Sending mail and attachment with a new patch file generated on server\n";
			$re = 1;
			last;
		}
	}
	return $re;
}


sub sendMail
{
    my $body= shift @_;
             
    # Sending mail...
    $blatCmd .= " - @_";
    open(MAIL, "| $blatCmd") || die "Can't open file: $!";
    print MAIL $body;
    print "Mail sent to the team\n";
    close(MAIL);
    
}
sub checking_revision_and_checkout
{
	$local_code_path = $_[0];
	$repository_code_path = $_[1];
	$change_log = $_[2];
	$text = $_[3];

	#Checking the code 
	if(-d "$local_code_path")
	{
		print "\nFinding Out revision numbers of $text ... \n";
		system("svn info $repository_code_path --username socqa --password Yo'\$8'lc9u > $repository_info");
		system("svn info $local_code_path --username socqa --password Yo'\$8'lc9u > $local_info");

		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		if($repo > $local)
		{
			print"Check out needed as Working copy is older than Repository revision\n\n";
			chdir($local_code_path);

			#Generating Change log from previous revision
			system("svn diff --username socqa --password Yo'\$8'lc9u -r $local:$repo > $change_log");

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
		system("svn checkout $repository_code_path --username socqa --password Yo'\$8'lc9u 2>&1 > $co_log | tee $co_error_log");

		$body = "Hi Team, \n    Failures observed, while checking out the $text code\n Please find the attachment\n\n This is an Automatically generated email notification";

		checkout($body);
	}

}

sub checking_revision_and_checkout_4_srccode
{
	$local_code_path = $_[0];
	$repository_code_path = $_[1];
	$change_log = $_[2];
	$text = $_[3];
	
	#Checking the code 
	if(-d "$local_code_path")
	{
		print "\nFinding Out revision numbers of $text ... \n";
		system("svn info $repository_code_path --username socqa --password Yo'\$8'lc9u > $repository_info");
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
	system("svn checkout $repository_code_path --username socqa --password Yo'\$8'lc9u 2>&1 > $co_log | tee $co_error_log");

	$body = "Hi Team, \n    Failures observed, while checking out the $text code\n Please find the attachment\n\n This is an Automatically generated email notification";

	checkout($body);

}


sub checkout
{
	$result=checkoutfailed($co_log,$co_error_log);
	if($result!=1)
	{
		chdir($local_path);
		print "Checkout failed and sending the mail to build team\n";
		my %data = (
		-f        => $from,
		-to       => $build_team,
		-subject  => "\"checkout failed\"",
		-server   => $SMTP,
	       -debug    => " ",
	       -attacht  => "co_error.log"
	   );
	   $body = $_[0];
	   sendMail($body,%data);
	   exit;
	}

}

sub checkoutfailed
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

sub patch_result
{
	chdir("$code_base/$dev_folder");

	my %data = (
        -f        => $from,
        -to       => $Dev_team,
        -subject  => "\"Patch merge Failed\"",
        -server   => $SMTP,
       -debug    => " ",
        -log      => "blat.log",
	-attacht => "merge.log"
   );

   $body = $_[0];

   sendMail($body, %data);

}

