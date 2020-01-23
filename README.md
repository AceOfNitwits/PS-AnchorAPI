# PowerShell Anchor-Api Module
PowerShell module for managing Axcient Anchor via the v2 API

🌟 ***Now with filesystem navigation***

Functions are PS-friendly, returning objects and accepting pipeline input where possible, including collections of objects.

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

   Provides an option to `-Expand` the object to include company_name and creator_name for human-friendly output.

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
   
   Provides option to set a `-RecordCountLimit` 

✅ Get-AnchorOrgMachines (List an organization's machines)

✅ Get-AnchorOrgRoots (List an organization's roots)

✅ Get-AnchorOrgShares (List an organization's shares)   

✅ Get-AnchorOrgUsers (List an organization's users)

✅ Get-AnchorMachineBackups (List backups)

⬜ List files on a file server enabled machine          

⬜ List group members                                   

⬜ List mapped paths on a file server enabled machine   

✅ Get-AnchorPersonActivity (List recent activity for a person)

   Automatically gets activity descriptions and returns them as part of the object for human-friendly output.
   
   Provides option to set a `-RecordCountLimit` 

✅ Get-AnchorOrgActivity (List recent activity for an organization)

   Automatically gets activity descriptions and returns them as part of the object for human-friendly output.

   Provides option to set a `-RecordCountLimit` 

✅ Get-AnchorRootFilesModifiedSince (List recently modified files)

✅ Get-AnchorOrgShareSubscribers( List share subscribers)

   Makes the returned data structure more friendly. Contains a `-Raw` option if you prefer the original, unfriendly object structure.

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

⬜ Save-AnchorFolder (Download a folder)

   Defaults to downloading a ZIP file of folder contents.
   
   Include `-AsFiles` option to download child files and folders individually.

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

⬜ Write-AnchorFolder (not implemented in API)

   Upload the contents and structure of a folder.

## Navigation functions 📁

Yes. You can navigate the Anchor file system from the PowerShell command line! It's not a PSDrive. It's kind of like FTP.

✅ apwd

   Display the present working Org:Root:Folder

✅ aco/acc

   Select a new organization/company by id
   
✅ alo/alc

   List child organizations/companies of the present working organization/company
   
✅ acr

   Select a new root by id
   
✅ alr

   List roots in the present working organization/company
   
✅ acd

   Select a new folder in the present working root by id
   
✅ aget

   Download a file in the present working root by id
   
⬜ aput

   Upload a file to the present working folder

# To-Do

## Complete all functions

## More examples. 

## Improve authentication logic to only prompt for TOTP when it's actually needed. 

## Improve error handling.

# Comments
- I know I'm onto something when I can write a statement like this, and it works: `get-anchororg -top | Get-AnchorOrgChildren | where name -match "little" | get-anchororgshares | where name -match "Sync" | Get-AnchorOrgShareSubscribers -IncludeFromGroup -Raw`
