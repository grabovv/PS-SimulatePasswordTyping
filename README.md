# How to use?
To run this script, you need to execute the PowerShell script in the console:<br><br>
`powershell -ep bypass -f <file_location>`<br><br>
Specify the delay in seconds before pasting (typing) the clipboard content.<br>
Copy the content (password) to the clipboard.<br>
Highlight with the mouse the field where the password should be entered.<br>
Press F8 - the script will type the clipboard content after the delay you specified.<br>

# Description
The script first prompts for a delay before pasting the clipboard content.<br>
After that, it creates a hotkey (F8) through which we will trigger the paste action.<br>
Upon pressing the hotkey, the script waits for the previously specified delay and then pastes the content (simulating typing) into the selected mouse location.

# Use-case
Useful for authentication in cases of complex and long passwords and in situations where we cannot paste the password using '**CTRL + C**' / '**CTRL + V**'.
