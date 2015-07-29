#!/usr/bin/perl

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

#**********************************************Declaration of Build Script Paths
$AON_build_path="perl /home/socplatform-qa/Scripts/Build_Scripts/sample.pl";
$native_build_path="perl /home/socplatform-qa/Scripts/Build_Scripts/Dhanush_buildscript.pl 2";
$Android_build_path="perl /home/socplatform-qa/Scripts/Build_Scripts/Dhanush_buildscript.pl 3";

#*********************************************Entering required data from the user for job scheduling
print "Do you want to run the build for 
1.every hour 
2.every day 
3.every week 
4.every month\n";
print "Please enter the number(1-4):";
START:
chomp($input =<STDIN>);
if($input eq 1)
{
	$min=check_min();
	$schedule_time = "$min * * * *";
}
elsif($input eq 2)
{_
		
	$hour=check_hour();
	$min=check_min();

	$schedule_time = "$min $hour * * *";
}
elsif($input eq 3)
{
	$day_week=check_day_week();	
	$hour=check_hour();
	$min=check_min();
	
	$schedule_time = "$min $hour * * $day_week";
}
elsif($input eq 4)
{
	$date=check_date();	
	$hour=check_hour();
	$min=check_min();

	$schedule_time = "$min $hour $date * *";
}
else
{
	print "please enter the proper number:";
	goto START;
}


print "Please select a build target from the following:
1.DhanushAON\n 
2.DhanushNative\n
3.DhanushAndroid\n
4.All\n
Please enter the number:";

START:
chomp($input=<STDIN>);

if($input eq 1)
{
	$build_path=$AON_build_path;
	$remove_line="Dhanush_buildscript.pl 1";
}
elsif($input eq 2)
{
	$build_path=$native_build_path;
	$remove_line="Dhanush_buildscript.pl 2";
}
elsif($input eq 3)
{
	$build_path=$Android_build_path;
	$remove_line="Dhanush_buildscript.pl 3";
}

else
{
	print "Please enter valid Number(1-3)\n";
	goto START;
}


$filename="/var/spool/cron/crontabs/socplatform-qa";

system("sed -i '/$remove_line/d' $filename");

system("sed -i '1 i $schedule_time $build_path' $filename");

if($input eq 4)
{
	system("sed -i '1 i $schedule_time $build_path1' $filename");
	system("sed -i '1 i $schedule_time $build_path2' $filename");

}

#*********************************************Functions*******************************************
#Scheduling job for date
sub check_date
{
	print "At what date you want to start the job:";
	START:
	chomp($date =<STDIN>);
	if($date !~ /^([1-2][1-9]|[3][0-1]|[1-9])$/)
	{
		print "Enter correct date value";
		goto START;
	}
		
	return $date;

}

#Schedule job on day_week
sub check_day_week
{
	print "At what day_week you want to start the job:";
	START:
	chomp($day_week =<STDIN>);
	if($day_week !~ /^[0-7]$/)
	{
		print "Enter correct day in a week";
		goto START;
	}
	return $day_week;
}

#Schedule job for hour
sub check_hour
{
	print "At what hour you want to start a job:";
	START:	
	chomp($hour =<STDIN>);
	if($hour !~ /^(2[0-3]|1[0-9]|[0-9])$/)
	{
		print "Enter correct hour value";
		goto START;
	}

	return $hour;
}

#Schedule job for min
sub check_min
{

	print "At what minute you want to run the job:";
	START:	
	chomp($min =<STDIN>);
	if($min !~ /^([1-5][0-9]|[0-9])$/)
	{
		print "Enter correct minute value:";
		goto START;
	}
	return $min;
}





