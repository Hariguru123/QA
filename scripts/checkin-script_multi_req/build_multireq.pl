#!/usr/bin/perl
#*****************************************************************************************************************************************\
# 
#   File Name  :   build_multireq.pl
#    
#   Description:  It provides the UI to the developers and validating the inputs
#   	
# ****************************************************************************************************************************************/
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use File::Basename;

#Declare the uploaded file size
$CGI::POST_MAX = 1024 * 5000000;
my $query = new CGI;

#Retrieve the userID and password (User input while submitting the requset) 
my $username = $query->param("Username");
my $password = $query->param("password");

$password =~ s/\$/\"\\\$\"/g;

my $result=system("svn info http://insvn01:9090/svn/swdepot/Dhanush/SW/Adv-trunk --username $username --password $password > log.txt 2> fail.txt");

#my $result=system("svn info http://soctsvn01:9090/svn/SocPlatform-QA --username $username --password $password > log.txt 2> fail.txt");

system("echo $password > $username.txt");

if((!$username)&&(!$password))
{
	print header;
	print start_html("Get Form");
	print "Please enter the username and password in the login page";
	print end_html;
	exit;

}
#Need to change(ADD to SVN)
if($result)
{
	print header;
	print start_html("Get Form");
	print "Please enter the correct username and password";
	print end_html;
	exit;
}
else
{
print "Content-type:text/html\n\n";
print <<EndOfHTML;
<html><head><title>Build Request Form</title></head>
<head>
<script>
function validate()
{
 	 var BugID=document.new.BugID.value 
 	 var CodeReviewID=document.new.Code_ReviewID.value 
 	 var checkbox=document.new.conflicts.checked
 	 var patchfilename=document.new.patchfile.value
 	 var logfilename=document.new.logfile.value
 	 var repo_logfilename=document.new.repologfile.value
  	 var regex=/^(.+).patch\$/;

	if(!BugID)
	{
		alert('Please enter the BugID')
		return false
	} 
	else if(isNaN(BugID))
	{
		alert('Please enter the valid BugID')
		return false
	}
	if(!CodeReviewID)
	{
		alert('Please enter the Code Review ID')
		return false
	}
  	else if(isNaN(CodeReviewID))
  	{
		alert('Please enter the valid Code Review ID')
		return false
	}
	if(!checkbox)
  	{
		alert('Please click the check box')
		return false
	}
	if(!patchfilename)
	{
		alert('Please upload the patch file')
		return false
	}
	if(!patchfilename.match(regex))
	{
		alert('Please enter the proper patch file')
	        return false
	}
 	if(!logfilename)
 	{
		alert('Please upload the add_information.log file')
		return false
  	}
	if(!repo_logfilename)
	{
		alert('Please upload the repository log file')
		return false
	}

	var patchfilesize=document.new.patchfile.files[0].size
	if(!patchfilesize)
  	{
		alert('patch file is empty,Please upload the proper patch file')
		return false
	}

 
var r=confirm("please confirm all the details you entered is correct")
if (r==true)
{
 return true
}
else
{
  return false
}   
}
</script>
<SCRIPT type="text/javascript">
	window.history.forward();
	function noBack() { window.history.forward(); }
</SCRIPT>

</head>
<body onload="noBack();" 
	onpageshow="if (event.persisted) noBack();" onunload="" bgcolor="#F5D0A9">
<form action="build_multiprocess_FIFO.pl" name="new" method="post" enctype="multipart/form-data" onsubmit="return validate();"><p>
<h2><b>Build Request form</b></h2>
<input type="hidden" name="username" value="$username" >
<input type="hidden" name="password" value="$password" >	

<p3><br><b><em>Enter BugID:</b></em></p3>
<input type="text" name="BugID" size=10 maxlength="20" >

<p3><br><br><b><em>Enter CodeReviewID:</b></em><p3>
<input type="text" name="Code_ReviewID" size=10 maxlength="20" >

&nbsp;&nbsp;&nbsp;&nbsp<input type="checkbox" name="conflicts" value="checked"><b><em>No conflicts </em></b>

<p3><br><br><b><em>Patch File:</b></em></p3>
<input id="fileupload" name="patchfile" type="file" value="upload"/>

<p3><br><br><b><em>Add information Log File:</b></em></p3>
<input id="fileupload" name="logfile" type="file" value="upload"/>

<p3><br><br><b><em>Repository URL Log File:</b></em></p3>
<input id="fileupload" name="repologfile" type="file" value="upload"/>

<p3><br><br><b><em>Select Android Build:</b></em><p3>
<input type="radio" name="androidbuild" value="no" checked>Incremental
<input type="radio" name="androidbuild" value="clean" >Clean

<p3><br><br><b><em>Cc list(optional):</b></em></p3>
<pre><select name='mailids' multiple="multiple" size='5'>	
<option value="<vinaykumar.medari\@incubesol.com>">vinaykumar.medari\@incubesol.com</option>
<option value="<adonimohammed.arif\@inedasystems.com>">adonimohammed.arif\@inedasystems.com</option>
<option value="<ashwineechandrashekar.dhakate\@inedasystems.com>">ashwineechandrashekar.dhakate\@inedasystems.com</option>
<option value="<balakishore.pati\@inedasystems.com>">balakishore.pati\@inedasystems.com</option>
<option value="<chaitanyakumar.nella\@inedasystems.com>">chaitanyakumar.nella\@inedasystems.com</option>
<option value="<govindu.kanike\@inedasystems.com>">govindu.kanike\@inedasystems.com</option>
<option value="<hemanth.padmanabhan\@inedasystems.com>">hemanth.padmanabhan\@inedasystems.com</option>
<option value="<himamsu.mylavarapu\@inedasystems.com>">himamsu.mylavarapu\@inedasystems.com</option>
<option value="<janardhan.kolli\@inedasystems.com>">janardhan.kolli\@inedasystems.com</option>
<option value="<kishore.kundanagurthy\@inedasystems.com>">kishore.kundanagurthy\@inedasystems.com</option>
<option value="<mousumi.jana\@inedasystems.com>">mousumi.jana\@inedasystems.com</option>
<option value="<kotesh.pedumajji\@inedasystems.com>">kotesh.pedumajji\@inedasystems.com</option>
<option value="<kvphanipavan.kumar\@inedasystems.com>">kvphanipavan.kumar\@inedasystems.com</option>
<option value="<lakshmilavanya.gamini\@inedasystems.com>">lakshmilavanya.gamini\@inedasystems.com</option>
<option value="<maruthi.machani\@inedasystems.com>">maruthi.machani\@inedasystems.com</option>
<option value="<narsireddy.annapureddy\@inedasystems.com>">narsireddy.annapureddy\@inedasystems.com</option>
<option value="<nithin.puravankara\@inedasystems.com>">nithin.puravankara\@inedasystems.com</option>
<option value="<nitin.ghate\@inedasystems.com>">nitin.ghate\@inedasystems.com</option>
<option value="<nssr.murthy\@inedasystems.com>">nssr.murthy\@inedasystems.com</option>
<option value="<padmavathi.volety\@inedasystems.com>">padmavathi.volety\@inedasystems.com</option>
<option value="<phanikrishna.vallabhaneni\@inedasystems.com>">phanikrishna.vallabhaneni\@inedasystems.com</option>
<option value="<raghavendra.kandalai\@inedasystems.com>">raghavendra.kandalai\@inedasystems.com</option>
<option value="<raghavendrasandeep.dhanvada\@inedasystems.com>">raghavendrasandeep.dhanvada\@inedasystems.com</option>
<option value="<raghunandan.ravi\@inedasystems.com>">raghunandan.ravi\@inedasystems.com</option>
<option value="<rajashekar.alusa\@inedasystems.com>">rajashekar.alusa\@inedasystems.com</option>
<option value="<raju.narlapuram\@inedasystems.com>">raju.narlapuram\@inedasystems.com</option>
<option value="<rakesh.shasanapuri\@inedasystems.com>">rakesh.shasanapuri\@inedasystems.com</option>
<option value="<rani.thoomoju\@inedasystems.com>">rani.thoomoju\@inedasystems.com</option>
<option value="<sindhura.aluru\@inedasystems.com>">sindhura.aluru\@inedasystems.com</option>
<option value="<socplatform-mm\@inedasystems.com>">socplatform-mm\@inedasystems.com</option>
<option value="<socplatform-qa\@inedasystems.com>">socplatform-qa\@inedasystems.com</option>
<option value="<socplatform-dd\@inedasystems.com>">socplatform-dd\@inedasystems.com</option>
<option value="<socplatform-ui\@inedasystems.com>">socplatform-ui\@inedasystems.com</option>
<option value="<srikanthbabu.jasty\@inedasystems.com>">srikanthbabu.jasty\@inedasystems.com</option>
<option value="<srinivas.ganji\@inedasystems.com>">srinivas.ganji\@inedasystems.com</option>
<option value="<suman.kopparapu\@inedasystems.com>">suman.kopparapu\@inedasystems.com</option>
<option value="<swathi.kanamarlapudi\@inedasystems.com>">swathi.kanamarlapudi\@inedasystems.com</option>
<option value="<tilaktirumalesh.tangudu\@inedasystems.com>">tilaktirumalesh.tangudu\@inedasystems.com</option>
<option value="<vamshikrishna.gajjela\@inedasystems.com>">vamshikrishna.gajjela\@inedasystems.com</option>
<option value="<vamsikrishna.devara\@inedasystems.com>">vamsikrishna.devara\@inedasystems.com</option>
<option value="<veerendra.jonnalagadda\@inedasystems.com>">veerendra.jonnalagadda\@inedasystems.com</option>
<option value="<velayudham.murugesan\@inedasystems.com>">velayudham.murugesan\@inedasystems.com</option>
<option value="<venkataraghavendra.gade\@inedasystems.com>">venkataraghavendra.gade\@inedasystems.com</option>
<option value="<venkateshwarrao.gannavarapu\@inedasystems.com>">venkateshwarrao.gannavarapu\@inedasystems.com</option>
<option value="<venkatasuryanarayana.dommeti\@inedasystems.com>">venkatasuryanarayana.dommeti\@inedasystems.com</option>
<option value="<vivekkumar.gupta\@inedasystems.com>">vivekkumar.gupta\@inedasystems.com</option>
</select>

<br><br><input type="submit" style="font-face: 'Comic Sans MS'; font-size: larger; color: black; background-color: #CC3333"; value="Send request" ><p>
</form>

</body></html>
EndOfHTML

}	

