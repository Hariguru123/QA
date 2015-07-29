1. pre-commit
*************

Description: This script is used to validate the commit message in the SVN.(Hook script)

Usage: Script should place at the SVN hooks folder and it will validate message while commiting  in to SVN

Ex:
message should be Issue Id: 1234
Reviewer Name: "user name"
Comments: reviewer_comments (optional)


2. post-commit
**************

Description: This script is used to send mail to the developer after commit.(Hook script)

Usage: Script should place at the SVN hooks folder and it will send a mail to the developer after commiting in to SVN

3. post-commit in actual server

