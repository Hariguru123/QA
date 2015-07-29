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
	if($line =~ /(.+)\/DHANUSH_MICRO_mSDK-S\/Scripts/)
	{
		$local_path=$1;
		$local_path="$local_path/DHANUSH_MICRO_mSDK-S";
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
$tools_path="$local_path/Tools";
$wearable_path="$local_path/Native";
$sensor_path="$local_path/AON";
$ui_path="$local_path/Tools/Utilities/UIResourceGenerator";


#Creating output Directory
system("mkdir -p $local_path/Output");

print "**************** Build Options ******************\n";
print "Please select one of the following build options.\n";
print "Enter 1 for Sensor subsystem build\n";
print "Enter 2 for Wearable subsystem build\n";
print "Enter 3 for UI Resources build\n";
print "Enter 4 to build all subsystems\n";

chomp($input = <STDIN>);

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
	print "Compiling All subsystems...\n";
	build_sensor();
	build_wearable();
	build_kernel();
}
else
{
	print "Please enter a value in between (1-4)\n";	
	print "Exiting; re-run the script again for build options...\n";
	exit;
}



#Subroutine to build Wearable subsystem 
sub build_wearable()
{
	if(-d "$wearable_path")
	{
		fcopy("$wearable_path/native.bin", "$local_path/Output") or die "copy failed ...$!";
		fcopy("$wearable_path/dictionary.bin", "$local_path/Output") or die "copy failed ...$!";
		print "Native binary is copied to output directory\n";
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
		$status = system("./gen_UI_bin.sh MSDK1 > buildlog.txt 2> faillog.txt;");
		if ($status)
		{
			print("UI Build Failed. Please check the $ui_path/faillog.txt and $ui_path/buildlog.txt for more details\n");
			exit;
		}
		else
		{
			#Updating newly built images under Android images (boot) folder
			fcopy("$ui_path/d_ui.bin", "$local_path/Output") or die "copy failed ...$!";;
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
			#Updating newly built images under Android images (boot) folder
			fcopy("$sensor_path/output/a_msram.bin", "$local_path/Output") or die "copy failed ...$!";
			fcopy("$sensor_path/output/aonsram.bin", "$local_path/Output") or die "copy failed ...$!";
			fcopy("$sensor_path/output/aontcm.bin", "$local_path/Output") or die "copy failed ...$!";
			fcopy("$sensor_path/output/d_aflash.bin", "$local_path/Output") or die "copy failed ...$!";
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




