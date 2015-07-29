#!/usr/bin/perl
#********************************************************************************************************************************
# 
#   File Name  :   Dhanush_buildscript_Micro_InWatch_A0.pl
#    
#   Description:  It will build the corresponding code based on the arguments received.(1 for ALL, 2 for AON, 3 for BootLoader, #		  4 for Native)
#		  1. For ALL Builds(AONsensor, Bootloader, Native)
#   	  2. It builds the AONsensor code.
#		  3. It builds the BootLoader code.
#		  4. It builds the Native code.
#	  
#********************************************************************************************************************************

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use MIME::Lite;

$num_args = @ARGV;

if($num_args < 4)
{ 
	print "Usage: perl Dhanush_buildscript_Micro_InWatch_A0.pl <1-4> <Daily/Release> <Trunk/Branch Repository name> <local path(Folder name where trunk or release codes will check out)>\n";
	die("Number of arguments are less\n");
}

$input=$ARGV[0];

if($input eq 1)
{
	print "Building DhanushAON Micro, DhanushBootLoader Micro, DhanushNative Micro InWatch_A0 Projects.....";
	$build = "All";
}
elsif($input eq 2)
{
	print "Building DhanushAON Micro Project.....";
	$build = "DhanushAON";
}
elsif($input eq 3)
{
	print "Building DhanushBootLoader Micro Project.....";
	$build = "DhanushBootLoader";
}
elsif($input eq 4)
{
	print "Building DhanushNative Micro Project.....";
	$build = "DhanushNative";
}
else
{
	print "Please Pass the arguments (1-4)\n";
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
	#open(my $RF, "</home/$username/release_micro.txt") || die("Can't open file: /home/$username/release_micro.txt");
	#@txt = <$RF>;

	#$txt_read = $txt[0];
	#chomp($txt_read);

	#$rel_number = $txt_read;
	#$sub_rel = "00.91.$rel_number";
	#close($RF);
	#$buildnumber="00.91.$rel_number";
}
else
{
	print "Please pass the proper second argument<Daily (or) Release>\n";
	exit;
}

$repository_name = $ARGV[2];

$toolchain_path="$local_path/toolchain";
$toolchain_mips_path="/home/$username/mips-2013.11";


#Declaration of Date and Time
currentdate();
my $currentDate = "$year\-$mon\-$mday";
my $currentTime = "$hr\-$min\-$sec";


if($ARGV[1] eq "Daily")
{
	$dst_images_dir = "/home/$username/share/Micro_InWatch_Builds/Daily_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Micro_InWatch_Builds/Daily_images/$currentDate";
}
elsif($ARGV[1] eq "Release")
{
	$dst_images_dir = "/home/$username/share/Micro_InWatch_Builds/Release_images/$currentDate";
	$dst_images_dir1 = "//192.168.42.46/share/Micro_InWatch_Builds/Release_images/$currentDate";
	$buildnumber="$buildnumber\_$currentDate";

	$sub_rel = "$currentTime";
	$buildnumber = "";
}

#Declaration of logs
$co_log  = "$local_path/checkout.log";
$co_error_log = "$local_path/co_error.log";
$repository_info = "$local_path/repository_info.log";
$local_info = "$local_path/local_info.log";
$change_log_tc = "$local_path/changelog_toolchain.txt";

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


#function to check the revision and check out

#Declaration of local path
$local_path_sourcecode_resources="$local_path/Ble_Firmware";
$change_log_src_resources="$local_path/changelog_Ble_Firmware.txt";
$sourcecode_repo_path_resources="http://insvn01:9090/svn/swdepot/Dhanush/SW/Branches/InWatch_A0/AONsensor/resources/Ble_Firmware";

$message = "Ble_Firmware";
$rtn = checking_revision_and_checkout_4_srccode($local_path_sourcecode_resources, $sourcecode_repo_path_resources, $change_log_src_resources, $message, $local_path);

system("svn info $sourcecode_repo_path_resources --username socqa --password Yo'\$8'lc9u > $repository_info 2> $co_error_log");
$repo = read_last_revision($repository_info);

fcopy("$local_path/Ble_Firmware/CSR_Notifications.img","$local_path");

$ble_msg = "\n\n\nInWatch_A0 BLE Firmware:\nInWatch_A0 BLE Firmware copied successfully to Daily images for the svn check-in at $sourcecode_repo_path_resources with revision: $repo.";

#Declaration of AONsensor paths
if(($build eq "DhanushAON") || ($build eq "All"))
{

	#Declaration of repositories
	$toolchain_repo_path= "http://insvn01:9090/svn/swdepot/Dhanush/Tools/Native_AON/toolchain";
	$sourcecode_repo_path="$repository_name/AONsensor";
	$aon_toolchain_path="$toolchain_path/ubuntu64/mips/bin";

	#Declaration of local path
	$dhanushaon_path="$local_path/AONsensor";
	$change_log_src = "$local_path/changelog_AONsensor.txt";

	#Declaration of DhanushAON Environment paths
	$dhanushaonenv_path="$dhanushaon_path/build/dhanushaon_env.sh";
	$dhanushaonenv_temp_path="$dhanushaon_path/build/dhanushtemp.sh";

	#declaration of destination directories
	$dst_reports_log_dir_AON="/home/$username/share/Micro_InWatch_error_logs/DhanushAON/$currentDate/$currentTime";
	$dst_reports_log_dir_AON1="//192.168.42.46/share/Micro_InWatch_error_logs/DhanushAON/$currentDate/$currentTime";


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
				$aon_msg = "\n\n\nInWatch_A0 AON:\nInWatch_A0 AONSensor Check Out Failed, mail has been send previously on checkout failed and can not continue AON build.";
				goto Bootldr_build;
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
				$aon_msg = "\n\n\nInWatch_A0 AON:\nInWatch_A0 AONSensor Check Out Failed, mail has been send previously on checkout failed and can not continue AON build.";
				goto Bootldr_build;
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
				$aon_msg = "\n\n\nInWatch_A0 AON:\n$mail_str(Rev No: $repo) at $sourcecode_repo_path.";
				goto Bootldr_build;
			}
			else
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Dhanush Micro InWatch_A0 AONsensor Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Dhanush Micro InWatch_A0 AONsensor Build";
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
			$aon_msg = "\n\n\nInWatch_A0 AON:\nToolChain Check Out Failed, mail has been send previously on checkout failed and can not continue AON build.";
			goto Bootldr_build;
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

	$message = "Dhanush AON Source";
	$rtn = checking_revision_and_checkout_4_srccode($dhanushaon_path, $sourcecode_repo_path, $change_log_src, $message, $local_path);
	
	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$aon_msg = "\n\n\nInWatch_A0 AON:\nInWatch_A0 AONSensor Check Out Failed, mail has been send previously on checkout failed and can not continue AON build.";
			goto Bootldr_build;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	$checkins = 1;
	print "*****************InWatch_A0 AONsensor BUILD PROCESS****************************\n";

	chdir($dhanushaon_path);
	#change the env path to the local path
	change_envfile_path($aon_toolchain_path,$dhanushaonenv_path,$dhanushaonenv_temp_path);

	#Build the AON Project
	$status = system(". ./build/dhanushaon_env.sh > log.txt;make clean > clobberlog.txt 2> faillog.txt; make > buildlog.txt 2>> faillog.txt");

	if (($status) || (!(-f "$dhanushaon_path/output/AON.bin") || !(-f "$dhanushaon_path/output/UI.bin")))
	{
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
		$repo_print = read_last_revision($repository_info);

		system("mkdir -p $dst_reports_log_dir_AON");
		fcopy("faillog.txt", $dst_reports_log_dir_AON);
		fcopy("buildlog.txt", $dst_reports_log_dir_AON);

		$body = "Hi Team,\n\n\nFailures observed while building the dhanush micro InWatch_A0 AON code for the svn check-in at $sourcecode_repo_path with revision:$repo_print.\nPlease find the build log in the share path:\"$dst_reports_log_dir_AON1\".	\n\n\n\n****This is an Automatically generated email notification from Build server****";

		if($return_value=mailstatus("Buildfail"))
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Dhanush Micro InWatch_A0 AONsensor Build Failed - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Dhanush Micro InWatch_A0 AONsensor Build Failed";
			}

			sendMail($Dev_team, $subject1, $body, "");		
			if($build eq "All")
			{
				$aon_msg = "\n\n\nInWatch_A0 AON:\nInWatch_A0 AON Sensor Build Failed, mail has been send previously on build failed sharing the information of error logs path for the SVN check-in at $sourcecode_repo_path with revision:$repo_print.";
			}
		}	
	}
	else
	{
		print "InWatch_A0 AONsensor Build completed successfully \n";
	
		$repo_print = read_last_revision($repository_info);

		#update the destination folder after successfull build

		if(($subject eq "Weekly") || ($subject eq "Release"))
		{		
			$dst_reports_dir_AON="/home/$username/share/Micro_InWatch_Builds/Release_Builds/$buildnumber/$currentTime/AON_$repo_print";
			$dst_reports_dir_AON1="//192.168.42.46/share/Micro_InWatch_Builds/Release_Builds/$buildnumber/$currentTime/AON_$repo_print";
		}
		elsif($subject eq "Daily")
		{
			$dst_reports_dir_AON="/home/$username/share/Micro_InWatch_Builds/Daily_Builds/$currentDate/$currentTime/AON_$repo_print";
			$dst_reports_dir_AON1="//192.168.42.46/share/Micro_InWatch_Builds/Daily_Builds/$currentDate/$currentTime/AON_$repo_print";
		}
		
		# Create share location
		system("mkdir -p $dst_reports_dir_AON");

		#copy the output files to destination location
		dircopy("$dhanushaon_path/output", $dst_reports_dir_AON);

		#copying bins to local path
		fcopy("$dhanushaon_path/output/AON.bin", "$local_path");

		fcopy("$dhanushaon_path/output/UI.bin", "$local_path");

		if($build ne "All")
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				#creating share location for images
				system("mkdir -p $dst_images_dir/$sub_rel");

				fcopy("$dhanushaon_path/output/AON.bin", "$dst_images_dir/$sub_rel");

				fcopy("$dhanushaon_path/output/UI.bin", "$dst_images_dir/$sub_rel");
			}
			elsif($subject eq "Daily")
			{
				#creating share location for images
				system("mkdir -p $dst_images_dir/$currentTime");

				fcopy("$dhanushaon_path/output/AON.bin", "$dst_images_dir/$currentTime");

				fcopy("$dhanushaon_path/output/UI.bin", "$dst_images_dir/$currentTime");
			}
		}

		print "AONsensor output files copied to $dst_reports_dir_AON \n";

		$body = "Hi Team,\n\n\nDhanush Micro InWatch_A0 AON Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print. \nPlease find the output binaries in the share path: \"$dst_reports_dir_AON1\".\n\n\n\n****This is an Automatically generated email notification from Build server****";

		if($return_value=mailstatus("Buildpass"))
		{	
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Dhanush Micro InWatch_A0 AONsensor Build - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Dhanush Micro InWatch_A0 AONsensor Build";
			}

			if($build ne "All")
			{
				sendMail($Dev_team, $subject1, $body, "");
			}
			if($build eq "All")
			{
				$aon_msg = "\n\n\nInWatch_A0 AON:\nDhanush Micro InWatch_A0 AON Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print. \nPlease find the output binaries in the share path: \"$dst_reports_dir_AON1\".";
			}
		}
	}
}

Bootldr_build:
if(($build eq "DhanushBootLoader") || ($build eq "All"))
{

	#Declaration of repositories
	$toolchain_repo_path= "http://insvn01:9090/svn/swdepot/Dhanush/Tools/Native_AON/toolchain";
	$sourcecode_repo_path="$repository_name/BootLoader";

	#Declaration of local path
	$dhanushbootldr_path="$local_path/BootLoader";
	$change_log_bootldr_src = "$local_path/changelog_BootLoader.txt";

	$dhanushBL0_path="$local_path/BootLoader/BL0";
	$dhanushelf_util_path="$local_path/BootLoader/elf_util_code";

	$dhanushbl0env_path="$dhanushBL0_path/config/config.mk";
	$dhanushbl0env_temp_path="$dhanushBL0_path/temp_bl0config.mk";

	$dhanushelf_utilenv_path="$dhanushelf_util_path/config/config.mk";
	$dhanushelf_utilenv_temp_path="$dhanushelf_util_path/temp_elfconfig.mk";

	#Declaration of destination directories
	$dst_reports_log_dir_bootldr="/home/$username/share/Micro_InWatch_error_logs/DhanushBootLoader/$currentDate/$currentTime";
	$dst_reports_log_dir_bootldr1="//192.168.42.46/share/Micro_InWatch_error_logs/DhanushBootLoader1/$currentDate/$currentTime";

	if(-d "$dhanushbootldr_path")
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
				$bootldr_msg = "\n\n\nInWatch_A0 BootLoader:\nInWatch_A0 BootLoader Check Out Failed, mail has been send previously on checkout failed and can not continue Bootloader build.";
				goto native_build;
			}
			if($build ne "All")
			{
				exit;
			}
		}
		
		system("svn info $dhanushbootldr_path --username socqa --password Yo'\$8'lc9u > $local_info 2> $co_error_log");
		$rtn = check_info($local_info, $co_error_log);

		if($rtn eq 2)
		{
			if($build eq "All")
			{
				$bootldr_msg = "\n\n\nInWatch_A0 BootLoader:\nInWatch_A0 BootLoader Check Out Failed, mail has been send previously on checkout failed and can not continue BootLoader build.";
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
				$bootldr_msg = "\n\n\nInWatch_A0 BootLoader:\n$mail_str(Rev No: $repo) at $sourcecode_repo_path.";
				goto native_build;
			}
			else
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Dhanush Micro InWatch_A0 BootLoader Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Dhanush Micro InWatch_A0 BootLoader Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
				exit;
			}
		}
	}

	$message = "Dhanush InWatch_A0 BootLoader Source";
	$rtn = checking_revision_and_checkout_4_srccode($dhanushbootldr_path, $sourcecode_repo_path, $change_log_src, $message, $local_path);

	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$bootldr_msg = "\n\n\nInWatch_A0 BootLoader:\nInWatch_A0 BootLoader Check Out Failed, mail has been send previously on checkout failed and can not continue BootLoader build.";
			goto native_build;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	print "*****************InWatch_A0 BootLoader BUILD PROCESS****************************\n";	

	$checkins = 1;
	change_envfile_path($dhanushBL0_path,$dhanushbl0env_path,$dhanushbl0env_temp_path);

	change_envfile_path($dhanushelf_util_path,$dhanushelf_utilenv_path,$dhanushelf_utilenv_temp_path);


	#Build the BootLoader Project

	chdir($dhanushbootldr_path);

	system("rm -rf $dhanushBL0_path/Bootloader.bin");

	system("chmod -R 777 gen_bins.sh");

	$status = system("./gen_bins.sh> buildlog.txt 2> faillog.txt");

	if (($status) || (!(-f "$dhanushelf_util_path/bin/spiutil.elf")) || (!(-f "$dhanushBL0_path/bin/d_bl0.bin")) || (!(-f "$dhanushBL0_path/Bootloader.bin")))
	{
		print("\n InWatch_A0 BootLoader Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
		
		$repo_print = read_last_revision($repository_info);
		
		system("mkdir -p $dst_reports_log_dir_bootldr");
		fcopy("faillog.txt", $dst_reports_log_dir_bootldr);
		fcopy("buildlog.txt", $dst_reports_log_dir_bootldr);

		$body = "Hi Team,\n\n\nFailures observed while building the dhanush micro InWatch_A0 BootLoader code for the svn check-in at $sourcecode_repo_path with revision:$repo_print.\nPlease find the build log in the share path:\"$dst_reports_log_dir_bootldr1\".\n\n\n\n****This is an Automatically generated email notification from Build server****";
		
		if($return_value=mailstatus("Buildfail"))
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Dhanush Micro InWatch_A0 BootLoader Build Failed - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Dhanush Micro InWatch_A0 BootLoader Build Failed";
			}

			sendMail($Dev_team, $subject1, $body, "");

			if($build eq "All")
			{
				$bootldr_msg = "\n\n\nInWatch_A0 BootLoader:\nDhanush Micro InWatch_A0 BootLoader Build Failed, mail has been send previously on build failed sharing the information of error logs path for SVN check-in at $sourcecode_repo_path with revision:$repo_print.";
			}
		}
	}
	else
	{
		print "InWatch_A0 BootLoader Build completed successfully \n";

		$repo_print = read_last_revision($repository_info);
	
		#update the destination folder after successfull build	
		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			$dst_reports_dir_bootldr="/home/$username/share/Micro_InWatch_Builds/Release_Builds/$buildnumber/$currentTime/BootLoader_$repo_print";
			$dst_reports_dir_bootldr1="//192.168.42.46/share/Micro_InWatch_Builds/Release_Builds/$buildnumber/$currentTime/BootLoader_$repo_print";
		}
		elsif($subject eq "Daily")
		{
			$dst_reports_dir_bootldr="/home/$username/share/Micro_InWatch_Builds/Daily_Builds/$currentDate/$currentTime/BootLoader_$repo_print";
			$dst_reports_dir_bootldr1="//192.168.42.46/share/Micro_InWatch_Builds/Daily_Builds/$currentDate/$currentTime/BootLoader_$repo_print";
		}
		
		#creating share location
		system("mkdir -p $dst_reports_dir_bootldr");

		#copy the output files to destination location 
		fcopy("$dhanushelf_util_path/bin/spiutil.elf", $dst_reports_dir_bootldr);
		fcopy("$dhanushBL0_path/Bootloader.bin", $dst_reports_dir_bootldr);

		#copying images to local path
		fcopy("$dhanushelf_util_path/bin/spiutil.elf", "$local_path");
		fcopy("$dhanushBL0_path/Bootloader.bin", "$local_path");

		if($build ne "All")
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				#creating share location for images
				system("mkdir -p $dst_images_dir/$sub_rel");

				fcopy("$dhanushelf_util_path/bin/spiutil.elf", "$dst_images_dir/$sub_rel");
				fcopy("$dhanushBL0_path/Bootloader.bin", "$dst_images_dir/$sub_rel");
			}
			elsif($subject eq "Daily")
			{
				#creating share location for images
				system("mkdir -p $dst_images_dir/$currentTime");

				fcopy("$dhanushelf_util_path/bin/spiutil.elf", "$dst_images_dir/$currentTime");
				fcopy("$dhanushBL0_path/Bootloader.bin", "$dst_images_dir/$currentTime");
			}
		}
		$body = "Hi Team,\n\n\nDhanush Micro InWatch_A0 BootLoader Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_bootldr1\".	\n\n\n\n****This is an Automatically generated email notification from Build server****";
	
		if($return_value=mailstatus("Buildpass"))
		{
			if($build ne "All")
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Dhanush Micro InWatch_A0 BootLoader Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Dhanush Micro InWatch_A0 BootLoader Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
			}
			if($build eq "All")
			{
				$bootldr_msg = "\n\n\nInWatch_A0 BootLoader:\nDhanush Micro InWatch_A0 BootLoader Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_bootldr1\".";
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

	#Declaration of DhanushNative environment paths
	$dhanushnativeenv_path="$dhanushnative_path/build/scripts/native_env.sh";
	$dhanushnativeenv_temp_path="$dhanushnative_path/build/scripts/temp.sh";

	#Declaration of destination directories
	$dst_reports_log_dir_Native="/home/$username/share/Micro_InWatch_error_logs/DhanushNative/$currentDate/$currentTime";
	$dst_reports_log_dir_Native1="//192.168.42.46/share/Micro_InWatch_error_logs/DhanushNative/$currentDate/$currentTime";

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
				$native_msg = "\n\n\nInWatch_A0 Native:\nInWatch_A0 Native Check Out Failed, mail has been send previously on checkout failed and can not continue Native build.";
				goto build_end;
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
				$native_msg = "\n\n\nInWatch_A0 Native:\nInWatch_A0 Native Check Out Failed, mail has been send previously on checkout failed and can not continue Native build.";
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
			$body = "Hi Team,\n\n\n$mail_str(Rev No: $repo) at $sourcecode_repo_path.\n\n\n\n****This is an Automatically generated email notification from Build server****";

			if($build eq "All")
			{
				$native_msg = "\n\n\nInWatch_A0 Native:\n$mail_str(Rev No: $repo) at $sourcecode_repo_path.";
				goto build_end;
			}
			else
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Dhanush Micro InWatch_A0 Native Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Dhanush Micro InWatch_A0 Native Build";
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
			$native_msg = "\n\n\nInWatch_A0 Native:\nToolchain Check Out Failed, mail has been send previously on checkout failed and can not continue Native build.";
			goto build_end;
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

	$message = "Dhanush Native Source";
	$rtn = checking_revision_and_checkout_4_srccode($dhanushnative_path, $sourcecode_repo_path, $change_log_src, $message, $local_path);

	if($rtn eq 2)
	{
		if($build eq "All")
		{
			$native_msg = "\n\n\nInWatch_A0 Native:\nInWatch_A0 Native Check Out Failed, mail has been send previously on checkout failed and can not continue Native build.";
			goto build_end;
		}
		if($build ne "All")
		{
			exit;
		}
	}

	$checkins = 1;
	print "*****************InWatch_A0 Native BUILD PROCESS****************************\n";	

	chdir($dhanushnative_path);
	#change the env path to the local path
	change_envfile_path($dhanushnative_path,$dhanushnativeenv_path,$dhanushnativeenv_temp_path);

	#Declaration of DhanushNative environment paths
	$srcBuild_ScriptPath="$dhanushnative_path/gen_bin.sh";
	$build_ScriptPath="$dhanushnative_path/temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "mips-sde-elf-objcopy";

	my $path = "/home/socplatform-qa/InWatch/toolchain/ubuntu64/mips/bin/mips-sde-elf-objcopy";

	foreach my $line (<$RD>)
	{
		if($line =~ /.+$path_string/)
		{
			  if($line=~s/.+$path_string/$path/)
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

	#Build the Native Project
	$status = system(". ./build/scripts/native_env.sh > log.txt; ./gen_bin.sh > buildlog.txt 2> faillog.txt");

	if (($status) || (!(-f "$dhanushnative_path/output/Native.bin")))
	{
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
		
		$repo_print = read_last_revision($repository_info);
		
		system("mkdir -p $dst_reports_log_dir_Native");
		fcopy("faillog.txt", $dst_reports_log_dir_Native);
		fcopy("buildlog.txt", $dst_reports_log_dir_Native);

		$body = "Hi Team,\n\n\nFailures observed while building the dhanush micro InWatch_A0 Native code for the svn check-in at $sourcecode_repo_path with revision:$repo_print.\nPlease find the build log in the share path:\"$dst_reports_log_dir_Native1\".\n\n\n\n****This is an Automatically generated email notification from Build server****";
		
		if($return_value=mailstatus("Buildfail"))
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				$subject1 = "Dhanush Micro InWatch_A0 Native Build Failed - $sub_rel";
			}
			elsif($subject eq "Daily")
			{
				$subject1 = "Dhanush Micro InWatch_A0 Native Build Failed";
			}

			sendMail($Dev_team, $subject1, $body, "");

			if($build eq "All")
			{
				$native_msg = "\n\n\nInWatch_A0 Native:\nDhanush Micro InWatch_A0 Native Build Failed, mail has been send previously on build failed sharing the information of error logs path for SVN check-in at $sourcecode_repo_path with revision:$repo_print.";
			}
		}
	}
	else
	{
		print "InWatch_A0 Native Build completed successfully \n";

		$repo_print = read_last_revision($repository_info);
	
		#update the destination folder after successfull build	
		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			$dst_reports_dir_Native="/home/$username/share/Micro_InWatch_Builds/Release_Builds/$buildnumber/$currentTime/Native_$repo_print";
			$dst_reports_dir_Native1="//192.168.42.46/share/Micro_InWatch_Builds/Release_Builds/$buildnumber/$currentTime/Native_$repo_print";
		}
		elsif($subject eq "Daily")
		{
			$dst_reports_dir_Native="/home/$username/share/Micro_InWatch_Builds/Daily_Builds/$currentDate/$currentTime/Native_$repo_print";
			$dst_reports_dir_Native1="//192.168.42.46/share/Micro_InWatch_Builds/Daily_Builds/$currentDate/$currentTime/Native_$repo_print";
		}
			
		#creating share location
		system("mkdir -p $dst_reports_dir_Native");

		#copy the output files to destination location 
		dircopy("$dhanushnative_path/output", $dst_reports_dir_Native);

		#copying images to local path
		fcopy("$dhanushnative_path/output/Native.bin", "$local_path");

		if($build ne "All")
		{
			if(($subject eq "Weekly") || ($subject eq "Release"))
			{
				#creating share location for images
				system("mkdir -p $dst_images_dir/$sub_rel");

				fcopy("$dhanushnative_path/output/Native.bin", "$dst_images_dir/$sub_rel");
			}
			elsif($subject eq "Daily")
			{
				#creating share location for images
				system("mkdir -p $dst_images_dir/$currentTime");

				fcopy("$dhanushnative_path/output/Native.bin", "$dst_images_dir/$currentTime");
			}
		}

		$body = "Hi Team,\n\n\nDhanush Micro InWatch_A0 Native Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_Native1\".	\n\n\n\n****This is an Automatically generated email notification from Build server****";
	
		if($return_value=mailstatus("Buildpass"))
		{
			if($build ne "All")
			{
				if(($subject eq "Weekly") || ($subject eq "Release"))
				{
					$subject1 = "Dhanush Micro InWatch_A0 Native Build - $sub_rel";
				}
				elsif($subject eq "Daily")
				{
					$subject1 = "Dhanush Micro InWatch_A0 Native Build";
				}

				sendMail($Dev_team, $subject1, $body, "");
			}
			if($build eq "All")
			{
				$native_msg = "\n\n\nInWatch_A0 Native:\nDhanush Micro InWatch_A0 Native Build Completed Successfully for the svn check-in at $sourcecode_repo_path with revision: $repo_print.\nPlease find the output binaries in the share path: \"$dst_reports_dir_Native1\".";
			}
		}
	}
}

build_end:

if($checkins eq 1)
{
	if($build eq "All")
	{
		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			#creating share location for images
			system("mkdir -p $dst_images_dir/$sub_rel");
		
			#copy the output files to destination location 
			fcopy("$local_path/AON.bin", "$dst_images_dir/$sub_rel") or die $!;
			fcopy("$local_path/UI.bin", "$dst_images_dir/$sub_rel") or die $!;

			fcopy("$local_path/spiutil.elf", "$dst_images_dir/$sub_rel") or die $!;
			fcopy("$local_path/Bootloader.bin", "$dst_images_dir/$sub_rel") or die $!;

			fcopy("$local_path/Native.bin", "$dst_images_dir/$sub_rel") or die $!;

			fcopy("$local_path/CSR_Notifications.img", "$dst_images_dir/$sub_rel") or die $!;
		}
		elsif($subject eq "Daily")
		{
			#creating share location for images
			system("mkdir -p $dst_images_dir/$currentTime");

			#copy the output files to destination location 
			fcopy("$local_path/AON.bin", "$dst_images_dir/$currentTime") or die $!;
			fcopy("$local_path/UI.bin", "$dst_images_dir/$currentTime") or die $!;

			fcopy("$local_path/spiutil.elf", "$dst_images_dir/$currentTime") or die $!;
			fcopy("$local_path/Bootloader.bin", "$dst_images_dir/$currentTime") or die $!;

			fcopy("$local_path/Native.bin", "$dst_images_dir/$currentTime") or die $!;

			fcopy("$local_path/CSR_Notifications.img", "$dst_images_dir/$currentTime") or die $!;
		}

		print "Dhanush Micro InWatch_A0 binaries are copied to $dst_images_dir \n";

		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			$img_body="\n\n$subject Image - $sub_rel copied to $dst_images_dir1.";
		}
		elsif($subject eq "Daily")
		{
			$img_body="\n\nDaily Image copied to $dst_images_dir1.";
		}

		$start_body = "Hi Team,";
		$end_body = "\n\n\n\n****This is an Automatically generated email notification from Build server****";

		$body = "$start_body$img_body$ble_msg$aon_msg$bootldr_msg$native_msg$end_body";

		if(($subject eq "Weekly") || ($subject eq "Release"))
		{
			$subject1 = "Dhanush Micro InWatch_A0 $subject Builds - $sub_rel";
		}
		elsif($subject eq "Daily")
		{
			$subject1 = "Dhanush Micro InWatch_A0 $subject Builds";
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
	my $src_string = "export TOOL_CHAIN=";
	my $src_path = "=$fun_path";
	my $toolchain_string = "export DK_ROOT=";
	my $toolchain_repo_path = "=$toolchain_path";
	my $codesourcery_string = "CROSS_COMPILE =";
	my $codesourcery_path ="= /home/$username/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin/mips-linux-gnu-";

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
 		elsif($line =~ /$codesourcery_string/)
 		{
  			  if($line=~s/=.+\n/$codesourcery_path\n/)
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

sub change_configfile_path
{
	$dhanush_envpath=$_[1];	
	$dhanush_env_temppath=$_[2];
	open(my $RD, "+< $dhanush_envpath") || die("Can't open file: $dhanush_envpath");
	open(my $RD1, " > $dhanush_env_temppath") || die("Can't open file: $dhanush_env_temppath");

	$fun_path=$_[0];
	my $src_string = "export BABEL_CONFIG_FILE=";
	my $src_path = "=$fun_path";
	
	foreach my $line (<$RD>)
	{
   		if($line =~ /$src_string/)
   		{
        		if($line=~s/=.+\n/$src_path\n/)
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

