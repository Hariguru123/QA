#!/usr/bin/perl

#*************************************************************************************************************\
# 
#   File Name  :   svn_checkin.pl
#    
#   Description:  This file is taking the inputs(Issue Id and headline,Issue Type,Reviewername,Comments) 
#		  from the user and check in that local copy to SVN.You should copy this
#                 perl file to localworking copy(which is going to be check-in to SVN) 
# 
#   Example O/P:  Sending        checkin.txt
#                 Transmitting file data .
#		  Committed revision 85.
#
#   Pre-Req: All the files in the localcopy should be added to SVN. 	
# **************************************************************************************************************/

#Accepting SVN username
print "Please enter the SVN username: ";
$username = <STDIN>;
chomp($username);

#Accepting SVN password
print "Please enter the SVN password: ";
$password = <STDIN>;
chomp($password);

$password =~ s/\$/\"\\\$\"/g;

#**************Input from the user for SVN working copy path
print "Enter the PATH of the working copy folder, which you want to commit:";
$inp_path = <STDIN>;
chomp($inp_path);


#****************Input from the user for Issue ID and Hedline
print "Enter the Issue Id and Headline<IssueId - Headline>:";
START:
$bugID=<STDIN>;

#Validating the BUG ID with Headline
if($bugID !~ /^\s*\d{4,10}\s*-\s*.+\n$/)
{
	print "Issue Id should be 4 to 10 digit number and headline should be needed.\nex:1234-[Bug description]\nplease enter the valid Issue Id and Hedline:";
	goto START;
}

#****************Input from the user for Issue Type
print "Enter the Issue type <Bug|Feature|Enhancement|Other>:";
START_IType:
$bugType=<STDIN>;

#Validating the BUG Type
if($bugType !~ /^\s*(Bug|Feature|Enhancement|Other)\s*$/i)
{
	print "Issue type should be either bug, Feature, Enhancement or Other\nplease enter the valid Bug type:";
	goto START_IType;
}


#***************Input from the user for Reviewer name
print "Enter the Reviewer Name:";
START1:
chomp($reviewer_name=<STDIN>);

#Validating the Reviewer Name
if(!$reviewer_name)
{
	print "Enter the Reviewer Name:";
	goto START1;
}
if($reviewer_name !~ /^\s*\w+/)
{
	print "Name should be start with word charcter\n";
	print "Enter the Reviewer Name:";
	goto START1;
}


#**************Input from the user for comments
print "Enter comments(type END to Exit):";
while(<STDIN>)
{
	last if /^END$/;
	$reviewer_comments .=$_;
}

#assign the string(pre-commit script defined string) to a variable
chomp($bugID);
chomp($bugType);
if(!$reviewer_comments)
{
	$commit_string= "Issue Id:$bugID\nIssue Type:$bugType\nReviewer:$reviewer_name";
}
else
{
  $commit_string= "Issue Id:$bugID\nIssue Type:$bugType\nReviewer:$reviewer_name\nComments:$reviewer_comments";
}

#**************commit the local copy to SVN
system("svn ci $inp_path -m \"$commit_string\" --username $username --password $password");









