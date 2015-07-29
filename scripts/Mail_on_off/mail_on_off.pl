#!/usr/bin/perl
#**************************************************************************************************\
# 
#   File Name  :   Dhanush_buildscript.pl
#    
#   Description:  Based on the input from the user,It writes the data in to the mail.txt file.
#   
#   Note:Sending Mail to the developer while building the targets is based on the text 
#        in the mail.txt file.
#
#   Eg:If data in the text file is "Buildfail ON  Buildpass OFF",build script read the line and it will 
#      sent a mail to the developer when the build is failed and it will not sent a mail to developer when 
#      the build is passed.
#
# *************************************************************************************************/
$username=$ENV{'USER'};
$local_path="/home/$username";
$mail_path="$local_path/mail.txt";

print "
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * *
* Please select the value from the following to switch ON/OFF the mail configuration *	
*                                                                                    *      
*           1.ON(Build pass & Build fail)				             *	
*                                                                                    *    
*           2.ON(Build pass) & OFF(Build fail)                                       *
*                                                                                    *
*           3.ON(Build fail) & OFF(Build pass)                                       *  
*                                                                                    *
*           4.OFF(Build pass & Build fail)                                           *
*                                                                                    *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * *
";

print "enter the number \n";

START:
chomp($input=<STDIN>);

if($input eq 1)
{
$mail="Buildpass ON\nBuildfail ON";
open(FH,"> $mail_path")||die $!;
print FH $mail;
close FH;
print "Mail configuration is switched ON for both buildpass and build fail\n";
}

elsif($input eq 2)
{
$mail="Buildpass ON\nBuildfail OFF";
open(FH,"> $mail_path")||die $!;
print FH $mail;
close FH;
print "Mail configuration is switched ON for buildpass only \n";
}
elsif($input eq 3)
{
$mail="Buildfail ON\nBuildpass OFF";
open(FH,"> $mail_path")||die $!;
print FH $mail;
close FH;
print "Mail configuration is switched ON for buildfail only \n";
		
}
elsif($input eq 4)
{
$mail="Buildpass OFF\nBuildfail OFF";
open(FH,"> $mail_path")||die $!;
print FH $mail;
close FH;
print "Mail configuration is switched OFF for both buildpass and build fail\n";
}
else
{
	print "Please enter the valid number:";
	goto START;
}

