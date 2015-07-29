#!/usr/bin/perl
#*****************************************************************************************************************************************\
# 
#   File Name  :   buildreq.pl
#    
#   Description:  It provides the UI to the developers and validating the inputs
#   	
# ****************************************************************************************************************************************/
print "Content-type:text/html\n\n";
print <<EndOfHTML;
<html><head><title>Build Request Form</title></head>
<head>
<script>
function validate()
{

  var BugID=document.new.BugID.value 
  var CRNO=document.new.Code_ReviewID.value 
  var checkbox=document.new.conflicts.checked
  var patchfilename=document.new.patchfile.value
  var logfilename=document.new.logfile.value
  var regex=/^(Dhanush(AON|-Android)|Native).patch\$/;
  var regex1=/^add_information.log\$/;

     
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
  if(!CRNO)
  {
	alert('Please enter the Code Review ID')
	return false
  }
  else if(isNaN(CRNO))
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
	alert('Please upload the log file')
	return false
  }
 if(!logfilename.match(regex1))
  {
	alert('Please enter the proper log file')
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
	onpageshow="if (event.persisted) noBack();" onunload="" bgcolor="#CCFFCC">
<form action="buildprocess.pl" name="new" method="post" enctype="multipart/form-data" onsubmit="return validate();"><p>
<h2><b>Build Request form</b></h2>

<p3><br><b><em>Enter BugID:</b></em></p3>
<input type="text" name="BugID" size=10 maxlength="20" >

<p3><br><br><b><em>Enter CR No:</b></em><p3>
<input type="text" name="Code_ReviewID" size=10 maxlength="20" >

&nbsp;&nbsp;&nbsp;&nbsp<input type="checkbox" name="conflicts" value="checked"><b><em>No conflicts </em></b>

<p3><br><br><b><em>Patch File:</b></em></p3>
<input id="fileupload" name="patchfile" type="file" value="upload"/>

<p3><br><br><b><em>Log File:</b></em></p3>
<input id="fileupload" name="logfile" type="file" value="upload"/>

<br><br><input type="submit" style="font-face: 'Comic Sans MS'; font-size: larger; color: black; background-color: #CC3333"; value="Send request" ><p>
</form>

</body></html>
EndOfHTML




