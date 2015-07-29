#!/usr/bin/perl
#********************************************************************************************************************\
# 
#   File Name  :   buildscript.pl
#    
#   Description:  It will build the corresponding code based on the arguments received.Developer will 
#		  receive a mail if build either passed or failed,with all corresponding logs/ouputs in one location.
#   	
# ********************************************************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use MIME::Lite;

$server_path=$ARGV[0];
$dev_folder=$ARGV[1];
$patch_file=$ARGV[2];
$lst=$ARGV[3];
$android_update_path =$ARGV[4];
$username =$ARGV[5];
$password =$ARGV[6];
$androidbuild =$ARGV[7];
$build_team=$ARGV[8];

$username_sys="socplatform-qa";

my $image_log="$server_path/image.log";

$code_base_name = $patch_file;
$code_base="$server_path";

$repository_info = "$code_base/$dev_folder/repository_info.log";

$patch_file = "$patch_file.patch";

$local_path = "/media/Data/trunk_wc";

$bins_path = "$local_path/SVN_bins";

if($lst eq "Adv-trunk")
{
	$bins_path = "$local_path/SVN_bins";
}
else
{
	$bins_path = "$local_path/SVN_bins/release";
}

$dst_images_dir = "$local_path/build_requests";
$dst_images_dir1 = "//192.168.42.46/build_requests";

system("sudo chmod -R 777 $dst_images_dir");

$codebase_devfolder = "$code_base/$dev_folder";

open(FH,"< $code_base/$dev_folder/details.log") || die("Can't open file: $code_base/$dev_folder/details.log in build script");
my($bugid,$crnum,$username);
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
}
close(FH);

$mail_details="Your Check-in request details:\n
Bug: $bugid
Code base: $code_base_name
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

$details = "$code_base_name\_$dev_folder\_$username";

#checking the image.log is existed or not. if not, creating the log file and writing "build started" to the file.
if(!(-e $image_log))
{
	open(FH,"> $image_log") || die("Can't open file: $image_log in build script");
	print FH "build started";
	close FH;
}

$toolchain_path="/home/socplatform-qa/toolchain";

#Declaration of AONsensor paths
if($patch_file eq "AONsensor.patch")
{
	$dhanushaon_path="$code_base/$dev_folder/AONsensor";
	$dhanushaonenv_path="$dhanushaon_path/build/scripts/dhanushaon_env.sh";
	$dhanushaonenv_temp_path="$dhanushaon_path/build/scripts/dhanushtemp.sh";
	$dst_reports_log_dir_AON="$dst_images_dir/error_logs/$details";
	$dst_reports_log_dir_AON1="$dst_images_dir1/error_logs/$details";
	$name="AON";
	$name1="AONsensor";
}
#Declaration of DhanushNative paths
elsif($patch_file eq "Native.patch")
{
	$dhanushnative_path="$code_base/$dev_folder/Native";
	$dhanushnativeenv_path="$dhanushnative_path/build/scripts/native_env.sh";
	$dhanushnativeenv_temp_path="$dhanushnative_path/build/scripts/temp.sh";
	$dst_reports_log_dir_Native="$dst_images_dir/error_logs/$details";
	$dst_reports_log_dir_Native1="$dst_images_dir1/error_logs/$details";
	$name="NATIVE";
	$name1="Native";
}
#Declaration of unified Kernel paths
elsif($patch_file eq "android-linux-mti-unif-3.10.14.patch")
{
	$dhanushandroid_path="$code_base/$dev_folder";
	$dhanush_unif_kernel_path="$code_base/$dev_folder/android-linux-mti-unif-3.10.14";
	$dst_reports_log_dir_Kernel="$dst_images_dir/error_logs/$details";
	$dst_reports_log_dir_Kernel1="$dst_images_dir1/error_logs/$details";
	$name="UNIFIED KERNEL";
	$name1="android-linux-mti-unif-3.10.14";
}
#Declaration of BL1 paths
elsif($patch_file eq "BL1.patch")
{
	$dhanushBL1_path="$code_base/$dev_folder/BL1";
	$dst_reports_log_dir_BL1="$dst_images_dir/error_logs/$details";
	$dst_reports_log_dir_BL11="$dst_images_dir1/error_logs/$details";
	$name="BL1";
	$name1="BL1";
}
#Declaration of BL0 paths
elsif($patch_file eq "BL0.patch")
{
	$dhanushBL0_path="$code_base/$dev_folder/BL0";
	$dst_reports_log_dir_BL0="$dst_images_dir/error_logs/$details";
	$dst_reports_log_dir_BL01="$dst_images_dir1/error_logs/$details";
	$name="BL0";
	$name1="BL0";
}
#Declaration of U-Boot paths
elsif($patch_file eq "U-Boot.patch")
{
	$dhanushUboot_path="$code_base/$dev_folder/U-Boot";
	$dst_reports_log_dir_Uboot="$dst_images_dir/error_logs/$details";
	$dst_reports_log_dir_Uboot1="$dst_images_dir1/error_logs/$details";
	$name="U-Boot";
	$name1="U-Boot";
}
#Declaration of DFU paths
elsif($patch_file eq "DFU_SDK_NAND.patch")
{
	$dhanushDFU_path="$code_base/$dev_folder/DFU_SDK_NAND";
	$dst_reports_log_dir_dfu="$dst_images_dir/error_logs/$details";
	$dst_reports_log_dir_dfu1="$dst_images_dir1/error_logs/$details";
	$name="DFU";
	$name1="DFU_SDK_NAND";
}
#Declaration of SPI Load paths
elsif($patch_file eq "SPILoadUtility.patch")
{
	$dhanushLoadSPI_path="$code_base/$dev_folder/SPILoadUtility";
	$dst_reports_log_dir_loadspi="$dst_images_dir/error_logs/$details";
	$dst_reports_log_dir_loadspi1="$dst_images_dir1/error_logs/$details";
	$name="LOADSPI";
	$name1="SPILoadUtility";
}
#Declaration of BL1_SD_FAT paths
elsif($patch_file eq "BL1_REV1.patch")
{
	$dhanushBL1_SD_path="$code_base/$dev_folder/BL1_REV1";
	$dst_reports_log_dir_BL1_SD="$dst_images_dir/error_logs/$details";
	$dst_reports_log_dir_BL1_SD1="$dst_images_dir1/error_logs/$details";
	$name="BL1_REV1";
	$name1="BL1_REV1";
}
#Declaration of Android FS(Kitkat 4.4.2) paths
elsif($patch_file eq "AndroidKK4.4.2.patch")
{
	$dhanushandroid_path="$code_base/$dev_folder";
	$dhanushandroid_KK_path="$android_update_path/AndroidKK4.4.2";
	$dst_reports_log_dir_Android="$dst_images_dir/error_logs/$details";
	$dst_reports_log_dir_Android1="$dst_images_dir1/error_logs/$details";
	$name="ANDROID KITKAT 4.4.2";
	$name1="AndroidKK4.4.2";
}
#Declaration of SGX paths
elsif($patch_file eq "SGX.patch")
{
	$dhanushandroid_path="$code_base/$dev_folder";
	$dhanushSGX_path="$code_base/$dev_folder/SGX";
	$dst_reports_log_dir_SGX="$dst_images_dir/error_logs/$details";
	$dst_reports_log_dir_SGX1="$dst_images_dir1/error_logs/$details";
	$name="SGX";
	$name1="SGX";
}

$passed_subj="[$name] Build is PASSED with code changes of bug - $bugid";
$failed_subj="[$name] Build is FAILED with code changes of bug - $bugid";

if($patch_file eq "AONsensor.patch")
{

	print "*****************AONsensor BUILD PROCESS****************************\n";
	#delete the output folder with contents and create new output folder 
	system("rm -rf $dhanushaon_path/output"); 
	system("mkdir $dhanushaon_path/output");

	chdir($dhanushaon_path);
	#change the env path to the local path
	change_envfile_path($dhanushaon_path,$dhanushaonenv_path,$dhanushaonenv_temp_path);

	#Build the AON Project
	$status = system(". ./build/scripts/dhanushaon_env.sh > $code_base/$dev_folder/log.txt;./aon_build.sh > $code_base/$dev_folder/buildlog.txt 2>> $code_base/$dev_folder/faillog.txt");

	if((!(-f "$dhanushaon_path/output/aon.bin") || !(-f "$dhanushaon_path/output/dfu.bin") ) || ($status)) 
	{
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");

		system("mkdir -p -m 0777 $dst_reports_log_dir_AON");

		fcopy("$code_base/$dev_folder/faillog.txt", $dst_reports_log_dir_AON) || die("Can't copy file: $code_base/$dev_folder/faillog.txt to $dst_reports_log_dir_AON");

		fcopy("$code_base/$dev_folder/buildlog.txt", $dst_reports_log_dir_AON) || die("Can't copy file: $code_base/$dev_folder/buildlog.txt to $dst_reports_log_dir_AON");

		$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir_AON1\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

		sendMail($Dev_team, $build_team, $failed_subj, $body, "");

		delete_folder();
	}
	else
	{
		print "AONsensor Build Completed successfully \n";

		#wait for unlock the image.log
		wait_until_unlock_logfile($image_log);

		#lock the image.log untill the updates completed.
		open(FH1,"> $image_log") || die("Can't open file: $image_log in AON build script");
		print FH1 "preparing images tar...";

		#copying tar.gz to common images directory
		fcopy("$bins_path/images_up.tar.gz", "$code_base/$dev_folder/images_up.tar.gz") || die("Can't copy file $bins_path/images_up.tar.gz to $code_base/$dev_folder/images_up.tar.gz in AON build script");

		if(-f "$code_base/$dev_folder/images_up.tar.gz")
		{
			chdir("$code_base/$dev_folder") || die("Can't change directory to $code_base/$dev_folder");

			#untar the images_up.tar.gz
			system("tar -xvzf images_up.tar.gz");

			#remove images_up.tar.gz
			system("rm -rf images_up.tar.gz");

			fcopy("$dhanushaon_path/output/aon.bin", "images/boot") || die("Can't copy file: $dhanushaon_path/output/aon.bin to images/boot");

			fcopy("$dhanushaon_path/output/dfu.bin", "images/boot") || die("Can't copy file: $dhanushaon_path/output/dfu.bin to images/boot");

			#tar the images folder to images_up.tar.gz
			system("tar cvzf $code_base/$dev_folder/images_up.tar.gz images");

			#remove images
			system("rm -rf images");

			#copying tar.gz to common images directory
			fcopy("images_up.tar.gz", "$dst_images_dir/images_up_$details.tar.gz") || die("Can't copy file to $dst_images_dir/images_up_$details.tar.gz in AON build script");
		}

		#copying tar.gz to common images directory
		fcopy("$bins_path/images_smp.tar.gz", "$code_base/$dev_folder/images_smp.tar.gz") || die("Can't copy file $bins_path/images_smp.tar.gz to $code_base/$dev_folder/images_smp.tar.gz in AON build script");

		if(-f "$code_base/$dev_folder/images_smp.tar.gz")
		{
			chdir("$code_base/$dev_folder") || die("Can't change directory to $code_base/$dev_folder");

			#untar the images_smp.tar.gz
			system("tar -xvzf images_smp.tar.gz");

			#remove images_smp.tar.gz
			system("rm -rf images_smp.tar.gz");

			fcopy("$dhanushaon_path/output/aon.bin", "images/boot") || die("Can't copy file: $dhanushaon_path/output/aon.bin to images/boot");

			fcopy("$dhanushaon_path/output/dfu.bin", "images/boot") || die("Can't copy file: $dhanushaon_path/output/dfu.bin to images/boot");

			#tar the images folder to images_smp.tar.gz
			system("tar cvzf $code_base/$dev_folder/images_smp.tar.gz images");

			#remove images
			system("rm -rf images");

			#copying tar.gz to common images directory
			fcopy("images_smp.tar.gz", "$dst_images_dir/images_smp_$details.tar.gz") || die("Can't copy file to $dst_images_dir/images_smp_$details.tar.gz in AON build script");
		}

		#unlock
		close(FH1);
		system("chmod 777 $image_log");

		$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the image available at \"$dst_images_dir1/images_up_$details.tar.gz\" and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $build_team, $passed_subj, $body, "");

		#sanity tests
		open($BS,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
		print $BS "$dev_folder\n";
		close $BS;

		fcopy("$codebase_devfolder/$name1/dhanushaon_env_tmp.sh","$codebase_devfolder/$name1/build/scripts/dhanushaon_env.sh");
	}
}

if($patch_file eq "Native.patch")
{

	print "*****************Native BUILD PROCESS****************************\n";	
	#delete the output folder with contents and create new output folder 
	system("rm -rf $dhanushnative_path/output"); 
	system("mkdir $dhanushnative_path/output");

	chdir($dhanushnative_path);
	#change the env path to the local path
	change_envfile_path($dhanushnative_path,$dhanushnativeenv_path,$dhanushnativeenv_temp_path);

	#Build the Native Project
	$status = system(". ./build/scripts/native_env.sh > $code_base/$dev_folder/log.txt; make clobber >$code_base/$dev_folder/clobber_log.txt 2> $code_base/$dev_folder/faillog.txt;make BUILD_NUC=1 rel > $code_base/$dev_folder/buildlog.txt 2>> $code_base/$dev_folder/faillog.txt;");
	if ($status) 
	{
		print("\n Build Failed, Copying Build log in to share folder and sending mail to Build Team\n");
		
		system("mkdir -p -m 0777 $dst_reports_log_dir_Native");
		fcopy("$code_base/$dev_folder/faillog.txt", $dst_reports_log_dir_Native) || die("Can't copy file $code_base/$dev_folder/faillog.txt to $dst_reports_log_dir_Native");

		fcopy("$code_base/$dev_folder/buildlog.txt", $dst_reports_log_dir_Native) || die("Can't copy file $code_base/$dev_folder/buildlog.txt to $dst_reports_log_dir_Native");

		$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir_Native1\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

		sendMail($Dev_team, $build_team, $failed_subj, $body, "");

		delete_folder();
	}
	else
	{
		print "Native Build Completed successfully \n";

		#renaming bin

		fcopy("$dhanushnative_path/output/dhanush_wearable.bin", "$dhanushnative_path/output/native.bin") || die("Can't rename file: $dhanushnative_path/output/dhanush_wearable.bin to $dhanushnative_path/output/native.bin");

		#wait for unlock the image.log
		wait_until_unlock_logfile($image_log);

		#lock the image.log untill the updates completed.
		open(FH1,"> $image_log") || die("Can't open file: $image_log in Native build script");
		print FH1 "preparing images tar...";

		#copying tar.gz to dev folder
		fcopy("$bins_path/images_up.tar.gz", "$code_base/$dev_folder/images_up.tar.gz") || die("Can't copy file $bins_path/images_up.tar.gz to $code_base/$dev_folder/images_up.tar.gz in Native build script");

		#copy the output files to destination location 
		dircopy("$dhanushnative_path/output", "$dst_images_dir/output_$details");

		if(-f "$code_base/$dev_folder/images_up.tar.gz")
		{
			chdir("$code_base/$dev_folder") || die("Can't change directory: $code_base/$dev_folder");

			#untar the images_up.tar.gz
			system("tar -xvzf images_up.tar.gz");

			#remove images_up.tar.gz
			system("rm -rf images_up.tar.gz");

			fcopy("$dhanushnative_path/output/native.bin", "images/boot") || die("Can't copy file $dhanushnative_path/output/native.bin to images/boot");

			#tar the images folder to images_up.tar.gz
			system("tar cvzf $code_base/$dev_folder/images_up.tar.gz images");

			#remove images
			system("rm -rf images");

			#copying tar.gz to common images directory
			fcopy("images_up.tar.gz", "$dst_images_dir/images_up_$details.tar.gz") || die("Can't copy file images_up.tar.gz to $dst_images_dir/images_up_$details.tar.gz in Native build script");
		}


		#copying tar.gz to dev folder
		fcopy("$bins_path/images_smp.tar.gz", "$code_base/$dev_folder/images_smp.tar.gz") || die("Can't copy file $bins_path/images_smp.tar.gz to $code_base/$dev_folder/images_smp.tar.gz in Native build script");

		if(-f "$code_base/$dev_folder/images_smp.tar.gz")
		{
			chdir("$code_base/$dev_folder") || die("Can't change directory: $code_base/$dev_folder");

			#untar the images_smp.tar.gz
			system("tar -xvzf images_smp.tar.gz");

			#remove images_smp.tar.gz
			system("rm -rf images_smp.tar.gz");

			fcopy("$dhanushnative_path/output/native.bin", "images/boot") || die("Can't copy file $dhanushnative_path/output/native.bin to images/boot");

			#tar the images folder to images_smp.tar.gz
			system("tar cvzf $code_base/$dev_folder/images_smp.tar.gz images");

			#remove images
			system("rm -rf images");

			#copying tar.gz to common images directory
			fcopy("images_smp.tar.gz", "$dst_images_dir/images_smp_$details.tar.gz") || die("Can't copy file images_smp.tar.gz to $dst_images_dir/images_smp_$details.tar.gz in Native build script");
		}

		#unlock
		close(FH1);
		system("chmod 777 $image_log");

		$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the image available at \"$dst_images_dir1/images_up_$details.tar.gz\" and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $build_team, $passed_subj, $body, "");

		#sanity tests
		open(FH,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
		print FH "$dev_folder\n";
		close FH;

		fcopy("$codebase_devfolder/$name1/native_env_tmp.sh","$codebase_devfolder/$name1/build/scripts/native_env.sh");
		system("svn revert -R $dhanushnative_path/output");

	}
}

if($patch_file eq "android-linux-mti-unif-3.10.14.patch")
{

	print "*****************UNIFIED KERNEL BUILD PROCESS****************************\n";

	#change to the current path
	chdir($dhanush_unif_kernel_path);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanush_unif_kernel_path/build.sh";

	$build_ScriptPath = "$dhanush_unif_kernel_path/build_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "export PATH=";

	my $path = "=/home/$username_sys/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin:\$PATH";

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

	$status=system("./build.sh up clean int > $code_base/$dev_folder/kernel_buildlog.txt 2> $code_base/$dev_folder/kernel_faillog.txt");

	if((-f "$dhanush_unif_kernel_path/arch/mips/boot/vmlinux.bin"))
	{
		print "Android Kernel Build Completed Successfully \n";

		$arg = $androidbuild;
		$arg3 = "up";
		$check = 0;

REPEAT_BUILD:
		build_android2($arg, $arg3);
		
		if($check eq 0)
		{
			$check = 2;
			$arg3 = "smp";
			$arg = "no";
			goto REPEAT_BUILD;
		}

		$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the image available at \"$dst_images_dir1/images_up_$details.tar.gz\" (and smp image) and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $build_team, $passed_subj, $body, "");

		#sanity tests
		open(FH,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
		print FH "$dev_folder\n";
		close FH;

		fcopy("$codebase_devfolder/$name1/build_tmp.sh","$codebase_devfolder/$name1/build.sh");
		fcopy("$codebase_devfolder/SGX/sgx_tmp.sh","$codebase_devfolder/SGX/sgx.sh");
	}
	else
	{
		print("\n Kernel Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		system("mkdir -p -m 0777 $dst_reports_log_dir_Kernel");
	
		fcopy("$code_base/$dev_folder/kernel_buildlog.txt",$dst_reports_log_dir_Kernel) || die("Can't copy file: $code_base/$dev_folder/kernel_buildlog.txt to $dst_reports_log_dir_Kernel");

		fcopy("$code_base/$dev_folder/kernel_faillog.txt",$dst_reports_log_dir_Kernel) || die("Can't copy file: $code_base/$dev_folder/kernel_faillog.txt to $dst_reports_log_dir_Kernel");

		$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir_Kernel1\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

		sendMail($Dev_team, $build_team, $failed_subj, $body, "");

		delete_folder();

		open(FH2,"> $android_update_path/revert.txt");
		print FH2 "$android_update_path";
		close(FH2);
		
		system("svn revert -R $android_update_path/AndroidKK4.4.2 --username $username --password $password > $android_update_path/revert.log 2> $android_update_path/rev_err.log");

		system("rm -rf $android_update_path/revert.txt");

		system("rm -rf $android_update_path/lock.txt");
	}

	open(FH2,"> $codebase_devfolder/Android.txt");
	print FH2 "$android_update_path";
	close(FH2);

	open(FH2,"> $android_update_path/revert.txt");
	print FH2 "$android_update_path";
	close(FH2);
		
	system("svn revert -R $android_update_path/AndroidKK4.4.2 --username $username --password $password > $android_update_path/revert.log 2> $android_update_path/rev_err.log");

	system("rm -rf $android_update_path/revert.txt");
	
}

if($patch_file eq "SGX.patch")
{

	$arg = $androidbuild;
	$arg3 = "up";
	$check = 0;

REPEAT_BUILD:
	build_android2($arg, $arg3);
		
	if($check eq 0)
	{
		$check = 2;
		$arg3 = "smp";
		$arg = "no";
		goto REPEAT_BUILD;
	}

	$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the image available at \"$dst_images_dir1/images_up_$details.tar.gz\" (and SMP image) and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

	sendMail($Dev_team, $build_team, $passed_subj, $body, "");

	#sanity tests
	open(FH,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
	print FH "$dev_folder\n";
	close FH;

	fcopy("$codebase_devfolder/$name1/sgx_tmp.sh","$codebase_devfolder/$name1/sgx.sh");
	fcopy("$codebase_devfolder/android-linux-mti-unif-3.10.14/build_tmp.sh","$codebase_devfolder/android-linux-mti-unif-3.10.14/build.sh");

	open(FH2,"> $codebase_devfolder/Android.txt");
	print FH2 "$android_update_path";
	close(FH2);

	open(FH2,"> $android_update_path/revert.txt");
	print FH2 "$android_update_path";
	close(FH2);
		
	system("svn revert -R $android_update_path/AndroidKK4.4.2 --username $username --password $password > $android_update_path/revert.log 2> $android_update_path/rev_err.log");

	system("rm -rf $android_update_path/revert.txt");		
}

if($patch_file eq "BL1.patch")
{

	print "*****************BL1 BUILD PROCESS****************************\n";

	#change to the current path
	chdir($dhanushBL1_path);
	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushBL1_path/config/config.mk";

	$build_ScriptPath = "$dhanushBL1_path/config/config_temp.mk";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "CROSS_COMPILE =";

	my $path = "= /home/$username_sys/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin/mips-linux-gnu-";

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

	$status=system("make clean; make > $code_base/$dev_folder/BL1_buildlog.txt 2> $code_base/$dev_folder/BL1_faillog.txt");

	if((!(-f "$dhanushBL1_path/out/bl1.bin")) || ($status)) 
	{
		print("\n BL1 Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		system("mkdir -p -m 0777 $dst_reports_log_dir_BL1");
	
		fcopy("$code_base/$dev_folder/BL1_buildlog.txt","$dst_reports_log_dir_BL1/BL1_buildlog.txt") || die("Can't copy file: $code_base/$dev_folder/BL1_buildlog.txt to $dst_reports_log_dir_BL1/BL1_buildlog.txt");

		fcopy("$code_base/$dev_folder/BL1_faillog.txt","$dst_reports_log_dir_BL1/BL1_faillog.txt") || die("Can't copy file: $code_base/$dev_folder/BL1_faillog.txt to $dst_reports_log_dir_BL1/BL1_faillog.txt");

		$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir_BL11\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

		sendMail($Dev_team, $build_team, $failed_subj, $body, "");

		delete_folder();
	}
	else
	{
		print "BL1 Build Completed Successfully \n";
	
		#wait for unlock the image.log
		wait_until_unlock_logfile($image_log);

		#lock the image.log untill the updates completed.
		open(FH1,"> $image_log") || die("Can't open file: $image_log in BL1 build script");
		print FH1 "preparing images tar...";

		#copying tar.gz to dev folder
		fcopy("$bins_path/images_up.tar.gz", "$code_base/$dev_folder/images_up.tar.gz") || die("Can't copy file $bins_path/images_up.tar.gz to $code_base/$dev_folder/images_up.tar.gz in BL1 build script");

		if(-f "$code_base/$dev_folder/images_up.tar.gz")
		{
			chdir("$code_base/$dev_folder") || die("Can't change directory: $code_base/$dev_folder");

			#untar the images_up.tar.gz
			system("tar -xvzf images_up.tar.gz");

			#remove images_up.tar.gz
			system("rm -rf images_up.tar.gz");

			fcopy("$dhanushBL1_path/out/bl1.bin", "images/boot") || die("Can't copy file: $dhanushBL1_path/out/bl1.bin to images/boot");

			#tar the images folder to images_up.tar.gz
			system("tar cvzf $code_base/$dev_folder/images_up.tar.gz images");

			#remove images
			system("rm -rf images");

			#copying tar.gz to common images directory
			fcopy("images_up.tar.gz", "$dst_images_dir/images_up_$details.tar.gz") || die("Can't copy file: $dst_images_dir/images_up_$details.tar.gz in BL1 build script");
		}	


		#copying tar.gz to dev folder
		fcopy("$bins_path/images_smp.tar.gz", "$code_base/$dev_folder/images_smp.tar.gz") || die("Can't copy file $bins_path/images_smp.tar.gz to $code_base/$dev_folder/images_smp.tar.gz in BL1 build script");

		if(-f "$code_base/$dev_folder/images_smp.tar.gz")
		{
			chdir("$code_base/$dev_folder") || die("Can't change directory: $code_base/$dev_folder");

			#untar the images_smp.tar.gz
			system("tar -xvzf images_smp.tar.gz");

			#remove images_smp.tar.gz
			system("rm -rf images_smp.tar.gz");

			fcopy("$dhanushBL1_path/out/bl1.bin", "images/boot") || die("Can't copy file: $dhanushBL1_path/out/bl1.bin to images/boot");

			#tar the images folder to images_smp.tar.gz
			system("tar cvzf $code_base/$dev_folder/images_smp.tar.gz images");

			#remove images
			system("rm -rf images");

			#copying tar.gz to common images directory
			fcopy("images_smp.tar.gz", "$dst_images_dir/images_smp_$details.tar.gz") || die("Can't copy file: $dst_images_dir/images_smp_$details.tar.gz in BL1 build script");
		}	

		#unlock
		close(FH1);
		system("chmod 777 $image_log");

		$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the image available at \"$dst_images_dir1/images_up_$details.tar.gz\" and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $build_team, $passed_subj, $body, "");
		
		#sanity tests
		open(FH,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
		print FH "$dev_folder\n";
		close FH;

		fcopy("$codebase_devfolder/$name1/config_tmp.mk","$codebase_devfolder/$name1/config/config.mk");
	}
}

if($patch_file eq "U-Boot.patch")
{

	print "************************U-Boot BUILD PROCESS************************\n";

	#change to the current path
	chdir($dhanushUboot_path);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushUboot_path/build.sh";

	$build_ScriptPath = "$dhanushUboot_path/build_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "export PATH=";

	my $path = "=$toolchain_path/ubuntu64/mips/bin:\$PATH";

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

	$status=system("./build.sh clean; ./build.sh > $code_base/$dev_folder/U-Boot_buildlog.txt 2> $code_base/$dev_folder/U-Boot_faillog.txt");

	if((!(-f "$dhanushUboot_path/u-boot.bin")) || ($status))
	{
		print("\n U-Boot Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		system("mkdir -p -m 0777 $dst_reports_log_dir_Uboot");
	
		fcopy("$code_base/$dev_folder/U-Boot_buildlog.txt","$dst_reports_log_dir_Uboot/U-Boot_buildlog.txt") || die("Can't copy file: $code_base/$dev_folder/U-Boot_buildlog.txt to $dst_reports_log_dir_Uboot/U-Boot_buildlog.txt");

		fcopy("$code_base/$dev_folder/U-Boot_faillog.txt","$dst_reports_log_dir_Uboot/U-Boot_faillog.txt") || die("Can't copy file: $code_base/$dev_folder/U-Boot_faillog.txt to $dst_reports_log_dir_Uboot/U-Boot_faillog.txt");

		$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir_Uboot1\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

		sendMail($Dev_team, $build_team, $failed_subj, $body, "");

		delete_folder();
	}
	else
	{
		print "U-Boot Build Completed Successfully \n";
	
		#wait for unlock the image.log
		wait_until_unlock_logfile($image_log);

		#lock the image.log untill the updates completed.
		open(FH1,"> $image_log") || die("Can't open file: $image_log in U-Boot build script");
		print FH1 "preparing images tar...";

		#copying tar.gz to dev folder
		fcopy("$bins_path/images_up.tar.gz", "$code_base/$dev_folder/images_up.tar.gz") || die("Can't copy file $bins_path/images_up.tar.gz to $code_base/$dev_folder/images_up.tar.gz in U-Boot build script");

		if(-f "$code_base/$dev_folder/images_up.tar.gz")
		{
			chdir("$code_base/$dev_folder") || die("Can't change directory: $code_base/$dev_folder");

			#untar the images_up.tar.gz
			system("tar -xvzf images_up.tar.gz");

			#remove images_up.tar.gz
			system("rm -rf images_up.tar.gz");

			fcopy("$dhanushUboot_path/u-boot.bin", "images/boot/u-boot.bin") || die("Can't copy file: $dhanushUboot_path/u-boot.bin to images/boot");

			#tar the images folder to images_up.tar.gz
			system("tar cvzf $code_base/$dev_folder/images_up.tar.gz images");

			#remove images
			system("rm -rf images");

			#copying tar.gz to common images directory
			fcopy("images_up.tar.gz", "$dst_images_dir/images_up_$details.tar.gz") || die("Can't copy file: $dst_images_dir/images_up_$details.tar.gz in U-Boot build script");
		}


		#copying tar.gz to dev folder
		fcopy("$bins_path/images_smp.tar.gz", "$code_base/$dev_folder/images_smp.tar.gz") || die("Can't copy file $bins_path/images_smp.tar.gz to $code_base/$dev_folder/images_smp.tar.gz in U-Boot build script");

		if(-f "$code_base/$dev_folder/images_smp.tar.gz")
		{
			chdir("$code_base/$dev_folder") || die("Can't change directory: $code_base/$dev_folder");

			#untar the images_smp.tar.gz
			system("tar -xvzf images_smp.tar.gz");

			#remove images_smp.tar.gz
			system("rm -rf images_smp.tar.gz");

			fcopy("$dhanushUboot_path/u-boot.bin", "images/boot/u-boot.bin") || die("Can't copy file: $dhanushUboot_path/u-boot.bin to images/boot");

			#tar the images folder to images_smp.tar.gz
			system("tar cvzf $code_base/$dev_folder/images_smp.tar.gz images");

			#remove images
			system("rm -rf images");

			#copying tar.gz to common images directory
			fcopy("images_smp.tar.gz", "$dst_images_dir/images_smp_$details.tar.gz") || die("Can't copy file: $dst_images_dir/images_smp_$details.tar.gz in U-Boot build script");
		}

		#unlock
		close(FH1);
		system("chmod 777 $image_log");

		$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the image available at \"$dst_images_dir1/images_smp_$details.tar.gz\" and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $build_team, $passed_subj, $body, "");
		
		#sanity tests
		open(FH,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
		print FH "$dev_folder\n";
		close FH;

		fcopy("$codebase_devfolder/$name1/build_tmp.sh","$codebase_devfolder/$name1/build.sh");
	}
}

if($patch_file eq "BL0.patch")
{

	print "*****************BL0 BUILD PROCESS****************************\n";

	#change to the current path
	chdir($dhanushBL0_path);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushBL0_path/config/config.mk";

	$build_ScriptPath = "$dhanushBL0_path/config/config_temp.mk";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "CROSS_COMPILE =";

	my $path = "= /home/$username_sys/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin/mips-linux-gnu-";

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

	$status=system("make clean; make > $code_base/$dev_folder/BL0_buildlog.txt 2> $code_base/$dev_folder/BL0_faillog.txt");

	if((!(-f "$dhanushBL0_path/bin/bl0.bin")) || ($status)) 
	{
		print("\n BL0 Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		system("mkdir -p -m 0777 $dst_reports_log_dir_BL0");
	
		fcopy("$code_base/$dev_folder/BL0_buildlog.txt","$dst_reports_log_dir_BL0/BL0_buildlog.txt") || die("Can't copy file: $code_base/$dev_folder/BL0_buildlog.txt to $dst_reports_log_dir_BL0/BL0_buildlog.txt");

		fcopy("$code_base/$dev_folder/BL0_faillog.txt","$dst_reports_log_dir_BL0/BL0_faillog.txt") || die("Can't copy file: $code_base/$dev_folder/BL0_faillog.txt to $dst_reports_log_dir_BL0/BL0_faillog.txt");

		$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir_BL01\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

		sendMail($Dev_team, $build_team, $failed_subj, $body, "");

		delete_folder();
	}
	else
	{
		print "BL0 Build Completed Successfully \n";
	
		$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the binary available at \"$dst_images_dir1/$details\" and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

		system("mkdir -p $dst_images_dir/$details");
		#copying to local path
		fcopy("$dhanushBL0_path/bin/bl0.bin", "$dst_images_dir/$details/bl0.bin") || die("Can't copy file: $dhanushBL0_path/bin/bl0.bin to $dst_images_dir/$details/bl0.bin");

		sendMail($Dev_team, $build_team, $passed_subj, $body, "");

		#sanity tests
		open(FH,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
		print FH "$dev_folder\n";
		close FH;

		fcopy("$codebase_devfolder/$name1/config_tmp.mk","$codebase_devfolder/$name1/config/config.mk");
	}
}

if($patch_file eq "DFU_SDK_NAND.patch")
{

	print "*****************DFU BUILD PROCESS****************************\n";

	#change to the current path
	chdir($dhanushDFU_path);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushDFU_path/config/config.mk";

	$build_ScriptPath = "$dhanushDFU_path/config/config_temp.mk";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "CROSS_COMPILE =";

	my $path = "= /home/$username_sys/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin/mips-linux-gnu-";

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

	$status=system("make clean; make > $code_base/$dev_folder/DFU_buildlog.txt 2> $code_base/$dev_folder/DFU_faillog.txt");

	if((!(-f "$dhanushDFU_path/bin/dfu.bin")) || ($status)) 
	{
		print("\n DFU Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		system("mkdir -p -m 0777 $dst_reports_log_dir_DFU");
	
		fcopy("$code_base/$dev_folder/DFU_buildlog.txt","$dst_reports_log_dir_DFU/DFU_buildlog.txt") || die("Can't copy file: $code_base/$dev_folder/DFU_buildlog.txt to $dst_reports_log_dir_DFU/DFU_buildlog.txt");

		fcopy("$code_base/$dev_folder/DFU_faillog.txt","$dst_reports_log_dir_DFU/DFU_faillog.txt") || die("Can't copy file: $code_base/$dev_folder/DFU_faillog.txt to $dst_reports_log_dir_DFU/DFU_faillog.txt");

		$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir_DFU1\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

		sendMail($Dev_team, $build_team, $failed_subj, $body, "");

		delete_folder();
	}
	else
	{
		print "DFU Build Completed Successfully \n";
	
		fcopy("$dhanushDFU_path/bin/dfu.bin", "$dst_images_dir/dfu.bin") || die("Can't copy file: $dhanushDFU_path/bin/dfu.bin to $dst_images_dir/dfu_$details.bin");

		$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the image available at \"$dst_images_dir1/dfu_$details.bin\" and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

		sendMail($Dev_team, $build_team, $passed_subj, $body, "");
		
		#sanity tests
		open(FH,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
		print FH "$dev_folder\n";
		close FH;

		fcopy("$codebase_devfolder/$name1/config_tmp.mk","$codebase_devfolder/$name1/config/config.mk");
	}
}

if($patch_file eq "BL1_REV1.patch")
{

	print "*****************BL1_SD_FAT BUILD PROCESS****************************\n";

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushBL1_SD_path/build_bl1.sh";

	$build_ScriptPath = "$dhanushBL1_SD_path/build_bl1_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "export PATH=";

	my $path = "=/home/$username_sys/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin:\$PATH";

	my $path_string1 = "CROSS_COMPILE=mips-sde-elf-";

	my $path1 = "CROSS_COMPILE=$toolchain_path/ubuntu64/mips/bin/mips-sde-elf-";

	foreach my $line (<$RD>)
	{
		if($line =~ /$path_string/)
		{
			  if($line=~s/=.+\n/$path\n/)
			  {  
				print $RD1 $line;	
			  }
		}
		elsif($line =~ /$path_string1/)
		{
			  if($line=~s/$path_string1/$path1/)
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

	chdir($dhanushBL1_SD_path);

	system("chmod -R 777 $dhanushBL1_SD_path");

	$status=system("./build_bl1.sh > BL1_SD_buildlog.txt 2> BL1_SD_faillog.txt");

	if((!(-f "$dhanushBL1_SD_path/bl1.bin")) || ($status)) 
	{
		print("\n BL1_SD_FAT Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		system("mkdir -p $dst_reports_log_dir_BL1_SD");
	
		fcopy("$dhanushBL1_SD_path/BL1_SD_buildlog.txt","$dst_reports_log_dir_BL1_SD/BL1_SD_buildlog.txt") || die("Can't copy file: $dhanushBL1_SD_path/BL1_SD_buildlog.txt to $dst_reports_log_dir_BL1_SD/BL1_SD_buildlog.txt");

		fcopy("$dhanushBL1_SD_path/BL1_SD_faillog.txt","$dst_reports_log_dir_BL1_SD/BL1_SD_faillog.txt") || die("Can't copy file: $dhanushBL1_SD_path/BL1_SD_faillog.txt to $dst_reports_log_dir_BL1_SD/BL1_SD_faillog.txt");

		$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir_BL1_SD1\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

		sendMail($Dev_team, $build_team, $failed_subj, $body, "");

		delete_folder();
	}
	else
	{
		print "BL1_SD_FAT Build completed successfully \n";
	
		$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the binary available at \"$dst_images_dir1/$details\" and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

		system("mkdir -p $dst_images_dir/$details");

		#copying bin to local path
		fcopy("$dhanushBL1_SD_path/bl1.bin", "$dst_images_dir/$details/bl1.bin") || die("Can't copy file: $dhanushBL1_SD_path/bl1.bin to $dst_images_dir/$details/bl1.bin");

		sendMail($Dev_team, $build_team, $passed_subj, $body, "");

		#sanity tests
		open(FH,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
		print FH "$dev_folder\n";
		close FH;

		fcopy("$codebase_devfolder/$name1/build_bl1_tmp.sh","$codebase_devfolder/$name1/build_bl1.sh");
	}
}

if($patch_file eq "SPILoadUtility.patch")
{

	print "*****************LoadSPI BUILD PROCESS****************************\n";

	chdir($dhanushLoadSPI_path);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushLoadSPI_path/config/config.mk";

	$build_ScriptPath = "$dhanushLoadSPI_path/config/config_temp.mk";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "CROSS_COMPILE=";

	my $path = "= /home/$username_sys/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin/mips-linux-gnu-";

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

	$status=system("make clean; make > LoadSPI_buildlog.txt 2> LoadSPI_faillog.txt");

	if((!(-f "$dhanushLoadSPI_path/bin/loadspi.bin")) || ($status)) 
	{
		print("\n LoadSPI Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		system("mkdir -p $dst_reports_log_dir_LoadSPI");
	
		fcopy("$dhanushLoadSPI_path/LoadSPI_buildlog.txt","$dst_reports_log_dir_LoadSPI/LoadSPI_buildlog.txt") || die("Can't copy file: $dhanushLoadSPI_path/LoadSPI_buildlog.txt to $dst_reports_log_dir_LoadSPI/LoadSPI_buildlog.txt");

		fcopy("$dhanushLoadSPI_path/LoadSPI_faillog.txt","$dst_reports_log_dir_LoadSPI/LoadSPI_buildlog.txt") || die("Can't copy file: $dhanushLoadSPI_path/LoadSPI_faillog.txt to $dst_reports_log_dir_LoadSPI/LoadSPI_buildlog.txt");

		$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir_LoadSPI1\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

		sendMail($Dev_team, $build_team, $failed_subj, $body, "");

		delete_folder();
	}
	else
	{
		print "LoadSPI Build completed successfully \n";

		$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the binary available at \"$dst_images_dir1/$details\" and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

		system("mkdir -p $dst_images_dir/$details");

		#copying bin to local path
		fcopy("$dhanushLoadSPI_path/bin/loadspi.bin", "$dst_images_dir/$details/loadspi.bin") || die("Can't copy file: $dhanushLoadSPI_path/bin/loadspi.bin to $dst_images_dir/$details/loadspi.bin");

		sendMail($Dev_team, $build_team, $passed_subj, $body, "");
		
		#sanity tests
		open(FH,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
		print FH "$dev_folder\n";
		close FH;

		fcopy("$codebase_devfolder/$name1/config_tmp.mk","$codebase_devfolder/$name1/config/config.mk");
	}
}

if ($patch_file eq "AndroidKK4.4.2.patch")
{

	$dhanushkernel_path = "$dhanushandroid_path/android-linux-mti-unif-3.10.14";
	
	#change to the current path
	chdir($dhanushkernel_path);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushkernel_path/build.sh";

	$build_ScriptPath = "$dhanushkernel_path/build_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "export PATH=";

	my $path = "=/home/$username_sys/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin:\$PATH";

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


	$dhanushSGX_path = "$dhanushandroid_path/SGX";
	#change to the current path
	chdir($dhanushSGX_path);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushSGX_path/sgx.sh";

	$build_ScriptPath = "$dhanushSGX_path/sgx_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "export MHOME=";
	my $path1_str = "export ANDROID_ROOT=";
	my $path2_str = "export KERNELDIR=";

	my $path = "=$dhanushandroid_path";
	my $path1 = "=$android_update_path/AndroidKK4.4.2";
	my $path2 = "=$dhanushkernel_path";

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

	if($lst eq "Adv-trunk")
	{
		fcopy("$local_path/Adv-trunk/Android/adv_fullbuild.sh", "$dhanushandroid_path/adv_fullbuild.sh");
		fcopy("$local_path/Adv-trunk/Android/adv2_fullbuild.sh", "$dhanushandroid_path/adv2_fullbuild.sh");
	}
	else
	{
		fcopy("$local_path/release/Android/adv_fullbuild.sh", "$dhanushandroid_path/adv_fullbuild.sh");
		fcopy("$local_path/release/Android/adv2_fullbuild.sh", "$dhanushandroid_path/adv2_fullbuild.sh");
	}


	#change to the current path
	chdir($dhanushandroid_path);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushandroid_path/adv2_fullbuild.sh";

	$build_ScriptPath = "$dhanushandroid_path/adv2_fullbuild_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path1_str = "export ANDROID_ROOT=";
	my $path2_str = "export DISCIMAGE=";

	my $path1 = "=$android_update_path/AndroidKK4.4.2";
	my $path2 = "=$android_update_path/AndroidKK4.4.2/images/sgx_bin";

	foreach my $line (<$RD>)
	{
		if($line =~ /$path1_str/)
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

	$arg = $androidbuild;
	$arg3 = "up";
	$check = 0;

REPEAT_BUILD:

	print "*****************ANDROID BUILD PROCESS****************************\n";

	#change to the current path
	chdir($dhanushandroid_path) || die("Can't change directory: $dhanushandroid_path");

	$status = system("./adv2_fullbuild.sh $arg int $arg3 > $code_base/$dev_folder/android_buildlog.txt 2> $code_base/$dev_folder/android_faillog.txt");
	if((!(-f "$dhanushandroid_KK_path/images/rfs/system.img")) || ($status)) 
	{

		print("\n Android FS(Kitkat)Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		system("mkdir -p -m 0777 $dst_reports_log_dir_Android");

		dircopy("$dhanushandroid_KK_path/logs","$dst_reports_log_dir_Android/logs") || die("Can't copy directory: $dhanushandroid_KK_path/logs to $dst_reports_log_dir_Android/logs");

		$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir_Android1\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

		sendMail($Dev_team, $build_team, $failed_subj, $body, "");

		open(FH2,"> $android_update_path/revert.txt");
		print FH2 "$android_update_path";
		close(FH2);
		
		system("svn revert -R $android_update_path/AndroidKK4.4.2 --username $username --password $password > $android_update_path/revert.log 2> $android_update_path/rev_err.log");

		system("rm -rf $android_update_path/revert.txt");

		system("rm -rf $android_update_path/lock.txt");

		delete_folder();

		exit;
	}
	else
	{
		print "Android FS(Kitkat) Build completed successfully \n";
		
		$body = "Dear $username,\n\n\n$mail_details\nThe build of your changes has PASSED.\n\nPlease perform the Sanity on the image available at \"$dst_images_dir1/images_$details.tar.gz\" and Please submit the sanity result and this check-in ID - \"$dev_folder\" to Build server(in Sanity Request form) for check-in the code changes of bug - $bugid to SVN.\n\n\n****This is an Automatically generated email notification from Build server****";

		#wait for unlock the image.log
		wait_until_unlock_logfile($image_log);

		#lock the image.log untill the updates completed.
		open(FH1,"> $image_log") || die("Can't open file: $image_log in Android FS build script");
		print FH1 "preparing images tar...";

		fcopy("$bins_path/aon.bin", "$android_update_path/AndroidKK4.4.2/images/boot");

		fcopy("$bins_path/native.bin", "$android_update_path/AndroidKK4.4.2/images/boot");

		fcopy("$bins_path/dfu.bin", "$android_update_path/AndroidKK4.4.2/images/boot");

		fcopy("$bins_path/bl1.bin", "$android_update_path/AndroidKK4.4.2/images/boot");

		fcopy("$bins_path/u-boot.bin", "$android_update_path/AndroidKK4.4.2/images/boot");


		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/arch/mips/boot/vmlinux.bin", "$android_update_path/AndroidKK4.4.2/images/boot");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wlcore/wlcore.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wlcore/wlcore_sdio.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wl12xx/wl12xx.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/misc/ti-st/tty_hci.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/misc/ti-st/st_drv.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$dhanushandroid_path/SGX/eurasia_km/eurasiacon/binary2_incdhad1_android_release/target/dc_incdhad1.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$dhanushandroid_path/SGX/eurasia_km/eurasiacon/binary2_incdhad1_android_release/target/pvrsrvkm.ko","$android_update_path/AndroidKK4.4.2/images/modules");


		fcopy("$android_update_path/AndroidKK4.4.2/hardware/img/combined_source/imgvideo/imgvideo.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$android_update_path/AndroidKK4.4.2/hardware/img/combined_source/vdec/vdecdd.ko","$android_update_path/AndroidKK4.4.2/images/modules");


		system("mkdir -p -m 0777 $dhanushandroid_path/$arg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/arch/mips/boot/vmlinux.bin", "$dhanushandroid_path/$arg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wlcore/wlcore.ko","$dhanushandroid_path/$arg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wlcore/wlcore_sdio.ko","$dhanushandroid_path/$arg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wl12xx/wl12xx.ko","$dhanushandroid_path/$arg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/misc/ti-st/tty_hci.ko","$dhanushandroid_path/$arg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/misc/ti-st/st_drv.ko","$dhanushandroid_path/$arg3");

		fcopy("$dhanushandroid_path/SGX/eurasia_km/eurasiacon/binary2_incdhad1_android_release/target/dc_incdhad1.ko","$dhanushandroid_path/$arg3");

		fcopy("$dhanushandroid_path/SGX/eurasia_km/eurasiacon/binary2_incdhad1_android_release/target/pvrsrvkm.ko","$dhanushandroid_path/$arg3");


		fcopy("$android_update_path/AndroidKK4.4.2/hardware/img/combined_source/imgvideo/imgvideo.ko","$dhanushandroid_path/$arg3");

		fcopy("$android_update_path/AndroidKK4.4.2/hardware/img/combined_source/vdec/vdecdd.ko","$dhanushandroid_path/$arg3");

		dircopy("$android_update_path/AndroidKK4.4.2/images/sgx_bin","$dhanushandroid_path/$arg3/sgx_bin");

		
		fcopy("$local_path/Scripts/mkfs.incdhad1","$android_update_path/AndroidKK4.4.2/images");
		
		fcopy("$local_path/Scripts/mkheader","$android_update_path/AndroidKK4.4.2/images");

		dircopy("$local_path/Scripts/media","$android_update_path/AndroidKK4.4.2/images/media");

		dircopy("$local_path/Scripts/Music","$android_update_path/AndroidKK4.4.2/images/Music");

		fcopy("$local_path/resources/logo1.bin","$android_update_path/AndroidKK4.4.2/images/boot");

		chdir("$android_update_path/AndroidKK4.4.2") || die("Can't change directory: $android_update_path/AndroidKK4.4.2");

		#copy the output files to destination location 
		system("tar cvzf images_$arg3.tar.gz images");

		#copying tar.gz to common images directory
		fcopy("images_$arg3.tar.gz", "$dst_images_dir/images_$arg3\_$details.tar.gz") || die("Can't copy file: $dst_images_dir/images_$arg3\_$details.tar.gz in Android FS(kitkat) build script");

		if($check eq 0)
		{
			$check = 1;
			$arg3 = "smp";
			$arg = "no";
			goto REPEAT_BUILD;
		}
		
		print FH1 "\nimages tar completed...\n";
		#unlock
		close(FH1);
		system("chmod 777 $image_log");

		sendMail($Dev_team, $build_team, $passed_subj, $body, "");

		#sanity tests
		open(FH,">> $code_base/builds_success.log") || die("Can't open file: $code_base/builds_success.log");
		print FH "$dev_folder\n";
		close FH;

		fcopy("$codebase_devfolder/android-linux-mti-unif-3.10.14/build_tmp.sh","$codebase_devfolder/android-linux-mti-unif-3.10.14/build.sh");
		fcopy("$codebase_devfolder/SGX/sgx_tmp.sh","$codebase_devfolder/SGX/sgx.sh");

		open(FH2,"> $codebase_devfolder/Android.txt");
		print FH2 "$android_update_path";
		close(FH2);
		
		open(FH2,"> $android_update_path/revert.txt");
		print FH2 "$android_update_path";
		close(FH2);
		
		system("svn revert -R $android_update_path/AndroidKK4.4.2 --username $username --password $password > $android_update_path/revert.log 2> $android_update_path/rev_err.log");

		system("rm -rf $android_update_path/revert.txt");
	}
}

system("sudo chmod -R 777 $dst_images_dir");

#*****************************************Functions****************************************************************************

sub build_android2
{

	$rarg = $_[0];
	$rarg3 = $_[1];

	$dhanushkernel_path = "$dhanushandroid_path/android-linux-mti-unif-3.10.14";
	
	#change to the current path
	chdir($dhanushkernel_path);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushkernel_path/build.sh";

	$build_ScriptPath = "$dhanushkernel_path/build_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "export PATH=";

	my $path = "=/home/$username_sys/MentorGraphics/Sourcery_CodeBench_Lite_for_MIPS_GNU_Linux/bin:\$PATH";

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


	$dhanushSGX_path = "$dhanushandroid_path/SGX";
	#change to the current path
	chdir($dhanushSGX_path);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushSGX_path/sgx.sh";

	$build_ScriptPath = "$dhanushSGX_path/sgx_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path_string = "export MHOME=";
	my $path1_str = "export ANDROID_ROOT=";
	my $path2_str = "export KERNELDIR=";

	my $path = "=$dhanushandroid_path";
	my $path1 = "=$android_update_path/AndroidKK4.4.2";
	my $path2 = "=$dhanushkernel_path";


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


	if($lst eq "Adv-trunk")
	{
		fcopy("$local_path/Adv-trunk/Android/adv_fullbuild.sh", "$dhanushandroid_path/adv_fullbuild.sh");
		fcopy("$local_path/Adv-trunk/Android/adv2_fullbuild.sh", "$dhanushandroid_path/adv2_fullbuild.sh");
	}
	else
	{
		fcopy("$local_path/release/Android/adv_fullbuild.sh", "$dhanushandroid_path/adv_fullbuild.sh");
		fcopy("$local_path/release/Android/adv2_fullbuild.sh", "$dhanushandroid_path/adv2_fullbuild.sh");
	}


	#change to the current path
	chdir($dhanushandroid_path);

	# Replacing the $PATH value with local tool chain path

	$srcBuild_ScriptPath = "$dhanushandroid_path/adv2_fullbuild.sh";

	$build_ScriptPath = "$dhanushandroid_path/adv2_fullbuild_temp.sh";

	open(my $RD, "+< $srcBuild_ScriptPath") || die("Can't open file: $srcBuild_ScriptPath");
	open(my $RD1, " > $build_ScriptPath") || die("Can't open file: $build_ScriptPath");

	my $path1_str = "export ANDROID_ROOT=";
	my $path2_str = "export DISCIMAGE=";

	my $path1 = "=$android_update_path/AndroidKK4.4.2";
	my $path2 = "=$android_update_path/AndroidKK4.4.2/images/sgx_bin";

	foreach my $line (<$RD>)
	{
		if($line =~ /$path1_str/)
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

	print "*****************ANDROID BUILD PROCESS****************************\n";

	#change to the current path
	chdir($dhanushandroid_path) || die("Can't change directory: $dhanushandroid_path");

	$status = system("./adv2_fullbuild.sh $rarg int $rarg3 > $dhanushandroid_path/android_buildlog.txt 2> $dhanushandroid_path/android_faillog.txt");

	if((!(-f "$android_update_path/AndroidKK4.4.2/images/rfs/system.img")) || ($status)) 
	{

		print("\n Android Full Build Failed, Copying fail log in to share folder and sending mail to Build Team\n");

		system("mkdir -p -m 0777 $dst_reports_log_dir_Android");

		dircopy("$android_update_path/AndroidKK4.4.2/logs","$dst_reports_log_dir_Android/logs") || die("Can't copy directory: $dhanushandroid_KK_path/logs to $dst_reports_log_dir_Android/logs");

		$body = "Dear $username,\n\n\n$mail_details\nYour Check-in request is rejected, because the build is failed with your code changes. Please find the build fail log at \"$dst_reports_log_dir_Android1\".\nPlease resolve the build issues and submit as a new check-in request.\n\n\n****This is an Automatically generated email notification from Build Server****";

		sendMail($Dev_team, $build_team, $failed_subj, $body, "");

		delete_folder();
	}
	else
	{
		print "Android Kitkat Build completed successfully \n";
		
		#wait for unlock the image.log
		wait_until_unlock_logfile($image_log);

		#lock the image.log untill the updates completed.
		open(FH1,"> $image_log") || die("Can't open file: $image_log in Kitkat build script");
		print FH1 "preparing images tar...";


		fcopy("$bins_path/aon.bin", "$android_update_path/AndroidKK4.4.2/images/boot");

		fcopy("$bins_path/native.bin", "$android_update_path/AndroidKK4.4.2/images/boot");

		fcopy("$bins_path/dfu.bin", "$android_update_path/AndroidKK4.4.2/images/boot");

		fcopy("$bins_path/bl1.bin", "$android_update_path/AndroidKK4.4.2/images/boot");

		fcopy("$bins_path/u-boot.bin", "$android_update_path/AndroidKK4.4.2/images/boot");


		fcopy("$code_base/$dev_folder/android-linux-mti-unif-3.10.14/arch/mips/boot/vmlinux.bin", "$android_update_path/AndroidKK4.4.2/images/boot");

		fcopy("$code_base/$dev_folder/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wlcore/wlcore.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$code_base/$dev_folder/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wlcore/wlcore_sdio.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$code_base/$dev_folder/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wl12xx/wl12xx.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$code_base/$dev_folder/android-linux-mti-unif-3.10.14/drivers/misc/ti-st/tty_hci.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$code_base/$dev_folder/android-linux-mti-unif-3.10.14/drivers/misc/ti-st/st_drv.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$code_base/$dev_folder/SGX/eurasia_km/eurasiacon/binary2_incdhad1_android_release/target/dc_incdhad1.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$code_base/$dev_folder/SGX/eurasia_km/eurasiacon/binary2_incdhad1_android_release/target/pvrsrvkm.ko","$android_update_path/AndroidKK4.4.2/images/modules");


		fcopy("$android_update_path/AndroidKK4.4.2/hardware/img/combined_source/imgvideo/imgvideo.ko","$android_update_path/AndroidKK4.4.2/images/modules");

		fcopy("$code_base/$dev_folder$android_update_path/AndroidKK4.4.2/hardware/img/combined_source/vdec/vdecdd.ko","$android_update_path/AndroidKK4.4.2/images/modules");


		system("mkdir -p -m 0777 $dhanushandroid_path/$rarg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/arch/mips/boot/vmlinux.bin", "$dhanushandroid_path/$rarg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wlcore/wlcore.ko","$dhanushandroid_path/$rarg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wlcore/wlcore_sdio.ko","$dhanushandroid_path/$rarg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/net/wireless/ti/wl12xx/wl12xx.ko","$dhanushandroid_path/$rarg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/misc/ti-st/tty_hci.ko","$dhanushandroid_path/$rarg3");

		fcopy("$dhanushandroid_path/android-linux-mti-unif-3.10.14/drivers/misc/ti-st/st_drv.ko","$dhanushandroid_path/$rarg3");

		fcopy("$dhanushandroid_path/SGX/eurasia_km/eurasiacon/binary2_incdhad1_android_release/target/dc_incdhad1.ko","$dhanushandroid_path/$rarg3");

		fcopy("$dhanushandroid_path/SGX/eurasia_km/eurasiacon/binary2_incdhad1_android_release/target/pvrsrvkm.ko","$dhanushandroid_path/$rarg3");

		fcopy("$android_update_path/AndroidKK4.4.2/hardware/img/combined_source/imgvideo/imgvideo.ko","$dhanushandroid_path/$rarg3");

		fcopy("$android_update_path/AndroidKK4.4.2/hardware/img/combined_source/vdec/vdecdd.ko","$dhanushandroid_path/$rarg3");


		dircopy("$android_update_path/AndroidKK4.4.2/images/sgx_bin","$dhanushandroid_path/$arg3/sgx_bin");


		fcopy("$local_path/Scripts/mkfs.incdhad1","$android_update_path/AndroidKK4.4.2/images");
		
		fcopy("$local_path/Scripts/mkheader","$android_update_path/AndroidKK4.4.2/images");

		dircopy("$local_path/Scripts/media","$android_update_path/AndroidKK4.4.2/images/media");

		dircopy("$local_path/Scripts/Music","$android_update_path/AndroidKK4.4.2/images/Music");

		fcopy("$local_path/resources/logo1.bin","$android_update_path/AndroidKK4.4.2/images/boot");
		
		chdir("$android_update_path/AndroidKK4.4.2") || die("Can't change directory: $android_update_path/AndroidKK4.4.2");

		#copy the output files to destination location 
		system("tar cvzf images_$rarg3.tar.gz images");

		#copying tar.gz to common images directory
		fcopy("images_$rarg3.tar.gz", "$dst_images_dir/images_$rarg3\_$details.tar.gz") || die("Can't copy file: $dst_images_dir/images_$rarg3\_$details.tar.gz in Android FS(kitkat) build script");

		print FH1 "\nimages tar completed...\n";
		#unlock
		close(FH1);
		system("chmod 777 $image_log");
	}
}

sub delete_folder
{
	#delete the dev folder 
	system("rm -rf $code_base/$dev_folder");
}

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
	my $cc=$_[1];
	my $subject=$_[2];
	my $message=$_[3];
	my $attachPath=$_[4];
	my $bcc = 'Build_Server <socplatform-qa@inedasystems.com>';
	
	$msg = MIME::Lite->new(
                 From     => $from,
                 To       => $to,
                 Cc       => $cc,
				 Bcc	  => $bcc,				 
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

