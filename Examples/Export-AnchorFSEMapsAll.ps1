# Use this script to back up your file server enabled machine mappings. 
# Here's how it works:

# Get top org      | get all machines      | retreieve only FSE-enabled machines    | Get all the mappings             | Export them to a file in your doanloads folder
Get-AnchorOrg -Top | Get-AnchorOrgMachines | Where-Object machine_type -eq 'server' | Get-AnchorMachineFseMaps -Expand | Export-Csv -NoTypeInformation -Path "$env:USERPROFILE\Downloads\AnchorFSEMaps$(Get-Date -Format 'yyyy-MM-dd').csv"
