# Include the Anchor API scripts
. ".\Anchor-ApiOauth.ps1"
. ".\Anchor-ApiReporting.ps1"

$anchorParentOrgID = 361 # Modify this to be your own org_id

#Run this first to get an Oauth token.
Function Authenticate {
    Get-AnchorOauthToken
}

# Populates various lists of anchor objects 
Function Populate-UsefulVariables{
    Write-Host "Getting AnchorOrg object for the parent org id..."
    $script:anchorParentOrg = Get-AnchorOrg -id $anchorParentOrgID
    
    Write-Host "Getting collection of AnchorOrg objects for children of parent org..."
    $script:anchorCustomerOrgs = $anchorParentOrg | Get-AnchorOrgChildren
    Write-Host $script:anchorCustomerOrgs.Count "customer orgs retrieved."

    Write-Host "Getting collection of AnchorMachine objects for the parent org..."
    $script:anchorMachines = $anchorParentOrg | Get-AnchorOrgMachines
    Write-Host $script:anchorMachines.Count "machines retrieved."
    
    Write-Host "Getting collection of AnchorRoot objects for the parent org..."
    $script:anchorRoots = $anchorParentOrg | Get-AnchorOrgRoots
    Write-Host $script:anchorRoots.Count "roots retrieved."
}

# Get a list of all machine backups including the machine it's associated with.
Function Get-AllBackups {
    Write-Host "Getting collection of backups for all AnchorMachine objects..."
    # Getting backup roots by org doesn't tell you which machines they're associated with, so we have to itterate through all machines to see if they have backups. 😒
    # Excluding mobile machine_type cuts down some of the work.
    # It takes about 0.3 seconds per machine. Using Measure-Command gives some mildly interesting data about how long it takes.
    $duration = Measure-Command{$script:anchorBackups = $anchorMachines | Where-Object machine_type -ne mobile | Get-AnchorMachineBackups}
    $secondsPerMachine = $duration.TotalSeconds / ($anchorMachines | Where-Object machine_type -ne mobile).Count
    Write-Host ($anchorMachines | Where-Object machine_type -ne mobile).Count "machines processed."
    Write-Host "$($duration.TotalSeconds) seconds duration."
    Write-Host "$secondsPerMachine seconds per machine."
}

# Displays a all machine backup root id's and the last time anything in them was modified.
# Go make a sandwich while you wait for this to complete.
Function Report-BackupsLastModified {
    $duration = Measure-Command{$anchorBackups | Get-AnchorRootLastModified | Out-Default}
    $secondsPerBackup = $duration.TotalSeconds / $anchorBackups.Count
    Write-Host $anchorBackups.Count "backup roots processed."
    Write-Host "$($duration.TotalSeconds) seconds duration."
    Write-Host "$secondsPerBackup seconds per backup root."
}