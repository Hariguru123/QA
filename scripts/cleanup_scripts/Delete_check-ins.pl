#!/usr/bin/perl

#Deletes check-in requests data

#Build Requests
system("find /media/Data/trunk_wc/build_requests -maxdepth 1 -mtime +7 > temp2.txt");

open(FH1, "< temp2.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	print "$line1\n";

	system("sudo rm -rf $line1");
}


#AONsensor
system("find /media/Data/sdk/AONsensor -maxdepth 1 -mtime +7 > temp.txt");

open(FH1, "< temp.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	print "$line1\n";

	system("sudo rm -rf $line1");
}


#Native
system("find /media/Data/sdk/Native -maxdepth 1 -mtime +7 > temp.txt");

open(FH1, "< temp.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	print "$line1\n";

	system("sudo rm -rf $line1");
}


#BL1
system("find /media/Data/sdk/BL1 -maxdepth 1 -mtime +7 > temp.txt");

open(FH1, "< temp.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	print "$line1\n";

	system("sudo rm -rf $line1");
}

#u-Boot
system("find /media/Data/sdk/U-Boot -maxdepth 1 -mtime +7 > temp.txt");

open(FH1, "< temp.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	print "$line1\n";

	system("sudo rm -rf $line1");
}



#SGX
system("find /media/Data/sdk/SGX -maxdepth 1 -mtime +7 > temp.txt");

open(FH1, "< temp.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	chomp($line1);

	if(-d "$line1")
	{
		print "folder: $line1\n";

		chdir($line1) || die("\ndirectory can not be changed");

		@sub_folders = split('/',$line1);

		$sub_length = @sub_folders;

		$name = $sub_folders[$sub_length-1];

		system("sudo chmod 777 $name.txt");

		open(FH2, "< $name.txt") || die("can not open file $!\n");
		@lines2 = <FH2>;
		close(FH2);

		chomp($lines2[0]);

		print "trunk: $lines2[0]\n";

		chdir($lines2[0]) || die("\ndirectory can not be changed");

		open(FH2, ">revert.txt") || die("can not open file $!\n");

		system("sudo svn revert -R AndroidKK4.4.2");

		close(FH2);

		system("sudo rm -rf revert.txt");

		system("sudo rm -rf lock.txt");

		chdir("/media/Data/sdk/SGX");

		system("sudo rm -rf $line1");
	}
	else
	{
		print " ln: $line1\n";

		system("sudo rm -rf $line1");
	}
}


#Kernel
system("find /media/Data/sdk/android-linux-mti-unif-3.10.14 -maxdepth 1 -mtime +7 > temp.txt");

open(FH1, "< temp.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	chomp($line1);

	if(-d "$line1")
	{
		print "folder: $line1\n";

		chdir($line1) || die("\ndirectory can not be changed");

		@sub_folders = split('/',$line1);

		$sub_length = @sub_folders;

		$name = $sub_folders[$sub_length-1];

		system("sudo chmod 777 $name.txt");

		open(FH2, "< $name.txt") || die("can not open file $!\n");
		@lines2 = <FH2>;
		close(FH2);

		chomp($lines2[0]);

		print "trunk: $lines2[0]\n";

		chdir($lines2[0]) || die("\ndirectory can not be changed");

		open(FH2, ">revert.txt") || die("can not open file $!\n");

		system("sudo svn revert -R AndroidKK4.4.2");

		close(FH2);

		system("sudo rm -rf revert.txt");

		system("sudo rm -rf lock.txt");

		chdir("/media/Data/sdk/android-linux-mti-unif-3.10.14");

		system("sudo rm -rf $line1");
	}
	else
	{
		print " ln: $line1\n";

		system("sudo rm -rf $line1");
	}
}


#AndroidKK4.4.2
system("find /media/Data/sdk/AndroidKK4.4.2 -maxdepth 1 -mtime +7 > temp.txt");

open(FH1, "< temp.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	chomp($line1);

	if(-d "$line1")
	{
		print "folder: $line1\n";

		chdir($line1) || die("\ndirectory can not be changed");

		@sub_folders = split('/',$line1);

		$sub_length = @sub_folders;

		$name = $sub_folders[$sub_length-1];

		system("sudo chmod 777 $name.txt");

		open(FH2, "< $name.txt") || die("can not open file $!\n");
		@lines2 = <FH2>;
		close(FH2);

		chomp($lines2[0]);

		print "trunk: $lines2[0]\n";

		chdir($lines2[0]) || die("\ndirectory can not be changed");

		open(FH2, ">revert.txt") || die("can not open file $!\n");

		system("sudo svn revert -R AndroidKK4.4.2");

		close(FH2);

		system("sudo rm -rf revert.txt");

		system("sudo rm -rf lock.txt");

		chdir("/media/Data/sdk/AndroidKK4.4.2");

		system("sudo rm -rf $line1");
	}
	else
	{
		print " ln: $line1\n";

		system("sudo rm -rf $line1");
	}
}

