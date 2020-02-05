# PowerShell Anchor-Api Module
PowerShell module for managing Axcient Anchor via the v2 API

This module is designed to administer and automate all aspects of the Anchor system that are available through the API.
Functions should be PS-friendly, returning objects and accepting pipeline input where possible, including collections of objects, which allows for creation/modification/deletion of Anchor objects in bulk. (See ModuleGoals.md.)

# Why a PowerShell Module for Anchor?

- PowerShell offers powerful capabilities for administration and automation. Combining this with the flexibility of Anchor affords many benefits.
- System administrators are already using PowerShell to administer and automate products like Office 365 and ActiveDirectory.
- Other popular Web-based services (like Autotask) have open-source PowerShell wrappers. A PowerShell wrapper for Anchor allows administrators to use data from one (or several) systems to drive actions in other systems.
- Powershell's abilities to manipulate collections of objects, run multi-threaded processes, and schedule jobs allows for process automation that is not available through the native Anchor interfaces. Examples, both general and specific:
   - Backup FSE mappings. If FSE mappings are lost (because a tech re-registers the sync account under a different Windows profile, for example 😡) there is no way to recover them, and no native record of what they were. **See the Examples folder, and if you haven't done this, do it now.**
   - Add users, shares, etc. to multiple organizations at one time.
   - Add a specific file or folder to the root of every user, in companies that start with 'A', that are in the US/Eastern time zone, all at once, with a single command.
   - List machines that are specific to an organization and not its children. (Seriously, this should be implemented natively, but it's not.) `PS> Get-AnchorOrg -Top | Get-AnchorOrgMachines -ExcludeChildren`
   - Get the last date and time the contents of a root changed. `Get-AnchorRootLastModified`
   - Daily, create a list of machines that have not logged in for a specific time period and create a ticket in your PSA to have someone check on the machine.
   - Monitor for specific administrative activity (like creation of an organization) and create tickets or send emails to appropriate resources for necessary follow-up.
   - Automate the onboarding of an entire organization, including org policies, shares, users, and groups, with a collection of .csv files and a single command.
   - Automate user termination procedures, including granting access to the user's root to other users.
   - Monitor for the existence of specific files in a location for automated processing. (For example, saving a .csv file into a particular folder could trigger creation of user accounts in Office 365 or even Anchor itself.)
   - Create a report of user access rights that can be formatted and manipulated to meet specific requirements.
   - Automatically upload and share files created from other automation processes.
   - Security monitoring: Get a list of all file shares created before a certain date that are still active.
   - Automatically provision more space for an organization that approaches its space quota and generate an email/ticket for follow-up.
   - Compare the list of an organizaiton's machines to a list of company managed machines (queried from an RMM tool, for example) to determine if users have loaded the agent on non-authorized machines; automatically create tickets/emails for followup.
   - Check for the existence of a backup of certain folders on every machine and create it if it doesn't exist.
   - Move a file or folder between roots that aren't synced to your PC. (This can be accomplished natively in a multi-step process, by navigating to the folder in the Web portal, downloading the file, then navigating to the target folder and uploading the file, then deleting the copy on your PC. With the Powershell Anchor-Api module this --is-- will be performed in a single command.)


# Usage

1. Download the files in the Anchor-Api folder to a folder named Anchor-Api, in your $env:PSModulePath (usually %userprofile%\My Documents\WindowsPowerShell\Modules, or C:\Program Files\WindowsPowerShell\Modules, or C:\windows\system32\WindowsPowerShell\v1.0\Modules\).

1. Run `Import-Module Anchor-Api` to import the functions, classes, and variables into your current session.

1. Try it out. 
   1. You'll probably want to start with `Get-AnchorOrg -Top`, which will return the top-level organization (yours). You can use that object as the key in other functions.
   1. For example: 
   
   `$anchorTopOrg = Get-AnchorOrg -Top`
   
   `$anchorTopOrg | Get-AnchorOrgChildren`
   
   `#anchorTopOrg | Get-AnchorOrgMachines`

- To see the list of available commands, use `Get-Command -Module Anchor-Api`.
- `Get-Help <command-name>` returns helpful info in some cases. (More to come.)
- Look at the Examples folder of this git for examples.

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

  Returns the current Oauth token so it can be inspected or manually exported and imported into another session without needing to re-authenticate (as long as the token hasn't expired).

✅ Set-AnchorOauthToken

  Manually set the Oauth token for the current session to prevent the need to authenticate again if you already have a valid token from another session (as long as the token hasn't expired).

✅ Set-AnchorOauthUri

  Change the Web URI from which tokens are granted. Should work with self-hosted Anchor instances.

## API functions 

### General functions

✅ Get-AnchorActivityTypes (Get a list of activity types)

✅ Get-AnchorApiVersion (Version)

### Activity functions

✅ Get-AnchorActivity (Get an activity record)

✅ New-AnchorActivity (Create an activity record)

   Oddly enough, this command allows you to create false activity events in the activity log.

### File and Folder functions

✅ Get-AnchorFileMetadata (Get file metadata)

✅ Get-AnchorFolderMetadata (Get folder metadata)

⬜ Create a subfolder                                   

⬜ Delete a file                                        

⬜ Delete a folder                                      

✅ Move-AnchorFile (Move a file)
   
   Ultimately, hope to add a feature to specify a root id so that a file can be moved to another root (by copying locally).

⬜ Move a folder                                        

✅ Rename a file                                        

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

✅ Get-AnchorGroup (Get a group)

✅ Get-AnchorGroupMembers (List group members)
   
   The API returns only the id's of member persons and groups. This function includes the `-Expand` option, to include group and person names in the results.

✅ New-AnchorGroup (Create a group)

   Can accept csv input.

⬜ Update a group                                       

⬜ Update group members                                 

⬜ Delete a group                                       

### Guest functions

⬜ Convert a guest to a standard account                

⬜ Create a guest                                       

⬜ Update a guest                                       

⬜ Delete a guest                                       

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

✅ Get-AnchorMachineLocalFolders (List files on a file server enabled machine)

   The Api endpoint `machine/<machine_id>/ls` does not behave as the title describes:
   1. It does not list files, only folders.
   1. It works for any machine with a desktop client, not just FSE machines
   
   Unlike most of the endpoints, this one returns a paginated array of folder name strings, rather than nice key:value pairs.

✅ Get-AnchorMachineFseMap (Get a machine mapping)

✅ Get-AnchorMachineFseMaps (List mapped paths on a file server enabled machine)

   Includes `-Expand` property

✅ Get-AnchorMachineStatus (Get a machine's status)

✅ New-AnchorMachineBackup (Create a backup)

✅ Remove-AnchorMachineBackup (Delete a backup)

⬜ Restore a backup                                     

⬜ Delete a machine mapping                             

⬜ Map a path on a file server enabled machine to a root

### Organization (Company) functions

✅ Get-AnchorOrg (Get an organization)

✅ Get-AnchorOrgActivity (List recent activity for an organization)

   Automatically gets activity descriptions and returns them as part of the object for human-friendly output.

   Provides option to set a `-RecordCountLimit` 

✅ Get-AnchorOrgAuthSources (List an organization's authentication sources)

✅ New-AnchorOrgChild (Create an organization)

   Have not yet tested CSV import.

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

⬜ Update an organization                               

⬜ Update an organization's policy                      

⬜ Delete an organization                               

⬜ Create a share                                       

⬜ Update a share                                       

⬜ Update share subscribers                             

⬜ Delete a share                                       

### Person (Account) functions

✅ Get-AnchorPerson (Get a person)

✅ Get-AnchorPersonActivity (List recent activity for a person)

   Automatically gets activity descriptions and returns them as part of the object for human-friendly output.
   
   Provides option to set a `-RecordCountLimit` 

✅ New-AnchorPerson (Create a person)

   Accepts command line, pipeline, or CSV input for bulk additions, including adding accounts to more than one organization at a time.

⬜ Update a person                                      

✅ Remove-AnchorPerson (Delete a person)

   Accepts multiple values in the `-id` parameter, or pipeline input, for bulk deletions. 
   
   ⚠ BE VERY CAREFUL WHAT YOU PASS TO THIS FUNCTION! Something like `$users = Get-AnchorOrg -Top | Get-AnchorOrgUsers; $users | Remove-AnchorPerson -Confirm:$false` will delete all users across all organizations without warning. (Just typing that gave me chills!)
   
   Supports PowerShell `-Confirm` and `-WhatIf` common parameters to help avoid potential disasters.
   
   🐛 All of the API parameters appear to be non-functional.

⬜ Create an account sync root                          

### Root functions

✅ Find-AnchorRootFilesAndFolders (Search files and folders)

✅ Get-AnchorRootFilesModifiedSince (List recently modified files)

✅ Get-AnchorRootLastModified (not specified in API)

  Uses multiple API functions to determine the last time any file in a root was modified.

✅ Get-AnchorRootMetadata (Get root metadata)

⬜ Create a folder in a root                            

⬜ Lock a root                                          

⬜ Unlock a root                                        

⬜ Upload a file to a root

## Development functions 🧪

✅ Get-AnchorRawData

   This is a straight API wrapper that returns exactly what the API returns.
   
✅ Update-AnchorModule

   Alias: `ReloadAnchor`
   
   Exports the current Oauth token, re-imports the module, then updates the Oauth token.

## Navigation functions 📁

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

## Convert all functions to use runspaces

## Create classes for all object types

## Allow for secure storage of credentials.

## Allow for storage of custom settings.

See: https://stackoverflow.com/questions/25318199/powershell-module-where-to-store-user-settings

# Comments
- I know I'm onto something when I can write statements like these, and they work: 

`PS> get-anchororg -top | Get-AnchorOrgChildren | where name -match "little" | get-anchororgshares | where name -match "Sync" | Get-AnchorOrgShareSubscribers -IncludeFromGroup -Raw`

`PS> Get-AnchorOrg -Top | Get-AnchorOrgChildren | ? name -Match "International" | Get-AnchorOrgRoots | ? name -EQ 'IGC Common Files' | Get-AnchorRootFilesModifiedSince -Since (Get-Date('2020-01-24 00:00')).ToUniversalTime()`
