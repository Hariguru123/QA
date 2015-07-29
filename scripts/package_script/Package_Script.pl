#!/usr/bin/perl
#*******************************************************************************************************************************
# 
#   File Name  :   Package_Script.pl
#    
#   Description:  It Packages the Dhanush build binaries based on the input arguments into Daily or Weekly or Release images.
#
#*******************************************************************************************************************************

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

$buildtype = $ARGV[0];
$platform = $ARGV[1];
$code_path=$ARGV[2];

open(FH, ">$code_path/SVN_revisions.txt") || die("can not open $code_path/SVN_revisions.txt\n");

#Get Revision info
if(($platform eq "MSDK3") || ($platform eq "MSDK2") || ($platform eq "MSDK1"))
{
	system("svn info $code_path/AON --username socqa --password Yo'\$8'lc9u > local_info.log 2> local_info_err.log");
	$repo1 = read_last_revision("local_info.log");
	print FH "AON: $repo1\n";

	system("svn info $code_path/Native --username socqa --password Yo'\$8'lc9u > local_info.log 2> local_info_err.log");
	$repo2 = read_last_revision("local_info.log");
	print FH "Native: $repo2\n";

	if($repo2 > $repo1)
	{
		$repo = $repo2;
	}
	else
	{
		$repo = $repo1;
	}

	system("svn info $code_path/Bootloader --username socqa --password Yo'\$8'lc9u > local_info.log 2> local_info_err.log");
	$repo3 = read_last_revision("local_info.log");
	print FH "BootLoader: $repo3\n";

	if($repo3 > $repo)
	{
		$repo = $repo3;
	}

	system("svn info $code_path/UIResourceGenerator --username socqa --password Yo'\$8'lc9u > local_info.log 2> local_info_err.log");
	$repo4 = read_last_revision("local_info.log");
	print FH "UIResourceGenerator: $repo4\n";

	if($repo4 > $repo)
	{
		$repo = $repo4;
	}
}
elsif($platform eq "i600_REVB")
{

	system("svn info $code_path/AONsensor --username socqa --password Yo'\$8'lc9u > local_info.log 2> local_info_err.log");
	$repo1 = read_last_revision("local_info.log");
	print FH "AONsensor: $repo1\n";

	system("svn info $code_path/Native --username socqa --password Yo'\$8'lc9u > local_info.log 2> local_info_err.log");
	$repo2 = read_last_revision("local_info.log");
	print FH "Native: $repo2\n";

	system("svn info $code_path/BootLoader --username socqa --password Yo'\$8'lc9u > local_info.log 2> local_info_err.log");
	$repo3 = read_last_revision("local_info.log");
	print FH "BootLoader: $repo3\n";

	system("svn info $code_path --username socqa --password Yo'\$8'lc9u > local_info.log 2> local_info_err.log");
	$repo = read_last_revision("local_info.log");
}
else
{
	system("svn info $code_path --username socqa --password Yo'\$8'lc9u > local_info.log 2> local_info_err.log");
	$repo = read_last_revision("local_info.log");
}

close(FH);
#Get current date and time
currentdate();
$currentDate = "$year\-$mon\-$mday";
if($year =~/20(\d\d)/)
{
	$yr = $1;
}

#Creating tag for Daily, Weekly and Release builds
if($buildtype eq "Daily")
{
	$version = "D$yr\.$mon\.$repo";
}
elsif($buildtype eq "Weekly")
{
	$version = "W$yr\.$mon\.$repo";
}
elsif($buildtype eq "Release")
{
	$version = "R$yr\.$mon\.$repo";
}

#Build share
$dst_images_dir = "/home/socplatform-qa/share/$platform\_Builds/$currentDate/$version";
$dst_images_dir1 = "//192.168.42.46/share/$platform\_Builds/$currentDate/$version";

#creating share location for builds
system("mkdir -p $dst_images_dir");

dircopy("$code_path/Output", "$dst_images_dir") || die("can not copy directory $code_path/Output to $dst_images_dir1");

fcopy("$code_path/SVN_revisions.txt", "$dst_images_dir/SVN_revisions.txt") || die("can not copy directory $code_path/SVN_revisions.txt to $dst_images_dir1");


print "Binaries are copied to $dst_images_dir1\n";


#****************************************************** Sub-Routines **********************************************************

sub currentdate
{
    ($sec, $min, $hr, $mday, $mon, $year, $wday, $yday, $daylight) = localtime();
    $year += 1900;
    $mon++;

    # Appending 0's if less than 10
    if( $sec < 10 )
    {
        $sec = "0$sec";
    }
    if( $min < 10 )
    {
        $min = "0$min";
    }
    if( $hr < 10 )
    {
        $hr = "0$hr";
    }
    if( $mday < 10 )
    {
        $mday = "0$mday";
    }
    if( $mon < 10 )
    {
        $mon = "0$mon";
    }
}

sub read_last_revision
{
    my $file = $_[0];
    open($Read, "< $file") || die("Can't open file: $file in read_last_revision\n");
    my @lines = <$Read>;
    close($RD);

    my $failed = 0;

    foreach my $line (@lines)
    {
        chomp($line);
	if($line =~/Last Changed Rev: (\d+)/)
	{
		$revision = $1;
		last;
	}
    }
    return $revision;
}

