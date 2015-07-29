#!/usr/bin/perl

#*****************************************************************************************************************************************\
# 
#   File Name  :   sanity_req.pl
#    
#   Description:  It provides the Login UI to the developers and validating the login
#   	
# ****************************************************************************************************************************************/
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use strict;
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
<html><head><title>sanity Form</title></head>
<head>
<script>
function validate()
{
	var Checkin_ID=document.new.Checkin_ID.value 
	var result_pass=document.new.result[0].checked
	var result_fail=document.new.result[1].checked
	var Checkin_cmnt=document.new.Checkin_cmnt.value 
	var resultlog=document.new.ResultLog.value
	var regex=/.+.(log|txt|xls|ods)\$/;
	 
	if(!Checkin_ID)
	{
		alert('Please enter the Checkin_ID')
		return false
	}
	if(!Checkin_cmnt)
	{
		alert('Please enter the Checkin_cmnt')
		return false
	} 

	if(!resultlog)
	{
		alert('Please upload the result log file')
		return false
	}
	if(!resultlog.match(regex))
	{
		alert('Please upload the proper result log file in txt or xls or log or ods format')
		return false
	}

	var resultlogsize=document.new.ResultLog.files[0].size

	if(!resultlogsize)
	{
		alert('Log file is empty,Please upload the proper log file')
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
<form action="sanity_process.pl" name="new" method="post" enctype="multipart/form-data" onsubmit="return validate();"><p>
<h2><b>Sanity Request form</b></h2>

<p3><br><b><em>Checkin ID:</b></em></p3>
<input type="text" name="Checkin_ID" size=20 maxlength="50" >

<p3><br><br><b><em>sanity Result:</b></em><p3>
<input type="radio" name="result" value="Yes" checked>PASS
<input type="radio" name="result" value="No" >FAIL

<p3><br><br><b><em>Result LogFile:</b></em></p3>
<input id="fileupload" name="ResultLog" type="file" value="upload"/>

<p3><br><br><b><em>Checkin Comment:</b></em></p3>
<input type="text" name="Checkin_cmnt" size=100 maxlength="800" >

<input type="hidden" name="username" value="$username" >
<input type="hidden" name="password" value="$password" >


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


