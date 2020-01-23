# PowerShell Anchor-Api Module
PowerShell module for managing Axcient Anchor via the v2 API

Functions are PS-friendly, returning objects and accepting pipeline input.

# Usage

Place all files except README.md and Anchor-BackupCheck.ps1 into a folder named Anchor-Api, in your $env:PSModulePath (usually %userprofile%\My Documents\WindowsPowerShell\Modules, or C:\Program Files\WindowsPowerShell\Modules, or C:\windows\system32\WindowsPowerShell\v1.0\Modules\).

Run `Import-Module Anchor-Api` to import the functions into your current session.
To see the list of available commands, use `Get-Command -Module Anchor-Api`.
`Get-Help <command-name>` returns helpful info in some cases.
Look at Anchor-BackupCheck.ps1 for examples.

# To-do 

## Finish populating management functions

⬜ Rename a file

⬜ Move a file

⬜ Lock a file

⬜ Unlock a file

⬜ Delete a file

⬜ Upload a file to a folder

⬜ Create a subfolder

⬜ Download a folder

⬜ Share a folder

⬜ Rename a folder

⬜ Move a folder

⬜ Lock a folder

⬜ Unlock a folder

⬜ Delete a folder

⬜ Upload a file to a root

⬜ Create a folder in a root

⬜ Lock a root

⬜ Unlock a root

⬜ Create an organization

⬜ Update an organization

⬜ Disable an organization

⬜ Enable an organization

⬜ Delete an organization

⬜ Update an organization's policy

⬜ Create a share

⬜ Update a share

⬜ Update share subscribers

⬜ Delete a share

⬜ Create a person

⬜ Update a person

⬜ Delete a person

⬜ Create an account sync root

⬜ Create a guest

⬜ Update a guest

⬜ Delete a guest

⬜ Convert a guest to a standard account

⬜ Create a group

⬜ Update a group

⬜ Update group members

⬜ Delete a group

⬜ Enable file server on a machine

⬜ Disable file server on a machine

⬜ Map a path on a file server enabled machine to a root

⬜ Delete a machine mapping

⬜ Restore a backup

⬜ Delete a backup

⬜ Create an activity record

## Finish populating reporting functions

✔ List an organization's guests

✔ List an organization's groups

✔ List an organization's authentication sources

✔ List recent activity for an organization

✔ Get usage for an organization

✔ List recent activity for a person

✔ Get a guest

⬜ Get files and folders shared with a guest

⬜ Get a group

⬜ Get a grip

⬜ List group members

⬜ Get a machine

⬜ Get a machine's status

⬜ List files on a file server enabled machine

⬜ List mapped paths on a file server enabled machine

⬜ Get a machine mapping

✔ Get a list of activity types

⬜ Get an activity record


## ⬜ More examples. 

## ✔ Convert to a module

## ⬜ Improve authentication logic to only prompt for TOTP when it's actually needed. 

# Comments
- I know I'm onto something when I can write a statement like this, and it works: `get-anchororg -top | Get-AnchorOrgChildren | where name -match "little" | get-anchororgshares | where name -match "Sync" | Get-AnchorOrgShareSubscribers -IncludeFromGroup -Raw`
