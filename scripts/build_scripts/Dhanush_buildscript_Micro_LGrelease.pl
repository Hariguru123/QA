#!/usr/bin/perl
#********************************************************************************************************************************
# 
#   File Name  :   Dhanush_buildscript_Micro_LGrelease.pl
#    
#   Description:  It will build the corresponding code based on the arguments received.
#	  
# #********************************************************************************************************************************

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use MIME::Lite;

$num_args = @ARGV;

if($num_args < 4)
{ 
	print "Usage: perl Dhanush_buildscript_Micro_LGrelease.pl <1> <Daily/Release> <Trunk/Branch Repository name> <local path(Folder name where trunk or release codes will check out)>\n";
	die("Number of arguments are less\n");
}


$input=$ARGV[0];

if($input eq 1)
{
	print "Building DhanushAON Micro, DhanushNative Micro, DhanushBootLoader, DhanushUI Micro Projects.....";
	$build = "All";
}
else
{
	print "Please Pass the argument (1)\n";
	exit;
}

#To Identify the repository is a trunk or branch

$repos_name = $ARGV[2];
@temp = split("\/","$repos_name");

$repo_s=join("\/",@temp);
$sz = @temp;
$lst = $temp[$sz-1];

if($lst eq "Micro-trunk")
{
	print "\nBuild will triggers under trunk..\n";
}
else
{
	print "\nBuild will triggers under release branch..\n";
}


#Declaration of local path
$username="socplatform-qa";
$local_path="$ARGV[3]";

if(!(-d "$local_path"))
{
	system("mkdir -p $local_path");
}

if($ARGV[1] eq "Daily")
{
	$subject = "Daily";
}
elsif($ARGV[1] eq "Release")
{
	if($lst eq "Micro-trunk")
	{
		$subject = "Weekly";
	}
	else
	{
		$subject = "Release";
	}

#To continue release numbers reading release number from local file
#	open(my $RF, "</home/$username/release_micro.txt") || die("Can't open file: /home/$username/release_micro.txt");
#	@txt = <$RF>;

#	$txt_read = $txt[0];
#	chomp($txt_read);

#	$rel_number = $txt_read;
#	$sub_rel = "00.91.$rel_number";
#	close($RF);
#	$buildnumber="00.91.$rel_number";
}
else
{
	print "Please pass the proper second argument<Daily (or) Release>\n";
	exit;
}

$repository_name = $ARGV[2];

$toolchain_mips_path="/home/$username/mips-2013.11";


#Declaration of Date and Time
currentdate();
my $currentDate = "$year\-$mon\-$mday";
my $currentTime = "$hr\-$min\-$sec";


if($ARGV[1] eq "Daily")
{
	$dst_images_dir = "/home/$username/share/Micro_LG_Builds/Daily_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Micro_LG_Builds/Daily_images/$currentDate";
}
elsif($ARGV[1] eq "Release")
{
	$dst_images_dir = "/home/$username/share/Micro_LG_Builds/Release_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Micro_LG_Builds/Release_images/$currentDate";
	#$buildnumber="$buildnumber\_$currentDate";
	$buildnumber = "";
	$sub_rel = "$currentTime";
}

#Declaration of logs
$co_log  = "$local_path/checkout.log";
$co_error_log = "$local_path/co_error.log";
$repository_info = "$local_path/repository_info.log";
$local_info = "$local_path/local_info.log";

#Declaration of mail Configuration path
$mail_path="$local_path/mail.txt";

$mail_str="No check-ins are happened after last build";
$checkins = 0;

#Declaration of mail parameters
$from = 'Build_Server <socplatform-qa@inedasystems.com>';
#$from = 'Build_Server <hgsnarayana.mavilla@incubesol.com>';
#$from = 'Vinay <vinaykumar.medari@incubesol.com>';

$Dev_team = 'Dhanush-SW <dhanush-sw@inedasystems.com>';
#$Dev_team = 'nagoorsaheb.inaganti@incubesol.com';
#$Dev_team = 'Dev team <hgsnarayana.mavilla@incubesol.com>';
#$Dev_team = 'Vinay <vinaykumar.medari@incubesol.com>';

#$build_team = 'dhanush-swqa <dhanush-swqa@inedasystems.com>';
#$build_team = 'nagoorsaheb.inaganti@incubesol.com';
#$build_team = 'QA team <hgsnarayana.mavilla@incubesol.com>';
#$build_team = 'Vinay <vinaykumar.medari@incubesol.com>';


if($build eq "All")
{

	#Declaration of repositories
	$sourcecode_repo_path="$repository_name/DHANUSH_M_LR_Internal";

	#Declaration of local path
	$dhanushcode_path="$local_path/DHANUSH_M_LR_Internal";
	$change_log_src = "$local_path/changelog_DHANUSH_M_LR_Internal.txt";
	$toolchain_path = "$local_path/DHANUSH_M_LR_Internal/Tools/toolchain";

	#declaration of destination directories
	$dst_reports_log_dir_code="/home/$username/share/Micro_LG_error_logs/DHANUSH_M_LR_Internal/$currentDate/$currentTime";
	$dst_reports_log_dir_code1="//192.168.42.46/share/Micro_LG_error_logs/DHANUSH_M_LR_Internal/$currentDate/$currentTime";

	$message = "Dhanush code";
	$rtn = checking_revision_and_checkout_4_srccode($dhanushcode_path, $sourcecode_repo_path, $change_log_src, $message, $local_path);
	
	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$aon_msg = "\n\n\nLG-release:\nDHANUSH_M_LR_Internal Check Out Failed, mail has been send previously on checkout failed and can not continue DHANUSH_M_LR_Internal build.";
			exit;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	dircopy("$toolchain_mips_path", "$toolchain_path/mips-2013.11") || die("can not copy directory");

	system("chmod -R 777 $dhanushcode_path/*");

	print "*****************DHANUSH_M_LR_Internal BUILD PROCESS****************************\n";

	chdir($dhanushcode_path);

	fcopy("$dhanushcode_path/Tools/Utilities/elf2bin64", "$dhanushcode_path/Tools/Utilities/elf2bin");

	#Build the LG release Project
	$status = system("make clean > clobberlog.txt 2> faillog.txt; make > buildlog.txt 2>> faillog.txt");

	if ($status) 
	{
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
		$repo_print = read_last_revision($repository_info);

		system("mkdir -p $dst_reports_log_dir_code");
		fcopy("faillog.txt", $dst_reports_log_dir_code);
		fcopy("buildlog.txt", $dst_reports_log_dir_code);

		if($return_value=mailstatus("Buildfail"))
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Dhanush Micro LG-release Build Failed";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Dhanush Micro LG-release Build Failed";
			}
	
			if($build eq "All")
			{
				$aon_msg = "\n\n\nLG-release:\nLG-release Build Failed, mFailures observed while building the dhanush micro LG release branch code for the svn check-in at $sourcecode_repo_path with revision:$repo_print.\nPlease find the build log in the share path:\"$dst_reports_log_dir_code1\".";
			}
		}	
	}
	else
	{
		print "LG-release Build completed successfully \n";
		
		$repo_print = read_last_revision($repository_info);

		#update the destination folder after successfull build

		if(($subject eq "Weekly") || ($subject eq "Release"))
		{		
			$dst_reports_dir_code="/home/$username/share/Micro_LG_Builds/Release_Builds/$buildnumber/$currentTime/LGrelease_$repo_print";
			$dst_reports_dir_code1="//192.168.42.46/share/Micro_LG_Builds/Release_Builds/$buildnumber/$currentTime/LGrelease_$repo_print";
		}
		elsif($subject eq "Daily")
		{
			$dst_reports_dir_code="/home/$username/share/Micro_LG_Builds/Daily_Builds/$currentDate/$currentTime/LGrelease_$repo_print";
			$dst_reports_dir_code1="//192.168.42.46/share/Micro_LG_Builds/Daily_Builds/$currentDate/$currentTime/LGrelease_$repo_print";
		}
			
		# Create share location
		system("mkdir -p $dst_reports_dir_code");

		#copy the output files to destination location
		dircopy("$dhanushcode_path/Output", $dst_reports_dir_code);

		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			#creating share location for images
			system("mkdir -p $dst_images_dir/$sub_rel");

			fcopy("$dhanushcode_path/Output/aonsram.bin", "$dst_images_dir/$sub_rel");

			fcopy("$dhanushcode_path/Output/aontcm.bin", "$dst_images_dir/$sub_rel");

			fcopy("$dhanushcode_path/Output/d_native.bin", "$dst_images_dir/$sub_rel");

			fcopy("$dhanushcode_path/Output/bl1.bin", "$dst_images_dir/$sub_rel");

			fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/d_bl0.bin", "$dst_images_dir/$sub_rel");

			fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/d_ui.bin", "$dst_images_dir/$sub_rel");

			fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/recovery.bin", "$dst_images_dir/$sub_rel");
		}
		elsif($subject eq "Daily")
		{
			#creating share location for images
			system("mkdir -p $dst_images_dir/$currentTime");

			fcopy("$dhanushcode_path/Output/aonsram.bin", "$dst_images_dir/$currentTime");

			fcopy("$dhanushcode_path/Output/aontcm.bin", "$dst_images_dir/$currentTime");

			fcopy("$dhanushcode_path/Output/d_native.bin", "$dst_images_dir/$currentTime");

			fcopy("$dhanushcode_path/Output/bl1.bin", "$dst_images_dir/$currentTime");

			fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/d_bl0.bin", "$dst_images_dir/$currentTime");

			fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/d_ui.bin", "$dst_images_dir/$currentTime");

			fcopy("$dhanushcode_path/Tools/Utilities/SPI_Utility/recovery.bin", "$dst_images_dir/$currentTime");
		}

		print "LGrelease output files copied to $dst_reports_dir_code \n";

		$body = "Hi Team,\n\n\nDhanush Micro LG-release Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print. \nPlease find the output binaries in the share path: \"$dst_reports_dir_code1\".\n\n\n\n****This is an Automatically generated email notification from Build server****";

		if($return_value=mailstatus("Buildpass"))
		{	
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Dhanush Micro LG-release Build";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Dhanush Micro LG-release Build";
			}

			if($build ne "All")
			{
				sendMail($Dev_team, $subject1, $body, "");
			}
			if($build eq "All")
			{
				$aon_msg = "\n\n\nLG-release:\nDhanush Micro LG-release Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print. \nPlease find the output binaries in the share path: \"$dst_reports_dir_code1\".";
			}
		}
	}
}#End of IF loop

if($build eq "All")
{

	print "Dhanush Micro binaries are copied to $dst_images_dir \n";

	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		$img_body="\n\n$subject Image copied to $dst_images_dir1.";
	}
	elsif($subject eq "Daily")
	{
		$img_body="\n\nDaily Image copied to $dst_images_dir1.";
	}

	$start_body = "Hi Team,";
	$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";

	$body = "$start_body$img_body$aon_msg$end_body";

	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		$subject1 = "Dhanush Micro LG $subject Builds";
	}
	elsif($subject eq "Daily")
	{
		$subject1 = "Dhanush Micro LG $subject Builds";
	}

	sendMail($Dev_team, $subject1, $body, "");
}

if(($subject eq "Weekly") || ($subject eq "Release"))
{
	#To continue release numbers reading release number from local file
	open(my $RF, ">/home/$username/release_micro.txt") || die("Can't open file: /home/$username/release_micro.txt");

	$rel_number = $rel_number+1;
	if($rel_number < 10)
	{
		print $RF "00$rel_number";
	}
	elsif($rel_number < 100)
	{
		print $RF "0$rel_number";
	}
	else
	{
		print $RF "$rel_number";
	}
	close($RF);
}

#*****************************************Functions****************************************************************************
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
my $subject=$_[1];
my $message=$_[2];
my $attachPath=$_[3];

 $msg = MIME::Lite->new(
                 From     => $from,
                 To       => $to,
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

sub checking_revision_and_checkout
{
	$local_code_path = $_[0];
	$repository_code_path = $_[1];
	$change_log = $_[2];
	$text = $_[3];
	$chk_out_path = $_[4];

	print "\nFinding Out revision numbers of $text ... \n";
	system("svn info $repository_code_path --username socqa --password Yo'\$8'lc9u > $repository_info");

	#Checking the code 
	if(-d "$local_code_path")
	{
		system("svn info $local_code_path --username socqa --password Yo'\$8'lc9u > $local_info");
		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		if($repo > $local)
		{
			print"Check out needed as Working copy is older than Repository revision\n";
			chdir($local_code_path);

			#Generating Change log from previous revision
			system("svn diff -r $local:$repo --username socqa --password Yo'\$8'lc9u > $change_log");

			print "Update $text from SVN... \n";
			system("svn revert -R $local_code_path --username socqa --password Yo'\$8'lc9u");

			system("svn update $local_code_path --username socqa --password Yo'\$8'lc9u > $co_log 2> $co_error_log");

			$body = "Hi Team, \n    Failures observed, while updating the $text code\n Please find the attachment\n\n This is an Automatically generated email notification";

			$rt = checkout($body);
			print "Updated successfully ... \n";
		}
		else
		{
			print "Working copy is same as Repository revision\n";
			print "No need to update source code... \n\n";
		}
	}
	else
	{
		print "Checkout the $text from SVN... \n";
		chdir($chk_out_path);
		system("svn checkout $repository_code_path --username socqa --password Yo'\$8'lc9u > $co_log 2> $co_error_log");

		$body = "Hi Team, \n    Failures observed, while checking out the $text code\n Please find the attachment\n\n This is an Automatically generated email notification";

		$rt = checkout($body);
	}
	return $rt;
}

sub checking_revision_and_checkout_4_srccode
{
	$local_code_path = $_[0];
	$repository_code_path = $_[1];
	$change_log = $_[2];
	$text = $_[3];
	$chk_out_path = $_[4];
	
	print "\nFinding Out revision numbers of $text ... \n";
	system("svn info $repository_code_path --username socqa --password Yo'\$8'lc9u > $repository_info");

	#Checking the code 
	if(-d "$local_code_path")
	{
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
	chdir($chk_out_path);
	system("svn checkout $repository_code_path --username socqa --password Yo'\$8'lc9u > $co_log 2> $co_error_log");

	$body = "Hi Team, \n    Failures observed, while checking out the $text code\n Please find the attachment\n\n This is an Automatically generated email notification";

	$rt = checkout($body);

	return $rt;
}

sub checkout
{
	$result=checkoutfailed($co_log,$co_error_log);
	if($result!=1)
	{
		#chdir($local_path);
		print "Checkout failed and sending the mail to build team\n";

	   	sendMail($Dev_team, 'checkout failed', $_[0], $co_error_log);

		return 2;	#error failed to check out
	}
	else
	{
		return 0;
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


sub check_info
{
	$te = $_[0];
	$te_err = $_[1];

	$result = info_failed($te, $te_err);
	if($result!=1)
	{
		$body = "Hi Team,\n\nCheckout failed and sending mail, please find the attachment";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";
		$body="$body$end_body";

	   	sendMail($Dev_team, 'checkout failed', $body, $co_error_log);

		return 2;	#error failed to check out
	}
	else
	{
		return 0;
	}
}

sub info_failed
{
	my $checkoutfile = $_[0];
	open(my $RD, "< $checkoutfile") || die("Can't open file: $file");
	my @lines = <$RD>;
	close($RD);
	$checkedout=0;

	foreach my $line (@lines)
	{
		chomp($line);
		if($line =~/Last Changed Rev: (\d+)/)
		{
			$revision = $1;
			$checkedout=1;
			last;
		}
	}

	if($checkedout!=1)
	{
		my $errorfile = $_[1];
		open(my $RD1, "< $errorfile") || die("Can't open file: $file");
		my @lines1 = <$RD1>;
		close($RD1);
		$error=0;

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
			print "could not get repository info\n";
		}	
		return 0;
	} 
	else
	{
		return 1;
	}
}

sub mailstatus
{
	
	$mail_string=$_[0];
	if(open(FH,"< $mail_path"))
	{
		foreach $line(<FH>)
		{	
			if($line =~ /$mail_string ON/i)
			{
				$value=1;
				last;
			}
			elsif($line =~ /$mail_string OFF/i)
			{
				$value=0;
				last;
			}
			else
			{
				$value=1;
			}			
		
		}
	}
	else
	{
		open(FH,"> $local_path/mail_log.txt");
		print FH "file is not in present in that location\n";		
		$value=1;
	}

	return $value;
}

