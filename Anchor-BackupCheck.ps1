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
    # Note that the parent org owns all child org machines, so this includes all machines.
    $script:anchorMachines = $anchorParentOrg | Get-AnchorOrgMachines
    Write-Host $script:anchorMachines.Count "machines retrieved."

    Write-Host "Getting collection of AnchorMachine objects for the customer orgs..."
    # Note that the parent org owns all child org machines, so this includes all machines.
    $script:anchorCustomerMachines = $anchorCustomerOrgs | Get-AnchorOrgMachines
    Write-Host $script:anchorCustomerMachines.Count "machines retrieved."

    Write-Host "Calculating collection of AnchorMachine objects explicitly in the parent org..."
    $Script:anchorParentMachines = $anchorParentOrg | Get-AnchorOrgMachines -ExcludeChildren
    Write-Host $script:anchorParentMachines.Count "machines calculated."

    Write-Host "Creating collection of all AnchorMachine objects with their correct organization_id..."
    $Script:anchorOrgMachines = $Script:anchorParentMachines + $Script:anchorCustomerMachines
    Write-Host $script:anchorOrgMachines.Count "machines in total. (This should match the number of machines retrieved from the parent org.)"
    
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

# Get a list of all machine backup root id's and the last time anything in them was modified.
# Go make a sandwich while you wait for this to complete.
Function Get-BackupsLastModified {
    Write-Host "Getting last_modified date for machine backups."
    $duration = Measure-Command{$script:anchorBackupsLastModified = $anchorBackups | Get-AnchorRootLastModified}
    $secondsPerBackup = $duration.TotalSeconds / $anchorBackups.Count
    Write-Host $anchorBackups.Count "backup roots processed."
    Write-Host "$($duration.TotalSeconds) seconds duration."
    Write-Host "$secondsPerBackup seconds per backup root."
}

Function Report-MachineBackups{
    Populate-UsefulVariables
    Get-AllBackups
    Get-BackupsLastModified
    $anchorMachines | ? machine_type -ne mobile | ForEach-Object {
        $machineId = $_.id
        $machineName = $_.dns_name
        $myBackups = $anchorBackups | ? {$_.machine_id -eq $machineId}
        $myBackups | ForEach-Object {
            $rootId = $_.id
            $myLastModified = ($Script:anchorBackupsLastModified | ? {$_.id -eq $rootId}).modified
            If($myLastModified){
                $_ | Select @{'N'='machine_name';'E'={"$machineName"}}, path, @{'N'='last_modified';'E'={"$myLastModified"}}
            }
        }
    }
}