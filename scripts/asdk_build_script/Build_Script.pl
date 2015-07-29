#!/usr/bin/perl
#********************************************************************\
# SDK package build script. Provide option to build subsystems 
# separately or build everything together.	
#********************************************************************/

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

system("pwd > path.txt");
open(FH,"<path.txt");

#creating a reference location
foreach $line(<FH>)
{
	if($line =~ /(.+)\/DHANUSH_ADVANCED_SDK\/Scripts/)
	{
		$local_path=$1;
		$local_path="$local_path/DHANUSH_ADVANCED_SDK";
	}
	else
	{
		print "Build Script is not available under Scripts folder\n";
		exit;
	}
}
close(FH);

#ALL DECLARATIONS
$scripts_path="$local_path/Scripts";
$toolchain_path="$local_path/Tools/toolchain";
$bootloaders_path="$local_path/Bootloaders";
$kernel_bins_path="$local_path/Kernel";
$tools_path="$local_path/Tools";
$android_path="$local_path/Android/AndroidKK4.4.2";
$androidcode_path="$local_path/Android";
$wearable_path="$local_path/Wearable";
$sensor_path="$local_path/Sensor";
$ui_path="$local_path/Tools/Utilities/UIResourceGenerator";

#checking for required Android packages
print "Check initiated for required packages to build Android.\n";
print "Please check $scripts_path/packages.txt for any missing packages.\n";
chdir($scripts_path);
system("chmod 777 check-packages.sh");
system("./check-packages.sh > packages.txt 2> out.txt");
print "Continue with the build only if all required packages are installed.\n";
print "Enter 1 to continue to Build.\n";

chomp($input = <STDIN>);
if($input eq 1)
{
	print "Continuing to build options\n";
}
else
{
	print "Exiting\n";
	exit;
}

print "**************** Build Options ******************\n";
print "Please select one of the following build options.\n";
print "Enter 1 for Sensor subsystem build\n";
print "Enter 2 for Wearable subsystem build\n";
print "Enter 3 for UI Resources build\n";
print "Enter 4 for Kernel build\n";
print "Enter 5 for Android Build\n";
print "Enter 6 to build all subsystems\n";

chomp($input = <STDIN>);

#Sanity check for existing images
sanity_check();

#input parser and builds go from here
if($input eq 1)
{
	print "Compiling Sensor subsystem...\n";
	build_sensor();
}
elsif($input eq 2)
{
	print "Compiling Wearable subsystem...\n";
	build_wearable();
}
elsif($input eq 3)
{
	print "Compiling UI subsystem...\n";
	build_ui();
}
elsif($input eq 4)
{
	print "Compiling Kernel subsystems...\n";
	build_kernel();
}
elsif($input eq 5)
{
	print "Compiling Android subsystems...\n";
	if(-f "$local_path/images.tar.gz")
	{
		system("rm -rf $local_path/images.tar.gz");
	}
	build_android();
}
elsif($input eq 6)
{
	print "Compiling all subsystems...\n";
	if(-f "$local_path/images.tar.gz")
	{
		system("rm -rf $local_path/images.tar.gz");
	}
	build_android();
}
else
{
	print "Please enter a value in between (1-6)\n";	
	print "Exiting; re-run the script again for build options...\n";
	exit;
}

chdir($local_path);
system("tar xvzf images.tar.gz");
system("cp Scripts/Imgcreation.sh images");
chdir("$local_path/images");
system("sudo -s sh Imgcreation.sh");

if(-f "$local_path/images/aSDK.img")
{
	system("echo File exists >img_successlog.txt");
}   
else
{
	system("echo File does not exists >img_faillog.txt");
}

system("mv aSDK.img $local_path");

chdir($local_path);
system("tar cvzf aSDK.img.tar.gz aSDK.img");
system("sudo rm -rf aSDK.img images");


#Subroutine to build Wearable subsystem 
sub build_wearable()
{
	if(-d "$wearable_path")
	{
		print "***************** Wearable Build in Progress**********************\n";
		#delete the output folder with contents and create new output folder 
		system("rm -rf $wearable_path/output"); 
		system("mkdir $wearable_path/output");
		chdir($wearable_path);
		#Build the Wearable subsystem
		$status = system("./build/build.sh ADV_IMG1 clean rel > buildlog.txt 2>> faillog.txt;");
		if ($status)
		{
			print("Wearable Build Failed. Please check the $wearable_path/faillog.txt and $wearable_path/buildlog.txt for more details\n");
			exit;
		}
		else
		{
						
			if(-f "$local_path/images.tar.gz")
			{
				#Updating the tarred images in root folder
				chdir("$local_path");
				system("tar -xvzf $local_path/images.tar.gz");
				fcopy("$wearable_path/output/adv1image1/native1.bin", "$local_path/images/boot");
				fcopy("$wearable_path/output/adv1image1/native2.bin", "$local_path/images/boot");
				system("rm -rf $local_path/images.tar.gz");
				system("tar cvzf $local_path/images.tar.gz images");
				system("rm -rf $local_path/images");
			}
			#Updating newly built images under Android images (boot) folder
			fcopy("$wearable_path/output/adv1image1/native1.bin", "$android_path/images/boot");
			fcopy("$wearable_path/output/adv1image1/native2.bin", "$android_path/images/boot");
			print "***************** Wearable Build Completed **********************\n";
		}
	}
	else
	{
		print "$wearable_path does not exist\n";
		print "Exiting..\n";
		exit;
	}
}

#Subroutine to build UI resources
sub build_ui()
{
	if(-d "$ui_path")
	{
		chdir($ui_path);
		print "***************** UI Build in Progress**********************\n";
		$status = system("./gen_UI_bin.sh ADV_320 > buildlog.txt 2> faillog.txt; ./spi_dump_gen d_ui.bin 0x0 > buildlog.txt 2>> faillog.txt;");
		if ($status)
		{
			print("UI Build Failed. Please check the $ui_path/faillog.txt and $ui_path/buildlog.txt for more details\n");
			exit;
		}
		else
		{
			if(-f "$local_path/images.tar.gz")
			{
				#Updating the tarred images in root folder
				chdir("$local_path");
				system("tar -xvzf $local_path/images.tar.gz");
				fcopy("$ui_path/SPI_DUMP.bin", "$local_path/images/boot/d_ui.bin");
				system("rm -rf $local_path/images.tar.gz");
				system("tar cvzf $local_path/images.tar.gz images");
				system("rm -rf $local_path/images");
			}
			#Updating newly built images under Android images (boot) folder
			fcopy("$ui_path/SPI_DUMP.bin", "$android_path/images/boot/d_ui.bin");
			print "***************** UI Build Completed **********************\n";
		}
	}
	else
	{
		print "$ui_path does not exist\n";
		print "Exiting...\n";
		exit;
	}
}

#Subroutine to build sensor subsystem
sub build_sensor()
{
	if(-d "$sensor_path")
	{
		chdir($sensor_path);
		print "***************** Sensor Build in Progress**********************\n";
		$status = system("./build.sh clean > buildlog.txt 2> faillog.txt; ./build.sh > buildlog.txt 2>> faillog.txt;");
		if ($status)
		{
			print("Sensor Build Failed. Please check the $sensor_path/faillog.txt and $sensor_path/buildlog.txt for more details\n");
			exit;
		}
		else
		{
			if(-f "$local_path/images.tar.gz")
			{
				#Updating the tarred images in root folder
				chdir("$local_path");
				system("tar -xvzf $local_path/images.tar.gz");
				fcopy("$sensor_path/output/a_msram.bin", "$local_path/images/boot");
				fcopy("$sensor_path/output/aonsram.bin", "$local_path/images/boot");
				fcopy("$sensor_path/output/aontcm.bin", "$local_path/images/boot");
				fcopy("$sensor_path/output/d_aflash.bin", "$local_path/images/boot");
				system("rm -rf $local_path/images.tar.gz");
				system("tar cvzf $local_path/images.tar.gz images");
				system("rm -rf $local_path/images");
			}
			#Updating newly built images under Android images (boot) folder
			fcopy("$sensor_path/output/a_msram.bin", "$android_path/images/boot");
			fcopy("$sensor_path/output/aonsram.bin", "$android_path/images/boot");
			fcopy("$sensor_path/output/aontcm.bin", "$android_path/images/boot");
			fcopy("$sensor_path/output/d_aflash.bin", "$android_path/images/boot");
			print "***************** Sensor Build Completed **********************\n";
		}
	}
	else
	{
		print "$sensor_path does not exist\n";
		print "Exiting...\n";
		exit;
	}
}


#Subroutine to build kernel subsystem
sub build_kernel()
{
	if(-d "$kernel_bins_path")
	{
		chdir($kernel_bins_path);
		print "***************** Kernel Build in Progress**********************\n";
		$status = system("./build.sh smp clean int no > buildlog.txt 2> faillog.txt");
		if ($status)
		{
			print("Kernel Build Failed. Please check the $kernel_bins_path/faillog.txt and $kernel_bins_path/buildlog.txt for more details\n");
			exit;
		}
		else
		{
			if(-f "$local_path/images.tar.gz")
			{
				#Updating the tarred images in root folder
				chdir("$local_path");
				system("tar -xvzf $local_path/images.tar.gz");
				fcopy("$kernel_bins_path/arch/mips/boot/vmlinux.bin", "$local_path/images/boot");
				fcopy("$kernel_bins_path/drivers/net/wireless/ti/wl12xx/wl12xx.ko", "$local_path/images/modules");
				fcopy("$kernel_bins_path/drivers/net/wireless/ti/wlcore/wlcore.ko", "$local_path/images/modules");
				fcopy("$kernel_bins_path/drivers/net/wireless/ti/wlcore/wlcore_sdio.ko", "$local_path/images/modules");
				fcopy("$kernel_bins_path/drivers/misc/ti-st/st_drv.ko", "$local_path/images/modules");
				fcopy("$kernel_bins_path/drivers/misc/ti-st/tty_hci.ko", "$local_path/images/modules");

				system("rm -rf $local_path/images.tar.gz");
				system("tar cvzf $local_path/images.tar.gz images");
				system("rm -rf $local_path/images");
			}
			#Updating newly built images under Android images (boot) folder

			fcopy("$kernel_bins_path/arch/mips/boot/vmlinux.bin", "$android_path/images/boot");
			fcopy("$kernel_bins_path/drivers/net/wireless/ti/wl12xx/wl12xx.ko", "$android_path/images/modules");
			fcopy("$kernel_bins_path/drivers/net/wireless/ti/wlcore/wlcore.ko", "$android_path/images/modules");
			fcopy("$kernel_bins_path/drivers/net/wireless/ti/wlcore/wlcore_sdio.ko", "$android_path/images/modules");
			fcopy("$kernel_bins_path/drivers/misc/ti-st/st_drv.ko", "$android_path/images/modules");
			fcopy("$kernel_bins_path/drivers/misc/ti-st/tty_hci.ko", "$android_path/images/modules");

			print "***************** Kernel Build Completed **********************\n";
		}
	}
	else
	{
		print "$kernel_bins_path does not exist\n";
		print "Exiting...\n";
		exit;
	}
}

#Subroutine for Android build
#Boot folder from tarred images in root will be copied to boot folder under Android images
sub build_android()
{
	if(-d "$android_path")
	{
		print "******************* Android Build In Progress *********************\n";
		chdir($android_path);
		$status = system("./build.sh clean > Android_buildlog.txt 2> Android_faillog.txt");
		if((!(-f "$android_path/images/rfs/system.img")) || ($status)) 
		{
			print "Android Build Failed. Please check the $android_path/Android_buildlog.txt and $android_path/Android_faillog.txt for more details\n";
			exit;
		}
		else
		{
			if(-f "$local_path/images.tar.gz")
			{
				#Extract tarred images in root to copy the boot folder
				chdir("$local_path");
				system("tar -xvzf $local_path/images.tar.gz");
				dircopy("$local_path/images/boot", "$android_path/images/boot");
				system("rm -rf $local_path/images.tar.gz");
			}
			else
			{
					print "Android pre-built images don't exist. Copying binaries to it.\n";
					dircopy("$local_path/Android/sgx_bin", "$android_path/images/sgx_bin");

					fcopy("$local_path/Bootloaders/bl0.bin", "$android_path/images/boot");
					fcopy("$local_path/Bootloaders/bl1.bin", "$android_path/images/boot");
					fcopy("$local_path/Bootloaders/u-boot.bin", "$android_path/images/boot");
					fcopy("$local_path/Bootloaders/logo1.bin", "$android_path/images/boot");
					fcopy("$local_path/Bootloaders/ble_fw.bin", "$android_path/images/boot");
					
					fcopy("$local_path/Android/sgx_bin/system/modules/pvrsrvkm.ko","$android_path/images/modules");
					fcopy("$local_path/Android/sgx_bin/system/modules/dc_incdhad1.ko","$android_path/images/modules");
					fcopy("$local_path/Android/video/imgvideo.ko","$android_path/images/modules");
					fcopy("$local_path/Android/video/topazkm.ko","$android_path/images/modules");
					fcopy("$local_path/Android/video/vdecdd.ko","$android_path/images/modules");
					
					fcopy("$local_path/Scripts/mkfs.incdhad1","$android_path/images");
					fcopy("$local_path/Scripts/mkheader","$android_path/images");
					dircopy("$local_path/Scripts/Music","$android_path/images/Music");
					dircopy("$local_path/Scripts/media","$android_path/images/media");
					
					fcopy("$tools_path/dfu.bin", "$android_path/images/boot");

					build_kernel();
					print "Compiled Kernel binaries and copied same to Android images\n";
					build_sensor();
					print "Compiled Sensor binaries and copied same to Android images\n";
					build_wearable();
					print "Compiled Wearable binaries and copied same to Android images\n";
					build_ui();
					print "Compiled UI binaries and copied same to Android images\n";
			}
			chdir("$android_path");
			#tar the images folder to images.tar.gz
			system("tar cvzf $local_path/images.tar.gz images");
			system("rm -rf $local_path/images");
			print "******************* Android Build Completed *********************\n";
		}
	}
	else
	{
		print "$android_path does not exist\n";
		print "Exiting...\n";
		exit;
	}
}

#Subroutine to check tarred images file and Android images folder.
#If either of these don't exist this subroutine will create them
sub sanity_check()
{
	print "Sanity check of pre-built images in progress...\n";
	if(!(-d "$android_path/images"))
	{
		print "Android pre-built images don't exist.\n";
		print "Re-building Android\n";
		build_android();
	}
	elsif(!(-f "$local_path/images.tar.gz"))
	{
		#Android images path is confirmed to exist from above
		#We just need to tar existing images
		chdir("$android_path");
		system("tar cvzf $local_path/images.tar.gz images");
	}
	print "Sanity check completed\n";
}
