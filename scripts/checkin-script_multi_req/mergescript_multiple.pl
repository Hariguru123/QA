#!/usr/bin/perl
#*****************************************************************************************************************************************\
# 
#   File Name  :   mergescript_multiple.pl
#    
#   Description:  It will take the inputs from the CGI script and start the merge process with the latest svn copy.Developer will 
#		  receive a mail if merge process is failed or patch file is empty and it will call the build script.
#   	
# ****************************************************************************************************************************************/
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use MIME::Lite;

$server_path=$ARGV[0];
$dev_folder=$ARGV[1];
$patch_file=$ARGV[2];
$command_log=$ARGV[3];
$repository_log=$ARGV[4];
$androidbuild=$ARGV[5];
$again=$ARGV[6];
$build_team=$ARGV[7];

$name="$patch_file";

$codebase_devfolder="$server_path/$dev_folder";

#Declaration of PATCH and MERGE logs
$merge_log = "$codebase_devfolder/merge.log";
$status_log = "$codebase_devfolder/status_merge.log";
$patch_err_log = "$codebase_devfolder/patch_error.log";
$error_log = "$codebase_devfolder/status_error.log";
$temp_log = "$codebase_devfolder/temp.log";

$local_android_path="/media/Data/Android";

$var = "trunk";
$fileexist1 = "$local_android_path/$var"."1";
$fileexist2 = "$local_android_path/$var"."2";
$fileexist3 = "$local_android_path/$var"."3";
$fileexist4 = "$local_android_path/$var"."4";
$fileexist5 = "$local_android_path/$var"."5";

$android_update_path= "$fileexist5";

open(FH,"< $codebase_devfolder/details.log") || die("$codebase_devfolder/details.log file can not be opened in merge script\n");

foreach $line(<FH>)
{
	if($line =~ /^BugID:(\d+)\n$/)
	{
		 $bugid=$1;
	}	
	if($line =~ /^Code_Review ID:(\d+)/)
	{
		 $crnum=$1;
	}	
	if($line =~ /^username:(.+)\n$/)
	{
		 $username=$1;
	}
	if($line =~ /^password:(.+)/)
	{
		 $password=$1;
	}
}
close(FH);

$password =~ s/\$/\"\\\$\"/g;

$mail_details="Your Check-in request details:\n
Bug: $bugid
Code base: $name
Code Review ID: $crnum\n";

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

		if($username eq "$new_list[0]")
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
$from = 'Build_Server <socplatform-qa@inedasystems.com>';

#$Dev_team = 'Dhanush-SW <dhanush-sw@inedasystems.com>';
#$Dev_team = 'Vinay Kumar <vinaykumar.medari@incubesol.com>';
#$Dev_team = 'Build_Server <socplatform-qa@inedasystems.com>';
$Dev_team = $mail_id;

#$build_team = 'dhanush-swqa <dhanush-swqa@inedasystems.com>';
#$build_team = 'Vinay Kumar <vinaykumar.medari@incubesol.com>';
#$build_team = 'Build_Server <socplatform-qa@inedasystems.com>';

$local_path = "/media/Data/trunk_wc";

#Declaration of checkout logs
$co_log  = "$codebase_devfolder/checkout.log";
$co_error_log = "$codebase_devfolder/co_error.log";
$repository_info = "$codebase_devfolder/repository_info.log";
$local_info = "$codebase_devfolder/local_info.log";
$change_log_tc = "$codebase_devfolder/changelog_toolchain.txt";
$change_log_src = "$codebase_devfolder/changelog_dhanushcode.txt";

#Declaration of repositories
$scripts_repo_path="http://insvn01:9090/svn/swdepot/Dhanush/SW/Adv-trunk/Scripts";
$android_scripts_repo_path="http://insvn01:9090/svn/swdepot/Dhanush/SW/Adv-trunk/Android";

$local_path_sourcecode="$codebase_devfolder/$patch_file";
$message = "$patch_file Source";

$patch_file = "$patch_file.patch";

$repos_log = "$codebase_devfolder/$repository_log";
open(FH_R,"< $repos_log");

@lines=<FH_R>;
chomp($lines[0]);

$sourcecode_repo_path=$lines[0];

close FH_R;

my $ER;
open($ER,">$merge_log") || die("\n$merge_log file can not be opened");

chdir($local_path)|| die("\ndirectory can not be changed");

$local_path_toolchaincode = "/home/socplatform-qa/toolchain/ubuntu64/bin";

#Check if it is already build for once

if($again eq "1")
{
	# Get Android update path
	if(-e "$server_path/$dev_folder/Android.txt")
	{
		open(FH5,"< $server_path/$dev_folder/Android.txt");
		@lines = <FH5>;
		close(FH5);

		$android_update_path = $lines[0];
		chomp($android_update_path);
	}
	goto apply_patch;
}

#function to check the revision and check out, need to use scripts folder in the build script
$message_tc = "Scripts";
$local_path_scriptscode = "$local_path/Scripts";
$checkout_path = "$local_path";

$rtn = checking_revision_and_checkout($local_path_scriptscode, $scripts_repo_path, $change_log_tc, $message_tc, $checkout_path);
if($rtn eq 2)
{
	print $ER "Scripts Checkout failed, can not checkout code and apply patch\n";
	print $ER "merge failure\n";
	goto FAIL;
}

system("chmod -R 777 $local_path_scriptscode/*");

print "Scripts CheckOut Completed Successfully\n";

#function to check the revision and check out, need to use scripts folder in the build script
$message_tc = "logo";
$local_path_scriptscode = "$local_path/resources";
$checkout_path = "$local_path";
$scripts_logo_path = "http://insvn01:9090/svn/swdepot/Dhanush/SW/Adv-trunk/Boot/resources";

$rtn = checking_revision_and_checkout($local_path_scriptscode, $scripts_logo_path, $change_log_tc, $message_tc, $checkout_path);
if($rtn eq 2)
{
	print $ER "Scripts Checkout failed, can not checkout code and apply patch\n";
	print $ER "merge failure\n";
	goto FAIL;
}

system("chmod -R 777 $local_path_scriptscode/*");

print "logo CheckOut Completed Successfully\n";

#SVN checkout

$message="$name";
if(($name eq "AndroidKK4.4.2") || ($name eq "android-linux-mti-unif-3.10.14") || ($name eq "SGX"))
{

	@temp = split("\/","$sourcecode_repo_path");

	pop(@temp);
	pop(@temp);
	$repo_s=join("\/",@temp);

	#To Identify the repository is a trunk or branch

	$sz = @temp;
	$lst = $temp[$sz-1];

	$android_scripts_repo_path="$repo_s/Android";

	#function to check the revision and check out, need to use scripts folder in the build script
	$message_tc = "Android Scripts";

	if($lst eq "Adv-trunk")
	{
		$local_path_scriptscode = "$local_path/Adv-trunk/Android";
		$checkout_path = "$local_path/Adv-trunk";
	}
	else
	{
		$local_path_scriptscode = "$local_path/release/Android";
		$checkout_path = "$local_path/release";

		$body = "Dear $username,\n\n\n$mail_details\nAt Present, Check-ins Other than Trunk are not allowed to perform(Branch check-ins are restricted).\n\n\n ****This is an Automatically generated email notification****";

		print $ER "Check-in failed\n";

		close($ER);

		sendMail($Dev_team, $build_team, "[$name] Restricted SVN check-ins other than Trunk", $body, "$codebase_devfolder/$patch_file", "$codebase_devfolder/$command_log", "$merge_log");

		exit;
	}

	$body = "Dear $username,\n\n\n$mail_details\nThe Check-in Request with your code changes submitted got SVN checkout failure errors, while checking out the $message_tc code.\n\nPlease resolve the checkout errors and submitt as a new check-in request.\n\n\n ****This is an Automatically generated email notification****";

	chdir($checkout_path)|| die("\ndirectory can not be changed");

	system("rm -rf $local_path_scriptscode");

	system("svn checkout --depth=files $android_scripts_repo_path --username socqa --password Yo'\$8'lc9u > $co_log 2> $co_error_log");

	$rtn = checkout($body);

	if($rtn eq 2)
	{
		print $ER "Android Scripts Checkout failed, can not checkout code and apply patch\n";
		print $ER "merge failure\n";
		goto FAIL;
	}

	system("chmod -R 777 $local_path_scriptscode/*");

	print "Android Scripts CheckOut Completed Successfully\n";

	$checkout_path="$codebase_devfolder";

	chdir("$codebase_devfolder") or die "can not change directory to $codebase_devfolder, Please enter correct path";

	chdir($checkout_path);

	$text = $message;

	$body = "Dear $username,\n\n\n$mail_details\nThe Check-in Request with your code changes submitted got SVN checkout failure errors, while checking out the $text code.\n\nPlease resolve the checkout errors and submitt as a new check-in request.\n\n\n ****This is an Automatically generated email notification****";

	if(!(-e "$fileexist1/lock.txt"))
	{
		open(LCK,">$fileexist1/lock.txt") || die("\n$fileexist1/lock.txt file can not be opened");
		print LCK "In trunk1..\n";
		close(LCK);
		$android_update_path = "$fileexist1";
	}
	elsif(!(-e "$fileexist2/lock.txt"))
	{
		open(LCK,">$fileexist2/lock.txt") || die("\n$fileexist2/lock.txt file can not be opened");
		print LCK "In trunk2..\n";
		close(LCK);
		$android_update_path = "$fileexist2";
	}
	elsif(!(-e "$fileexist3/lock.txt"))
	{
		open(LCK,">$fileexist3/lock.txt") || die("\n$fileexist3/lock.txt file can not be opened");
		print LCK "In trunk3..\n";
		close(LCK);
		$android_update_path = "$fileexist3";
	}
	elsif(!(-e "$fileexist4/lock.txt"))
	{
		open(LCK,">$fileexist4/lock.txt") || die("\n$fileexist4/lock.txt file can not be opened");
		print LCK "In trunk4..\n";
		close(LCK);
		$android_update_path = "$fileexist4";
	}
	elsif(!(-e "$fileexist5/lock.txt"))
	{
		open(LCK,">$fileexist5/lock.txt") || die("\n$fileexist5/lock.txt file can not be opened");
		print LCK "In trunk5..\n";
		close(LCK);
		$android_update_path = "$fileexist5";
	}
	else
	{
		$body = "Dear $username,\n\n\n$mail_details\nThe Check-in Request with your code changes can not be accepted, as build server is fully loaded with android builds.\n\nPlease wait for some time and submitt as a new check-in request.\n\n\n ****This is an Automatically generated email notification****";	

		print $ER "Check-in failed\n";

		sendMail($Dev_team, $build_team, "[$name] Build server is loaded fully with android builds", $body, "$codebase_devfolder/$patch_file", "$codebase_devfolder/$command_log", "$merge_log");

		goto FAIL;
	}

	system("svn checkout $repo_s/Android/android-linux-mti-unif-3.10.14 --username $username --password $password > $co_log 2> $co_error_log");

	$rtn = checkout($body);
	if($rtn eq 2)
	{
		print $ER "Checkout failed, can not checkout code and apply patch\n";
		print $ER "merge failure\n";
		goto FAIL;
	}

	system("svn info $repo_s/Android/AndroidKK4.4.2 --username socqa --password Yo'\$8'lc9u > repo_info.log 2> repo_info_err.log");
	$repo = read_last_revision("repo_info.log");

	system("svn info $android_update_path/AndroidKK4.4.2 --username socqa --password Yo'\$8'lc9u > local_info.log 2> local_info_err.log");
	$local = read_last_revision("local_info.log");

	if($repo > $local)
	{
		system("svn up $android_update_path/AndroidKK4.4.2 --username $username --password $password > $co_log 2> $co_error_log");
	}

	system("svn checkout $repo_s/Android/SGX --username $username --password $password > $co_log 2> $co_error_log");

	$rtn = checkout($body);
	if($rtn eq 2)
	{
		print $ER "Checkout failed, can not checkout code and apply patch\n";
		print $ER "merge failure\n";
		goto FAIL;
	}
}
else
{
	$checkout_path="$codebase_devfolder";

	#To Identify the repository is a trunk or branch
	@temp = split("\/","$sourcecode_repo_path");

	foreach $a (@temp)
	{
		if($a =~/Adv-trunk/)
		{
			$lst = "Adv-trunk";
			last;
		}
		elsif($a =~/Micro-trunk/)
		{
			$lst = "Micro-trunk";
			last;
		}
		elsif($a =~/Advanced/)
		{
			$lst = "Release";
			last;
		}
		elsif($a =~/InWatch_A0/)
		{
			$lst = "InWatch_A0";
			last;
		}
		elsif($a =~/LGEngDevBranch/)
		{
			$lst = "LGEngDevBranch";
			last;
		}
		else
		{
			$lst = "Others";
		}
	}
	
	if(($lst eq "Micro-trunk") || ($lst eq "InWatch_A0"))
	{
		chdir($checkout_path) || die("can not change directory\n");

		pop(@temp);
		$sourcecode_repo_path = join("\/",@temp);
		system("svn co $sourcecode_repo_path --username $username --password $password > $co_log 2> $co_error_log");
		$rtn = checkout($body);
		if($rtn eq 2)
		{
			print $ER "Checkout failed, can not checkout code and apply patch\n";
			print $ER "merge failure\n";
			goto FAIL;
		}

		$sz = @temp;
		$utrunk = $temp[$sz-1];
		
		fcopy("$codebase_devfolder/$patch_file", "$codebase_devfolder/$utrunk") || die("Can't copy file: $codebase_devfolder/$patch_file to $codebase_devfolder/$utrunk");

		fcopy("$codebase_devfolder/$command_log", "$codebase_devfolder/$utrunk") || die("Can't copy file: $codebase_devfolder/$command_log to $codebase_devfolder/$utrunk");

		$codebase_devfolder = "$codebase_devfolder/$utrunk";
		$local_path_sourcecode = "$codebase_devfolder/$name";
	}
	else
	{
		$rtn = checking_revision_and_checkout_4_srccode($local_path_sourcecode, $sourcecode_repo_path, $change_log_src, $message, $checkout_path);
		if($rtn eq 2)
		{
			print $ER "Checkout failed, can not checkout code and apply patch\n";
			print $ER "merge failure\n";
			goto FAIL;
		}
	}
}

apply_patch:

if($name eq "AndroidKK4.4.2")
{

	$body = "Dear $username,\n\n$mail_details\nThe Check-in Request with your code changes submitted got errors while applying patch and can not merge with the SVN.\n\nPlease resolve the errors and submitt the new patch to Build server for building the code changes of bug - $bugid.\n\n\n****This is an Automatically generated email notification from Build server****";

	chdir("$android_update_path/AndroidKK4.4.2");

	fcopy("$codebase_devfolder/$patch_file", $android_update_path) || die("Can't copy file: $codebase_devfolder/$patch_file to $android_update_path");

	fcopy("$codebase_devfolder/$command_log", $android_update_path) || die("Can't copy file: $codebase_devfolder/$command_log to $android_update_path");

	if(-e "$android_update_path/$patch_file")
	{
		$filesize = -s "$android_update_path/$patch_file";

		if($filesize == 0)
		{
			print $ER "Patch file is empty, can not apply a patch\n";
			print $ER "merge failure\n";
			goto FAIL;
		}
	}
	else
	{
		print $ER "$android_update_path/$patch_file does not exist, please check the patch file\n";
		print $ER "merge failure\n";
		goto FAIL;
	}

	#applying USER SVN patch
	$status = system("svn patch $android_update_path/$patch_file . > $status_log 2> $patch_err_log");

	$filesize = -s "$patch_err_log";

	if($filesize > 0)
	{
		print $ER "Error occured while applying SVN patch with $android_update_path/$patch_file, please check $patch_err_log\n";
		print $ER "merge failure\n";
		goto FAIL;
	}

	$body = "Dear $username,\n\n$mail_details\nThe Check-in Request with your code changes submitted got SVN Conflicts and can not merge with the SVN.\n\nPlease resolve the SVN conflicts and submitt the new patch to Build server for building the code changes of bug - $bugid.\n\n\n****This is an Automatically generated email notification from Build server****";

	$ret = check_conflict_on_patch($status_log);

	if($ret)
	{
		fcopy("$status_log","$patch_err_log") || die("\n$status_log can not be copied as $patch_err_log in merge script");
		print $ER "Error occured while applying SVN patch with $codebase_devfolder/$patch_file, please check the $patch_err_log file\n";
		print $ER "merge failure\n";
		goto FAIL;
	}
	if(-e "$android_update_path/$command_log")
	{
		add_delete_files("$android_update_path/$command_log");
		$filesize = -s "$patch_err_log";

		if($filesize > 0)
		{
			print $ER "Error occured while applying SVN patch with $android_update_path/$command_log, please check $patch_err_log\n";
			print $ER "merge failure\n";
			goto FAIL;
		}
	}
	else
	{
		print $ER "$android_update_path/$command_log does not exist, please check the patch file\n";
		print $ER "merge failure\n";
		goto FAIL;
	}

}
else
{

	$body = "Dear $username,\n\n$mail_details\nThe Check-in Request with your code changes submitted got errors while applying patch and can not merge with the SVN.\n\nPlease resolve the errors and submitt the new patch to Build server for building the code changes of bug - $bugid.\n\n\n****This is an Automatically generated email notification from Build server****";

	chdir("$local_path_sourcecode");

	if(-e "$codebase_devfolder/$patch_file")
	{
		$filesize = -s "$codebase_devfolder/$patch_file";

		if($filesize == 0)
		{
			print $ER "Patch file is empty, can not apply a patch\n";
			print $ER "merge failure\n";
			goto FAIL;
		}
	}
	else
	{
		print $ER "$codebase_devfolder/$patch_file does not exist, please check the patch file\n";
		print $ER "merge failure\n";
		goto FAIL;
	}

	#applying USER SVN patch
	$status = system("svn patch $codebase_devfolder/$patch_file . > $status_log 2> $patch_err_log");

	$filesize = -s "$patch_err_log";

	if($filesize > 0)
	{
		print $ER "Error occured while applying SVN patch with $codebase_devfolder/$patch_file, please check $patch_err_log\n";
		print $ER "merge failure\n";
		goto FAIL;
	}

	$body = "Dear $username,\n\n$mail_details\nThe Check-in Request with your code changes submitted got SVN Conflicts and can not merge with the SVN.\n\nPlease resolve the SVN conflicts and submitt the new patch to Build server for building the code changes of bug - $bugid.\n\n\n****This is an Automatically generated email notification from Build server****";

	$ret = check_conflict_on_patch($status_log);

	if($ret)
	{
		fcopy("$status_log","$patch_err_log") || die("\n$status_log can not be copied as $patch_err_log"); 
		print $ER "Error occured while applying SVN patch with $codebase_devfolder/$patch_file, please check the $patch_err_log file\n";
		print $ER "merge failure\n";
		goto FAIL;
	}
	if(-e "$codebase_devfolder/$command_log")
	{
		add_delete_files("$codebase_devfolder/$command_log");
		$filesize = -s "$patch_err_log";

		if($filesize > 0)
		{
			print $ER "Error occured while applying SVN patch with $codebase_devfolder/$command_log, please check $patch_err_log\n";
			print $ER "merge failure\n";
			goto FAIL;
		}
	}
	else
	{
		print $ER "$codebase_devfolder/$command_log does not exist, please check the patch file\n";
		print $ER "merge failure\n";
		goto FAIL;
	}
}

chdir("$local_path_sourcecode");

#Patch merged completed successfully

print $ER "merge successfull";
close($ER);

goto build;

FAIL:

close($ER);

if(($name eq "AndroidKK4.4.2") || ($name eq "android-linux-mti-unif-3.10.14") || ($name eq "SGX"))
{
	system("rm -rf $android_update_path/lock.txt");
}


if(!(-e "$patch_err_log"))
{
	sendMail($Dev_team, $build_team, "[$name] Patch Merge Failed with code changes of bug - $bugid", $body, "$codebase_devfolder/$patch_file", "$codebase_devfolder/$command_log", "$merge_log");
}
else
{
	sendMail($Dev_team, $build_team, "[$name] Patch Merge Failed with code changes of bug - $bugid", $body, "$codebase_devfolder/$patch_file", "$codebase_devfolder/$command_log", "$patch_err_log");
}

delete_folder();

exit;

build:

if($name eq "AONsensor")
{
	fcopy("$codebase_devfolder/$name/build/scripts/dhanushaon_env.sh","$codebase_devfolder/$name/dhanushaon_env_tmp.sh");
}
if($name eq "Native")
{
	fcopy("$codebase_devfolder/$name/build/scripts/native_env.sh","$codebase_devfolder/$name/native_env_tmp.sh");
}
if($name eq "android-linux-mti-unif-3.10.14")
{
	fcopy("$codebase_devfolder/$name/build.sh","$codebase_devfolder/$name/build_tmp.sh");
	fcopy("$codebase_devfolder/SGX/sgx.sh","$codebase_devfolder/SGX/sgx_tmp.sh");
}
if($name eq "SGX")
{
	fcopy("$codebase_devfolder/android-linux-mti-unif-3.10.14/build.sh","$codebase_devfolder/android-linux-mti-unif-3.10.14/build_tmp.sh");

	fcopy("$codebase_devfolder/$name/sgx.sh","$codebase_devfolder/$name/sgx_tmp.sh");
}
if($name eq "BL0")
{
	fcopy("$codebase_devfolder/$name/config/config.mk","$codebase_devfolder/$name/config_tmp.mk");
}
if($name eq "BL1_REV1")
{
	fcopy("$codebase_devfolder/$name/build_bl1.sh","$codebase_devfolder/$name/build_bl1_tmp.sh");
}
if($name eq "BL1")
{
	fcopy("$codebase_devfolder/$name/config/config.mk","$codebase_devfolder/$name/config_tmp.mk");
}
if($name eq "DFU_SDK_NAND")
{
	fcopy("$codebase_devfolder/$name/config/config.mk","$codebase_devfolder/$name/config_tmp.mk");
}
if($name eq "SPILoadUtility")
{
	fcopy("$codebase_devfolder/$name/config/config.mk","$codebase_devfolder/$name/config_tmp.mk");
}
if($name eq "U-Boot")
{
	fcopy("$codebase_devfolder/$name/build.sh","$codebase_devfolder/$name/build_tmp.sh");
}
if($name eq "AndroidKK4.4.2")
{
	fcopy("$codebase_devfolder/android-linux-mti-unif-3.10.14/build.sh","$codebase_devfolder/android-linux-mti-unif-3.10.14/build_tmp.sh");
	fcopy("$codebase_devfolder/SGX/sgx.sh","$codebase_devfolder/SGX/sgx_tmp.sh");
}

if($lst eq "InWatch_A0")
{
	#do nothing
}
elsif($lst eq "LGEngDevBranch")
{
	#do nothing
}
elsif($lst eq "Micro-trunk")
{
	chdir("$codebase_devfolder");

	system("perl /usr/lib/cgi-bin/Micro_buildscript.pl $server_path $dev_folder $name $utrunk $username '$password''$build_team'");
}
elsif($lst eq "Adv-trunk")
{
	system("perl /usr/lib/cgi-bin/buildscript.pl $server_path $dev_folder $name $lst $android_update_path $username '$password' $androidbuild '$build_team'");
}
else
{
	# do nothing
}

#********************************************Functions********************************************
sub check_conflicts
{

	$status = system("svn status -u --username $username --password $password > $status_log 2> $error_log");

	$filesize = -s "$error_log";

	if($filesize > 0)
	{
		print $ER "SVN error occured, please check the $error_log file\n";
		print $ER "merge failure\n";
		return 2;
	}

	my $file = $status_log;
	open(my $RD, "< $file") || die("Can't open file: $file in merge script(check_conflicts)");
	my @lines = <$RD>;
	close($RD);

	foreach $line (@lines)
	{
		chomp($line);

		$b = unpack("x0 A1", $line);
		if($b eq 'M')
		{
			$data = unpack("x21 A*", $line);
		}
		elsif($b eq 'A')
		{
			$data = unpack("x21 A*", $line);
		}
		elsif($b eq 'D')
		{
			$data = unpack("x21 A*", $line);
		}
		elsif($b eq '?')
		{
			$data = unpack("x21 A*", $line);
		}
		elsif($b eq '!')
		{
			$data = unpack("x21 A*", $line);
		}
		elsif($b eq 'C')
		{
			$data = unpack("x21 A*", $line);
		}
		elsif($b eq 'X')
		{
			$data = unpack("x21 A*", $line);
		}

	}
	return 0;
}

sub add_delete_files
{

	my $file = $_[0];
	open(my $RD, "< $file") || die("Can't open file: $file in merge script(add_delete_files)");
	my @lines = <$RD>;
	close($RD);

	$length = @lines;

	foreach $a (@lines)
	{
		chomp($a);

		if($a =~/(.+):\t(.+)/)
		{
			$name1 = $1;
			$frd = $2;
			
			if($frd eq "FolderAdded")
			{
				if(-d "$name1")
				{
					print "Directory $name1 already exists\n";
					system("svn add $name1 >> $status_log 2> $temp_log");
				}
				else
				{
					system("mkdir -p $name1");
					system("svn add $name1 >> $status_log 2> $patch_err_log");
				}
			}
			elsif($frd eq "FileAdded")
			{
				if(-e "$name1")
				{
					print "File $name1 already exists\n";
					system("svn add $name1 >> $status_log 2> $temp_log");
				}
				else
				{
					system("touch $name1");
					system("svn add $name1 >> $status_log 2> $patch_err_log");
				}
			}
			elsif($frd eq "Deleted")
			{
				if(-d "$name1")
				{
					system("svn delete $name1 >> $status_log 2> $patch_err_log");
				}
				elsif(-e "$name1")
				{
					system("svn delete $name1 >> $status_log 2> $patch_err_log");
				}
				else
				{
					system("svn delete $name1 >> $status_log 2> $temp_log");
					print "$name1 already deleted\n";
				}
			}
		}
	}
	return;
}

sub check_conflict_on_patch
{
	my $re = 0;
	$file = $_[0];

	open(my $FH, "<$file") || die("Can't open file: $file in merge script(check_conflict_on_patch)");
	my @lines = <$FH>;
	close($FH);

	foreach $line (@lines)
	{
		if($line =~/^>(\s+)rejected hunk @@ .+/)
		{
			print $ER "\n Conflicts occured while applying patch(merging). please resolve conflicts manually\n";
			print $ER "\n Sending mail and attachment with a new patch file generated on server\n";
			$re = 1;
			last;
		}
		elsif($line =~/^>(\s+)applied hunk @@ .+/)
		{
			print $ER "\n Conflicts occured while applying patch(merging).please resolve conflicts manually\n";
			print $ER "\n Sending mail and attachment with a new patch file generated on server\n";
			$re = 1;
			last;
		}
	}
	return $re;
}

#********************************************Functions********************************************

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
	if($sendmail_flag eq 0)
	{

		$msg = MIME::Lite->new(
				 From     => $from,
				 To       => $to,
				 Cc       => $cc,
				 Bcc	  => $bcc,
				 Subject  => $subject,
				 Data     => $message
				 );

		#$msg->attr("content-type" => "text/html");  

		if($attachPath ne "")
		{
			$msg->attach(
				Type => 'application/text',
				Path => $attachPath
				);
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

		print "Email Sent Successfully by test script\n";
	}
}

sub checking_revision_and_checkout
{
	$local_code_path = $_[0];
	$repository_code_path = $_[1];
	$change_log = $_[2];
	$text = $_[3];
	$chk_out_path = $_[4];

	print "\nFinding Out revision numbers of $text ... \n";
	system("svn info $repository_code_path --username $username --password $password > $repository_info");

	#Checking the code 
	if(-d "$local_code_path")
	{
		system("svn upgrade $local_code_path --username $username --password $password");
		system("svn info $local_code_path --username $username --password $password > $local_info");

		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		if($repo > $local)
		{
			print"Check out needed as Working copy is older than Repository revision\n";
			chdir($local_code_path);

			#Generating Change log from previous revision
			system("svn diff -r $local:$repo --username $username --password $password > $change_log");

			print "Update $text from SVN... \n";
			system("svn revert -R $local_code_path --username $username --password $password");

			system("svn update $local_code_path --username $username --password $password > $co_log 2> $co_error_log");

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
		system("svn checkout $repository_code_path --username $username --password $password > $co_log 2> $co_error_log");

		$body = "Dear $username,\n\n\n$mail_details\nThe Check-in Request with your code changes submitted got SVN checkout failure errors, while checking out the $text code.\n\nPlease resolve the checkout errors and submitt as a new check-in request.\n\n\n ****This is an Automatically generated email notification****";

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
	system("svn info $repository_code_path --username $username --password $password > $repository_info");

	#Checking the code 
	if(-d "$local_code_path")
	{
		system("svn upgrade $local_code_path --username $username --password $password");
		system("svn info $local_code_path --username $username --password $password > $local_info");

		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		chdir($local_code_path);

		#Generating Change log from previous revision
		system("svn diff -r $local:$repo --username $username --password $password > $change_log");

		#remove the folders and files in the local path
		if(-d "$local_code_path")
		{
		  system("rm -rf $local_code_path");
		}	
	}
	print "Checkout the $text from SVN... \n";
	chdir($chk_out_path);
	system("svn checkout $repository_code_path --username $username --password $password > $co_log 2> $co_error_log");

	$body = "Dear $username,\n\n\n$mail_details\nThe Check-in Request with your code changes submitted got SVN checkout failure errors, while checking out the $text code.\n\nPlease resolve the checkout errors and submitt as a new check-in request.\n\n\n ****This is an Automatically generated email notification****";

	$rt = checkout($body);
	return $rt;
}

sub checkout
{

	$sendmail_flag=0;

	$bdy=$_[0];
	$result=checkoutfailed($co_log,$co_error_log);
	if($result!=1)
	{
		print "Checkout failed and sending the mail to build team\n";

	   	sendMail($build_team, $Dev_team, "[$name] Check Out Failed for the Check-in Request with BugID - $bugid", $bdy, $co_error_log);

		$sendmail_flag=1;

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
    open(my $RD, "< $checkoutfile");
    my @lines = <$RD>;
    close($RD);

    $checkedout=0;  
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
       open(my $RD1, "< $errorfile") || die("Can't open file: $file in merge script(checkoutfailed)");
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
    open($Read, "< $file") || die("Can't open file: $file in merge script(read_last_revision)");
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

sub check_patch_file
{

	my $pfile = $_[0];
	open(my $PF, "< $pfile") || die("Can't open file: $file in merge script(check_patch_file)");
	my @lines_pf = <$PF>;
	close($PF);

	if(!($lines_pf[0]=~/Index:(.+)/))
	{
		return 1;
	}
	return 0;
}

sub add_files_to_next
{
	my $status = system("svn status > $temp_log 2> $error_log");

	my $filesize = -s "$error_log";

	if($filesize > 0)
	{
		print $ER "SVN error occured, please check the $error_log file\n";
		print $ER "merge failure\n";
		return 2;
	}

	my $file = "$temp_log";
	open(my $RD, "< $file") || die("Can't open file: $file in merge script(add_files_to_next)");
	my @lines = <$RD>;
	close($RD);

	my $zero = 0;
	my $add_flag=0;
	my $del_flag=0;

	open(my $AD, ">$codebase_devfolder/$command_log_next") || die("Can't open file: $command_log_next in merge script(add_files_to_next)");

	foreach my $line (@lines)
	{
		chomp($line);

		$b = unpack("x0 A1", $line);
		if($b eq 'A')
		{
			$data = unpack("x8 A*", $line);
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
		}
		if($b eq 'D')
		{
			$data = unpack("x8 A*", $line);
			chomp($data);

			print $AD "$data:\tDeleted\n";

			$del_flag=1;
		}
	}

	if(($add_flag==0) && ($del_flag==0))
	{
		print $AD "$zero\n";
	}
	close($AD);
	return 0;
}

sub wait_until_unlock_logfile	
{

	my $log_path=$_[0];
	START:	
	open(FH,"< $log_path") || die("Can't open file: $log_path in merge script(wait_until_unlock_logfile)");
	while($! eq "Permission denied")
	{
		sleep(2);
		goto START;
	}
	close(FH);
}

sub delete_folder
{
	open(FH1,"> $del_log");
	print FH1 "$dev_folder";
	close FH1;		
	
	#delete the dev folder 
	system("rm -rf $codebase_devfolder");

	#remove the del file
	system("rm -rf $del_log");
}

