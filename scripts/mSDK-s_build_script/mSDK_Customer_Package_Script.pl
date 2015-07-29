#! usr/bin/perl 

#***************************************************************************
#This Script file is used for MSDK1 Packaging.
#The packaging process consists of Check out from SVN,removing unwanted folders,files.
#Editing some files and running the build script.


#**********Variables Declarations**********************************
@date = split(" ",`date`);
$userName =  $ENV{'LOGNAME'}; 
$dir = "MSDK1_package_$date[1]_$date[2]";
$path = `pwd`;
$dest_path = "/home/$userName/Desktop";
$rootpath = "$dest_path/$dir";
$packagepath = "$rootpath/Package";
$aonpath = "$rootpath/AON";
$nativepath = "$rootpath/Native";
$toolchain_mips = "/home/$userName/toolchain/ubuntu64/mips";

$AONCO = "http://192.168.24.194:9090/svn/swdepot/Dhanush/SW/AON";
$nativeco = "http://192.168.24.194:9090/svn/swdepot/Dhanush/SW/Native";
$toolco = "http://192.168.24.194:9090/svn/swdepot/Dhanush/SW/Tools";
$packageCO = "http://192.168.24.194:9090/svn/swdepot/Dhanush/SW/Scripts/Package";
$Docsco="http://192.168.24.194:9090/svn/swdepot/Dhanush/SW/Documents/Dhanush_Micro_SDK_API_Guide";
$Scripts_path="http://192.168.24.194:9090/svn/swdepot/Dhanush/QA/scripts/mSDK-s_build_script";

#***************Creating a Directory for MSDK1 package****************************************************
chdir($dest_path);

print "\n Creating a directory for the mSDK-S package\n";
mkdir($dir) or die "$!\n Please remove the already existed packaging directory \n" ;

mkdir("logs")or die "$!\n Please remove the logs directory" ;
chdir($dir) or die "\n Couldnt change the directory\n";


#**************Checking out AON,Packages and Native**********************************************************
open(REV,"> $rootpath/SVN_Revisions.txt");
print "\nSVN CHECK OUT FROM AON\n";
print "Enter whether you want to checkout the latest revision(opt 1) or check out other revisions( opt 2):\n";

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
	print "Invalid option entered\n";
}

print "\nSVN CHECK OUT FROM PACKAGE";
print "\nEnter whether you want to checkout the latest revision(opt 1) or check out other revisions( opt 2):\n";
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
	print " Invalid Option entered\n";
	exit;
}


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
	system("sh package.sh MSDK1 >> packageshlog.txt");
	
	print "\n--->Deleting package.sh and readme.txt files from the AON folder\n";
	unlink("package.sh");
	unlink("readme.txt");
	
	print"\n--->Deleting 160 *160 and 320 * 240 folders\n";
	system("rm -rf $aonpath/applications/160*160");
	system("rm -rf $aonpath/applications/320*240");
	
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
	system("sh package.sh MSDK1 >> packageshlog.txt");
	
	print "\n--->Deleting package.sh and readme.txt files from the AON folder\n";
	unlink("package.sh");
	unlink("readme.txt");
	
	print"\n--->Deleting 160 *160 and 320 * 240 folders\n";
	system("rm -rf $aonpath/applications/160*160");
	system("rm -rf $aonpath/applications/320*240");
	
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

#*********************Packaging structure***********************
system("mkdir -p $rootpath/DHANUSH_MICRO_mSDK-S/Native");
system("mkdir -p $rootpath/DHANUSH_MICRO_mSDK-S/Bootloader");
system("mkdir -p $rootpath/DHANUSH_MICRO_mSDK-S/Scripts");

chdir("$rootpath");
system("svn co $Scripts_path >> $dest_path/logs/Scripts_checkout_log");

print"\n***************Renaming the directories***********\n";
chdir($rootpath);
print"\n--->Renaming the directories AON as Sensor \n";
system("cp -r AON DHANUSH_MICRO_mSDK-S/");
system("cp $dest_path/Pre-binaries/native.bin DHANUSH_MICRO_mSDK-S/Native");
system("cp $dest_path/Pre-binaries/dictionary.bin DHANUSH_MICRO_mSDK-S/Native");
system("cp $dest_path/Pre-binaries/spiDump.bin DHANUSH_MICRO_mSDK-S/Bootloader");
system("cp $dest_path/Pre-binaries/spiutil.elf DHANUSH_MICRO_mSDK-S/Bootloader");
system("cp mSDK-s_build_script/build_script_MSDK1.pl DHANUSH_MICRO_mSDK-S/Scripts/Build_Script.pl");

chdir("$rootpath/DHANUSH_MICRO_mSDK-S");
print "\nSVN CHECK OUT OF TOOL CHAIN";
system("svn co $toolco >> \"$dest_path/logs/toolco_log\"");

print"\n***********copying the mips folder to toolchain path **********\n";
print "\n--->Copying the mips folder to the toolchain path\n";
system("cp -r $toolchain_mips $rootpath/DHANUSH_MICRO_mSDK-S/Tools/toolchain/ubuntu64");



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
chdir("$rootpath/DHANUSH_MICRO_mSDK-S/Docs");
system("svn co $Docsco >> $dest_path/logs/Docs_checkout_log");
system("mv Dhanush_Micro_SDK_API_Guide SDK_API_Guide");
chdir("./SDK_API_Guide");
system("rm -rf `find . -type d -name .svn`");
system("rm -rf AON_MSDKS");
chdir("$rootpath/DHANUSH_MICRO_mSDK-S/Scripts");
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



