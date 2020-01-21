# Include the Anchor API scripts
#. ".\Anchor-ApiOauth.ps1"
#. ".\Anchor-ApiReporting.ps1"

#$anchorParentOrgID = 361 # Modify this to be your own org_id

#Run this first to get an Oauth token and top organization id
Function Sign-In {
    Authenticate-AnchorAccount
}

# Populates various lists of anchor objects 
Function Populate-UsefulVariables{

    Write-Host "Getting top-level org..."
    $script:anchorTopOrg = Get-AnchorOrg -Top
    Write-Host "Top-level org id:" $script:anchorTopOrg.id
    
    Write-Host "Getting collection of AnchorOrg objects for children of top org..."
    $script:anchorCustomerOrgs = $anchorTopOrg | Get-AnchorOrgChildren
    Write-Host $script:anchorCustomerOrgs.Count "customer orgs retrieved."

    $script:anchorOrgs = @($script:anchorTopOrg) + $script:anchorCustomerOrgs

    Write-Host "Getting collection of AnchorMachine objects for the top org..."
    Write-Host "Note that an org also owns all child org machines, so this includes all machines in your anchor environment." -ForegroundColor Yellow
    $script:anchorMachines = $anchorTopOrg | Get-AnchorOrgMachines
    Write-Host $script:anchorMachines.Count "machines retrieved."

    Write-Host "Getting collection of AnchorMachine objects for the customer orgs..."
    Write-Host "Note that this does not include machines explicity in the parent org, so we'll have to calculate those and add them back in later." -ForegroundColor Yellow
    $script:anchorCustomerMachines = $anchorCustomerOrgs | Get-AnchorOrgMachines
    Write-Host $script:anchorCustomerMachines.Count "machines retrieved."

    Write-Host "Calculating collection of AnchorMachine objects explicitly in the top org..."
    Write-Host "This is not a feature of the API, but it's implemented as part of the module function." -ForegroundColor Yellow
    $Script:anchorParentMachines = $anchorTopOrg | Get-AnchorOrgMachines -ExcludeChildren
    Write-Host $script:anchorParentMachines.Count "machines calculated."

    Write-Host "Creating collection of all AnchorMachine objects with their correct organization_id..."
    Write-Host "We need to add the two lists of machines together now." -ForegroundColor Yellow
    $Script:anchorOrgMachines = $Script:anchorParentMachines + $Script:anchorCustomerMachines
    Write-Host $script:anchorOrgMachines.Count "machines in total. (This should match the number of machines retrieved from the top-level org.)"
    
    Write-Host "Getting collection of AnchorRoot objects for the top org..."
    Write-Host "This retrieves a list of all roots in your Anchor environment." -ForegroundColor Yellow
    $script:anchorRoots = $anchorTopOrg | Get-AnchorOrgRoots
    Write-Host $script:anchorRoots.Count "roots retrieved."
}

# Get a list of all machine backups including the machine it's associated with.
Function Get-AllBackups {
    Write-Host "Getting collection of backups for all AnchorMachine objects..."
    # Getting backup roots by org doesn't tell you which machines they're associated with, so we have to itterate through all machines to see if they have backups. 😒
    # Excluding machine_type 'mobile' cuts down some of the work.
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

# Running this function runs all of the above.
Function Report-MachineBackups{
    Populate-UsefulVariables
    Get-AllBackups
    Get-BackupsLastModified
    $script:backupReport = [pscustomobject]@()
    $anchorBackups | ForEach-Object {
        $rootId = $_.id
        $machineId = $_.machine_id
        $path = $_.path
        $myLastModified = ($Script:anchorBackupsLastModified | ? {$_.id -eq $rootId}).modified
        $myMachine = $script:anchorOrgMachines | ? {$_.id -eq $machineId}
        $myMachineName = $myMachine.dns_name
        $myMachineOrg = $myMachine.organization_id
        $myOrgName = ($script:anchorOrgs | ? {$_.id -eq $myMachineOrg}).name
        $Script:backupReport += [pscustomobject]@{'Organization'="$myOrgName";'Machine'="$myMachineName";'BackupPath'="$path";'LastModified'="$myLastModified"}
    }
    $script:backupReport | ForEach-Object {
        Write-Host ($_ | Out-String)
    }
}