#!/usr/bin/perl

#SVN update toolchain
system("svn up /home/socplatform-qa/toolchain > tc_up.txt 2> tc_up_err.txt");

system("sudo svn up /var/lib/jenkins/toolchain > jtc_up.txt 2> jtc_up_err.txt");

#Deletes aSDK Daily Builds Data
system("find /home/socplatform-qa/share/aSDK_Builds -maxdepth 1 -mtime +30 > list1.txt");

open(FH1, "< list1.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	print "$line1 \n";
	system("sudo rm -rf $line1");
}

#Deletes MSDK1 Daily Builds Data
system("find /home/socplatform-qa/share/MSDK1_Builds -maxdepth 1 -mtime +30 > list1.txt");

open(FH1, "< list1.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	print "$line1 \n";
	system("sudo rm -rf $line1");
}

#Deletes MSDK3 Daily Builds Data
system("find /home/socplatform-qa/share/MSDK3_Builds -maxdepth 1 -mtime +30 > list1.txt");

open(FH1, "< list1.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	print "$line1 \n";
	system("sudo rm -rf $line1");
}

#Deletes i600_REVB_Builds Daily Builds Data
system("find /home/socplatform-qa/share/i600_REVB_Builds -maxdepth 1 -mtime +30 > list1.txt");

open(FH1, "< list1.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	print "$line1 \n";
	system("sudo rm -rf $line1");
}

#Deletes LG Daily Builds Data
system("find /home/socplatform-qa/share/LG_Builds/Daily_Builds -maxdepth 1 -mtime +30 > list1.txt");

open(FH1, "< list1.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	print "$line1 \n";
	system("sudo rm -rf $line1");
}

#Deletes LG Daily images Data
system("find /home/socplatform-qa/share/LG_Builds/Daily_images -maxdepth 1 -mtime +30 > list1.txt");

open(FH1, "< list1.txt");
@lines1 = <FH1>;
close(FH1);

foreach $line1 (@lines1)
{
	print "$line1 \n";
	system("sudo rm -rf $line1");
}

