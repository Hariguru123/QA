#!/usr/bin/perl

#*****************************************************************************************************************************************\
# 
#   File Name  :   login.pl
#    
#   Description:  It provides the Check-in Login UI to the developers and validating the SVN login details and it ask the user to enter in 
#   to the build request form or sanity request form
#   	
# ****************************************************************************************************************************************/
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

print "Content-type:text/html\n\n";
print start_html(-title=>"Build-Request-login", 
	-bgcolor=>"#cccccc", -text=>"#999999",
	-background=>"/ineda_.png",
	-background-position=>"right center",
	-background-origin=>"content-box",
	-padding-right=>"5px");
print <<EndOfHTML;
<html><head><title>Check-in Request Login Form</title></head>
<head>
<SCRIPT>
function validate()
{
	
	var username=document.new.Username.value 
	var password=document.new.password.value 
	var buildform=document.new.formname[0].selected
	var sanityform=document.new.formname[1].selected
	var checkinform=document.new.formname[2].selected

	if(!username)
  	{
		alert('Please enter the username')
		return false;
  	} 
	if(!password)
  	{
		alert('Please enter the password')
		return false;
  	} 
	if(buildform)
	{
		document.new.action ="build_multireq.pl";
		return true;
	}
	else
	if(sanityform)
	{
		document.new.action ="sanity_req.pl";
	  	return true;
	}
	else
	if(checkinform)
	{
		document.new.action ="check-in_req.pl";
	  	return true;	
	}
}
</SCRIPT>
<SCRIPT type="text/javascript">
	window.history.forward();
	function noBack() { window.history.forward(); }
</SCRIPT>

</head>

<body onload="noBack();" 
onpageshow="if (event.persisted) noBack();" onunload="" bgcolor="#F5D0A9">

<form action="sanity_req.pl" name="new" method="post" enctype="multipart/form-data" onsubmit="return validate();"><p>
<h2><b>Check-in Request Login Form</b></h2>

<p3><br><b><em>Username:</b></em></p3>
<input type="text" name="Username" size=10 maxlength="20" font color="black" face="arial">

<p3><br><br><b><em>Password:</b></em><p3>
<input type="password" name="password" size=10 maxlength="20" >

<br><br><b><em>Select Request:[Build or Sanity or Other]</b></em>

<select name="formname" id="Request">
<option value="1" selected="selected"> Build Request </option>buildform
<option value="2"> Sanity Request </option>sanityform
<option value="3"> Others </option>checkinform
</select>

<br><br><input type="submit" style="font-face: 'Comic Sans MS'; font-size: larger; color: black; background-color: #CC4444"; value="Send request" ><p>
</form>

</body></html>
EndOfHTML

#<input type="radio" name="formname" value="1" checked>build request form
#<input type="radio" name="formname" value="2">sanityform



