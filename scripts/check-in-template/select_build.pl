#!/usr/bin/perl

$buildname=$ARGV[0];

$username=$ENV{'USER'};

$build_path="/home/$username/post-commit";

if(!(-d $build_path))
{
	system("mkdir -m 0777 $build_path");
}

for($i=1;$i>=1;$i++)
{
	if(!(-d "$build_path/dev$i"))
	{
		system("mkdir -m 0777 $build_path/dev$i");
		last;
	}
	else
	{
		next;
	}
}

$arg="post-commit/dev$i";
	if($buildname eq "Android")
	{
		print "\n$buildname Building...";
		system("perl ~/Desktop/post-commit/Postcommit_buildscript.pl 3 $arg");
	}
	elsif($buildname eq "AONsensor")
	{
		print "\n$buildname Building...";
		system("perl ~/Desktop/post-commit/Postcommit_buildscript.pl 1 $arg");
	}
	elsif($buildname eq "Native")
	{
		print "\n$buildname Building...";
		system("perl ~/Desktop/post-commit/Postcommit_buildscript.pl 2 $arg");
	}
	else
	{
		open(FH,"> postlog.txt");
		print FH "\n No Source Code is changed in the Source Code folders\n";
		close FH;
	}

system("rm -rf $build_path/dev$i");


