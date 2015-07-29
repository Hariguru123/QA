#!/usr/bin/perl

use MIME::Lite;
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
print "Enter the source path:";
chomp($source_path=<STDIN>);
print "Enter the destination path:";
chomp($dest_path=<STDIN>);
print "Enter the Release number:";
START:
chomp($Release_num=<STDIN>);

#source path locations
$src_path_DhanushAON = "$source_path/Sensor_Subsystem";
$src_path_Dhanush_Native = "$source_path/Wearable";
$src_path_Dhanush_Android = "$source_path/Dhanush_Android";
$src_path_BL0 = "$source_path/BL0";
$src_path_BL1 = "$source_path/BL1";

#destination path locations
$dest_path1="$dest_path/Dhanush_SDK_$Release_num";
$dest_path_DhanushAON = "$dest_path1/Sensor_Subsystem";
$dest_path_Dhanush_Native = "$dest_path1/Wearable";
$dest_path_Dhanush_Android = "$dest_path1/Dhanush_Android";
$dest_path_BL0 = "$dest_path1/BL0";
$dest_path_BL1 = "$dest_path1/BL1";

if(!$Release_num)
{
	print"Please enter Release Number:";
	goto START;
}
elsif(-d "$dest_path/$Release_num")
{
	print "Release Number already existed.Please enter new Release Number:";
	goto START;
}
if(!($Release_num =~ /^(\d+)\.(\d+)$/))
{
		print "Enter the proper Release number:";
		goto START;
}

#copying the output of AON files to target location
dircopy("$src_path_DhanushAON/output", $dest_path_DhanushAON)||die $!;
copy_specific_extension_files("$src_path_DhanushAON/API","h","Sensor_Subsystem");

#copying the output of Native files to target location
dircopy("$src_path_Dhanush_Native/output", $dest_path_Dhanush_Native);
copy_specific_extension_files("$src_path_Dhanush_Native/API","h","Wearable");

#copying the ouput of Dhanush_Android files to target location
dircopy("$src_path_Dhanush_Android/sample_apps", $dest_path_Dhanush_Android);
fcopy("$src_path_Dhanush_Android/uimage", $dest_path_Dhanush_Android);
copy_specific_extension_files("$src_path_Dhanush_Android/uboot","bin","Dhanush_Android");
copy_specific_extension_files("$src_path_Dhanush_Android","tar","Dhanush_Android");

system(" mkdir $dest_path1/Boot_Loaders");
system("mkdir $dest_path1/Docs");
system("mkdir $dest_path1/Scripts");

#copying the output of Boot loader files to target location
copy_specific_extension_files("$src_path_BL0","bin","Boot_Loaders");
copy_specific_extension_files("$src_path_BL1","bin","Boot_Loaders");

chdir($dest_path);
#****************************Folder Zip*********************************************
system("zip -r Dhanush_SDK_$Release_num.zip Dhanush_SDK_$Release_num");
system("rm -rf Dhanush_SDK_$Release_num");

#copying to share
$package_dir="/home/socplatform-qa/share/packages";
$package_dir1="//192.168.42.46/share/packages";
fcopy("$dest_path/Dhanush_SDK_$Release_num.zip", $package_dir);


#*************************************Send Mail*************************************
$from='krishnamohan.maddineni@incubesol.com';
$to='hgsnarayana.mavilla@incubesol.com';
$cc='krishnamohan.maddineni@incubesol.com';
$subject="Packaging Done";
$body = "Hi Team,\n\n\n Packaging is completed and copied the zip file to $package_dir1 location";

sendMail($to,$cc, $subject,$body, "");


#*****************************************Functions**********************************
sub copy_specific_extension_files
{
	$folder_path=$_[0];	
	$extension=$_[1];
	$dest_folder = $_[2];
	opendir(DIR,$folder_path);

	while($file=readdir(DIR))
	{

		print $file;
		if($file =~ /.+\.$extension/)
		{
			fcopy("$folder_path/$file","$dest_path1/$dest_folder");
		}
	}
}


sub sendMail
{
	my $to = $_[0];
	my $cc=$_[1];
	my $subject=$_[2];
	my $message=$_[3];
	my $attachPath=$_[4];

	 $msg = MIME::Lite->new(
		         From     => $from,
		         To       => $to,
		         Cc       => $cc,
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

 
