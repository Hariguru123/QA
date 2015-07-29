#!/usr/bin/perl

print "\nEnter the Release name(Prealpha or Alpha or Beta...):";
chomp($rel_name=<STDIN>);

if(($rel_name ne "Prealpha") && ($rel_name ne "Alpha") && ($rel_name ne "Beta"))
{
	print "\nPlease enter proper release name(care of case sensitive)\n";
	exit;
}

$destination_path="http://insvn01:9090/svn/swdepot/Dhanush/SW/Branches/$rel_name";
$source_path = "http://insvn01:9090/svn/swdepot/Dhanush/SW/Adv-trunk";

$repository_info = "trunk_repository_info.log";
system("svn info $source_path --username socqa --password Yo'\$8'lc9u > $repository_info");

$repo = read_last_revision($repository_info);

print "rep: $repo \n";

print "\nEnter the Branch name in 00.XX.ddmmyyyy format:";
chomp($branchName=<STDIN>);

if(!($branchName =~/^(\d+)\.(\d+)\.(\d+)$/))
{
	print "\nPlease enter proper branch name\n";
	exit;
}

@array=($destination_path,$branchName);
$branchPath=join("/",@array);

#***********************Copy and commit the tag(or)branch************************ 
print "branchPath: $branchPath\n";

#commit string is based on pre commit hook script
$commit_string="Branching the Adv-trunk (rev: $repo) for $rel_name release with branch name - $branchName \n";

print "$commit_string \n";
$source_path="$source_path/";

print "$source_path \n";

print "$branchPath \n";

system("svn copy $source_path $branchPath --username socqa --password Yo'\$8'lc9u -m \"$commit_string\"");

print "\n\n*********************..Release Branching Done..*******************\n\n\n";


system("perl SDK_package_script.pl $rel_name $branchName");		#calling SDK package script.


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

