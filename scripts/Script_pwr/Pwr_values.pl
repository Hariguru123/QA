#!/usr/bin/perl

#Store the present location of the script to a variable
system("pwd>filepath.txt");
open(FH,"<filepath.txt");
$location=<FH>;

#Copy the command line argument to a string variable 
$str=$ARGV[0];

#Verifying the command line arguement
if($str eq "null")
{
  print("Please enter the command line input\n\n");
  exit;
		
}
elsif($str eq "MSDK")
{
    system("cp TargetFile/MSDK.xls $location");
    $targetfile="MSDK.xls";

}
elsif($str eq "IW")
{
    system("cp TargetFile/IW.xls $location");
    $targetfile="IW.xls";
}
elsif($str eq "Advance")
{
    system("cp TargetFile/ADV.xls $location");
    $targetfile="ADV.xls";
}
else
{
    print("Please enter the proper command line input\n\n");
    exit;

}

#Run the CSVtoXls.java file
#Functionality:It converts the .csv file to .xls file
system("javac -cp poi-3.10-FINAL-20140208.jar CSVtoXls.java");
system("java -cp .:poi-3.10-FINAL-20140208.jar CSVtoXls $location");


#Run the Pwr_values.java file
#Functionality:It copies the content from the .xls file to the corresponding target sheet.
system("javac -cp jxl-2.6.jar Pwr_values.java");
system("java -cp .:jxl-2.6.jar Pwr_values $targetfile $location");
close FH;

system("rm -rf filepath.txt");
system("rm -rf *.class");
system("mv *.csv CSV/");
system("mv *.xls XLS/");
system("mv XLS/$targetfile $location");



