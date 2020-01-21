# PowerShell Anchor-Api Module
PowerShell ✨module✨ for managing Axcient Anchor via the v2 API

Functions are PS-friendly, returning objects and accepting pipeline input.

# Usage

Place all files except README.md and Anchor-BackupCheck.ps1 into a folder named Anchor-Api, in your $env:PSModulePath (usually %userprofile%\My Documents\WindowsPowerShell\Modules, or C:\Program Files\WindowsPowerShell\Modules, or C:\windows\system32\WindowsPowerShell\v1.0\Modules\).

Run `Import-Module Anchor-Api` to import the functions into your current session.
To see the list of available commands, use `Get-Command -Module Anchor-Api`.
`Get-Help <command-name>` returns helpful info in some cases.
Look at Anchor-BackupCheck.ps1 for examples.

# To-do 

⬜ Finish populating management functions

⬜ Finish populating reporting functions

⬜ More examples. 

✔ Convert to a module

⬜ Improve authentication logic to only prompt for TOTP when it's actually needed. 
