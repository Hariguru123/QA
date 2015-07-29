#!/usr/bin/perl
#********************************************************************************************************************\
# 
#   File Name  :  Build_Script.pl
#    
#   Description:  Builds Android and Wearable code bases based on the input parameters.
#   	
# ********************************************************************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

system("pwd > path.txt");
open(FH,"<path.txt");

foreach $line(<FH>)
{
	if($line =~ /(.+)\/DHANUSH_ADVANCED_SDK\/Scripts/)
	{
		$local_path=$1;
		$local_path="$local_path/DHANUSH_ADVANCED_SDK";
	}
	else
	{
		print "Build Script is not available in Scripts folder under DHANUSH_ADVANCED_SDK directory structure\n";
		exit;
	}
}
close(FH);

#Declaration of Scripts path
$scripts_path="$local_path/Scripts";

chdir($scripts_path);

system("chmod 777 check-packages.sh");
system("./check-packages.sh > packages.txt 2> out.txt");

print "\n***************************** PACKAGES INSTALLED *****************************\n";
print "\nPlease check the list of the packages installed in this build system at $scripts_path/packages.txt and out.txt and proceed if no packages are need to be installed.\n\n";
print "*****************************************************************************\n\n";

print "Enter 1 to continue to SDK Build.\n";

chomp($input =<STDIN>);
if($input eq 1)
{
	print "Continuing build..\n";
}
else
{
	print "Exiting...\n";
}


print "********************************* SDK Build *********************************\n";
print "Please select any one build option.\n";
print "Enter 1 for Wearable and Android builds\n";
print "Enter 2 for Wearable Build\n";
print "Enter 3 for Android Build\n";

chomp($input =<STDIN>);

if($input eq 1)
{
	print "Compiling Wearable and Android...\n";
	$build = "All";
}
elsif($input eq 2)
{
	print "Compiling Wearable...\n";
	$build = "Wearable";
}
elsif($input eq 3)
{
	print "Compiling Android Kitkat-4.4.2...\n";
	$build = "Android";
}
else
{
	print "Please enter value in between (1-3)\n";
	print "1 - SDK Build(Wearable and Android Builds)\n";
	print "2 - Wearable Build\n";
	print "3 - Android Build\n";
	print "Exiting...\n";
	exit;
}

#Declaration of binaries and toolchain path
$toolchain_path="$local_path/Toolchain/Wearable_Sensor_Uboot";
$sensor_path="$local_path/Sensor";
$bootloaders_path="$local_path/Bootloaders";
$kernel_bins_path="$local_path/Kernel";
$tools_path="$local_path/Tools";

#Declaration of Android path
$android_path="$local_path/Android/AndroidKK4.4.2";
$androidcode_path="$local_path/Android";

#Declaration of Wearable path
$wearable_path="$local_path/Wearable";

#Declaration of destination directories
$dst_reports_dir_wearable="$wearable_path/output";

if(($build eq "Wearable") || ($build eq "All"))
{

	if(-d "$wearable_path")
	{
		print "***************** Wearable Build in Progress**********************\n";

		#delete the output folder with contents and create new output folder 
		system("rm -rf $wearable_path/output"); 
		system("mkdir $wearable_path/output");

		chdir($wearable_path);

		#Build the Wearable Project
		$status = system(". ./native_env.sh > log.txt; make clobber > clobber_log.txt 2> faillog.txt; make BUILD_NUC=1 rel > buildlog.txt 2>> faillog.txt;");
		if ($status)
		{
			fcopy("faillog.txt", $dst_reports_dir_wearable);
			fcopy("buildlog.txt", $dst_reports_dir_wearable);

			print("Wearable Build Failed, please check the $dst_reports_dir_wearable/faillog.txt for failure details\n");
			if($build eq "Wearable")
			{
				print "Done..\n";
				exit;
			}
		}
		else
		{
			print "Wearable Build Completed Successfully \n";

			print "Wearable output files after compilation are available at $dst_reports_dir_wearable\n";

			fcopy("$wearable_path/output/dhanush_wearable.bin", "$wearable_path/output/native.bin");

			if(-f "$local_path/images.tar.gz")
			{
				chdir("$local_path");

				#untar the images.tar.gz
				system("tar -xvzf $local_path/images.tar.gz");

				#remove images.tar.gz
				system("rm -rf $local_path/images.tar.gz");

				fcopy("$wearable_path/output/native.bin", "$local_path/images/boot");

				#tar the images folder to images.tar.gz
				system("tar cvzf $local_path/images.tar.gz images");

				#remove images
				system("rm -rf $local_path/images");

				if($build eq "Wearable")
				{
					print "Done..\n";
					exit;
				}
			}
			if(!(-d "$android_path/images"))
			{
				print "Android Kitkat4.4.2 build not available in SDK.\n";
				goto android_build;
			}
			elsif(!(-f "$local_path/images.tar.gz"))
			{
				fcopy("$sensor_path/aon.bin", "$android_path/images/boot");

				fcopy("$wearable_path/output/native.bin", "$android_path/images/boot");

				fcopy("$bootloaders_path/bl1.bin", "$android_path/images/boot");
				fcopy("$bootloaders_path/u-boot.bin", "$android_path/images/boot");
				fcopy("$bootloaders_path/logo1.bin", "$android_path/images/boot");

				fcopy("$tools_path/dfu.bin", "$android_path/images/boot");

				fcopy("$kernel_bins_path/vmlinux.bin", "$android_path/images/boot");
				fcopy("$kernel_bins_path/wlcore.ko","$android_path/images/modules");
				fcopy("$kernel_bins_path/wlcore_sdio.ko","$android_path/images/modules");
				fcopy("$kernel_bins_path/wl12xx.ko","$android_path/images/modules");

				fcopy("$kernel_bins_path/tty_hci.ko","$android_path/images/modules");
				fcopy("$kernel_bins_path/st_drv.ko","$android_path/images/modules");

				fcopy("$kernel_bins_path/pvrsrvkm.ko","$android_path/images/modules");
				fcopy("$kernel_bins_path/dc_incdhad1.ko","$android_path/images/modules");

				fcopy("$local_path/Scripts/mkfs.incdhad1","$android_path/images");
				fcopy("$local_path/Scripts/mkheader","$android_path/images");

				dircopy("$local_path/Scripts/Music","$android_path/images/Music");
				dircopy("$local_path/Scripts/media","$android_path/images/media");

				system("rm -rf $android_path/images/sgx_bin");
				dircopy("$androidcode_path/sgx_bin","$android_path/images/sgx_bin");

				chdir("$android_path");

				#tar the images folder to images.tar.gz
				system("tar cvzf $local_path/images.tar.gz images");

				if($build eq "Wearable")
				{
					print "Done..\n";
					exit;
				}
			}
			if($build eq "Wearable")
			{
				print "Done..\n";
				exit;
			}
		}
	}
	else
	{
		print "$local_path/Wearable directory not existed under SDK directory structure.\nExiting..\n";
		exit;
	}
}

android_build:
$build = "All";
if(($build eq "Android") || ($build eq "All"))
{

	if(-d "$android_path")
	{
		
		print "******************* Android Kitkat Build in progress *********************\n";
		
		#Build the Android Kitkat Project
		chdir($android_path);

		$status=system("./build.sh clean > Android_buildlog.txt 2> Android_faillog.txt");

		if((!(-f "$android_path/images/rfs/system.img")) || ($status)) 
		{
			print "\n  Android Kitkat Build Failed, please check the $android_path/logs/android_make.out for failure details\n";
		}
		else
		{
			print " Android Kitkat Build completed successfully \n";

			if(!(-f "$wearable_path/output/native.bin"))
			{
				print "Wearable build not available in SDK.\n";

				if(-d "$wearable_path")
				{
					chdir($wearable_path);

					#Build the Wearable Project
					$status = system(". ./native_env.sh > log.txt; make clobber > clobber_log.txt 2> faillog.txt; make BUILD_NUC=1 rel > buildlog.txt 2>> faillog.txt;");

					if ($status)
					{
						fcopy("faillog.txt", $dst_reports_dir_wearable);
						fcopy("buildlog.txt", $dst_reports_dir_wearable);

						print("Wearable Build Failed, please check the $dst_reports_dir_wearable/faillog.txt for failure details\n");
					}
					else
					{
						print "Wearable Build Completed Successfully \n";

						print "Wearable output files after compilation are available at $dst_reports_dir_wearable\n";

						fcopy("$wearable_path/output/dhanush_wearable.bin", "$wearable_path/output/native.bin");

						chdir("$local_path");

						#untar the images.tar.gz
						system("tar -xvzf $local_path/images.tar.gz");

						#remove images.tar.gz
						system("rm -rf $local_path/images.tar.gz");

						fcopy("$wearable_path/output/native.bin", "$local_path/images/boot");

						#tar the images folder to images.tar.gz
						system("tar cvzf $local_path/images.tar.gz images");

						#remove images
						system("rm -rf $local_path/images");
					}
				}
				else
				{
					print "$local_path/Wearable directory not existed under SDK directory structure.\nExiting..\n";
					exit;
				}
			}
			else
			{
				if(-f "$local_path/images.tar.gz")
				{
					system("rm -rf $local_path/images.tar.gz");
				}
				
				fcopy("$sensor_path/aon.bin", "$android_path/images/boot");

				fcopy("$wearable_path/output/native.bin", "$android_path/images/boot");

				fcopy("$bootloaders_path/bl1.bin", "$android_path/images/boot");
				fcopy("$bootloaders_path/u-boot.bin", "$android_path/images/boot");
				fcopy("$bootloaders_path/logo1.bin", "$android_path/images/boot");

				fcopy("$tools_path/dfu.bin", "$android_path/images/boot");

				fcopy("$kernel_bins_path/vmlinux.bin", "$android_path/images/boot");
				fcopy("$kernel_bins_path/wlcore.ko","$android_path/images/modules");
				fcopy("$kernel_bins_path/wlcore_sdio.ko","$android_path/images/modules");
				fcopy("$kernel_bins_path/wl12xx.ko","$android_path/images/modules");

				fcopy("$kernel_bins_path/tty_hci.ko","$android_path/images/modules");
				fcopy("$kernel_bins_path/st_drv.ko","$android_path/images/modules");

				fcopy("$kernel_bins_path/pvrsrvkm.ko","$android_path/images/modules");
				fcopy("$kernel_bins_path/dc_incdhad1.ko","$android_path/images/modules");

				fcopy("$local_path/Scripts/mkfs.incdhad1","$android_path/images");
				fcopy("$local_path/Scripts/mkheader","$android_path/images");

				dircopy("$local_path/Scripts/Music","$android_path/images/Music");
				dircopy("$local_path/Scripts/media","$android_path/images/media");

				system("rm -rf $android_path/images/sgx_bin");
				dircopy("$androidcode_path/sgx_bin","$android_path/images/sgx_bin");

				chdir("$android_path");

				#tar the images folder to images.tar.gz
				system("tar cvzf $local_path/images.tar.gz images");
			}
		}
	}
	else
	{
		print "$local_path/Android/AndroidKK4.4.2 directory not existed under SDK directory structure.\nExiting..\n";
	}
}


### ******************************************************* End of build script ***********************************************************###

