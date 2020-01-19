# Include the Anchor API scripts
. ".\Anchor-ApiOauth.ps1"
. ".\Anchor-ApiReporting.ps1"

$anchorParentOrgID = 361 # Modify this to be your own org_id

#Run this first to get an Oauth token.
Function Authenticate {
    $script:anchorOauthToken = Get-AnchorOauthToken
}

# Populates various lists of anchor objects 
Function Populate-UsefulVariables{
    Write-Host "Getting AnchorOrg object for the parent org id..."
    $script:anchorParentOrg = Get-AnchorOrg -OauthToken $anchorOauthToken -id $anchorParentOrgID
    Write-Host "Getting collection of AnchorOrg objects for children of parent org..."
    $script:anchorCustomerOrgs = $anchorParentOrg | Get-AnchorOrgChildren -OauthToken $anchorOauthToken
    Write-Host "Getting collection of AnchorMachine objects for the parent org..."
    $script:anchorMachines = $anchorParentOrg | Get-AnchorOrgMachines -OauthToken $anchorOauthToken
    Write-Host "Getting collection of AnchorRoot objects for the parent org..."
    $script:anchorRoots = $anchorParentOrg | Get-AnchorOrgRoots -OauthToken $anchorOauthToken
}

# Get a list of all machine backups including the machine it's associated with.
Function Get-AllBackups {
    Write-Host "Getting collection of backups for all AnchorMachine objects..."
    # Getting backup roots by org doesn't tell you which machines they're associated with, so we have to itterate through all machines to see if they have backups. 😒
    # Excluding mobile machine_type cuts down some of the work.
    # It takes about 3 seconds per machine. Using Measure-Command gives some mildly useful data about how long it takes.
    Measure-Command{$script:anchorBackups = $anchorMachines | Where-Object machine_type -ne mobile | Get-AnchorMachineBackups -OauthToken $anchorOauthToken}
}

# Displays a all machine backup root id's and the last time anything in them was modified.
# Go make a sandwich while you wait for this to complete.
Function Report-BackupsLastModified {
    $duration = Measure-Command{$anchorBackups | Get-AnchorRootLastModified -OauthToken $anchorOauthToken | Out-Default}
    $secondsPerBackup = $duration.TotalSeconds / $anchorBackups.Count
    Write-Host "$backupsPerSecond backups returned per second"
}