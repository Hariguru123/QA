#!/usr/bin/perl
#********************************************************************************************************************\
# 
#   File Name  :   Dhanush_buildscript_Advanced.pl
#    
#   Description:  It will build the corresponding code based on the arguments received.Developer will 
#		  receive a mail if build either passed or failed,with all corresponding logs/ouputs in one location.
#   	
# ********************************************************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use MIME::Lite;

$num_args = @ARGV;

if($num_args < 4)
{ 
	print "Usage: perl Dhanush_buildscript_Advanced.pl <1-8> <Daily/Release> <Trunk/Branch Repository name> <local path(Folder name where trunk or release codes will check out)>\n";
	die("Number of arguments are less\n");
}

$input=$ARGV[0];

if($input eq 1)
{
	print "Building Dhanushkernel, DhanushAndroid, DhanushNative, DhanushAON, DhanushBL1, DhanushUboot, DhanushBL0.....\n";
	$build = "All";
}
elsif($input eq 2)
{
	print "Building Dhanushkernel Project.....";
	$build = "DhanushKernel";
}
elsif($input eq 3)
{
	print "Building DhanushAndroid Project.....";
	$build = "DhanushAndroid";
}
elsif($input eq 4)
{
	print "Building DhanushNative Project.....";
	$build = "DhanushNative";
}
elsif($input eq 5)
{
	print "Building DhanushAON Project.....";
	$build = "DhanushAON";
}
elsif($input eq 6)
{
	print "Building DhanushBL1 Project.....";
	$build = "DhanushBL1";
}
elsif($input eq 7)
{
	print "Building DhanushUboot Project.....";
	$build = "DhanushUboot";
}
elsif($input eq 8)
{
	print "Building DhanushBL0 Project.....";
	$build = "DhanushBL0";
}
else
{
	print "Please Pass the arguments (1-8)";
	exit;
}

#To Identify the repository is a trunk or branch

$repos_name = $ARGV[2];
@temp = split("\/","$repos_name");

$repo_s=join("\/",@temp);
$sz = @temp;
$lst = $temp[$sz-1];

if($lst eq "Adv-trunk")
{
	$SVN_bin_path = "/media/Data/trunk_wc/SVN_bins";
}
else
{
	$SVN_bin_path = "/media/Data/trunk_wc/SVN_bins/release";
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
	if($lst eq "Adv-trunk")
	{
		$subject = "Weekly";
	}
	else
	{
		$subject = "Release";
	}

#To continue release numbers reading release number from local file
	open(my $RF, "</home/$username/release.txt") || die("Can't open file: /home/$username/release.txt");
	@txt = <$RF>;

	$txt_read = $txt[0];
	chomp($txt_read);

	$rel_number = $txt_read;
	$sub_rel = "00.93.$rel_number";
	close($RF);
	$buildnumber="00.93.$rel_number";
}
else
{
	print "Please pass the proper second argument<Daily (or) Release>\n";
	exit;
}

$repository_name = $ARGV[2];

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

$toolchain_path="$local_path/toolchain";
$toolchain_mips_path="/home/$username/mips-2013.11";

#Declaration of mail Configuration path
$mail_path="$local_path/mail.txt";

$mail_str="No check-ins are happened after last build";
$checkins = 0;

#Declaration of Date and Time
currentdate();
my $currentDate = "$year\-$mon\-$mday";
my $currentTime = "$mon\-$mday\-$hr\-$min";


if($ARGV[1] eq "Daily")
{
	$dst_images_dir = "/home/$username/share/Builds/Daily_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Builds/Daily_images/$currentDate";
}
elsif($ARGV[1] eq "Release")
{
	$dst_images_dir = "/home/$username/share/Builds/Release_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Builds/Release_images/$currentDate";
	$buildnumber="$buildnumber\_$currentDate";
}

$share_path = "/home/$username/share/Builds";

#Declaration of logs
$co_log  = "$local_path/checkout_scripts.log";
$co_error_log = "$local_path/co_error_scripts.log";
$repository_info = "$local_path/repo_info_scripts.log";
$local_info = "$local_path/local_info_scripts.log";

#Declaration of repositories
$sourcecode_repo_path_scripts="http://insvn01:9090/svn/swdepot/Dhanush/SW/Adv-trunk/Scripts";

#Declaration of local path
$local_path_sourcecode_scripts="$local_path/Scripts";
$change_log_src_scripts="$local_path/changelog_scripts.txt";

#function to check the revision and check out
$message = "Mkfs Scripts";
$rtn = checking_revision_and_checkout_4_srccode($local_path_sourcecode_scripts, $sourcecode_repo_path_scripts, $change_log_src_scripts, $message, $local_path);

#function to check the revision and check out

#Declaration of local path
$local_path_sourcecode_resources="$local_path/resources";
$change_log_src_resources="$local_path/changelog_resources.txt";
$sourcecode_repo_path_resources="http://insvn01:9090/svn/swdepot/Dhanush/SW/Adv-trunk/Boot/resources";

$message = "Logo";
$rtn = checking_revision_and_checkout_4_srccode($local_path_sourcecode_resources, $sourcecode_repo_path_resources, $change_log_src_resources, $message, $local_path);

system("sudo chmod 777 $SVN_bin_path/*");

#Declaration of local path
$dhanushandroid_path="$local_path/Android";
$repository_code_path="$repository_name/Android";

if(!(-d "$dhanushandroid_path"))
{
	system("mkdir -p $dhanushandroid_path");
}

chdir($dhanushandroid_path);

#function to check the revision and check out
system("svn checkout --depth=files $repository_code_path --username socqa --password Yo'\$8'lc9u > co_andr_scr.log 2> co_err_andr_scr.log");

fcopy("$dhanushandroid_path/Android/adv2_fullbuild.sh", "$dhanushandroid_path/adv2_fullbuild.sh");

if(($build eq "DhanushKernel") || ($build eq "All"))
{

	#Declaration of repositories
	$sourcecode_repo_path_kernel="$repository_name/Android/android-linux-mti-unif-3.10.14";

	#Declaration of local path
	$dhanushandroid_path="$local_path/Android";

	$local_path_sourcecode_SGX = "$dhanushandroid_path/SGX";

	$change_log_src_kernel = "$local_path/changelog_kernel.txt";

	#Declaration of logs
	$co_log  = "$local_path/checkout_kernel.log";
	$co_error_log = "$local_path/co_error_kernel.log";
	$repository_info = "$local_path/repository_info_kernel.log";
	$local_info = "$local_path/local_info_kernel.log";

	#Declaration of DhanushKernel paths
	$local_path_sourcecode_kernel="$dhanushandroid_path/android-linux-mti-unif-3.10.14";

	#Declaration of destination directories
	$dst_reports_log_dir_Android="/home/$username/share/error_logs/Dhanush-Android/$currentDate/$currentTime";
	$dst_reports_log_dir_Android1="//192.168.42.46/share/error_logs/Dhanush-Android/$currentDate/$currentTime";

	if(!(-d "$dhanushandroid_path"))
	{
		system("mkdir -p $dhanushandroid_path");
	}

	if(-d "$local_path_sourcecode_kernel")
	{
		#check local code has any changes from SVN version, if no changes are done, do not build just send mail.
		#Read svn info
		$repo = 1;
		$local = 0;

		system("svn info $sourcecode_repo_path_kernel --username socqa --password Yo'\$8'lc9u > $repository_info 2> $co_error_log");
		$rtn = check_info($repository_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$kernel_msg = "\n\n\nAndroid Kernel:\nAndroid Kernel Check Out Failed, mail has been send previously on checkout failed and can not continue Android Kernel build.";
				goto android_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}

		system("svn info $local_path_sourcecode_kernel --username socqa --password Yo'\$8'lc9u > $local_info 2> $co_error_log");
		$rtn = check_info($local_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$kernel_msg = "\n\n\nAndroid Kernel:\nAndroid Kernel Check Out Failed, mail has been send previously on checkout failed and can not continue Android Kernel build.";
				goto android_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}

		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		if($repo > $local)
		{
			print "SVN revisions are different need to perform build\n\n";
			$kernel_flag=1;
		}
		else
		{
			$kernel_flag=0;
			print "No need to update code and perform build\n\n";
			$body = "Hi Team,\n\n\n$mail_str(Rev No: $repo) at $sourcecode_repo_path_kernel. \n\n\n\n****This is an Automatically generated email notification from Build server****";

			if($build eq "All")
			{
				$kernel_msg = "\n\n\nAndroid Kernel:\n$mail_str(Rev No: $repo) at $sourcecode_repo_path_kernel.";
				goto android_build;
			}
			else
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Android Kernel Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Android Kernel Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
				exit;
			}
		}
	}
	else
	{
		$kernel_flag=1;
	}
	#function to check the revision and check out
	$message = "Asthra Fire Kernel Source";
	$rtn = checking_revision_and_checkout($local_path_sourcecode_kernel, $sourcecode_repo_path_kernel, $change_log_src_kernel, $message, $dhanushandroid_path);

	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$kernel_msg = "\n\n\nAndroid Kernel:\nAndroid Kernel Check Out Failed, mail has been send previously on checkout failed and can not continue Android Kernel build.";
			goto android_build;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	print "*****************KERNEL BUILD PROCESS****************************\n";

	$checkins = 1;
	#change to the current path
	chdir($local_path_sourcecode_kernel);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$local_path_sourcecode_kernel/build.sh";

	$build_ScriptPath = "$local_path_sourcecode_kernel/build_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "export PATH=";

	my $path = "=/home/$username/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin:\$PATH";

	foreach my $line (<$RD>)
	{
		if($line =~ /$path_string/)
		{
			  if($line=~s/=.+\n/$path\n/)
			  {  
				print $RD1 $line;
			  }
		}
		else
		{
			 print $RD1 $line;
		}
	}
	close($RD);
	close($RD1);
	system("rm -rf $srcBuild_ScriptPath");
	system("mv $build_ScriptPath $srcBuild_ScriptPath");
	system("chmod 777 $srcBuild_ScriptPath");

	$status=system("./build.sh up clean int > kernel_buildlog.txt 2> kernel_faillog.txt");

	if((-f "$local_path_sourcecode_kernel/arch/mips/boot/vmlinux.bin"))
	{
		print "Android Kernel Build completed successfully \n";
	
		$repo_print = read_last_revision($repository_info);
	
		$kernel_body = "Hi Team,\n\n\nKernel Build Completed Successfully for the svn check-in at $sourcecode_repo_path_kernel with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_images_dir1\".";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";

		$body = "$kernel_body$end_body";

		if($build ne "All")
		{
			$kernel_flag=1;
		}

		if($return_value=mailstatus("Buildpass"))
		{
			if($build ne "All")
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire Android Kernel Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire Android Kernel Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
			}
			if($build eq "All")
			{
				$kernel_msg = "\n\n\nAndroid Kernel:\nAsthra Fire Android Kernel Build Completed Successfully for the svn check-in at $sourcecode_repo_path_kernel with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_images_dir1\".";
			}
		}
	}
	else
	{
		print("\n Kernel Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		$repo_print = read_last_revision($repository_info);

		$kernel_body = "Hi Team,\n\n\nFailures observed while building the kernel code for the svn check-in at $sourcecode_repo_path_kernel with revision:$repo_print.\n\nPlease find the build log in the share path:\"$dst_reports_log_dir_Android1\".";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";

		$body = "$kernel_body$end_body";

		system("mkdir -p $dst_reports_log_dir_Android");
	
		fcopy("$local_path_sourcecode_kernel/kernel_buildlog.txt",$dst_reports_log_dir_Android);
		fcopy("$local_path_sourcecode_kernel/kernel_faillog.txt",$dst_reports_log_dir_Android);

		if($return_value=mailstatus("Buildfail"))
		{	
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Asthra Fire Android Kernel Build Failed - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Asthra Fire Android Kernel Build Failed";
			}

			sendMail($Dev_team, $subject1, $body, "");
			if($build eq "All")
			{
				$kernel_msg = "\n\n\nAndroid Kernel:\nAsthra Fire Android Kernel Build Failed, mail has been send previously on build failed sharing the information of error logs path for SVN check-in at $sourcecode_repo_path_kernel with revision:$repo_print.";
			}
		}
	}
}

android_build:
if(($build eq "DhanushAndroid") || ($build eq "All") || ($build eq "DhanushKernel"))
{

	#Declaration of repositories
	$sourcecode_repo_path_kernel="$repository_name/Android/android-linux-mti-unif-3.10.14";
	$sourcecode_repo_path_sgx="$repository_name/Android/SGX";
	
	#Declaration of local path
	$dhanushandroid_path="$local_path/Android";
	$change_log_src_kernel = "$local_path/changelog_kernel.txt";
	$change_log_src_SGX = "$local_path/changelog_SGX.txt";

	#Declaration of logs
	$co_log  = "$local_path/checkout_kernel.log";
	$co_error_log = "$local_path/co_error_kernel.log";
	$repository_info = "$local_path/repository_info_kernel.log";
	$local_info = "$local_path/local_info_kernel.log";

	#Declaration of DhanushKernel paths
	$local_path_sourcecode_kernel="$dhanushandroid_path/android-linux-mti-unif-3.10.14";
	$local_path_sourcecode_SGX="$dhanushandroid_path/SGX";
	
	#Declaration of destination directories
	$dst_reports_log_dir_Android="/home/$username/share/error_logs/Dhanush-Android/$currentDate/$currentTime";
	$dst_reports_log_dir_Android1="//192.168.42.46/share/error_logs/Dhanush-Android/$currentDate/$currentTime";

	if(!(-d "$dhanushandroid_path"))
	{
		system("mkdir -p $dhanushandroid_path");
	}

	if(-d "$local_path_sourcecode_SGX")
	{
		$sgx_flag = 0;
		system("svn info $sourcecode_repo_path_sgx --username socqa --password Yo'\$8'lc9u > $repository_info 2> $co_error_log");
		$rtn = check_info($repository_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
					$android_msg = "\n\n\nAndroid FS(Kitkat):\nAndroid SGX Check Out Failed, mail has been send previously on checkout failed and can not continue Android FS(Kitkat) Full build.";
					goto native_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}

		system("svn info $local_path_sourcecode_SGX --username socqa --password Yo'\$8'lc9u > $local_info 2> $co_error_log");
		$rtn = check_info($local_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
					$android_msg = "\n\n\nAndroid FS(Kitkat):\nAndroid SGX Check Out Failed, mail has been send previously on checkout failed and can not continue Android FS(Kitkat) Full build.";
					goto native_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}
	
		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);
	
		print "\nSGX:\nRepository revision: $repo\nLocal revision: $local\n";
	
		if($repo > $local)
		{
			$sgx_flag = 1;
		}
	}
	else
	{
		$sgx_flag = 1;
	}

	if(($kernel_flag == 1)||($sgx_flag == 1))
	{
		$arg = "no";

		print "SVN revisions are different need to perform build\n\n";

		#function to check the revision and check out
		$message = "Asthra Fire Kernel Source";
		$rtn = checking_revision_and_checkout($local_path_sourcecode_kernel, $sourcecode_repo_path_kernel, $change_log_src_kernel, $message, $dhanushandroid_path);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$android_msg = "\n\n\nAndroid FS(Kitkat):\nAndroid Kernel Check Out Failed, mail has been send previously on checkout failed and can not continue Android FS(Kitkat) Full build.";
				goto native_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}

		#function to check the revision and check out
		$message = "SGX Source";
		$rtn = checking_revision_and_checkout_4_srccode($local_path_sourcecode_SGX, $sourcecode_repo_path_sgx, $change_log_src_SGX, $message, $dhanushandroid_path);
		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$android_msg = "\n\n\nAndroid FS(Kitkat):\nAndroid SGX Check Out Failed, mail has been send previously on checkout failed and can not continue Android FS(Kitkat) Adv Full build.";
				goto native_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}
	}

	#change to the current path
	chdir($local_path_sourcecode_kernel);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$local_path_sourcecode_kernel/build.sh";

	$build_ScriptPath = "$local_path_sourcecode_kernel/build_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "export PATH=";

	my $path = "=/home/$username/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin:\$PATH";

	foreach my $line (<$RD>)
	{
		if($line =~ /$path_string/)
		{
			  if($line=~s/=.+\n/$path\n/)
			  {  
				print $RD1 $line;
			  }
		}
		else
		{
			 print $RD1 $line;
		}
	}
	close($RD);
	close($RD1);
	system("rm -rf $srcBuild_ScriptPath");
	system("mv $build_ScriptPath $srcBuild_ScriptPath");
	system("chmod 777 $srcBuild_ScriptPath");

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$local_path_sourcecode_SGX/sgx.sh";

	$build_ScriptPath = "$local_path_sourcecode_SGX/sgx_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "export MHOME=";
	my $path1_str = "export ANDROID_ROOT=";
	my $path2_str = "export KERNELDIR=";

	my $path = "=$dhanushandroid_path";
	my $path1 = "=$dhanushandroid_path/AndroidKK4.4.2";
	my $path2 = "=$local_path_sourcecode_kernel";

	foreach my $line (<$RD>)
	{
		if($line =~ /$path_string/)
		{
			if($line=~s/=.+\n/$path\n/)
			{  
			print $RD1 $line;	
			}
		}
		elsif($line =~ /$path1_str/)
		{
			if($line=~s/=.+\n/$path1\n/)
			{  
				print $RD1 $line;	
			}
		}
		elsif($line =~ /$path2_str/)
		{
			if($line=~s/=.+\n/$path2\n/)
			{  
				print $RD1 $line;	
			}
		}
		else
		{
			 print $RD1 $line;
		}
	}
	close($RD);
	close($RD1);
	system("rm -rf $srcBuild_ScriptPath");
	system("mv $build_ScriptPath $srcBuild_ScriptPath");
	system("chmod 777 $srcBuild_ScriptPath");

	#Declaration of repositories
	$sourcecode_repo_path_kitkat="$repository_name/Android/AndroidKK4.4.2";

	#Declaration of local path
	$dhanushandroid_path="$local_path/Android";
	$change_log_src = "$local_path/changelog_kitkat.txt";

	#Declaration of logs
	$co_log  = "$local_path/checkout_android.log";
	$co_error_log = "$local_path/co_error_android.log";
	$repository_info = "$local_path/repository_info_android.log";
	$local_info = "$local_path/local_info_android.log";

	#Declaration of DhanushAndroid paths
	$local_path_sourcecode_kitkat="$dhanushandroid_path/AndroidKK4.4.2";

	#Declaration of destination directories
	$dst_reports_log_dir_Android="/home/$username/share/error_logs/Dhanush-Android/$currentDate/$currentTime";
	$dst_reports_log_dir_Android1="//192.168.42.46/share/error_logs/Dhanush-Android/$currentDate/$currentTime";

	if(!(-d "$local_path"))
	{
		system("mkdir -p $local_path");
	}

	if(-d "$local_path_sourcecode_kitkat")
	{
		#check local code has any changes from SVN version, if no changes are done, do not build just send mail.
		#Read svn info
		$repo = 1;
		$local = 0;

		system("svn info $sourcecode_repo_path_kitkat --username socqa --password Yo'\$8'lc9u > $repository_info 2> $co_error_log");
		$rtn = check_info($repository_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
					$android_msg = "\n\n\nAndroid FS(Kitkat):\nAndroid FS(Kitkat) Check Out Failed, mail has been send previously on checkout failed and can not continue Android FS(Kitkat) Full build.";
					goto native_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}

		system("svn info $local_path_sourcecode_kitkat --username socqa --password Yo'\$8'lc9u > $local_info 2> $co_error_log");
		$rtn = check_info($local_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
					$android_msg = "\n\n\nAndroid FS(Kitkat):\nAndroid FS(Kitkat) Check Out Failed, mail has been send previously on checkout failed and can not continue Android FS(Kitkat) Full build.";
					goto native_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}
		
		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		$arg = "no";
		if($repo > $local)
		{
			print "SVN revisions are different need to perform build\n\n";
			$arg = "clean";
		}
		else
		{
			if(($kernel_flag == 1)||($sgx_flag == 1))
			{
				$arg = "no";
				goto sgx_build;
			}

			print "No need to update code and perform build\n\n";
			$body = "Hi Team,\n\n\n$mail_str(Rev No: $repo) at $sourcecode_repo_path_kitkat.\n\n\n\n****This is an Automatically generated email notification from Build server****";

			if($build eq "All")
			{
				$android_msg = "\n\n\nAndroid FS(Kitkat):\n$mail_str(Rev No: $repo) at $sourcecode_repo_path_kitkat.";
				goto native_build;
			}
			else
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire Android FS(Kitkat) Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire Android FS(Kitkat) Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
				exit;
			}
		}
	}


sgx_build:

	#function to check the revision and check out
	$message = "Asthra Fire Android Kitkat Source";
	$rtn = checking_revision_and_checkout($local_path_sourcecode_kitkat, $sourcecode_repo_path_kitkat, $change_log_src, $message, $dhanushandroid_path);

	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$android_msg = "\n\n\nAndroid FS(Kitkat):\nAndroid FS(Kitkat) Check Out Failed, mail has been send previously on checkout failed and can not continue Android FS(Kitkat) Full build.";
			goto native_build;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	$checkins = 1;

	$arg3 = "up";
	$check = 0;

REPEAT_BUILD:

	print "*****************ANDROID BUILD PROCESS****************************\n";
	
	chdir($dhanushandroid_path);
	system("chmod 777 adv2_fullbuild.sh");

	$status=system("./adv2_fullbuild.sh $arg int $arg3 > Android_buildlog.txt 2> Android_faillog.txt");

	if((!(-f "$local_path_sourcecode_kitkat/images/rfs/system.img")) || ($status)) 
	{
		print("\n Android Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");

		chdir($local_path_sourcecode_kitkat);
		$repo_print = read_last_revision($repository_info);

		$body = "Hi Team,\n\n\nFailures observed while building the Android FS(Kitkat) $arg3 code for the svn check-in at $sourcecode_repo_path_kitkat with revision:$repo_print.\nPlease find the build log in the share path:\"$dst_reports_log_dir_Android1\".\n\n\n";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";
	
		$kernel_body="";
		system("mkdir -p $dst_reports_log_dir_Android");
		dircopy("$local_path_sourcecode_kitkat/logs",$dst_reports_log_dir_Android);

		if($return_value=mailstatus("Buildfail"))
		{	
			$body = "$body$kernel_body$end_body";
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Asthra Fire Android FS(Kitkat) $arg3 Build Failed - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Asthra Fire Android FS(Kitkat) $arg3 Build Failed";
			}

			sendMail($Dev_team, $subject1, $body, "");
			if($build eq "All")
			{
				$android_msg = "\n\n\nAndroid FS(Kitkat):\nAndroid FS(Kitkat) $arg3 Build Failed, mail has been send previously on build failed sharing the information of error logs path for SVN check-in at $sourcecode_repo_path_kitkat with revision:$repo_print.";
			}
		}
	}
	else
	{
		print "Android Kitkat Build completed successfully \n";

		chdir($local_path_sourcecode_kitkat);

		$repo_print = read_last_revision($repository_info);
	
		$body = "Hi Team,\n\n\nAndroid FS(Kitkat) $arg3 Build Completed Successfully for the svn check-in at $sourcecode_repo_path_kitkat with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_images_dir1\".\n\n\n";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";
		
		$kernel_body="";

		fcopy("$local_path/aon.bin", "$local_path_sourcecode_kitkat/images/boot");

		fcopy("$local_path/native.bin", "$local_path_sourcecode_kitkat/images/boot");

		fcopy("$local_path/dfu.bin", "$local_path_sourcecode_kitkat/images/boot");

		fcopy("$local_path/bl1.bin", "$local_path_sourcecode_kitkat/images/boot");

		fcopy("$local_path/u-boot.bin", "$local_path_sourcecode_kitkat/images/boot");

		fcopy("$local_path/Scripts/mkfs.incdhad1","$local_path_sourcecode_kitkat/images");
		
		fcopy("$local_path/Scripts/mkheader","$local_path_sourcecode_kitkat/images");

		dircopy("$local_path/Scripts/media","$local_path_sourcecode_kitkat/images/media");

		dircopy("$local_path/Scripts/Music","$local_path_sourcecode_kitkat/images/Music");
		
		fcopy("$local_path/resources/logo1.bin","$local_path_sourcecode_kitkat/images/boot");

		#copy the output files to destination location 
		system("tar cvzf $local_path/images_$arg3.tar.gz images");

		#creating share location for images.tar.gz
		system("mkdir -p $dst_images_dir");

		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			#rename images 
			system("mv images images_$arg3\_$sub_rel");

			system("tar cvzf $local_path/images_$arg3\_$sub_rel.tar.gz images_$arg3\_$sub_rel");

			system("mv images_$arg3\_$sub_rel images");

			#copying tar.gz to common images directory
			fcopy("$local_path/images_$arg3\_$sub_rel.tar.gz", "$dst_images_dir/images_$arg3\_$sub_rel.tar.gz");

			#remove images_$sub_rel.tar.gz
			system("rm -rf $local_path/images_$arg3\_$sub_rel.tar.gz");
			
			fcopy("$local_path/images_$arg3.tar.gz", "$SVN_bin_path/images_$arg3.tar.gz");

		}
		elsif($subject eq "Daily")
		{
			#rename images 
			system("mv images images_$arg3\_$currentTime");

			#copy the output files to destination location 
			system("tar cvzf $local_path/images_$arg3\_$currentTime.tar.gz images_$arg3\_$currentTime");

			system("mv images_$arg3\_$currentTime images");

			#copying tar.gz to common images directory
			fcopy("$local_path/images_$arg3\_$currentTime.tar.gz", "$dst_images_dir/images_$arg3\_$currentTime.tar.gz");

			system("rm -rf $local_path/images_$arg3\_$currentTime.tar.gz");

			fcopy("$local_path/images_$arg3.tar.gz", "$SVN_bin_path/images_$arg3.tar.gz");

		}
	
		print "output files copied to $dst_images_dir1 \n";

		if($check eq 0)
		{
			$check = 1;
			$arg3 = "smp";
			$arg = "no";
			goto REPEAT_BUILD;
		}

		if($return_value=mailstatus("Buildpass"))
		{	
			$body = "$body$kernel_body$end_body";
			if($build ne "All")
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire Android FS(Kitkat) Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire Android FS(Kitkat) Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
			}
			if($build eq "All")
			{
				$android_msg = "\n\n\nAndroid FS(Kitkat):\nAsthra Fire Android FS(Kitkat) Build Completed Successfully for the svn check-in at $sourcecode_repo_path_kitkat with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_images_dir1\".";
			}
		}
	}
}

native_build:
if(($build eq "DhanushNative") || ($build eq "All"))
{

	#Declaration of repositories
	$toolchain_repo_path= "http://insvn01:9090/svn/swdepot/Dhanush/Tools/Native_AON/toolchain";
	$sourcecode_repo_path="$repository_name/Native";

	#Declaration of local path
	$dhanushnative_path="$local_path/Native";
	$change_log_src = "$local_path/changelog_Native.txt";

	#Declaration of logs
	$co_log  = "$local_path/checkout_Native.log";
	$co_error_log = "$local_path/co_error_Native.log";
	$repository_info = "$local_path/repository_info_Native.log";
	$local_info = "$local_path/local_info_Native.log";
	$change_log_tc = "$local_path/changelog_toolchain_Native.txt";

	#Declaration of DhanushNative environment paths
	$dhanushnativeenv_path="$dhanushnative_path/build/scripts/native_env.sh";
	$dhanushnativeenv_temp_path="$dhanushnative_path/build/scripts/temp.sh";

	#Declaration of destination directories
	$dst_reports_log_dir_Native="/home/$username/share/error_logs/DhanushNative/$currentDate/$currentTime";
	$dst_reports_log_dir_Native1="//192.168.42.46/share/error_logs/DhanushNative/$currentDate/$currentTime";
		
	if(!(-d "$local_path"))
	{
		system("mkdir -p $local_path");
	}

	if(-d "$dhanushnative_path")
	{
		#check local code has any changes from SVN version, if no changes are done, do not build just send mail.
		#Read svn info
		$repo = 1;
		$local = 0;

		system("svn info $sourcecode_repo_path --username socqa --password Yo'\$8'lc9u > $repository_info 2> $co_error_log");

		$rtn = check_info($repository_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$native_msg = "\n\n\nNative:\nNative Check Out Failed, mail has been send previously on checkout failed and can not continue Native build.";
				goto aon_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}
		
		system("svn info $dhanushnative_path --username socqa --password Yo'\$8'lc9u > $local_info 2> $co_error_log");
		$rtn = check_info($local_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$native_msg = "\n\n\nNative:\nNative Check Out Failed, mail has been send previously on checkout failed and can not continue Native build.";
				goto aon_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}

		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		if($repo > $local)
		{
			print "SVN revisions are different need to perform build\n\n";
		}
		else
		{
			print "No need to update code and perform build\n\n";
			$body = "Hi Team,\n\n\n$mail_str(Rev No: $repo) at $sourcecode_repo_path.\n\n\n\n****This is an Automatically generated email notification from Build server****";

			if($build eq "All")
			{
				$native_msg = "\n\n\nNative:\n$mail_str(Rev No: $repo) at $sourcecode_repo_path.";
				goto aon_build;
			}
			else
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire Native Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire Native Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
				exit;
			}
		}
	}

	#function to check the revision and check out
	$message = "tool chain";
	$rtn = checking_revision_and_checkout($toolchain_path, $toolchain_repo_path, $change_log_tc, $message, $local_path);

	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$native_msg = "\n\n\nNative:\nToolchain Check Out Failed, mail has been send previously on checkout failed and can not continue Native build.";
			goto aon_build;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	#system("unzip -o $toolchain_path/toolchain.zip -d /home/$username > toolchain.log");
	system("rm -rf $toolchain_path/ubuntu64/mips/*");
	system("cp -r $toolchain_mips_path/* $toolchain_path/ubuntu64/mips/");	
	system("chmod -R 777 $toolchain_path/*");
	
	printf "Toolchain CheckOut Completed Successfully\n";

	$message = "Asthra Fire Native Source";
	$rtn = checking_revision_and_checkout_4_srccode($dhanushnative_path, $sourcecode_repo_path, $change_log_src, $message, $local_path);

	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$native_msg = "\n\n\nNative:\nNative Check Out Failed, mail has been send previously on checkout failed and can not continue Native build.";
			goto aon_build;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	print "*****************Native BUILD PROCESS****************************\n";

	$checkins = 1;
	#delete the output folder with contents and create new output folder 
	system("rm -rf $dhanushnative_path/output"); 
	system("mkdir $dhanushnative_path/output");

	chdir($dhanushnative_path);
	#change the env path to the local path
	change_envfile_path($dhanushnative_path,$dhanushnativeenv_path,$dhanushnativeenv_temp_path);

	#Build the Native Project
	$status = system(". ./build/scripts/native_env.sh > log.txt; make clobber >clobber_log.txt 2> faillog.txt;make BUILD_NUC=1 rel > buildlog.txt 2>> faillog.txt;");
	if ($status) 
	{
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
		
		$repo_print = read_last_revision($repository_info);
		
		system("mkdir -p $dst_reports_log_dir_Native");
		fcopy("faillog.txt", $dst_reports_log_dir_Native);
		fcopy("buildlog.txt", $dst_reports_log_dir_Native);

		$body = "Hi Team,\n\n\nFailures observed while building the Asthra Fire Native code for the svn check-in at $sourcecode_repo_path with revision:$repo_print.\nPlease find the build log in the share path:\"$dst_reports_log_dir_Native1\".\n\n\n\n****This is an Automatically generated email notification from Build server****";
		
		if($return_value=mailstatus("Buildfail"))
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Asthra Fire Native Build Failed - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Asthra Fire Native Build Failed";
			}

			sendMail($Dev_team, $subject1, $body, "");

			if($build eq "All")
			{
				$native_msg = "\n\n\nNative:\nNative Build Failed, mail has been send previously on build failed sharing the information of error logs path for SVN check-in at $sourcecode_repo_path with revision:$repo_print.";
			}
		}
	}
	else
	{
		print "Native Build completed successfully \n";

		$repo_print = read_last_revision($repository_info);
		
		#update the destination folder after successfull build	
		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			$dst_reports_dir_Native="/home/$username/share/Builds/Release_Builds/$buildnumber/$currentTime/Native_$repo_print";
			$dst_reports_dir_Native1="//192.168.42.46/share/Builds/Release_Builds/$buildnumber/$currentTime/Native_$repo_print";
		}
		elsif($subject eq "Daily")
		{
			$dst_reports_dir_Native="/home/$username/share/Builds/Daily_Builds/$currentDate/$currentTime/Native_$repo_print";
			$dst_reports_dir_Native1="//192.168.42.46/share/Builds/Daily_Builds/$currentDate/$currentTime/Native_$repo_print";
		}

		#renaming bin

		fcopy("$dhanushnative_path/output/dhanush_wearable.bin", "$dhanushnative_path/output/native.bin");

		#creating share location
		system("mkdir -p $dst_reports_dir_Native");

		#copy the output files to destination location 
		dircopy("$dhanushnative_path/output", $dst_reports_dir_Native);

		#copying images to local path
		fcopy("$dhanushnative_path/output/native.bin", "$local_path");
		print "Native output files copied to $dst_reports_dir_Native \n";

		fcopy("$dhanushnative_path/output/native.bin", "$SVN_bin_path/native.bin");

		if($build ne "All")
		{
			if(-f "$local_path/images_up.tar.gz")
			{
				chdir("$local_path");

				#untar the images.tar.gz
				system("tar -xvzf $local_path/images_up.tar.gz");

				#remove images.tar.gz
				system("rm -rf $local_path/images_up.tar.gz");

				fcopy("$dhanushnative_path/output/native.bin", "$local_path/images/boot");

				#tar the images folder to images.tar.gz
				system("tar cvzf $local_path/images_up.tar.gz images");

				#creating share location for images.tar.gz
				system("mkdir -p $dst_images_dir");

				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					#rename images
					system("mv $local_path/images $local_path/images_up_$sub_rel");

					#tar the images folder to images_$sub_rel.tar.gz
					system("tar cvzf $local_path/images_up_$sub_rel.tar.gz images_up_$sub_rel");

					#remove images_$sub_rel
					system("rm -rf $local_path/images_up_$sub_rel");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_up_$sub_rel.tar.gz", "$dst_images_dir/images_up_$sub_rel.tar.gz");

					#remove images_$sub_rel.tar.gz
					system("rm -rf $local_path/images_up_$sub_rel.tar.gz");
					
					fcopy("$dhanushnative_path/output/native.bin", "$SVN_bin_path/native.bin");					
				}
				elsif($subject eq "Daily")
				{
					#rename images
					system("mv $local_path/images $local_path/images_up_$currentTime");

					#tar the images folder to images_$currentTime.tar.gz
					system("tar cvzf $local_path/images_up_$currentTime.tar.gz images_up_$currentTime");

					#remove images_$currentTime
					system("rm -rf $local_path/images_up_$currentTime");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_up_$currentTime.tar.gz", "$dst_images_dir/images_up_$currentTime.tar.gz");

					system("rm -rf $local_path/images_up_$currentTime.tar.gz");

					fcopy("$dhanushnative_path/output/native.bin", "$SVN_bin_path/native.bin");
				}
				print "Done..\n";
			}

			if(-f "$local_path/images_smp.tar.gz")
			{
				chdir("$local_path");

				#untar the images.tar.gz
				system("tar -xvzf $local_path/images_smp.tar.gz");

				#remove images.tar.gz
				system("rm -rf $local_path/images_smp.tar.gz");

				fcopy("$dhanushnative_path/output/native.bin", "$local_path/images/boot");

				#tar the images folder to images.tar.gz
				system("tar cvzf $local_path/images_smp.tar.gz images");

				#creating share location for images.tar.gz
				system("mkdir -p $dst_images_dir");

				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					#rename images
					system("mv $local_path/images $local_path/images_smp_$sub_rel");

					#tar the images folder to images_$sub_rel.tar.gz
					system("tar cvzf $local_path/images_smp_$sub_rel.tar.gz images_smp_$sub_rel");

					#remove images_$sub_rel
					system("rm -rf $local_path/images_smp_$sub_rel");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_smp_$sub_rel.tar.gz", "$dst_images_dir/images_smp_$sub_rel.tar.gz");

					#remove images_$sub_rel.tar.gz
					system("rm -rf $local_path/images_smp_$sub_rel.tar.gz");
					
					fcopy("$dhanushnative_path/output/native.bin", "$SVN_bin_path/native.bin");
				}
				elsif($subject eq "Daily")
				{
					#rename images
					system("mv $local_path/images $local_path/images_smp_$currentTime");

					#tar the images folder to images_$currentTime.tar.gz
					system("tar cvzf $local_path/images_smp_$currentTime.tar.gz images_smp_$currentTime");

					#remove images_$currentTime
					system("rm -rf $local_path/images_smp_$currentTime");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_smp_$currentTime.tar.gz", "$dst_images_dir/images_smp_$currentTime.tar.gz");

					system("rm -rf $local_path/images_smp_$currentTime.tar.gz");

					fcopy("$dhanushnative_path/output/native.bin", "$SVN_bin_path/native.bin");
				}

				print "Done..\n";
			}
		}
		
		$body = "Hi Team,\n\n\nAsthra Fire Native Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_Native1\".	\n\n\n\n****This is an Automatically generated email notification from Build server****";
		
		if($return_value=mailstatus("Buildpass"))
		{
			if($build ne "All")
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire Native Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire Native Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
			}
			if($build eq "All")
			{
				$native_msg = "\n\n\nNative:\nAsthra Fire Native Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_Native1\".";
			}
		}
	}
}

aon_build:
#Declaration of AONsensor paths
if(($build eq "DhanushAON") || ($build eq "All"))
{

	#Declaration of repositories
	$toolchain_repo_path= "http://insvn01:9090/svn/swdepot/Dhanush/Tools/Native_AON/toolchain";
	$sourcecode_repo_path="$repository_name/AONsensor";

	#Declaration of local path
	
	$dhanushaon_path="$local_path/AONsensor";
	$change_log_src = "$local_path/changelog_AONsensor.txt";

	#Declaration of logs
	$co_log  = "$local_path/checkout_AON.log";
	$co_error_log = "$local_path/co_error_AON.log";
	$repository_info = "$local_path/repository_info_AON.log";
	$local_info = "$local_path/local_info_AON.log";
	$change_log_tc = "$local_path/changelog_toolchain_AON.txt";

	#Declaration of DhanushAON Environment paths
	$dhanushaonenv_path="$dhanushaon_path/build/scripts/dhanushaon_env.sh";
	$dhanushaonenv_temp_path="$dhanushaon_path/build/scripts/dhanushtemp.sh";

	#declaration of destination directories
	$dst_reports_log_dir_AON="/home/$username/share/error_logs/DhanushAON/$currentDate/$currentTime";
	$dst_reports_log_dir_AON1="//192.168.42.46/share/error_logs/DhanushAON/$currentDate/$currentTime";

	if(!(-d "$local_path"))
	{
		system("mkdir -p $local_path");
	}

	if(-d "$dhanushaon_path")
	{
		#check local code has any changes from SVN version, if no changes are done, do not build just send mail.
		#Read svn info
		$repo = 1;
		$local = 0;

		system("svn info $sourcecode_repo_path --username socqa --password Yo'\$8'lc9u > $repository_info 2> $co_error_log");

		$rtn = check_info($repository_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$aon_msg = "\n\n\nAON:\nAONSensor Check Out Failed, mail has been send previously on checkout failed and can not continue AON build.";
				goto BL1_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}

		system("svn info $dhanushaon_path --username socqa --password Yo'\$8'lc9u > $local_info 2> $co_error_log");

		$rtn = check_info($local_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$aon_msg = "\n\n\nAON:\nAONSensor Check Out Failed, mail has been send previously on checkout failed and can not continue AON build.";
				goto BL1_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}

		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		if($repo > $local)
		{
			print "SVN revisions are different need to perform build\n\n";
		}
		else
		{
			print "No need to update code and perform build\n\n";
			$body = "Hi Team,\n\n\n$mail_str(Rev No: $repo) at $sourcecode_repo_path.\n\n\n\n****This is an Automatically generated email notification from Build server****";

			if($build eq "All")
			{
				$aon_msg = "\n\n\nAON:\n$mail_str(Rev No: $repo) at $sourcecode_repo_path.";
				goto BL1_build;
			}
			else
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire AONSensor Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire AONSensor Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
				exit;
			}
		}
	}

	#function to check the revision and check out
	$message = "tool chain";
	$rtn = checking_revision_and_checkout($toolchain_path, $toolchain_repo_path, $change_log_tc, $message, $local_path);

	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$aon_msg = "\n\n\nAON:\nToolChain Check Out Failed, mail has been send previously on checkout failed and can not continue AON build.";
			goto BL1_build;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	#system("unzip -o $toolchain_path/toolchain.zip -d /home/$username > toolchain.log");
	system("rm -rf $toolchain_path/ubuntu64/mips/*");
	system("cp -r $toolchain_mips_path/* $toolchain_path/ubuntu64/mips/");
	system("chmod -R 777 $toolchain_path/*");
	
	printf "Toolchain CheckOut Completed Successfully\n";

	$message = "Asthra Fire AON Source";
	$rtn = checking_revision_and_checkout_4_srccode($dhanushaon_path, $sourcecode_repo_path, $change_log_src, $message, $local_path);
	
	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$aon_msg = "\n\n\nAON:\nAONSensor Check Out Failed, mail has been send previously on checkout failed and can not continue AON build.";
			goto BL1_build;
		}
		if($build ne "All")
		{
			exit;
		}
	}
	
	print "*****************AONsensor BUILD PROCESS****************************\n";

	$checkins = 1;
	#delete the output folder with contents and create new output folder 
	system("rm -rf $dhanushaon_path/output"); 
	system("mkdir $dhanushaon_path/output");

	chdir($dhanushaon_path);
	#change the env path to the local path
	change_envfile_path($dhanushaon_path,$dhanushaonenv_path,$dhanushaonenv_temp_path);

	#Build the AON Project
	$status = system(". ./build/scripts/dhanushaon_env.sh > log.txt;./aon_build.sh > buildlog.txt 2> faillog.txt");

	if((!(-f "$dhanushaon_path/output/aon.bin") || !(-f "$dhanushaon_path/output/dfu.bin") ) || ($status)) 
	{
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
		$repo_print = read_last_revision($repository_info);

		system("mkdir -p $dst_reports_log_dir_AON");
		fcopy("faillog.txt", $dst_reports_log_dir_AON);
		fcopy("buildlog.txt", $dst_reports_log_dir_AON);

		$body = "Hi Team,\n\n\nFailures observed while building the Asthra Fire AON code for the svn check-in at $sourcecode_repo_path with revision:$repo_print.\nPlease find the build log in the share path:\"$dst_reports_log_dir_AON1\".	\n\n\n\n****This is an Automatically generated email notification from Build server****";

		if($return_value=mailstatus("Buildfail"))
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Asthra Fire AONSensor Build Failed - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Asthra Fire AONSensor Build Failed";
			}

			sendMail($Dev_team, $subject1, $body, "");		
			if($build eq "All")
			{
				$aon_msg = "\n\n\nAON:\nAON Sensor Build Failed, mail has been send previously on build failed sharing the information of error logs path for the SVN check-in at $sourcecode_repo_path with revision:$repo_print.";
			}
		}		
	}
	else
	{
		print "AONsensor Build Completed successfully \n";
		
		$repo_print = read_last_revision($repository_info);

		#update the destination folder after successfull build

		if(($subject eq "Weekly") || ($subject eq "Release"))
		{		
			$dst_reports_dir_AON="/home/$username/share/Builds/Release_Builds/$buildnumber/$currentTime/AON_$repo_print";
			$dst_reports_dir_AON1="//192.168.42.46/share/Builds/Release_Builds/$buildnumber/$currentTime/AON_$repo_print";
		}
		elsif($subject eq "Daily")
		{
			$dst_reports_dir_AON="/home/$username/share/Builds/Daily_Builds/$currentDate/$currentTime/AON_$repo_print";
			$dst_reports_dir_AON1="//192.168.42.46/share/Builds/Daily_Builds/$currentDate/$currentTime/AON_$repo_print";
		}
			
		# Create share location
		system("mkdir -p $dst_reports_dir_AON");

		#copy the output files to destination location
		dircopy("$dhanushaon_path/output", $dst_reports_dir_AON);
	
		#copying bins to local path for nand boot		
		fcopy("$dhanushaon_path/output/aon.bin", "$local_path");

		#copying bins to local path for nand boot		
		fcopy("$dhanushaon_path/output/dfu.bin", "$local_path");


		fcopy("$dhanushaon_path/output/aon.bin", "$SVN_bin_path/aon.bin");

		fcopy("$dhanushaon_path/output/dfu.bin", "$SVN_bin_path/dfu.bin");

		if($build ne "All")
		{
			if(-f "$local_path/images_up.tar.gz")
			{
				chdir("$local_path");

				#untar the images.tar.gz
				system("tar -xvzf $local_path/images_up.tar.gz");

				#remove images.tar.gz
				system("rm -rf $local_path/images_up.tar.gz");

				fcopy("$dhanushaon_path/output/aon.bin", "$local_path/images/boot");

				fcopy("$dhanushaon_path/output/dfu.bin", "$local_path/images/boot");

				#tar the images folder to images.tar.gz
				system("tar cvzf $local_path/images_up.tar.gz images");

				#creating share location for images.tar.gz
				system("mkdir -p $dst_images_dir");


				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					#rename images
					system("mv $local_path/images $local_path/images_up_$sub_rel");

					#tar the images folder to images_$sub_rel.tar.gz
					system("tar cvzf $local_path/images_up_$sub_rel.tar.gz images_up_$sub_rel");

					#remove images_$sub_rel
					system("rm -rf $local_path/images_up_$sub_rel");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_up_$sub_rel.tar.gz", "$dst_images_dir/images_up_$sub_rel.tar.gz");

					#remove images_$sub_rel.tar.gz
					system("rm -rf $local_path/images_up_$sub_rel.tar.gz");
					
				}
				elsif($subject eq "Daily")
				{
					#rename images
					system("mv $local_path/images $local_path/images_up_$currentTime");

					#tar the images folder to images_$currentTime.tar.gz
					system("tar cvzf $local_path/images_up_$currentTime.tar.gz images_up_$currentTime");

					#remove images_$currentTime
					system("rm -rf $local_path/images_up_$currentTime");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_up_$currentTime.tar.gz", "$dst_images_dir/images_up_$currentTime.tar.gz");

					system("rm -rf $local_path/images_up_$currentTime.tar.gz");
				}

				print "Done..\n";
			}

			if(-f "$local_path/images_smp.tar.gz")
			{
				chdir("$local_path");

				#untar the images.tar.gz
				system("tar -xvzf $local_path/images_smp.tar.gz");

				#remove images.tar.gz
				system("rm -rf $local_path/images_smp.tar.gz");

				fcopy("$dhanushaon_path/output/aon.bin", "$local_path/images/boot");

				fcopy("$dhanushaon_path/output/dfu.bin", "$local_path/images/boot");

				#tar the images folder to images.tar.gz
				system("tar cvzf $local_path/images_smp.tar.gz images");

				#creating share location for images.tar.gz
				system("mkdir -p $dst_images_dir");


				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					#rename images
					system("mv $local_path/images $local_path/images_smp_$sub_rel");

					#tar the images folder to images_$sub_rel.tar.gz
					system("tar cvzf $local_path/images_smp_$sub_rel.tar.gz images_smp_$sub_rel");

					#remove images_$sub_rel
					system("rm -rf $local_path/images_smp_$sub_rel");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_smp_$sub_rel.tar.gz", "$dst_images_dir/images_smp_$sub_rel.tar.gz");

					#remove images_$sub_rel.tar.gz
					system("rm -rf $local_path/images_smp_$sub_rel.tar.gz");
					
				}
				elsif($subject eq "Daily")
				{
					#rename images
					system("mv $local_path/images $local_path/images_smp_$currentTime");

					#tar the images folder to images_$currentTime.tar.gz
					system("tar cvzf $local_path/images_smp_$currentTime.tar.gz images_smp_$currentTime");

					#remove images_$currentTime
					system("rm -rf $local_path/images_smp_$currentTime");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_smp_$currentTime.tar.gz", "$dst_images_dir/images_smp_$currentTime.tar.gz");

					system("rm -rf $local_path/images_smp_$currentTime.tar.gz");

				}

				print "Done..\n";
			}
		}

		print "AONsensor output files copied to $dst_reports_dir_AON \n";

		$body = "Hi Team,\n\n\nAsthra Fire AON Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print. \nPlease find the output binaries in the share path: \"$dst_reports_dir_AON1\".\n\n\n\n****This is an Automatically generated email notification from Build server****";

		if($return_value=mailstatus("Buildpass"))
		{	
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "AONSensor Build - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "AONSensor Build";
			}

			if($build ne "All")
			{
				sendMail($Dev_team, $subject1, $body, "");
			}
			if($build eq "All")
			{
				$aon_msg = "\n\n\nAON:\nAsthra Fire AON Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print. \nPlease find the output binaries in the share path: \"$dst_reports_dir_AON1\".";
			}
		}
	}
}

BL1_build:
if(($build eq "DhanushBL1") || ($build eq "All"))
{

	#Declaration of repositories
	$sourcecode_repo_path_BL1="$repository_name/Boot/BL1";

	#Declaration of local path
	$dhanushBL1_path="$local_path/BL1";
	$change_log_src_BL1 = "$local_path/changelog_BL1.txt";

	#Declaration of logs
	$co_log  = "$local_path/checkout_BL1.log";
	$co_error_log = "$local_path/co_error_BL1.log";
	$repository_info = "$local_path/repository_info_BL1.log";
	$local_info = "$local_path/local_info_BL1.log";

	#Declaration of destination directories
	$dst_reports_log_dir_BL1="/home/$username/share/error_logs/Dhanush-BL1/$currentDate/$currentTime";
	$dst_reports_log_dir_BL11="//192.168.42.46/share/error_logs/Dhanush-BL1/$currentDate/$currentTime";

	if(!(-d "$local_path"))
	{
		system("mkdir -p $local_path");
	}

	if(-d "$dhanushBL1_path")
	{
		#check local code has any changes from SVN version, if no changes are done, do not build just send mail.
		#Read svn info
		$repo = 1;
		$local = 0;

		system("svn info $sourcecode_repo_path_BL1 --username socqa --password Yo'\$8'lc9u > $repository_info 2> $co_error_log");
		$rtn = check_info($repository_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$bl1_msg = "\n\n\nBL1:\nBL1 Check Out Failed, mail has been send previously on checkout failed and can not continue BL1 build.";
				goto Uboot_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}

		system("svn info $dhanushBL1_path --username socqa --password Yo'\$8'lc9u > $local_info 2> $co_error_log");
		$rtn = check_info($local_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$bl1_msg = "\n\n\nBL1:\nBL1 Check Out Failed, mail has been send previously on checkout failed and can not continue BL1 build.";
				goto Uboot_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}
		
		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		if($repo > $local)
		{
			print "SVN revisions are different need to perform build\n\n";
		}
		else
		{
			print "No need to update code and perform build\n\n";
			$body = "Hi Team,\n\n\n$mail_str(Rev No: $repo) at $sourcecode_repo_path_BL1.\n\n\n\n****This is an Automatically generated email notification from Build server****";

			if($build eq "All")
			{
				$bl1_msg = "\n\n\nBL1:\n$mail_str(Rev No: $repo) at $sourcecode_repo_path_BL1.";
				goto Uboot_build;
			}
			else
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire BL1 Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire BL1 Build";
				}
				
				sendMail($Dev_team, $subject1, $body, "");
				exit;
			}
		}
	}

	#function to check the revision and check out
	$message = "Asthra Fire BL1 Source";
	$rtn = checking_revision_and_checkout_4_srccode($dhanushBL1_path, $sourcecode_repo_path_BL1, $change_log_src_BL1, $message, $local_path);

	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$bl1_msg = "\n\n\nBL1:\nBL1 Check Out Failed, mail has been send previously on checkout failed and can not continue BL1 build.";
			goto Uboot_build;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	print "*****************BL1 BUILD PROCESS****************************\n";

	$checkins = 1;
	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushBL1_path/config/config.mk";

	$build_ScriptPath = "$dhanushBL1_path/config/config_temp.mk";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "CROSS_COMPILE =";

	my $path = "= /home/$username/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin/mips-linux-gnu-";

	foreach my $line (<$RD>)
	{
		if($line =~ /$path_string/)
		{
			  if($line=~s/=.+\n/$path\n/)
			  {  
				print $RD1 $line;	
			  }
		}

		else
		{
			 print $RD1 $line;
		}

	}
	close($RD);
	close($RD1);
	system("rm -rf $srcBuild_ScriptPath");
	system("mv $build_ScriptPath $srcBuild_ScriptPath");
	system("chmod 777 $srcBuild_ScriptPath");

	chdir($dhanushBL1_path);

	$status=system("make clean; make > BL1_buildlog.txt 2> BL1_faillog.txt");

	if((!(-f "$dhanushBL1_path/out/bl1.bin")) || ($status)) 
	{
		print("\n BL1 Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		$repo_print = read_last_revision($repository_info);

		$BL1_body = "Hi Team,\n\n\nFailures observed while building the BL1 code for the svn check-in at $sourcecode_repo_path_BL1 with revision:$repo_print.\nPlease find the build log in the share path:\"$dst_reports_log_dir_BL11\".";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";

		$body = "$BL1_body$end_body";

		system("mkdir -p $dst_reports_log_dir_BL1");
	
		fcopy("$dhanushBL1_path/BL1_buildlog.txt",$dst_reports_log_dir_BL1);
		fcopy("$dhanushBL1_path/BL1_faillog.txt",$dst_reports_log_dir_BL1);

		if($return_value=mailstatus("Buildfail"))
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Asthra Fire BL1 Build Failed - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Asthra Fire BL1 Build Failed";
			}

			sendMail($Dev_team, $subject1, $body, "");
			if($build eq "All")
			{
				$bl1_msg = "\n\n\nBL1:\nBL1 Build Failed, mail has been send previously on build failed sharing the information of error logs path for SVN check-in at $sourcecode_repo_path_BL1 with revision:$repo_print.";
			}
		}

	}
	else
	{
		print "BL1 Build completed successfully \n";
	
		$repo_print = read_last_revision($repository_info);
	
		#update the destination folder after successfull build		
		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			$dst_reports_dir_BL1="/home/$username/share/Builds/Release_Builds/$buildnumber/$currentTime/BL1_$repo_print";
			$dst_reports_dir_BL11="//192.168.42.46/share/Builds/Release_Builds/$buildnumber/$currentTime/BL1_$repo_print";
		}
	
		elsif($subject eq "Daily")
		{
			$dst_reports_dir_BL1="/home/$username/share/Builds/Daily_Builds/$currentDate/$currentTime/BL1_$repo_print";
			$dst_reports_dir_BL11="//192.168.42.46/share/Builds/Daily_Builds/$currentDate/$currentTime/BL1_$repo_print";
		}
	
		$BL1_body = "Hi Team,\n\n\nBL1 Build Completed Successfully for the svn check-in at $sourcecode_repo_path_BL1 with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_BL11\".";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";

		$body = "$BL1_body$end_body";

		system("mkdir -p $dst_reports_dir_BL1");

		#copy the output files to destination location 
		fcopy("$dhanushBL1_path/out/bl1.bin", $dst_reports_dir_BL1);

		#copying bin to local path
		fcopy("$dhanushBL1_path/out/bl1.bin", "$local_path");

		fcopy("$dhanushBL1_path/out/bl1.bin", "$SVN_bin_path/bl1.bin");

		print "output files copied to $dst_reports_dir_BL1 \n";
	
		if($build ne "All")
		{
			if(-f "$local_path/images_up.tar.gz")
			{
				chdir("$local_path");

				#untar the images.tar.gz
				system("tar -xvzf $local_path/images_up.tar.gz");

				#remove images.tar.gz
				system("rm -rf $local_path/images_up.tar.gz");

				fcopy("$dhanushBL1_path/out/bl1.bin", "$local_path/images/boot");

				#tar the images folder to images.tar.gz
				system("tar cvzf $local_path/images_up.tar.gz images");

				#creating share location for images.tar.gz
				system("mkdir -p $dst_images_dir");

				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					#rename images
					system("mv $local_path/images $local_path/images_up_$sub_rel");

					#tar the images folder to images_$sub_rel.tar.gz
					system("tar cvzf $local_path/images_up_$sub_rel.tar.gz images_up_$sub_rel");

					#remove images_$sub_rel
					system("rm -rf $local_path/images_up_$sub_rel");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_up_$sub_rel.tar.gz", "$dst_images_dir/images_up_$sub_rel.tar.gz");

					#remove images_$sub_rel.tar.gz
					system("rm -rf $local_path/images_up_$sub_rel.tar.gz");
					
					fcopy("$dhanushBL1_path/out/bl1.bin", "$SVN_bin_path/bl1.bin");					
				}
				elsif($subject eq "Daily")
				{
					#rename images
					system("mv $local_path/images $local_path/images_up_$currentTime");

					#tar the images folder to images_$currentTime.tar.gz
					system("tar cvzf $local_path/images_up_$currentTime.tar.gz images_up_$currentTime");

					#remove images_$currentTime
					system("rm -rf $local_path/images_up_$currentTime");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_up_$currentTime.tar.gz", "$dst_images_dir/images_up_$currentTime.tar.gz");

					system("rm -rf $local_path/images_up_$currentTime.tar.gz");

					fcopy("$dhanushBL1_path/out/bl1.bin", "$SVN_bin_path/bl1.bin");
				}

				print "Done..\n";
			}
			if(-f "$local_path/images_smp.tar.gz")
			{
				chdir("$local_path");

				#untar the images.tar.gz
				system("tar -xvzf $local_path/images_smp.tar.gz");

				#remove images.tar.gz
				system("rm -rf $local_path/images_smp.tar.gz");

				fcopy("$dhanushBL1_path/out/bl1.bin", "$local_path/images/boot");

				#tar the images folder to images.tar.gz
				system("tar cvzf $local_path/images_smp.tar.gz images");

				#creating share location for images.tar.gz
				system("mkdir -p $dst_images_dir");

				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					#rename images
					system("mv $local_path/images $local_path/images_smp_$sub_rel");

					#tar the images folder to images_$sub_rel.tar.gz
					system("tar cvzf $local_path/images_smp_$sub_rel.tar.gz images_smp_$sub_rel");

					#remove images_$sub_rel
					system("rm -rf $local_path/images_smp_$sub_rel");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_smp_$sub_rel.tar.gz", "$dst_images_dir/images_smp_$sub_rel.tar.gz");

					#remove images_$sub_rel.tar.gz
					system("rm -rf $local_path/images_smp_$sub_rel.tar.gz");
					
					fcopy("$dhanushBL1_path/out/bl1.bin", "$SVN_bin_path/bl1.bin");					
				}
				elsif($subject eq "Daily")
				{
					#rename images
					system("mv $local_path/images $local_path/images_smp_$currentTime");

					#tar the images folder to images_$currentTime.tar.gz
					system("tar cvzf $local_path/images_smp_$currentTime.tar.gz images_smp_$currentTime");

					#remove images_$currentTime
					system("rm -rf $local_path/images_smp_$currentTime");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_smp_$currentTime.tar.gz", "$dst_images_dir/images_smp_$currentTime.tar.gz");

					system("rm -rf $local_path/images_smp_$currentTime.tar.gz");

					fcopy("$dhanushBL1_path/out/bl1.bin", "$SVN_bin_path/bl1.bin");
				}

				print "Done..\n";
			}
		}
			
		if($return_value=mailstatus("Buildpass"))
		{	
			if($build ne "All")
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire BL1 Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire BL1 Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
			}
			if($build eq "All")
			{
				$bl1_msg = "\n\n\nBL1:\nBL1 Build Completed Successfully for the svn check-in at $sourcecode_repo_path_BL1 with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_BL11\".";
			}
		}
	}
}

Uboot_build:
if(($build eq "DhanushUboot") || ($build eq "All"))
{

	#Declaration of repositories
	$sourcecode_repo_path_Uboot="$repository_name/Boot/U-Boot";
	$toolchain_repo_path= "http://insvn01:9090/svn/swdepot/Dhanush/Tools/Native_AON/toolchain";

	#Declaration of local path
	$dhanushUboot_path="$local_path/U-Boot";
	$change_log_src_Uboot = "$local_path/changelog_Uboot.txt";

	#Declaration of logs
	$co_log  = "$local_path/checkout_Uboot.log";
	$co_error_log = "$local_path/co_error_Uboot.log";
	$repository_info = "$local_path/repository_info_Uboot.log";
	$local_info = "$local_path/local_info_Uboot.log";

	#Declaration of destination directories
	$dst_reports_log_dir_Uboot="/home/$username/share/error_logs/U-Boot/$currentDate/$currentTime";
	$dst_reports_log_dir_Uboot1="//192.168.42.46/share/error_logs/U-Boot/$currentDate/$currentTime";

	if(!(-d "$local_path"))
	{
		system("mkdir -p $local_path");
	}

	if(-d "$dhanushUboot_path")
	{
		#check local code has any changes from SVN version, if no changes are done, do not build just send mail.
		#Read svn info
		$repo = 1;
		$local = 0;

		system("svn info $sourcecode_repo_path_Uboot --username socqa --password Yo'\$8'lc9u > $repository_info 2> $co_error_log");
		$rtn = check_info($repository_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$uboot_msg = "\n\n\nU-Boot:\nU-Boot Check Out Failed, mail has been send previously on checkout failed and can not continue U-Boot build.";
				goto bl0_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}

		system("svn info $dhanushUboot_path --username socqa --password Yo'\$8'lc9u > $local_info 2> $co_error_log");
		$rtn = check_info($local_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$uboot_msg = "\n\n\nU-Boot:\nU-Boot Check Out Failed, mail has been send previously on checkout failed and can not continue U-Boot build.";
				goto bl0_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}
		
		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		if($repo > $local)
		{
			print "SVN revisions are different need to perform build\n\n";
		}
		else
		{
			print "No need to update code and perform build\n\n";
			$body = "Hi Team,\n\n\n$mail_str(Rev No: $repo) at $sourcecode_repo_path_Uboot.\n\n\n\n****This is an Automatically generated email notification from Build server****";

			if($build eq "All")
			{
				$uboot_msg = "\n\n\nU-Boot:\n$mail_str(Rev No: $repo) at $sourcecode_repo_path_Uboot.";
				goto bl0_build;
			}
			else
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire U-Boot Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire U-Boot Build";
				}
				sendMail($Dev_team, $subject1, $body, "");
				exit;
			}
		}
	}

	#function to check the revision and check out
	$message = "tool chain";
	$rtn = checking_revision_and_checkout($toolchain_path, $toolchain_repo_path, $change_log_tc, $message, $local_path);

	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$uboot_msg = "\n\n\nU-Boot:\nToolchain Check Out Failed, mail has been send previously on checkout failed and can not continue U-Boot build.";
			goto bl0_build;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	#system("unzip -o $toolchain_path/toolchain.zip -d /home/$username > toolchain.log");
	system("rm -rf $toolchain_path/ubuntu64/mips/*");
	system("cp -r $toolchain_mips_path/* $toolchain_path/ubuntu64/mips/");	
	system("chmod -R 777 $toolchain_path/*");

	printf "Toolchain CheckOut Completed Successfully\n";

	#function to check the revision and check out
	$message = "Asthra Fire Uboot Source";

	$rtn = checking_revision_and_checkout_4_srccode($dhanushUboot_path, $sourcecode_repo_path_Uboot, $change_log_src_Uboot, $message, $local_path);
	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$uboot_msg = "\n\n\nU-Boot:\nU-Boot Check Out Failed, mail has been send previously on checkout failed and can not continue U-Boot build.";
			goto bl0_build;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	print "************************U-Boot BUILD PROCESS************************\n";

	$checkins = 1;
	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushUboot_path/build.sh";

	$build_ScriptPath = "$dhanushUboot_path/build_temp.sh";
	$count = 0;

	open(my $RD, "< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path = "export PATH=$toolchain_path/ubuntu64/mips/bin:\$PATH";

	foreach my $line (<$RD>)
	{
		print $RD1 $line;
		if($count == 0)
		{
			print $RD1 "$path\n";
		}
		$count++;
	}
	close($RD);
	close($RD1);
	system("rm -rf $srcBuild_ScriptPath");
	system("mv $build_ScriptPath $srcBuild_ScriptPath");
	system("chmod 777 $srcBuild_ScriptPath");

	chdir($dhanushUboot_path);

	$status=system("./build.sh clean; ./build.sh > U-Boot_buildlog.txt 2> U-Boot_faillog.txt");

	if((!(-f "$dhanushUboot_path/u-boot.bin")) || ($status))
	{
		print("\n U-Boot Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		$repo_print = read_last_revision($repository_info);

		$Uboot_body = "Hi Team,\n\n\nFailures observed while building the U-Boot code for the svn check-in at $sourcecode_repo_path_Uboot with revision:$repo_print.\nPlease find the build log in the share path:\"$dst_reports_log_dir_Uboot1\".";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";

		$body = "$Uboot_body$end_body";

		system("mkdir -p $dst_reports_log_dir_Uboot");
	
		fcopy("$dhanushUboot_path/U-Boot_buildlog.txt",$dst_reports_log_dir_Uboot);
		fcopy("$dhanushUboot_path/U-Boot_faillog.txt",$dst_reports_log_dir_Uboot);

		if($return_value=mailstatus("Buildfail"))
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Asthra Fire U-Boot Build Failed - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Asthra Fire U-Boot Build Failed";
			}

			sendMail($Dev_team, $subject1, $body, "");
			if($build eq "All")
			{
				$uboot_msg = "\n\n\nU-Boot:\nU-Boot Build Failed, mail has been send previously on build failed sharing the information of error logs path for SVN check-in at $sourcecode_repo_path_Uboot with revision:$repo_print.";
			}

		}
	}
	else
	{
		print "U-Boot Build completed successfully \n";
	
		$repo_print = read_last_revision($repository_info);
	
		#update the destination folder after successfull build		
		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			$dst_reports_dir_Uboot="/home/$username/share/Builds/Release_Builds/$buildnumber/$currentTime/U-Boot_$repo_print";
			$dst_reports_dir_Uboot1="//192.168.42.46/share/Builds/Release_Builds/$buildnumber/$currentTime/U-Boot_$repo_print";
		}
	
		elsif($subject eq "Daily")
		{
			$dst_reports_dir_Uboot="/home/$username/share/Builds/Daily_Builds/$currentDate/$currentTime/U-Boot_$repo_print";
			$dst_reports_dir_Uboot1="//192.168.42.46/share/Builds/Daily_Builds/$currentDate/$currentTime/U-Boot_$repo_print";
		}
	
		$Uboot_body = "Hi Team,\n\n\nU-Boot Build Completed Successfully for the svn check-in at $sourcecode_repo_path_Uboot with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_Uboot1\".";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";

		$body = "$Uboot_body$end_body";

		system("mkdir -p $dst_reports_dir_Uboot");

		#copy the output files to destination location 
		fcopy("$dhanushUboot_path/u-boot.bin", $dst_reports_dir_Uboot);

		#copying bin to local path
		fcopy("$dhanushUboot_path/u-boot.bin", "$local_path");

		fcopy("$dhanushUboot_path/u-boot.bin", "$SVN_bin_path/u-boot.bin");

		print "output files copied to $dst_reports_dir_Uboot \n";

		if($build ne "All")
		{
			if(-f "$local_path/images_up.tar.gz")
			{
				chdir("$local_path");

				#untar the images.tar.gz
				system("tar -xvzf $local_path/images_up.tar.gz");

				#remove images.tar.gz
				system("rm -rf $local_path/images_up.tar.gz");

				fcopy("$dhanushUboot_path/u-boot.bin", "$local_path/images/boot");

				#tar the images folder to images.tar.gz
				system("tar cvzf $local_path/images_up.tar.gz images");

				#creating share location for images.tar.gz
				system("mkdir -p $dst_images_dir");

				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					#rename images
					system("mv $local_path/images $local_path/images_up_$sub_rel");

					#tar the images folder to images_$sub_rel.tar.gz
					system("tar cvzf $local_path/images_up_$sub_rel.tar.gz images_up_$sub_rel");

					#remove images_$sub_rel
					system("rm -rf $local_path/images_up_$sub_rel");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_up_$sub_rel.tar.gz", "$dst_images_dir/images_up_$sub_rel.tar.gz");

					#remove images_$sub_rel.tar.gz
					system("rm -rf $local_path/images_up_$sub_rel.tar.gz");
					
					fcopy("$dhanushUboot_path/u-boot.bin", "$SVN_bin_path/u-boot.bin");					
				}
				elsif($subject eq "Daily")
				{
					#rename images
					system("mv $local_path/images $local_path/images_up_$currentTime");

					#tar the images folder to images_$currentTime.tar.gz
					system("tar cvzf $local_path/images_up_$currentTime.tar.gz images_up_$currentTime");

					#remove images_$currentTime
					system("rm -rf $local_path/images_up_$currentTime");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_up_$currentTime.tar.gz", "$dst_images_dir/images_up_$currentTime.tar.gz");

					system("rm -rf $local_path/images_up_$currentTime.tar.gz");

					fcopy("$dhanushUboot_path/u-boot.bin", "$SVN_bin_path/u-boot.bin");
				}

				print "Done..\n";
			}

			if(-f "$local_path/images_smp.tar.gz")
			{
				chdir("$local_path");

				#untar the images.tar.gz
				system("tar -xvzf $local_path/images_smp.tar.gz");

				#remove images.tar.gz
				system("rm -rf $local_path/images_smp.tar.gz");

				fcopy("$dhanushUboot_path/u-boot.bin", "$local_path/images/boot");

				#tar the images folder to images.tar.gz
				system("tar cvzf $local_path/images_smp.tar.gz images");

				#creating share location for images.tar.gz
				system("mkdir -p $dst_images_dir");

				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					#rename images
					system("mv $local_path/images $local_path/images_smp_$sub_rel");

					#tar the images folder to images_$sub_rel.tar.gz
					system("tar cvzf $local_path/images_smp_$sub_rel.tar.gz images_smp_$sub_rel");

					#remove images_$sub_rel
					system("rm -rf $local_path/images_smp_$sub_rel");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_smp_$sub_rel.tar.gz", "$dst_images_dir/images_smp_$sub_rel.tar.gz");

					#remove images_$sub_rel.tar.gz
					system("rm -rf $local_path/images_smp_$sub_rel.tar.gz");
					
					fcopy("$dhanushUboot_path/u-boot.bin", "$SVN_bin_path/u-boot.bin");					
				}
				elsif($subject eq "Daily")
				{
					#rename images
					system("mv $local_path/images $local_path/images_smp_$currentTime");

					#tar the images folder to images_$currentTime.tar.gz
					system("tar cvzf $local_path/images_smp_$currentTime.tar.gz images_smp_$currentTime");

					#remove images_$currentTime
					system("rm -rf $local_path/images_smp_$currentTime");

					#copying tar.gz to common images directory
					fcopy("$local_path/images_smp_$currentTime.tar.gz", "$dst_images_dir/images_smp_$currentTime.tar.gz");

					system("rm -rf $local_path/images_smp_$currentTime.tar.gz");

					fcopy("$dhanushUboot_path/u-boot.bin", "$SVN_bin_path/u-boot.bin");
				}

				print "Done..\n";
			}
		}
			
		if($return_value=mailstatus("Buildpass"))
		{
			if($build ne "All")
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire U-Boot Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire U-Boot Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
			}
			if($build eq "All")
			{
				$uboot_msg = "\n\n\nU-Boot:\nU-Boot Build Completed Successfully for the svn check-in at $sourcecode_repo_path_Uboot with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_Uboot1\".";
			}
		}
	}
}

bl0_build:
if(($build eq "DhanushBL0") || ($build eq "All"))
{

	#Declaration of repositories
	$sourcecode_repo_path_BL0="$repository_name/Boot/BL0";

	#Declaration of local path
	$dhanushBL0_path="$local_path/BL0";
	$change_log_src_BL0 = "$local_path/changelog_BL0.txt";

	#Declaration of logs
	$co_log  = "$local_path/checkout_BL0.log";
	$co_error_log = "$local_path/co_error_BL0.log";
	$repository_info = "$local_path/repository_info_BL0.log";
	$local_info = "$local_path/local_info_BL0.log";

	#Declaration of destination directories
	$dst_reports_log_dir_BL0="/home/$username/share/error_logs/Dhanush-BL0/$currentDate/$currentTime";
	$dst_reports_log_dir_BL01="//192.168.42.46/share/error_logs/Dhanush-BL0/$currentDate/$currentTime";

	if(!(-d "$local_path"))
	{
		system("mkdir -p $local_path");
	}

	if(-d "$dhanushBL0_path")
	{
		#check local code has any changes from SVN version, if no changes are done, do not build just send mail.
		#Read svn info
		$repo = 1;
		$local = 0;

		system("svn info $sourcecode_repo_path_BL0 --username socqa --password Yo'\$8'lc9u > $repository_info 2> $co_error_log");
		$rtn = check_info($repository_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$bl0_msg = "\n\n\nBL0:\nBL0 Check Out Failed, mail has been send previously on checkout failed and can not continue BL0 build.";
				goto build_end;
			}
			if($build ne "All")
			{
				exit;
			}
		}

		system("svn info $dhanushBL0_path --username socqa --password Yo'\$8'lc9u > $local_info 2> $co_error_log");
		$rtn = check_info($local_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$bl0_msg = "\n\n\nBL0:\nBL0 Check Out Failed, mail has been send previously on checkout failed and can not continue BL0 build.";
				goto build_end;
			}
			if($build ne "All")
			{
				exit;
			}
		}
		
		$repo = read_last_revision($repository_info);
		$local = read_last_revision($local_info);

		print "Repository revision: $repo\nLocal revision: $local\n";

		if($repo > $local)
		{
			print "SVN revisions are different need to perform build\n\n";
		}
		else
		{
			print "No need to update code and perform build\n\n";
			$body = "Hi Team,\n\n\n$mail_str(Rev No: $repo) at $sourcecode_repo_path_BL0.\n\n\n\n****This is an Automatically generated email notification from Build server****";

			if($build eq "All")
			{
				$bl0_msg = "\n\n\nBL0:\n$mail_str(Rev No: $repo) at $sourcecode_repo_path_BL0.";
				goto build_end;
			}
			else
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire BL0 Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire BL0 Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
				exit;
			}
		}
	}

	#function to check the revision and check out
	$message = "Asthra Fire BL0 Source";
	$rtn = checking_revision_and_checkout_4_srccode($dhanushBL0_path, $sourcecode_repo_path_BL0, $change_log_src_BL0, $message, $local_path);

	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$bl0_msg = "\n\n\nBL0:\nBL0 Check Out Failed, mail has been send previously on checkout failed and can not continue BL0 build.";
			goto build_end;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	print "*****************BL0 BUILD PROCESS****************************\n";

	chdir($dhanushBL0_path);

	$checkins = 1;
	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushBL0_path/config/config.mk";

	$build_ScriptPath = "$dhanushBL0_path/config/config_temp.mk";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "CROSS_COMPILE =";

	my $path = "= /home/$username/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin/mips-linux-gnu-";

	foreach my $line (<$RD>)
	{
		if($line =~ /$path_string/)
		{
			  if($line=~s/=.+\n/$path\n/)
			  {  
				print $RD1 $line;	
			  }
		}
		else
		{
			 print $RD1 $line;
		}

	}
	close($RD);
	close($RD1);
	system("rm -rf $srcBuild_ScriptPath");
	system("mv $build_ScriptPath $srcBuild_ScriptPath");
	system("chmod 777 $srcBuild_ScriptPath");

	$status=system("make clean; make > BL0_buildlog.txt 2> BL0_faillog.txt");

	if((!(-f "$dhanushBL0_path/bin/bl0.bin")) || ($status)) 
	{
		print("\n BL0 Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		$repo_print = read_last_revision($repository_info);

		$BL0_body = "Hi Team,\n\n\nFailures observed while building the BL0 code for the svn check-in at $sourcecode_repo_path_BL0 with revision:$repo_print.\nPlease find the build log in the share path:\"$dst_reports_log_dir_BL01\".";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";

		$body = "$BL0_body$end_body";

		system("mkdir -p $dst_reports_log_dir_BL0");
	
		fcopy("$dhanushBL0_path/BL0_buildlog.txt",$dst_reports_log_dir_BL0);
		fcopy("$dhanushBL0_path/BL0_faillog.txt",$dst_reports_log_dir_BL0);

		if($return_value=mailstatus("Buildfail"))
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Asthra Fire BL0 Build Failed - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Asthra Fire BL0 Build Failed";
			}

			sendMail($Dev_team, $subject1, $body, "");
			if($build eq "All")
			{
				$bl0_msg = "\n\n\nBL0:\nBL0 Build Failed, mail has been send previously on build failed sharing the information of error logs path for SVN check-in at $sourcecode_repo_path_BL0 with revision:$repo_print.";
			}
		}
	}
	else
	{
		print "BL0 Build Completed Successfully \n";
	
		$repo_print = read_last_revision($repository_info);
	
		#update the destination folder after successfull build		
		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			$dst_reports_dir_BL0="/home/$username/share/Builds/Release_Builds/$buildnumber/$currentTime/BL0_$repo_print";
			$dst_reports_dir_BL01="//192.168.42.46/share/Builds/Release_Builds/$buildnumber/$currentTime/BL0_$repo_print";
		}
	
		elsif($subject eq "Daily")
		{
			$dst_reports_dir_BL0="/home/$username/share/Builds/Daily_Builds/$currentDate/$currentTime/BL0_$repo_print";
			$dst_reports_dir_BL01="//192.168.42.46/share/Builds/Daily_Builds/$currentDate/$currentTime/BL0_$repo_print";
		}
	
		$BL0_body = "Hi Team,\n\n\nBL0 Build Completed Successfully for the svn check-in at $sourcecode_repo_path_BL0 with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_BL01\".";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";

		$body = "$BL0_body$end_body";

		system("mkdir -p $dst_reports_dir_BL0");

		#copy the output files to destination location 
		fcopy("$dhanushBL0_path/bin/bl0.bin", $dst_reports_dir_BL0);

		#copying to local path
		fcopy("$dhanushBL0_path/bin/bl0.bin", "$local_path");

		#copying to local path
		fcopy("$dhanushBL0_path/bin/bl0.bin", "$share_path");

		fcopy("$dhanushBL0_path/bin/bl0.bin", "$SVN_bin_path/bl0.bin");

		print "output files copied to $dst_reports_dir_BL0 \n";
	
		if($return_value=mailstatus("Buildpass"))
		{	
			if($build ne "All")
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Asthra Fire BL0 Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Asthra Fire BL0 Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
			}
			if($build eq "All")
			{
				$bl0_msg = "\n\n\nBL0:\nBL0 Build Completed Successfully for the svn check-in at $sourcecode_repo_path_BL0 with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_BL01\".";
			}
		}
	}
}

build_end:
if($checkins eq 1)
{
	if($build eq "All")
	{
		if(-f "$local_path/images_up.tar.gz")
		{
			chdir("$local_path");

			#untar the images.tar.gz
			system("tar -xvzf $local_path/images_up.tar.gz");

			#remove images.tar.gz
			system("rm -rf $local_path/images_up.tar.gz");

			fcopy("$local_path/aon.bin", "$local_path/images/boot");

			fcopy("$local_path/native.bin", "$local_path/images/boot");

			fcopy("$local_path/dfu.bin", "$local_path/images/boot");

			fcopy("$local_path/bl1.bin", "$local_path/images/boot");

			fcopy("$local_path/u-boot.bin", "$local_path/images/boot");

			fcopy("$local_path/Scripts/mkfs.incdhad1","$local_path/images");
		
			fcopy("$local_path/Scripts/mkheader","$local_path/images");

			dircopy("$local_path/Scripts/media","$local_path/images/media");
		
			dircopy("$local_path/Scripts/Music","$local_path/images/Music");

			fcopy("$local_path/resources/logo1.bin","$local_path/images/boot");

			#tar the images folder to images.tar.gz
			system("tar cvzf $local_path/images_up.tar.gz images");

			#creating share location for images.tar.gz
			system("mkdir -p $dst_images_dir");

			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				#rename images
				system("mv $local_path/images $local_path/images_up_$sub_rel");

				#tar the images folder to images_$sub_rel.tar.gz
				system("tar cvzf $local_path/images_up_$sub_rel.tar.gz images_up_$sub_rel");

				#remove images_$sub_rel
				system("rm -rf $local_path/images_up_$sub_rel");

				#copying tar.gz to common images directory
				fcopy("$local_path/images_up_$sub_rel.tar.gz", "$dst_images_dir/images_up_$sub_rel.tar.gz");

				#remove images_$sub_rel.tar.gz
				system("rm -rf $local_path/images_up_$sub_rel.tar.gz");
			
				fcopy("$local_path/images_up.tar.gz", "$SVN_bin_path/images_up.tar.gz");			

				$img_body="\n\n$subject Image - $sub_rel copied to $dst_images_dir1.";

			}
			elsif($subject eq "Daily")
			{
				#rename images
				system("mv $local_path/images $local_path/images_up_$currentTime");

				#tar the images folder to images_$currentTime.tar.gz
				system("tar cvzf $local_path/images_up_$currentTime.tar.gz images_up_$currentTime");

				#remove images_$currentTime
				system("rm -rf $local_path/images_up_$currentTime");

				#copying tar.gz to common images directory
				fcopy("$local_path/images_up_$currentTime.tar.gz", "$dst_images_dir/images_up_$currentTime.tar.gz");

				system("rm -rf $local_path/images_up_$currentTime.tar.gz");

				fcopy("$local_path/images_up.tar.gz", "$SVN_bin_path/images_up.tar.gz");

				$img_body="\n\nDaily Image copied to $dst_images_dir1.";
			}

			print "Done..\n";
		}

		if(-f "$local_path/images_smp.tar.gz")
		{
			chdir("$local_path");

			#untar the images.tar.gz
			system("tar -xvzf $local_path/images_smp.tar.gz");

			#remove images.tar.gz
			system("rm -rf $local_path/images_smp.tar.gz");

			fcopy("$local_path/aon.bin", "$local_path/images/boot");

			fcopy("$local_path/native.bin", "$local_path/images/boot");

			fcopy("$local_path/dfu.bin", "$local_path/images/boot");

			fcopy("$local_path/bl1.bin", "$local_path/images/boot");

			fcopy("$local_path/u-boot.bin", "$local_path/images/boot");

			fcopy("$local_path/Scripts/mkfs.incdhad1","$local_path/images");
		
			fcopy("$local_path/Scripts/mkheader","$local_path/images");

			dircopy("$local_path/Scripts/media","$local_path/images/media");

			dircopy("$local_path/Scripts/Music","$local_path/images/Music");

			fcopy("$local_path/resources/logo1.bin","$local_path/images/boot");

			#tar the images folder to images.tar.gz
			system("tar cvzf $local_path/images_smp.tar.gz images");

			#creating share location for images.tar.gz
			system("mkdir -p $dst_images_dir");

			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				#rename images
				system("mv $local_path/images $local_path/images_smp_$sub_rel");

				#tar the images folder to images_$sub_rel.tar.gz
				system("tar cvzf $local_path/images_smp_$sub_rel.tar.gz images_smp_$sub_rel");

				#remove images_$sub_rel
				system("rm -rf $local_path/images_smp_$sub_rel");

				#copying tar.gz to common images directory
				fcopy("$local_path/images_smp_$sub_rel.tar.gz", "$dst_images_dir/images_smp_$sub_rel.tar.gz");

				#remove images_$sub_rel.tar.gz
				system("rm -rf $local_path/images_smp_$sub_rel.tar.gz");
			
				fcopy("$local_path/images_smp.tar.gz", "$SVN_bin_path/images_smp.tar.gz");

				$img_body="\n\n$subject Image - $sub_rel copied to $dst_images_dir1.";

			}
			elsif($subject eq "Daily")
			{
				#rename images
				system("mv $local_path/images $local_path/images_smp_$currentTime");

				#tar the images folder to images_$currentTime.tar.gz
				system("tar cvzf $local_path/images_smp_$currentTime.tar.gz images_smp_$currentTime");

				#remove images_$currentTime
				system("rm -rf $local_path/images_smp_$currentTime");

				#copying tar.gz to common images directory
				fcopy("$local_path/images_smp_$currentTime.tar.gz", "$dst_images_dir/images_smp_$currentTime.tar.gz");

				system("rm -rf $local_path/images_smp_$currentTime.tar.gz");

				fcopy("$local_path/images_smp.tar.gz", "$SVN_bin_path/images_smp.tar.gz");

				$img_body="\n\nDaily Image copied to $dst_images_dir1.";
			}

			print "Done..\n";
		}

		$start_body = "Hi Team,";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";

		$body = "$start_body$img_body$aon_msg$native_msg$kernel_msg$bl1_msg$uboot_msg$bl0_msg$android_msg$end_body";

		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			$subject1 = "Asthra Fire $subject Builds - $sub_rel";
		}
		elsif($subject eq "Daily")
		{
			$subject1 = "Asthra Fire $subject Builds";
		}

		sendMail($Dev_team, $subject1, $body, "");
	}

	if(($subject eq "Weekly") || ($subject eq "Release"))
	{
		#To continue release numbers reading release number from local file
		open(my $RF, ">/home/$username/release.txt") || die("Can't open file: /home/$username/release.txt");

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
sub change_envfile_path
{
	$dhanush_envpath=$_[1];	
	$dhanush_env_temppath=$_[2];
	open(my $RD, "+< $dhanush_envpath") || die("Can't open file: $dhanush_envpath");
	open(my $RD1, " > $dhanush_env_temppath") || die("Can't open file: $dhanush_env_temppath");

	$fun_path=$_[0];
	my $src_string = "export SRC_ROOT=";
	my $src_path = "=$fun_path";
	my $toolchain_string = "export DK_ROOT=";
	my $toolchain_repo_path = "=$toolchain_path";

	foreach my $line (<$RD>)
	{
   		if($line =~ /$src_string/)
   		{
        		if($line=~s/=.+\n/$src_path\n/)
        		{  
				print $RD1 $line;	
			}	    
   		}
 		elsif($line =~ /$toolchain_string/)
 		{
  			  if($line=~s/=.+\n/$toolchain_repo_path\n/)
    			  {  
				print $RD1 $line;	
   			  }
  		}
 		else
 		{
   			 print $RD1 $line;
 		}

	}
	close($RD);
	close($RD1);
	system("rm -rf $dhanush_envpath");
	system("mv $dhanush_env_temppath $dhanush_envpath");
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

