# PowerShell Anchor-Api Module
PowerShell module for managing Axcient Anchor via the v2 API

Functions are PS-friendly, returning objects and accepting pipeline input.

# Usage

Download the files in the Anchor-Api folder to a folder named Anchor-Api, in your $env:PSModulePath (usually %userprofile%\My Documents\WindowsPowerShell\Modules, or C:\Program Files\WindowsPowerShell\Modules, or C:\windows\system32\WindowsPowerShell\v1.0\Modules\).

Run `Import-Module Anchor-Api` to import the functions into your current session.
To see the list of available commands, use `Get-Command -Module Anchor-Api`.
`Get-Help <command-name>` returns helpful info in some cases.
Look at Anchor-BackupCheck.ps1 for examples.

# Functions

## Authentication functions 🔑

✅ Get-AnchorOauthState

   Returns the state of the current Oauth token

✅ Get-AnchorOauthToken

  Returns the current Oauth token so it can be inspected or manually imported into another session without needing to re-authenticate.

✅ Register-AnchorAccount

  Gets an Oauth token from the API.

✅ Set-AnchorOauthToken

  Manually set the Oauth token for the current session to prevent the need to authenticate again if you already have a valid token from another session.

✅ Set-AnchorOauthUri

  Change the Web URI from which tokens are granted. Should work with self-hosted Anchor instances.

## Reporting functions 🐇

⬜ Get a backup                                         

⬜ Get a group                                          

✅ Get-AnchorGuest (Get a guest)

✅ Get-AnchorActivityTypes (Get a list of activity types)

⬜ Get a machine                                        

⬜ Get a machine mapping                                

⬜ Get a machine's status                               

✅ Get-AnchorPerson (Get a person)

⬜ Get a root                                           

✅ Get-AnchorOrgShare (Get a share)

⬜ Get an activity record                               

✅ Get-AnchorOrg (Get an organization)

✅ Get-AnchorFileMetadata (Get file metadata)

⬜ Get files and folders shared with a guest            

✅ Get-AnchorFolderMetadata (Get folder metadata)

✅ Get-AnchorRootMetadata (Get root metadata)

✅ Get-AnchorOrgUsage (Get usage for an organization)

✅ Get-AnchorOrgAuthSources (List an organization's authentication sources)

✅ Get-AnchorOrgChildren (List an organization's child organizations)

✅ Get-AnchorOrgGroups (List an organization's groups)

✅ Get-AnchorOrgGuests (List an organization's guests) 

✅ Get-AnchorOrgMachines (List an organization's machines)

✅ Get-AnchorOrgRoots (List an organization's roots)

✅ Get-AnchorOrgShares (List an organization's shares)   

✅ Get-AnchorOrgUsers (List an organization's users)

✅ Get-AnchorMachineBackups (List backups)

⬜ List files on a file server enabled machine          

⬜ List group members                                   

⬜ List mapped paths on a file server enabled machine   

✅ Get-AnchorPersonActivity (List recent activity for a person)

✅ Get-AnchorOrgActivity (List recent activity for an organization)

✅ Get-AnchorRootFilesModifiedSince (List recently modified files)

✅ Get-AnchorOrgShareSubscribers( List share subscribers)

✅ Find-AnchorRootFilesAndFolders (Search files and folders)

✅ Get-AnchorApiVersion (Version)

✅ Get-AnchorRootLastModified (not specified in API)

  Uses multiple API functions to determine the last time any file in a root was modified.

## Management functions (Use at your own risk! Potential disruption, security violations, or data loss if used incorrectly.) 💣

⬜ Convert a guest to a standard account                

⬜ Create a backup                                      

⬜ Create a folder in a root                            

⬜ Create a group                                       

⬜ Create a guest                                       

⬜ Create a person                                      

⬜ Create a share                                       

⬜ Create a subfolder                                   

⬜ Create an account sync root                          

⬜ Create an activity record                            

⬜ Create an organization                               

⬜ Delete a backup                                      

⬜ Delete a file                                        

⬜ Delete a folder                                      

⬜ Delete a group                                       

⬜ Delete a guest                                       

⬜ Delete a machine mapping                             

⬜ Delete a person                                      

⬜ Delete a share                                       

⬜ Delete an organization                               

✅ Save-AnchorFile (Download a file)

⬜ Download a folder

⬜ Lock a file                                          

⬜ Lock a folder                                        

⬜ Lock a root                                          

⬜ Map a path on a file server enabled machine to a root

⬜ Move a file                                          

⬜ Move a folder                                        

⬜ Rename a file                                        

⬜ Rename a folder                                      

⬜ Restore a backup                                     

✅ New-AnchorFileShare (Share a file)

⬜ Share a folder                                       

⬜ Unlock a file                                        

⬜ Unlock a folder                                      

⬜ Unlock a root                                        

⬜ Update a group                                       

⬜ Update a guest                                       

⬜ Update a person                                      

⬜ Update a share                                       

⬜ Update an organization                               

⬜ Update an organization's policy                      

⬜ Update group members                                 

⬜ Update share subscribers                             

⬜ Upload a file to a folder                            

⬜ Upload a file to a root

# To-Do

## More examples. 

## Improve authentication logic to only prompt for TOTP when it's actually needed. 

# Comments
- I know I'm onto something when I can write a statement like this, and it works: `get-anchororg -top | Get-AnchorOrgChildren | where name -match "little" | get-anchororgshares | where name -match "Sync" | Get-AnchorOrgShareSubscribers -IncludeFromGroup -Raw`
