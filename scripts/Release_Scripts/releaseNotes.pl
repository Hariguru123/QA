#!/usr/bin/perl

#*****************************************************************************
# 
# File name: releaseNotes.pl
# 
# Location: Can be run anywhere in the system
# 
# Description: This script will take the inputs from check-in log and 
#              create a Release Notes of a specific release
# 
# Inputs required: 
#		1. Path of the local Working copy path of the release branch
#		2. Release build number/name
#		3. Revision number range (Starting revision and End revision)
#
# Prerequisites: The release branch should be checked out to the local machine
#
#******************************************************************************


# Working copy (trunk) path input
print "Enter the release branch path:\n";

WPATH:
$work_path = <STDIN>;

chop ($work_path);

if(!$work_path){

	print "Didn't enter the release branch path, please enter:\n";	
	goto WPATH;

}

# Build Release Number input
print "Enter the release build number:\n";

RNUM:
$rel_num = <STDIN>;

chop ($rel_num);

if(!$rel_num){

	print "Didn't enter the release build number, please enter:\n";
 	goto RNUM;
}

# Starting revison number
print "Enter the starting revision of the branch for this release:\n";

SREV:
$start_rev = <STDIN>;

chop ($start_rev);

if(!$start_rev){

	print "Didn't enter starting revision number, please enter:\n";	
	goto SREV;

}

# Ending revison number
print "Enter the ending revision of the branch for this release:\n";

EREV:
$end_rev = <STDIN>;

chop ($end_rev);

if(!$end_rev){

	print "Didn't enter ending revision number, please enter:\n";	
	goto EREV;

}

# Current path where this script resides
system ("pwd >curr.txt");

open (FH, "<curr.txt");

foreach $path (<FH>){

	$cPath = $path;
	last;

}

chomp ($cPath);

system ("mkdir releaseNotes_$rel_num");


$rel_Path = "$cPath/releaseNotes_$rel_num";

$log_Path = "$rel_Path/log.txt";

$relNotes_Path = "$rel_Path/ReleaseNotes.txt";

$bugs_Path = "$rel_Path/bugs.txt";

# Changing to working branch path
chdir("$work_path")|| die"Can't change to the directory $work_path";

# Upgrade the working copy to latest SVN revision
system("svn upgrade >upgrade_log.txt");

# Getting the SVN check-in log in between the start and end revison nnumbers
system ("svn log -r $start_rev:$end_rev >$log_Path");


open (RN, "+>>$relNotes_Path")|| die("Can't $!");

open (LG, "<$log_Path")|| die("Can't $!");

open (BUG, "+>>$bugs_Path")|| die("Can't $!");

@log = <LG>;

$i = 1;
$j = 1;

print RN "****************************** Release Notes of Dhanush SDK ******************************\n";

for( $a = 1; $a < 3; $a = $a + 1 ){

	print RN "\n";

}

print RN "Release build number: $rel_num\n\n\n";


print RN "New Features/Enhancements in this release: \n";

for( $a = 1; $a < 45; $a = $a + 1 ){

	print RN "-";

}

print RN "\n";

print BUG "Bugs fixed in this release: \n";
for( $a = 1; $a < 27; $a = $a + 1 ){

	print BUG "-";

}

print BUG "\n";

foreach $line (@log)
{

 if($line =~ /Issue Id:(.+)/){
  $issue = $1;
 }
 if($line =~ /Issue Type:Feature/){
  print RN "$i. $issue\n";
  $i++;
 }
 elsif($line =~ /Issue Type:Bug/){
  print BUG "$j. $issue\n";
  $j++;
 }

}

print RN "\n\n";

close (BUG);

open (BUG, "<$bugs_Path");

@bug = <BUG>;

foreach $bug (@bug)
{
print RN "$bug";
}

print RN "\n\n";

print RN "Known limitations in this release:\n";

for( $a = 1; $a < 34; $a = $a + 1 ){

	print RN "-";

}

close(RN);

close (BUG);

close (LG);



