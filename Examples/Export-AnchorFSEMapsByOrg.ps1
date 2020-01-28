# Use this script to back up your file server enabled machine mappings. 
# Here's how it works:

# Get top org      | Get all child orgs    | Iterate through each child org
Get-AnchorOrg -Top | Get-AnchorOrgChildren | ForEach-Object {
    #  | Get all org machines  | retreieve only FSE-enabled machines    | Get all the mappings             | Export them to a file in your doanloads folder prepended with the org name and appended with today's date. (The -replace '\[.*\] ', '' operator is because we have square brackets in some of our company names, and those are not allowed in file names.)
    $_ | Get-AnchorOrgMachines | Where-Object machine_type -eq 'server' | Get-AnchorMachineFseMaps -Expand | Export-Csv -NoTypeInformation -Path "$env:USERPROFILE\Downloads\$((Get-AnchorOrg -id $_.id).name -replace '\[.*\] ', '')_AnchorFSEMaps_$(Get-Date -Format 'yyyy-MM-dd').csv"
}