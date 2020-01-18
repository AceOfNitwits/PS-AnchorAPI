# Include the Anchor API script
. ".\Anchor-ApiOauth.ps1"
. ".\Anchor-ApiReporting.ps1"

$anchorParentOrgID = 361 # Modify this to be your own org_id

$anchorOauthToken = Get-AnchorOauthToken

# Populates various lists of anchor objects 
Function Populate-UsefulVariables{
    $script:anchorParentOrg = Get-AnchorOrg -OauthToken $anchorOauthToken -id $anchorParentOrgID
    $script:anchorCustomerOrgs = $anchorParentOrg | Get-AnchorOrgChildren -OauthToken $anchorOauthToken
    $script:anchorMachines = $anchorParentOrg | Get-AnchorOrgMachines -OauthToken $anchorOauthToken
    $script:anchorRoots = $anchorParentOrg | Get-AnchorOrgRoots -OauthToken $anchorOauthToken
}

# Get a list of all machine backups including the machine it's associated with.
Function Get-AllBackups {
    #Getting backup roots by org doesn't tell you which machines they're associated with, so we have to itterate through all machines to see if they have backups. 😒
    $script:backups = $machines | Get-AnchorMachineBackups -OauthToken $anchorOauthToken
}

# Displays a all machine backup root id's and the last time anything in them was modified.
# Go make a sandwich while you wait for this to complete.
Function Report-BackupsLastModified {
    $backups | Get-AnchorRootLastModified -OauthToken $anchorOauthToken
}