# PowerShell Anchor-Api Module
PowerShell module for managing Axcient Anchor via the v2 API

This module is designed to administer and automate all aspects of the Anchor system that are available through the API.
Functions should be PS-friendly, returning objects and accepting pipeline input where possible, including collections of objects, which allows for creation/modification/deletion of Anchor objects in bulk.

# Usage

1. Download the files in the Anchor-Api folder to a folder named Anchor-Api, in your $env:PSModulePath (usually %userprofile%\My Documents\WindowsPowerShell\Modules, or C:\Program Files\WindowsPowerShell\Modules, or C:\windows\system32\WindowsPowerShell\v1.0\Modules\).

1. Run `Import-Module Anchor-Api` to import the functions, classes, and variables into your current session.

1. Sign in and try it out. 
   1. You'll probably want to start with `Get-AnchorOrg -Top`, which will return the top-level organization (yours). You can use that object as the key in other functions.
   1. For example: 
   
   `$anchorTopOrg = Get-AnchorOrg -Top`
   
   `$anchorTopOrg | Get-AnchorOrgChildren`
   
   `#anchorTopOrg | Get-AnchorOrgMachines`

- To see the list of available commands, use `Get-Command -Module Anchor-Api`.
- `Get-Help <command-name>` returns helpful info in some cases.
- Look at Anchor-BackupCheck.ps1 for examples.

# Functions

## Authentication functions 🔑

✅ Connect-AnchorApiSession

  Gets an Oauth token from the API. You can supply `-Username` and `-Password` values from the command line, pipe a `[PSCredential]` object, or supply nothing, in which case the function will prompt you to supply credentials.

✅ Disconnect-AnchorApiSession

  Revokes the current Oauth token

✅ Update-AnchorApiSession

  Refreshes the Oauth token. This is handled automatically by the function calls as needed, but if you're building in automation and not going to call any functions for longer than the expiry period, you might want to do this manually.

✅ Get-AnchorOauthState

   Returns the state of the current Oauth token

✅ Get-AnchorOauthToken

  Returns the current Oauth token so it can be inspected or manually imported into another session without needing to re-authenticate.

✅ Set-AnchorOauthToken

  Manually set the Oauth token for the current session to prevent the need to authenticate again if you already have a valid token from another session.

✅ Set-AnchorOauthUri

  Change the Web URI from which tokens are granted. Should work with self-hosted Anchor instances.

## Reporting functions 🐇

### General functions

✅ Get-AnchorActivityTypes (Get a list of activity types)

✅ Get-AnchorApiVersion (Version)

### Activity functions

✅ Get-AnchorActivity (Get an activity record)

### File and Folder functions

✅ Get-AnchorFileMetadata (Get file metadata)

✅ Get-AnchorFolderMetadata (Get folder metadata)

### Group functions

✅ Get-AnchorGroup (Get a group)

✅ Get-AnchorGroupMembers (List group members)
   
   The API returns only the id's of member persons and groups. This function includes the `-Expand` option, to include group and person names in the results.

### Guest functions

✅ Get-AnchorGuest (Get a guest)

   Provides an option to `-Expand` the object to include company_name and creator_name for human-friendly output.

✅ Get-AnchorGuestFileShares (Get files and folders shared with a guest)
   
   Returned object includes a `created(local_offset)` field that is a valid PowerShell DateTime object with the correct local offset. This is convenient not only because it displays in local time, but because it can be used in PowerShell DateTime commands without additional conversion from a string or worrying about the time zone.
   Optional `-Expand` parameter looks up the creator_name from the creator_id and adds it to the returned object.

### Machine functions

✅ Get-AnchorMachine (Get a machine)

✅ Get-AnchorMachineBackup (Get a backup)                      

✅ Get-AnchorMachineBackups (List backups)

❗ Get-AnchorMachineFseFiles (List files on a file server enabled machine)

   This API call seems to be non-functional.

✅ Get-AnchorMachineFseMap (Get a machine mapping)

✅ Get-AnchorMachineFseMaps (List mapped paths on a file server enabled machine)

   Includes `-Expand` property

✅ Get-AnchorMachineStatus (Get a machine's status)

### Organization (Company) functions

✅ Get-AnchorOrg (Get an organization)

✅ Get-AnchorOrgActivity (List recent activity for an organization)

   Automatically gets activity descriptions and returns them as part of the object for human-friendly output.

   Provides option to set a `-RecordCountLimit` 

✅ Get-AnchorOrgAuthSources (List an organization's authentication sources)

✅ Get-AnchorOrgChildren (List an organization's child organizations)

✅ Get-AnchorOrgGroups (List an organization's groups)

✅ Get-AnchorOrgGuests (List an organization's guests) 
   
   Provides option to set a `-RecordCountLimit` 

✅ Get-AnchorOrgMachines (List an organization's machines)

✅ Get-AnchorOrgRoot (Get a root)

   This call requires both a company_id and a root_id. Not sure why you would want to use this over getting the root metadata, which only requires a root_id.

✅ Get-AnchorOrgRoots (List an organization's roots)

✅ Get-AnchorOrgShare (Get a share)

✅ Get-AnchorOrgShares (List an organization's shares)   

✅ Get-AnchorOrgShareSubscribers( List share subscribers)

   Makes the returned data structure more friendly. Contains a `-Raw` option if you prefer the original, unfriendly object structure.

✅ Get-AnchorOrgUsage (Get usage for an organization)

✅ Get-AnchorOrgUsers (List an organization's users)

### Person (Account) functions

✅ Get-AnchorPerson (Get a person)

✅ Get-AnchorPersonActivity (List recent activity for a person)

   Automatically gets activity descriptions and returns them as part of the object for human-friendly output.
   
   Provides option to set a `-RecordCountLimit` 

### Root functions

✅ Find-AnchorRootFilesAndFolders (Search files and folders)

✅ Get-AnchorRootFilesModifiedSince (List recently modified files)

✅ Get-AnchorRootLastModified (not specified in API)

  Uses multiple API functions to determine the last time any file in a root was modified.

✅ Get-AnchorRootMetadata (Get root metadata)

## Management functions (Use at your own risk! Potential disruption, security violations, or data loss if used incorrectly.) 💣

### General functions

### Activity functions

⬜ Create an activity record                            

### File and Folder functions

⬜ Create a subfolder                                   

⬜ Delete a file                                        

⬜ Delete a folder                                      

⬜ Move a file                                          

⬜ Move a folder                                        

⬜ Rename a file                                        

⬜ Rename a folder                                      

✅ Save-AnchorFile (Download a file)

⬜ Save-AnchorFolder (Download a folder)

   Defaults to downloading a ZIP file of folder contents.
   
   Include `-AsFiles` option to download child files and folders individually.

⬜ Upload a file to a folder                            

⬜ Write-AnchorFolder (not implemented in API)

   Upload the contents and structure of a folder.

⬜ Lock a file                                          

⬜ Lock a folder                                        

✅ New-AnchorFileShare (Share a file)

⬜ Share a folder                                       

⬜ Unlock a file                                        

⬜ Unlock a folder                                      

### Group functions

⬜ Create a group                                       

⬜ Update a group                                       

⬜ Update group members                                 

⬜ Delete a group                                       

### Guest functions

⬜ Convert a guest to a standard account                

⬜ Create a guest                                       

⬜ Update a guest                                       

⬜ Delete a guest                                       

### Machine functions

⬜ Create a backup                                      

⬜ Delete a backup                                      

⬜ Restore a backup                                     

⬜ Delete a machine mapping                             

⬜ Map a path on a file server enabled machine to a root

### Organization (Company) functions

⬜ Create an organization                               

⬜ Update an organization                               

⬜ Update an organization's policy                      

⬜ Delete an organization                               

⬜ Create a share                                       

⬜ Update a share                                       

⬜ Update share subscribers                             

⬜ Delete a share                                       

### Person (Account) functions

✅ New-AnchorPerson (Create a person)

   Accepts command line, pipeline, or CSV input for bulk additions.
   
   Still need to figure out how to add more than one group and root.

⬜ Update a person                                      

⬜ Delete a person                                      

⬜ Create an account sync root                          

### Root functions

⬜ Create a folder in a root                            

⬜ Lock a root                                          

⬜ Unlock a root                                        

⬜ Upload a file to a root

## Navigation functions 📁🧪

Yes. You can navigate the Anchor file system from the PowerShell command line! It's not a PSDrive. It's kind of like FTP. Ultimately, not all that practical, but an interesting distraction.

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

## Convert all reporting functions to use runspaces

# Comments
- I know I'm onto something when I can write statements like these, and they work: 

`PS> get-anchororg -top | Get-AnchorOrgChildren | where name -match "little" | get-anchororgshares | where name -match "Sync" | Get-AnchorOrgShareSubscribers -IncludeFromGroup -Raw`

`PS> Get-AnchorOrg -Top | Get-AnchorOrgChildren | ? name -Match "International" | Get-AnchorOrgRoots | ? name -EQ 'IGC Common Files' | Get-AnchorRootFilesModifiedSince -Since (Get-Date('2020-01-24 00:00')).ToUniversalTime()`
