# To use this function, run this script, then run something like the following:
# get-anchororg -top | Get-OrgAndChildMachinesByOrg

Function Get-OrgAndChildMachinesByOrg {
# Returns a list of all machines in the organiztion and all child organizations, with the correct company_id
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline)]$InputObject)
    process{
        # Return all the machines in this organization, excluding machines from child orgs.
        $_ | Get-AnchorOrgMachines -ExcludeChildren
        # Get the list of child orgs and pass them to this function recursively to return the results.
        $_ | Get-AnchorOrgChildren | Get-OrgAndChildMachinesByOrg
    }

}