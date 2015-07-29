Single handling Request:
*************************

Usage:
******
1.Run the perl file "Create_Patch.pl" in the local machine.(patch file and log file will be created after Execution of the script)

2.Open the browser and enter the URL http://192.168.26.135/cgi-bin/buildreq.pl.

3.Enter the BugID,CRNo and Upload patch file,logfile(Which are generated in the first step).

4.Submit the request and you will get a msg in the browser "Build request has been submitted successfully\nBuild process is in-progress and you will receive an email after build completion".



Description: This is a combination of CGI script,Patch merge Script and Build script.
************
1)User should enter the BUGID,CRNUmber,Patch File,Logfile and make sure there are no conflicts in the local copy(This is done by the another script that needs to be run before submit the details in the local machine).

2)After that it merges the patch file with the latest svn copy and build the code.Developer will receive mail after the build proccess completed  with all details(For both build fail or pass).

Note:
1)Single request is handling at a time and next req will start after completion of the first build request.

CGI script:
***********
1.CGI script will provide the UI to the developers.
2.After user inputs,it will validate all the inputs and calls the merge script with repository,source code folder,patch file and log file as arguements.
3.Two scripts in CGI,one is for providing the UI,validating inputs and another one is for creating repository,source code folder based on the patch file and copy the inputs to the source code folder. 

Merge script
*************  
1.It will take the inputs from the CGI script and start the merge process with the latest svn copy.
2.Developer will receive a mail if merge process is failed or patch file is empty.
3.Call the build script with repository,source code folder,patch file and log file as arguements,After completion of build script it will delete the Source code folder.

Build script:
*************
1.Based on the arguments provided it will build the corresponding code.
2.Developer will receive a mail if build either passed or failed,with all corresponding logs/ouputs in the build server location.(Location should also mentioned in the mail body) 





  
