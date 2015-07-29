#!/usr/bin/perl

$num_args = @ARGV;

if($num_args < 4)
{ 
	print "Usage: perl Release_Tagging_Script.pl <Branch Name(Beta, R0.91, R0.92..)> <Branch Creation Date(00.9X.DDMMYYYY)> <Source Path URL> <Destination Path URL>\n";
	die("Number of arguments are less\n");
}

$branch = $ARGV[0];
$branchName = $ARGV[1];
$source_path = $ARGV[2];
$destination_path=$ARGV[3];

@array=($destination_path,$branch);
$branchPath1=join("/",@array);

print "branchPath: $branchPath1 \n";

#commit string is based on pre commit hook script
$commit_string="Issue Id: 0000 - Branching\nIssue Type: Other\nReviewer: ReleaseEngineer\nCreating Branch folder for $branch release.\n";

system("svn mkdir $branchPath1 --username socqa --password Yo'\$8'lc9u -m \"$commit_string\"");

print "Branch Created for $branch Release\n";

@array=($branchPath1,$branchName);
$branchPath=join("/",@array);

print "branchPath: $branchPath \n";

$repository_info = "trunk_repository_info.log";
system("svn info $source_path --username socqa --password Yo'\$8'lc9u > $repository_info");

$repo = read_last_revision($repository_info);

print "rep: $repo \n";

#***********************Copy and commit the tag(or)branch************************ 

#commit string is based on pre commit hook script
$commit_string="Issue Id: 0000 - Branching\nIssue Type: Other\nReviewer: ReleaseEngineer\nBranching the Adv-trunk (rev: $repo) for $branch release with branch name - $branchName \n";

$source_path="$source_path/";

print "$source_path \n";

print "$branchPath \n";

system("svn copy $source_path $branchPath --username socqa --password Yo'\$8'lc9u -m \"$commit_string\"");

print "Done";

#*********************************** Functions **********************************

sub read_last_revision
{
    my $file = $_[0];
    open($Read, "< $file") || die("Can't open file: $file");
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

