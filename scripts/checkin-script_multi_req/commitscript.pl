#!/usr/bin/perl

#*****************************************************************************************************************************************\
# 
#   File Name  :   commitscript.pl
#    
#   Description:   It commits the developer code and will delete the entire code after commit based on some conditions 
#   	
#
# ****************************************************************************************************************************************/
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use MIME::Lite;

#Assigning the arguments
my $server_path=$ARGV[0];
my $dev_folder=$ARGV[1];
my $code_base=$ARGV[2];
my $bugid=$ARGV[3];
my $username=$ARGV[4];
my $password=$ARGV[5];
my $chkin_cmnt=$ARGV[6];
my $build_team=$ARGV[7];

#Declaration of logs  
my $image_log="$server_path/image.log";
my $ci_lock_log="$server_path/ci_lock.log";


my $dev_path="$server_path";

my $local_path = "/media/Data/trunk_wc";
my $repo_info = "$dev_path/$dev_folder/repo_info.log";
my $repo_info_err = "$dev_path/$dev_folder/repo_info_err.log";
my $local_info = "$dev_path/$dev_folder/local_info.log";
my $local_info_err = "$dev_path/$dev_folder/local_info_err.log";
my $repository_log = "repository_url.log";

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
my $from = 'Build_Server <socplatform-qa@inedasystems.com>';

#my $Dev_team = 'Dhanush-SW <dhanush-sw@inedasystems.com>';
#my $Dev_team = 'Vinay Kumar <vinaykumar.medari@incubesol.com>';
#my $Dev_team = 'Build_Server <socplatform-qa@inedasystems.com>';
my $Dev_team = $mail_id;

#my $build_team = 'dhanush-swqa <dhanush-swqa@inedasystems.com>';
#my $build_team = 'Vinay Kumar <vinaykumar.medari@incubesol.com>';
#my $build_team = 'Build_Server <socplatform-qa@inedasystems.com>';

open(FHC,"> comments.log");

print FHC "comments: $chkin_cmnt\n";

close FHC;

$androidbuild = "no";
$mail_details="Your Check-in request details:\n
Bug: $bugid
Code base: $code_base\n";

$repos_log = "$dev_path/$dev_folder/$repository_log";
open(FH_R,"< $repos_log");

@lines=<FH_R>;
chomp($lines[0]);

$sourcecode_repo_path=$lines[0];

close FH_R;

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
	pop(@temp);
	$sz = @temp;
	$utrunk = $temp[$sz-1];
	$code_base = $utrunk;
}
if($lst eq "Adv-trunk")
{
	$bins_path = "$local_path/SVN_bins";
}
elsif($lst eq "InWatch_A0")
{
	#do nothing
}
elsif($lst eq "LGEngDevBranch")
{
	#do nothing
}
elsif($lst eq "Micro-trunk")
{
	$bins_path = "$local_path/SVN_bins/Micro-trunk";
}
else
{
	$bins_path = "$local_path/SVN_bins/release";
}

system("sudo chmod -R 777 $bins_path");

my $img_path = "$bins_path/images/boot";

my($reqnum,$line,$filesize);

if(!(-e $image_log))
{
	open(FH,"> $image_log");
	print FH "ci\n";
	close FH;
}

open(FH2,"> $ci_lock_log");
print FH2 "commiting code in to SVN\n";

my $commit_message= "Issue Id:	$bugid-Bug\nIssue Type:	Bug\nReviewer:	$username\n\nComments:$chkin_cmnt";

system("svn info $sourcecode_repo_path --username socqa --password Yo'\$8'lc9u > $repo_info 2> $repo_info_err");
$repo = read_last_revision($repo_info);

if(($code_base eq "AndroidKK4.4.2") || ($code_base eq "android-linux-mti-unif-3.10.14") || ($code_base eq "SGX"))
{
	open(FH2,"< $dev_path/$dev_folder/Android.txt");
	@lines = <FH2>;
	close(FH2);

	$android_update_path = $lines[0];
	chomp($android_update_path);
}
if($code_base eq "AndroidKK4.4.2")
{
	system("svn info $android_update_path/AndroidKK4.4.2 --username socqa --password Yo'\$8'lc9u > $local_info 2> $local_info_err");
}
else
{
	system("svn info $dev_path/$dev_folder/$code_base --username socqa --password Yo'\$8'lc9u > $local_info 2> $local_info_err");
}

$local = read_last_revision($local_info);

if($repo > $local)
{
	print "SVN revisions are different need to update source code and submit a new request.\n\n";

	$body = "Dear $username,\n\n$mail_details\nThe Check-in Request with your code changes submitted is older than the SVN revision(outdated) and can not check-in to SVN.\n\nCheck-in script will update and build the code and gives you new build binaries.\n\nPlease perform sanity with the new build binaries and then submit for sanity request.\n\n\n****This is an Automatically generated email notification from Build server****";

	sendMail($Dev_team, $build_team, "[$code_base] Check-in request working copy is older than repository revision", $body);

	$patch_file = "$code_base";
	$command_log = "add_information.log";

	chdir("$dev_path/$dev_folder") || die("can not change directory to $dev_path/$dev_folder");

	if($code_base eq "AndroidKK4.4.2")
	{
		open(FH2,"> $android_update_path/revert.txt");
		print FH2 "$android_update_path";
		close(FH2);

		system("svn revert -R $android_update_path/AndroidKK4.4.2 --username $username --password '$password' > $android_update_path/revert.log 2> $android_update_path/rev_err.log");

		system("svn up $android_update_path/AndroidKK4.4.2 --username socqa --password Yo'\$8'lc9u > $android_update_path/up.log 2> $android_update_path/up_err.log");

		system("rm -rf $android_update_path/revert.txt");		
	}
	else
	{	
		system("svn revert -R $dev_path/$dev_folder/$code_base --username $username --password '$password' > revert.log 2> rev_err.log");

		system("svn up $dev_path/$dev_folder/$code_base --username socqa --password Yo'\$8'lc9u > up.log 2> up_err.log");
	}

	$again = 1;

	system("perl mergescript_multiple.pl $server_path $dev_folder $patch_file $command_log $repository_log $androidbuild $again '$build_team'");
}

if($code_base eq "AndroidKK4.4.2")
{

REPEAT:
	if(-e "$android_update_path/revert.txt")
	{
		goto REPEAT;
	}
	
#merging patch after reverting build changes and patch changes

	$patch_file = "$code_base.patch";
	$command_log = "add_information.log";

	$status_log = "$android_update_path/status_merge.log";
	$temp_log = "$android_update_path/temp.log";
	$patch_err_log = "$android_update_path/patch_error.log";

	chdir("$android_update_path/AndroidKK4.4.2");
	
	$status = system("svn patch $android_update_path/$patch_file . > $status_log");

	if(-e "$android_update_path/$command_log")
	{
		add_delete_files("$android_update_path/$command_log");

		$filesize = -s "$patch_err_log";

		if($filesize > 0)
		{
			print FH2 "Error occured while applying SVN patch with $android_update_path/$command_log, please check $patch_err_log\n";
			print FH2 "merge failure\n";
		}
	}
	
	$status = system("svn ci $android_update_path/$code_base -m \"$commit_message\" --username $username --password '$password' > /usr/lib/cgi-bin/ci.log 2> /usr/lib/cgi-bin/err_ci.log");
}
else
{
	$status = system("svn ci $dev_path/$dev_folder/$code_base -m \"$commit_message\" --username $username --password '$password' > ci.log 2> err_ci.log");
}

if($status)
{
	$body = "Dear $username,\n\n$mail_details\nYour Check-in request is rejected, because of SVN commit has FAILED.\nPlease submit sanity request after some time.\n\n\n****This is an Automatically generated email notification from Build Server****";

	sendMail($Dev_team, $build_team, "[$code_base] Check-in is not done for bug - $bugid because of SVN commit FAIL", $body, "/usr/lib/cgi-bin/err_ci.log");

	if($code_base eq "AndroidKK4.4.2")
	{
		open(FH2,"> $android_update_path/revert.txt");
		print FH2 "$android_update_path";
		close(FH2);

		system("svn revert -R $android_update_path/AndroidKK4.4.2 --username $username --password '$password' > $android_update_path/revert.log 2> $android_update_path/rev_err.log");

		system("rm -rf $android_update_path/revert.txt");
	}

	system("rm -rf $android_update_path/lock.txt");

	#delete the dev folder
	#system("rm -rf $dev_path/$dev_folder");

	close FH2;
}
else
{
	close FH2;

	#wait for unlock the bin_image.log
	wait_until_unlock_logfile($image_log);

	#lock the image.log untill the updates completed.
	open(FH1,"> $image_log");
	print FH1 "preparing images tar in ci...";
	
	if($code_base eq "AONsensor")
	{
		fcopy("$dev_path/$dev_folder/$code_base/output/aon.bin", "$bins_path/aon.bin");

		fcopy("$dev_path/$dev_folder/$code_base/output/dfu.bin", "$bins_path/dfu.bin");

		if(-f "$bins_path/images_up.tar.gz")
		{
			chdir("$bins_path") || die("Can't change diretory $!");

			#untar the images.tar.gz
			system("tar -xvzf images_up.tar.gz");

			#remove images.tar.gz
			system("rm -rf images_up.tar.gz");

			fcopy("$dev_path/$dev_folder/$code_base/output/aon.bin", "$img_path/aon.bin");

			fcopy("$dev_path/$dev_folder/$code_base/output/dfu.bin", "$img_path/dfu.bin");

			#tar the images folder to images.tar.gz
			system("tar cvzf images_up.tar.gz images");

			#remove images
			system("rm -rf images");
		}
	
		if(-f "$bins_path/images_smp.tar.gz")
		{
			chdir("$bins_path") || die("Can't change diretory $!");

			#untar the images.tar.gz
			system("tar -xvzf images_smp.tar.gz");

			#remove images.tar.gz
			system("rm -rf images_smp.tar.gz");

			fcopy("$dev_path/$dev_folder/$code_base/output/aon.bin", "$img_path/aon.bin");

			fcopy("$dev_path/$dev_folder/$code_base/output/dfu.bin", "$img_path/dfu.bin");

			#tar the images folder to images.tar.gz
			system("tar cvzf images_smp.tar.gz images");

			#remove images
			system("rm -rf images");
		}

	}
	if($code_base eq "Native")
	{
		fcopy("$dev_path/$dev_folder/$code_base/output/native.bin", "$bins_path/native.bin");
	
		if(-f "$bins_path/images_up.tar.gz")
		{
			chdir("$bins_path") || die("Can't change diretory $!");

			#untar the images.tar.gz
			system("tar -xvzf images_up.tar.gz");

			#remove images.tar.gz
			system("rm -rf images_up.tar.gz");

			fcopy("$dev_path/$dev_folder/$code_base/output/native.bin", "$img_path/native.bin");

			#tar the images folder to images.tar.gz
			system("tar cvzf images_up.tar.gz images");

			#remove images
			system("rm -rf images");
		}
		if(-f "$bins_path/images_smp.tar.gz")
		{
			chdir("$bins_path") || die("Can't change diretory $!");

			#untar the images.tar.gz
			system("tar -xvzf images_smp.tar.gz");

			#remove images.tar.gz
			system("rm -rf images_smp.tar.gz");

			fcopy("$dev_path/$dev_folder/$code_base/output/native.bin", "$img_path/native.bin");

			#tar the images folder to images.tar.gz
			system("tar cvzf images_smp.tar.gz images");

			#remove images
			system("rm -rf images");
		}
	}

	if(($code_base eq "AndroidKK4.4.2") || ($code_base eq "android-linux-mti-unif-3.10.14") || ($code_base eq "SGX"))
	{

		system("mkdir -p -m 0777 $bins_path/up");

		fcopy("$dev_path/$dev_folder/up/vmlinux.bin", "$bins_path/up/vmlinux.bin");
	
		fcopy("$dev_path/$dev_folder/up/wlcore.ko","$bins_path/up/wlcore.ko");

		fcopy("$dev_path/$dev_folder/up/wlcore_sdio.ko","$bins_path/up/wlcore_sdio.ko");

		fcopy("$dev_path/$dev_folder/up/wl12xx.ko","$bins_path/up/wl12xx.ko");

		fcopy("$dev_path/$dev_folder/up/tty_hci.ko","$bins_path/up/tty_hci.ko");

		fcopy("$dev_path/$dev_folder/up/st_drv.ko","$bins_path/up/st_drv.ko");

		fcopy("$dev_path/$dev_folder/up/dc_incdhad1.ko","$bins_path/up/dc_incdhad1.ko");

		fcopy("$dev_path/$dev_folder/up/pvrsrvkm.ko","$bins_path/up/pvrsrvkm.ko");

		fcopy("$dev_path/$dev_folder/up/vdecdd.ko","$bins_path/up/vdecdd.ko");

		fcopy("$dev_path/$dev_folder/up/imgvideo.ko","$bins_path/up/imgvideo.ko");


		dircopy("$dev_path/$dev_folder/up/sgx_bin","$bins_path/up/sgx_bin");


		system("mkdir -p -m 0777 $bins_path/smp");

		fcopy("$dev_path/$dev_folder/smp/vmlinux.bin", "$bins_path/smp/vmlinux.bin");
	
		fcopy("$dev_path/$dev_folder/smp/wlcore.ko","$bins_path/smp/wlcore.ko");

		fcopy("$dev_path/$dev_folder/smp/wlcore_sdio.ko","$bins_path/smp/wlcore_sdio.ko");

		fcopy("$dev_path/$dev_folder/smp/wl12xx.ko","$bins_path/smp/wl12xx.ko");

		fcopy("$dev_path/$dev_folder/smp/tty_hci.ko","$bins_path/smp/tty_hci.ko");

		fcopy("$dev_path/$dev_folder/smp/st_drv.ko","$bins_path/smp/st_drv.ko");

		fcopy("$dev_path/$dev_folder/smp/dc_incdhad1.ko","$bins_path/smp/dc_incdhad1.ko");

		fcopy("$dev_path/$dev_folder/smp/pvrsrvkm.ko","$bins_path/smp/pvrsrvkm.ko");

		fcopy("$dev_path/$dev_folder/smp/vdecdd.ko","$bins_path/smp/vdecdd.ko");

		fcopy("$dev_path/$dev_folder/smp/imgvideo.ko","$bins_path/smp/imgvideo.ko");


		dircopy("$dev_path/$dev_folder/smp/sgx_bin","$bins_path/smp/sgx_bin");

	}

	if($code_base eq "BL1")
	{
		fcopy("$dev_path/$dev_folder/$code_base/out/bl1.bin", "$bins_path/bl1.bin");
	
		if(-f "$bins_path/images_up.tar.gz")
		{
			chdir("$bins_path") || die("Can't change diretory $!");

			#untar the images.tar.gz
			system("tar -xvzf images_up.tar.gz");

			#remove images.tar.gz
			system("rm -rf images_up.tar.gz");

			fcopy("$dev_path/$dev_folder/$code_base/out/bl1.bin", "$img_path/bl1.bin");

			#tar the images folder to images.tar.gz
			system("tar cvzf images_up.tar.gz images");

			#remove images
			system("rm -rf images");
		}
		if(-f "$bins_path/images_smp.tar.gz")
		{
			chdir("$bins_path") || die("Can't change diretory $!");

			#untar the images.tar.gz
			system("tar -xvzf images_smp.tar.gz");

			#remove images.tar.gz
			system("rm -rf images_smp.tar.gz");

			fcopy("$dev_path/$dev_folder/$code_base/out/bl1.bin", "$img_path/bl1.bin");

			#tar the images folder to images.tar.gz
			system("tar cvzf images_smp.tar.gz images");

			#remove images
			system("rm -rf images");
		}
	}
	if($code_base eq "U-Boot")
	{
		fcopy("$dev_path/$dev_folder/$code_base/u-boot.bin", "$bins_path/u-boot.bin");
	
		if(-f "$bins_path/images_up.tar.gz")
		{
			chdir("$bins_path") || die("Can't change diretory $!");

			#untar the images.tar.gz
			system("tar -xvzf images_up.tar.gz");

			#remove images.tar.gz
			system("rm -rf images_up.tar.gz");

			fcopy("$dev_path/$dev_folder/$code_base/u-boot.bin", "$img_path/u-boot.bin");

			#tar the images folder to images.tar.gz
			system("tar cvzf images_up.tar.gz images");

			#remove images
			system("rm -rf images");
		}
		if(-f "$bins_path/images_smp.tar.gz")
		{
			chdir("$bins_path") || die("Can't change diretory $!");

			#untar the images.tar.gz
			system("tar -xvzf images_smp.tar.gz");

			#remove images.tar.gz
			system("rm -rf images_smp.tar.gz");

			fcopy("$dev_path/$dev_folder/$code_base/u-boot.bin", "$img_path/u-boot.bin");

			#tar the images folder to images.tar.gz
			system("tar cvzf images_smp.tar.gz images");

			#remove images
			system("rm -rf images");
		}
	}
	if($code_base eq "BL0")
	{
		fcopy("$dev_path/$dev_folder/$code_base/bin/bl0.bin", "$bins_path/bl0.bin");
	}
	if($code_base eq "DFU_SDK_NAND")
	{
		fcopy("$dev_path/$dev_folder/$code_base/bin/dfu.bin", "$bins_path/dfu_sdk_nand.bin");
	}
	if($code_base eq "BL1_REV1")
	{
		system("mkdir -p $bins_path/sd_boot");
		fcopy("$dev_path/$dev_folder/$code_base/bl1.bin", "$bins_path/sd_boot/bl1.bin");
	}
	if($code_base eq "SPILoadUtility")
	{
		fcopy("$dev_path/$dev_folder/$code_base/bin/loadspi.bin", "$bins_path/loadspi.bin");
	}
	if(($code_base eq "AndroidKK4.4.2") || ($code_base eq "android-linux-mti-unif-3.10.14") || ($code_base eq "SGX"))
	{
		fcopy("$bins_path/aon.bin", "$android_update_path/AndroidKK4.4.2/images/boot/aon.bin");

		fcopy("$bins_path/native.bin", "$android_update_path/AndroidKK4.4.2/images/boot/native.bin");

		fcopy("$bins_path/dfu.bin", "$android_update_path/AndroidKK4.4.2/images/boot/dfu.bin");

		fcopy("$bins_path/bl1.bin", "$android_update_path/AndroidKK4.4.2/images/boot/bl1.bin");

		fcopy("$bins_path/u-boot.bin", "$android_update_path/AndroidKK4.4.2/images/boot/u-boot.bin");

		fcopy("$dev_path/$dev_folder/up/vmlinux.bin", "$android_update_path/AndroidKK4.4.2/images/boot/vmlinux.bin");
	
		fcopy("$dev_path/$dev_folder/up/wlcore.ko","$android_update_path/AndroidKK4.4.2/images/modules/wlcore.ko");

		fcopy("$dev_path/$dev_folder/up/wlcore_sdio.ko","$android_update_path/AndroidKK4.4.2/images/modules/wlcore_sdio.ko");

		fcopy("$dev_path/$dev_folder/up/wl12xx.ko","$android_update_path/AndroidKK4.4.2/images/modules/wl12xx.ko");

		fcopy("$dev_path/$dev_folder/up/tty_hci.ko","$android_update_path/AndroidKK4.4.2/images/modules/tty_hci.ko");

		fcopy("$dev_path/$dev_folder/up/st_drv.ko","$android_update_path/AndroidKK4.4.2/images/modules/st_drv.ko");

		fcopy("$dev_path/$dev_folder/up/dc_incdhad1.ko","$android_update_path/AndroidKK4.4.2/images/modules/dc_incdhad1.ko");

		fcopy("$dev_path/$dev_folder/up/pvrsrvkm.ko","$android_update_path/AndroidKK4.4.2/images/modules/pvrsrvkm.ko");

		fcopy("$dev_path/$dev_folder/up/imgvideo.ko","$android_update_path/AndroidKK4.4.2/images/modules/imgvideo.ko");

		fcopy("$dev_path/$dev_folder/up/vdecdd.ko","$android_update_path/AndroidKK4.4.2/images/modules/vdecdd.ko");

		dircopy("$dev_path/$dev_folder/up/sgx_bin","$android_update_path/AndroidKK4.4.2/images/sgx_bin");

		fcopy("$local_path/Scripts/mkfs.incdhad1","$android_update_path/AndroidKK4.4.2/images");
	
		fcopy("$local_path/Scripts/mkheader","$android_update_path/AndroidKK4.4.2/images");

		dircopy("$local_path/Scripts/Music","$android_update_path/AndroidKK4.4.2/images/Music");
		
		dircopy("$local_path/Scripts/media","$android_update_path/AndroidKK4.4.2/images/media");

		fcopy("$local_path/resources/logo1.bin","$android_update_path/AndroidKK4.4.2/images/boot");


		chdir("$android_update_path/AndroidKK4.4.2") || die("Can't change directory: $android_update_path/AndroidKK4.4.2");

		system("rm -rf images_up.tar.gz");

		system("tar cvzf images_up.tar.gz images");

		system("sudo chmod -R 777 $bins_path");

		#copy the output files to destination location 
		fcopy("images_up.tar.gz", "$bins_path/images_up.tar.gz");
	
	
		#SMP
		fcopy("$bins_path/aon.bin", "$android_update_path/AndroidKK4.4.2/images/boot/aon.bin");

		fcopy("$bins_path/native.bin", "$android_update_path/AndroidKK4.4.2/images/boot/native.bin");

		fcopy("$bins_path/dfu.bin", "$android_update_path/AndroidKK4.4.2/images/boot/dfu.bin");

		fcopy("$bins_path/bl1.bin", "$android_update_path/AndroidKK4.4.2/images/boot/bl1.bin");

		fcopy("$bins_path/u-boot.bin", "$android_update_path/AndroidKK4.4.2/images/boot/u-boot.bin");

		fcopy("$dev_path/$dev_folder/smp/vmlinux.bin", "$android_update_path/AndroidKK4.4.2/images/boot/vmlinux.bin");
	
		fcopy("$dev_path/$dev_folder/smp/wlcore.ko","$android_update_path/AndroidKK4.4.2/images/modules/wlcore.ko");

		fcopy("$dev_path/$dev_folder/smp/wlcore_sdio.ko","$android_update_path/AndroidKK4.4.2/images/modules/wlcore_sdio.ko");

		fcopy("$dev_path/$dev_folder/smp/wl12xx.ko","$android_update_path/AndroidKK4.4.2/images/modules/wl12xx.ko");

		fcopy("$dev_path/$dev_folder/smp/tty_hci.ko","$android_update_path/AndroidKK4.4.2/images/modules/tty_hci.ko");

		fcopy("$dev_path/$dev_folder/smp/st_drv.ko","$android_update_path/AndroidKK4.4.2/images/modules/st_drv.ko");

		fcopy("$dev_path/$dev_folder/smp/dc_incdhad1.ko","$android_update_path/AndroidKK4.4.2/images/modules/dc_incdhad1.ko");

		fcopy("$dev_path/$dev_folder/smp/pvrsrvkm.ko","$android_update_path/AndroidKK4.4.2/images/modules/pvrsrvkm.ko");

		fcopy("$dev_path/$dev_folder/smp/imgvideo.ko","$android_update_path/AndroidKK4.4.2/images/modules/imgvideo.ko");

		fcopy("$dev_path/$dev_folder/smp/vdecdd.ko","$android_update_path/AndroidKK4.4.2/images/modules/vdecdd.ko");

		dircopy("$dev_path/$dev_folder/smp/sgx_bin","$android_update_path/AndroidKK4.4.2/images/sgx_bin");

		fcopy("$local_path/Scripts/mkfs.incdhad1","$android_update_path/AndroidKK4.4.2/images");
	
		fcopy("$local_path/Scripts/mkheader","$android_update_path/AndroidKK4.4.2/images");

		dircopy("$local_path/Scripts/Music","$android_update_path/AndroidKK4.4.2/images/Music");
		
		dircopy("$local_path/Scripts/media","$android_update_path/AndroidKK4.4.2/images/media");

		fcopy("$local_path/resources/logo1.bin","$android_update_path/AndroidKK4.4.2/images/boot");


		chdir("$android_update_path/AndroidKK4.4.2") || die("Can't change directory: $android_update_path/AndroidKK4.4.2");

		system("rm -rf images_smp.tar.gz");

		system("tar cvzf images_smp.tar.gz images");

		system("sudo chmod -R 777 $bins_path");

		#copy the output files to destination location 
		fcopy("images_smp.tar.gz", "$bins_path/images_smp.tar.gz");

	}

	#unlock
	print FH1 "images tar completed in ci\n";
	close(FH1);
	system("chmod 777 $image_log");

	#delete the dev folder 
	system("rm -rf $dev_path/$dev_folder");

	system("sudo chmod -R 777 $bins_path");

	if($code_base eq "AndroidKK4.4.2")
	{
		system("svn revert -R $android_update_path/AndroidKK4.4.2 --username $username --password '$password' > $android_update_path/revert.log 2> $android_update_path/rev_err.log");
		
	}
	system("rm -rf $android_update_path/lock.txt");
}

#**************Functions************************************
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


sub delete_folder
{
	#delete the dev folder 
	system("rm -rf $dev_path/$dev_folder");
}

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

	open(FHC,"> sendmail.log");

	print FHC "Cc_list: $cc\n";

	print FHC "comments: $chkin_cmnt\n";

	close FHC;

	my $msg = MIME::Lite->new(
			From     => $from,
			To       => $to,
			Cc       => $cc,
			Bcc	 	 => $bcc,
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
	return;
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

