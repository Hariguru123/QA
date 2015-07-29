#! usr/bin/perl 

#***************************************************************************
#This Script file is used for Android Packaging.
#The packaging process consists of Check out from SVN,removing unwanted folders,files.
#Editing some files and running the build script.
#author: sivaramaprasad.swayampakula@incubesol.com


#**********Variables Declarations**********************************
@date = split(" ",`date`);
$userName =  $ENV{'LOGNAME'}; 
$dir = "Android_package_$date[1]_$date[2]";
$path = `pwd`;
$dest_path = "/home/$userName/Desktop";
$rootpath = "$dest_path/$dir";
$packagepath = "$rootpath/Package";
$aonpath = "$rootpath/AON";
$nativepath = "$rootpath/Native";
$asdk_build_path = "$rootpath/asdk_build_script"; 
$asdk_script_file = "$rootpath/aSDK";
$toolchain_ubuntu = "$rootpath/toolchain/ubuntu64";
$toolchain_mips = "/home/$userName/toolchain/ubuntu64/mips";


$AONCO = "http://192.168.24.194:9090/svn/swdepot/Dhanush/Experimental/DoU_AON_Native/AON";
$packageCO = "http://192.168.24.194:9090/svn/swdepot/Dhanush/SW/Scripts/Package";
$nativeco = "http://192.168.24.194:9090/svn/swdepot/Dhanush/Experimental/DoU_AON_Native/Native";
$asdkbuildscriptco = "http://192.168.24.194:9090/svn/swdepot/Dhanush/QA/scripts/asdk_build_script";
$asdkpckgfile = "http://192.168.24.194:9090/svn/swdepot/Dhanush/SW/Scripts/Package/aSDK";
$toolchainco = "http://192.168.24.194:9090/svn/swdepot/Dhanush/SW/Tools/toolchain";
$Androidco = "http://192.168.24.194:9090/svn/swdepot/Dhanush/Advanced/Dhanush_Advanced_B0/Android/AndroidKK4.4.2";
$kernalco = "http://192.168.24.194:9090/svn/swdepot/Dhanush/Advanced/Dhanush_Advanced_B0/Android/android-linux-mti-unif-3.10.14";
$utilitiesco = "http://192.168.24.194:9090/svn/swdepot/Dhanush/SW/Tools/Utilities";
$Docsco="http://192.168.24.194:9090/svn/swdepot/Dhanush/SW/Documents/Dhanush_Micro_SDK_API_Guide";

#***************Creating a Directory for android package****************************************************
chdir($dest_path);

print "\n Creating a directory for the android package\n";
mkdir($dir) or die "$!\n Please remove the already existed packaging directory \n" ;

mkdir("logs")or die "$!\n Please remove the logs directory" ;
chdir($dir) or die "\n Couldnt change the directory\n";


#**************Checking out AON,Packages and Native**********************************************************
open(REV,"> $rootpath/SVN_Revisions.txt");
print "******************************************************************************************************\n";
print "SVN CHECK OUT FROM AON\n";
print "Enter whether you want to checkout the latest revision(opt 1) or check out other revisions( opt 2):\n";
LOOPAC:
$opt1 = <STDIN>;
if($opt1 == 1)
{
	checkout_check_revision($AONCO,0,"$rootpath","AON");
}

elsif($opt1 == 2)
{
	print "\n Enter the revision number that you want to check out:\n";
	$revaa = <STDIN>;
	chomp($revaa);
	checkout_check_revision($AONCO,$revaa,"$rootpath","AON");
}

else
{
	print "Invalid option entered,Please enter the correct value\n";
	goto LOOPAC; 
}

print "\n SVN CHECK OUT FROM PACKAGE";
print "\n Enter whether you want to checkout the latest revision(opt 1) or check out other revisions( opt 2):\n";
LOOPPC:
$opt2 = <STDIN>;

if($opt2 == 1)
{
	checkout_check_revision($packageCO,0,"$rootpath","Package");
}

elsif($opt2 == 2)
{
	print "Enter the revision number of the package that you want to check out:\n";
	$revss = <STDIN>;
	chomp($revss);
	checkout_check_revision($packageCO,$revss,"$rootpath","Package");
}

else 
{
	print "Invalid option entered,Please enter the correct value\n";
	goto LOOPPC;
}

print "\n SVN CHECK OUT FROM NATIVE";
print "\n Enter whether you want to checkout the latest revision(opt 1) or check out other revisions( opt 2):\n";
LOOPNC:
$opt3 = <STDIN>;

if($opt3 == 1)
{
	checkout_check_revision($nativeco,0,"$rootpath","Native");
}

elsif($opt3 == 2)
{
	print "Enter the revision number of the Native that you want to check out:\n";
	$revnn = <STDIN>;
	chomp($revnn);
	checkout_check_revision($nativeco,$revnn,"$rootpath","Native");
}

else 
{
	print "Invalid option entered,Please enter the correct value\n";
	goto LOOPNC;
}

print "\n SVN CHECK OUT FROM ASDK_BUILDS_SCRIPTS";
print "\n Enter whether you want to checkout the latest revision(opt 1) or check out other revisions( opt 2):\n";
LOOPBC:
$opt4 = <STDIN>;

if($opt4 == 1)
{
	checkout_check_revision($asdkbuildscriptco,0,"$rootpath","asdk_build_script");
}

elsif($opt4 == 2)
{
	print "Enter the revision number of the ASDK_BUILD_SCRIPTS that you want to check out:\n";
	$revas = <STDIN>;
	chomp($revas);
	checkout_check_revision($asdkbuildscriptco,$revas,"$rootpath","asdk_build_script");
}

else 
{
	print "Invalid option entered,Please enter the correct value\n";
	goto LOOPBC;
}

print "\n SVN CHECK OUT FROM ASDK PACKAGE.sh FILE";
system("svn co $asdkpckgfile >> \"$dest_path/logs/asdk_package_file_log\"");

print "\n SVN CHECK OUT OF TOOL CHAIN";
system("svn co $toolchainco >> \"$dest_path/logs/toolchainco_log\"");
 
print "\n****************AON  Package Options ******************\n";
print "Please select one of the following options.\n";
LOOP:print "1.AON_WithSource
2.AON_WithoutSource\n";

chomp($input = <STDIN>);
if($input eq 1)
{

	print "\n--->Making changes in the AON FOLDER\n";
	print "\n--->Copying the package.sh and readme.txt files to the AON folder from AON_SRC folder\n";
	system("cp Package/AON_SRC/package.sh AON/");
	system("cp Package/AON_SRC/readme.txt AON/");
	
	chdir($aonpath);
	system("chmod +x package.sh");
	print"\n--->Running the package.sh file\n";
	system("sh package.sh ADV >> packageshlog.txt");
	
	print "\n--->Deleting package.sh and readme.txt files from the AON folder\n";
	unlink("package.sh");
	unlink("readme.txt");
	
	print"\n--->Deleting 160 *160 and 128 * 128 folders\n";
	system("rm -rf $aonpath/applications/160*160");
	system("rm -rf $aonpath/applications/128*128");
	
	print"\n--->Copying build.sh and readme.txt from sdk_sensor folder to AON folder\n";
	system("cp $packagepath/AON_SRC/sdk_sensor/build.sh $aonpath");
	system("cp $packagepath/AON_SRC/sdk_sensor/readme.txt $aonpath");
	
	print"\n--->Making changes in commoninc file present in Build folder of AON\n";
	open(my $DATA,"<$aonpath/build/commoninc");
	@data = <$DATA> ;
	$lines = @data;
	$i = 0;
	while( $i <= $lines )
	{
		$data[$i] =~ s/\$\(HOME\)/\$\(SRC_PATH\)\/..\/Tools/;
		$i++;
	}
	close($DATA);
	unlink("$aonpath/build/commoninc");
	
	open(DATA2,">$aonpath/build/commoninc");
	print DATA2 @data;
	close DATA2;
	print "\n***********AON Packaging is done************\n";
}
elsif($input eq 2)
{
	print "\n--->Making changes in the AON FOLDER\n";
	print "\n--->Copying the package.sh and readme.txt files to the AON folder from AON folder\n";
	system("cp Package/AON/package.sh AON/");
	system("cp Package/AON/readme.txt AON/");
	
	chdir($aonpath);
	system("chmod +x package.sh");
	print"\n--->Running the package.sh file\n";
	system("sh package.sh ADV >> packageshlog.txt");
	
	print "\n--->Deleting package.sh and readme.txt files from the AON folder\n";
	unlink("package.sh");
	unlink("readme.txt");
	
	print"\n--->Deleting 160 *160 and 128 * 128 folders\n";
	system("rm -rf $aonpath/applications/160*160");
	system("rm -rf $aonpath/applications/128*128");
	
	print"\n--->Copying build.sh and readme.txt from sdk_sensor folder to AON folder\n";
	system("cp $packagepath/AON/sdk_sensor/build.sh $aonpath");
	system("cp $packagepath/AON/sdk_sensor/readme.txt $aonpath");
	
	print"\n--->Making changes in commoninc file present in Build folder of AON\n";
	open(my $DATA,"<$aonpath/build/commoninc");
	@data = <$DATA> ;
	$lines = @data;
	$i = 0;
	while( $i <= $lines )
	{
	$data[$i] =~ s/\$\(HOME\)/\$\(SRC_PATH\)\/..\/Tools/;
	$i++;
	}
	close($DATA);
	unlink("$aonpath/build/commoninc");
	
	open(DATA2,">$aonpath/build/commoninc");
	print DATA2 @data;
	close DATA2;
	print "\n*******AON Packaging is done*********\n";
}	
else
{
	print "Please enter a value either 1 or 2\n";
	goto LOOP; 	
	
}	

print "********Native  Package Options ********\n";
print "Please select one of the following options.\n";
LOOPN:print "1.Native_WithSource
2.Native_WithoutSource\n";

chomp($input = <STDIN>);
if($input eq 1)
{
	system("chmod +x $dest_path/$dir/Package/Native/Native_SRC/createsourcepackage.sh");
	chdir($nativepath);
	system("cp $dest_path/$dir/Package/Native/Native_SRC/createsourcepackage.sh $nativepath");
	system("cp $dest_path/$dir/Package/Native/Native_SRC/patch.txt $nativepath");
	system("sh createsourcepackage.sh >> Nativepackageshlog.txt");
	print "\n--->Deleting createsourcepackage.sh and patch.txt file from the Native folder\n";
	unlink("createsourcepackage.sh");
	unlink("patch.txt");
	print "\n***********Native Packaging is done**********\n";
}
elsif($input eq 2)
{
	system("chmod +x $dest_path/$dir/Package/Native/Native_APP_SRC/package.sh");
	chdir($nativepath);
	system("cp $dest_path/$dir/Package/Native/Native_APP_SRC/package.sh $nativepath");
	system("cp -r $dest_path/$dir/Package/Native/Native_APP_SRC/sdk_wearable $nativepath/");
	system("sh package.sh ADV >> Nativepackageshlog.txt");
	unlink("package.sh");
	system("rm -rf sdk_wearable");
	print "\n*******Native Packaging is done********\n";
}
else
{
	print "Please enter a value either 1 or 2\n";
	goto LOOPN; 	
	
}

open(my $DATA,"<$nativepath/build/build.sh");
@data = <$DATA> ;
$lines = @data;
$i = 0;
while( $i <= $lines )
{
	$data[$i] =~ s/\$HOME\/toolchain/\$SRC_ROOT\/..\/Tools\/toolchain/;
	$i++;
}
close($DATA);
unlink("$nativepath/build/build.sh");

open(DATA2,">$nativepath/build/build.sh");
print DATA2 @data;
close DATA2;
system("chmod 777 $nativepath/build/build.sh");

open(my $DATA,"<$nativepath/binSplit.sh");
@data = <$DATA> ;
$lines = @data;
$i = 0;
while( $i <= $lines )
{
	$data[$i] =~ s/\$HOME\/toolchain/..\/Tools\/toolchain/;
	$i++;
}
close($DATA);
unlink("$nativepath/binSplit.sh");

open(DATA2,">$nativepath/binSplit.sh");
print DATA2 @data;
close DATA2;

system("chmod 777 $nativepath/binSplit.sh");


print"\n***************Renaming the directories***********\n";
chdir($rootpath);
print"\n--->Renaming the directories AON and NATIVE as Sensor and Wearable\n";
system("mv AON Sensor");
system("mv Native Wearable");

print"\n***********copying the mips folder to toolchain path **********\n";
print "\n--->Copying the mips folder to the toolchain path\n";
system("cp -r $toolchain_mips $toolchain_ubuntu");


print"\n************copying the files from asdk_build_script folder to root folder***********\n";

print "\n--->copying the files from check_packages.sh and build_script.pl files to root folder \n";
system("cp $asdk_build_path/check-packages.sh .");
system("cp $asdk_build_path/Build_Script.pl .");


print"\n*********Copying the asdk_package.sh file to the root folder and deleting the folder from the root folder*****\n";
print "\n--->Copying the aSDK_package_with_Kernel_Sources.sh file to root folder\n";
system("cp $asdk_script_file/aSDK_package_with_Kernel_Sources.sh .");
system("rm -rf $dest_path/$dir/Wearable/Nativepackageshlog.txt");
system("rm -rf $dest_path/$dir/Sensor/makefile.MSDK4 $dest_path/$dir/Sensor/packageshlog.txt");

print"\n**************Creating an empty Readme.pdf and release_notes.pdf*************\n";
print "\n--->Creating a Readme.pdf file \n";
open(DATA3,">Readme.pdf");
close DATA3;
print "\n--->Creating a Release_Note.pdf file \n";
open(DATA4,">Release_Note.pdf");
close DATA4;

print"\n***********Creating a DOCS folder*******************\n";
print"\n--->Creating a docs folder\n";
mkdir("Docs");
chdir("$rootpath/Docs");
system("svn co $Docsco >> $dest_path/logs/Docs_checkout_log");
system("mv Dhanush_Micro_SDK_API_Guide SDK_API_Guide");
chdir("./SDK_API_Guide");
system("rm -rf `find . -type d -name .svn`");
system("rm -rf AON_MSDKS");
chdir("$rootpath");

print"\n***********Copying the Images.tar.gz files to the local folder*******\n";
print "\n--->Copying the images.tar.gz file from Desktop/asdk_images folder to Android packaging folder\n";
system("cp $dest_path/aSDK_images/images.tar.gz $dest_path/$dir");


print"\n*******Running the asdk_package script in the local folder**********\n";
mkdir("Final_packaging");
print "\n--->Creating the Final Packaging structure by running the script\n";
system("./aSDK_package_with_Kernel_Sources.sh $dest_path/$dir $dest_path/$dir/Final_packaging >> \"$dest_path/logs/asdk_pckgscriptlog\" ");

print"\n*********Checking out the android from SVN*************\n";
chdir("$dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Android");
print "Enter whether you want to checkout the latest revision(opt 1) or check out other revisions( opt 2):\n";
LOOPAND:
$opt5 = <STDIN>;

if($opt5 == 1)
{
	
	checkout_check_revision($Androidco,0,"$rootpath/Final_packaging/DHANUSH_ADVANCED_SDK/Android","AndroidKK4.4.2");
	
}
elsif($opt5 == 2)
{
	print "Enter the revision number of the AndroidKK4.4.2 that you want to check out:\n";
	$revands = <STDIN>;
	chomp($revands);
	checkout_check_revision($Androidco,$revands,"$rootpath/Final_packaging/DHANUSH_ADVANCED_SDK/Android","AndroidKK4.4.2");
}
else
{
	print "Please enter a value either 1 or 2\n";
	goto LOOPAND; 	
	
}

system("cp -r $dest_path/$dir/images.tar.gz $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Android/AndroidKK4.4.2");
chdir("AndroidKK4.4.2");
system("tar xzvf images.tar.gz");
system("rm -rf images.tar.gz");
print"\n Deleting the Img folder from Hardware section\n";

system("rm -rf  $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Android/AndroidKK4.4.2/hardware/img");
print"\n******Android packaging is done**********************\n";


print"\n*******Checking out the kernel from SVN and making changes to it************\n";

chdir("$dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel");
print "*********Kernel  Package Options ******\n";
print "Please select one of the following options.\n";
LOOPK:print "1.Kernel_WithoutSource
2.Kernel_WithSource\n";
chomp($input = <STDIN>);

if($input eq 1)
{

	system("cp $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Android/AndroidKK4.4.2/images/modules/wl12xx.ko $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel");

	system("cp $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Android/AndroidKK4.4.2/images/modules/wlcore.ko $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel");

	system("cp $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Android/AndroidKK4.4.2/images/modules/wlcore_sdio.ko $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel");

	system("cp $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Android/AndroidKK4.4.2/images/modules/st_drv.ko $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel");

	system("cp $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Android/AndroidKK4.4.2/images/modules/tty_hci.ko $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel");

	system("cp $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Android/AndroidKK4.4.2/images/boot/vmlinux.bin $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel");

}

elsif($input eq 2)
{
	print "Enter whether you want to checkout the latest revision(opt 1) or check out other revisions( opt 2):\n";
	LOOPKC:
	$opt6 = <STDIN>;
	if($opt6 == 1)
	{
		print "\n--->SVN CHECK OUT OF KERNEL\n";
		checkout_check_revision($kernalco,0,"$rootpath/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel","android-linux-mti-unif-3.10.14");
	}
	elsif($opt6 == 2)
	{
		print "Enter the revision number of the Kernel that you want to check out:\n";
		$revks = <STDIN>;
		chomp($revks);
		checkout_check_revision($kernalco,$revks,"$rootpath/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel","android-linux-mti-unif-3.10.14");
	}
	else
	{
		print "Please enter a value either 1 or 2\n";
		goto LOOPKC;
	}

	system ( "mv  $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel/android-linux-mti-unif-3.10.14/* $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel");

	system("rm -rf $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel/android-linux-mti-unif-3.10.14");
	print "\n--->Making changes in the module.c file in the kerna/kernal folder\n";
	chdir("$dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel/kernel");
	open(DATAa,"< $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel/kernel/module.c");
	@srh = <DATAa>;
	$h = @srh ;
	$x = 0;
	while ( $x < $h)
	{
		$srh[$x] =~ s/if \(flags & MODULE_INIT_IGNORE_VERMAGIC\)/\/\/if \(flags & MODULE_INIT_IGNORE_VERMAGIC\)/ ;
		$x++;
	}
	unlink("$dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel/kernel/module.c");
	close(DATAa);

	open(DATAb,"> $dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Kernel/kernel/module.c");
	print DATAb @srh ; 
	close DATAb;
}

else
{
	print "Please enter a value either 1 or 2\n";
	goto LOOPK; 	
	
}																		


print"\n************Checking out the utilities folder*********\n";
chdir("$dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Tools");
print "\n--->SVN CHECK OUT OF UTILITIES\n";
system("svn co $utilitiesco >> \"$dest_path/logs/utilitiescheckoutfile1\" ");

print "************Remove the .svn files in the package *************\n";
chdir("$dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/");
system("rm -rf `find . -type d -name .svn`");

print"\n********Running the build script .pl file in the scripts folder******\n";
chdir("$dest_path/$dir/Final_packaging/DHANUSH_ADVANCED_SDK/Scripts");
system("perl Build_Script.pl");
close(REV);

sub checkout_check_revision
{
	$URL=$_[0];
	$revision=$_[1];
	$root_path=$_[2];
	$code_base=$_[3];
	
	if ($revision eq 0)
	{
		system("svn co $URL >> \"$dest_path/logs/Androidcheckoutfile1\" ");
	}
	else
	{
		system("svn co -r $revision $URL >> \"$dest_path/logs/Androidcheckoutfile1\" ");
	}
	$local_path="$root_path/$code_base";
	@lines = `svn info  $local_path`;
	foreach my $line (@lines)
   	{
        	chomp($line);
		if($line =~/Last Changed Rev: (\d+)/)
		{
			$revision_svn = $1;
			last;
		}
    	}
	print REV "$code_base=$revision_svn\n";
	print "$code_base checkout is done \n";
}	


