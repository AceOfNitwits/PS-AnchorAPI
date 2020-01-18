#region Credits and Documentation
# Bryan Sullo - bryan@clocktowertech.com
# Anchor API Documentation: http://developer.anchorworks.com/v2/

# Query parameters go in the body, formatted as a hash table @{"parameter_name"="value"}
# Format date parameters like this @{"since"=(Get-Date (Get-Date).AddDays(-1) -Format "yyyy-MM-ddThh:mm:ss")}
# A valid Oauth token must be passed to all functions.
#   The functions will refresh the token if needed.

#endregion

# Base API URI
$apiUri = "https://clocktowertech.syncedtool.com/api/2"


# Returns the current Api Version
Function Get-AnchorApiVersion {
    param(
        [Parameter(Mandatory)]$OauthToken
    )
    $apiEndpoint = "version"
    $results = Get-AnchorData -ApiEndpoint $apiEndPoint -OauthToken $OauthToken
    $results
}


# Accepts 1 or more objects containing Anchor org id in the "id" property or a list of AnchorOrg ids.
# Returns AnchorOrg objects for each id.
Function Get-AnchorOrg {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]$OauthToken,
        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName)][string[]]$id
        
    )
    process{
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        ForEach ($orgId in $id){
            $apiEndpoint = "organization/$orgId"
            $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndPoint
            $results
        }
    }
}

# Accepts an AnchorOrg object or collection of AnchorOrg objects.
# Returns AnchorMachine objects.
Function Get-AnchorOrgMachines {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true,Position=1,HelpMessage='Organization ID')][string[]]$id,
        [Parameter(Mandatory=$true,position=0)]$OauthToken
    )
    process{
        #We might get multiple $id values from the parameter.
        ForEach ($orgId in $id){
            $apiEndpoint = "organization/$($orgId)/machines"
            $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndPoint
            # If there are no results, we don't want to return an empty object with just the organization property populated.
            If($results){
                $results | Select-Object *, @{N='organization';E={@{'id'="$orgId"}}} #, @{N='org_name';E={$orgName}}
            }
        }
    }
}

# Accepts an AnchorOrg object or collection of AnchorOrg objects.
# Returns AnchorOrg objects.
Function Get-AnchorOrgChildren {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor Organization ID')][string[]]$id,
        [Parameter(Mandatory,Position=0)]$OauthToken
    )
    process{
        #There may be multiple $id values passed by the function -id parameter
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$orgId/organizations"
            $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndPoint
            # Results arelady include parent_id so we can just return them as-is.
            $results
        }
    }
}


Function Get-AnchorOrgRoots {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]$OauthToken,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor Organization ID')][string[]]$id
        
    )
    process{
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$OrgId/roots"
            $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndpoint
            # Results already include company_id, so we can return them as-is
            $results # | Select-Object *, @{N='organization';E={@{'id'="$orgId"}}}
        }
    }
}

# Note that the Include switches must be explicitly called, despite the fact that some are on by default in the API.
Function Get-AnchorRootMetadata {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]$OauthToken,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor Root ID')][string[]]$id, 
        [Parameter(HelpMessage='Include collection of child objects (files and folders)')][switch]$IncludeChildren,
        [Parameter(HelpMessage='Include deleted items in child objects')][switch]$IncludeDeleted,
        [Parameter(HelpMessage='Include information about locks')][switch]$IncludeLockInfo,
        [Parameter(HelpMessage='Include collection of permissions for current user')][switch]$IncludePermissions,
        [Parameter(HelpMessage='Hash value returned from previous call to this endpoint. If hash is identical, return will include root id and a "modified" property with a value of false, indicating that the children have not been modified.')][ValidateLength(40,40)][string]$Hash
    )
    begin{
        $apiQuery = @{
            'include_children' = "$(If($IncludeChildren){"true"}Else{"false"})"
            'include_deleted' = "$(If($IncludeDeleted){"true"}Else{"false"})"
            'include_lock_info' = "$(If($IncludeLockInfo){"true"}Else{"false"})"
            'include_permissions' = "$(If($IncludePermissions){"true"}Else{"false"})"
            'hash' = "$Hash"
        }
    }
    process{
        foreach ($rootId in $id){
            $apiEndpoint = "files/$rootId"
            try{
                $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
            }
            catch{
                Switch -regex ($Error[0].Exception){
                    '\(304\)\sNot\sModified\.' {$results = @{'id'="$rootId";'modified'=$false}}
                    default {Write-Host $error[0].Exception}
                }
            }
            $results
        }
    }
}


Function Get-AnchorRootFilesModifiedSince {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]$OauthToken,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor root id')][string[]]$id,
        [Parameter(Mandatory,Position=2,HelpMessage='PowerShell DateTime object indicating the oldest modified file to return')][datetime]$Since
    )
    begin{
        $apiQuery = @{'since' = "$(Get-Date($Since) -Format 'yyyy-MM-ddThh:mm:ss')"}
    }
    process{
        foreach ($rootId in $id){
            $apiEndpoint = "files/$rootId/modified_since"
            $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
            $results
        }
    }
}

# Accepts one or more Anchor root IDs or objects containing a parameter named "id" with values of root IDs
# Returns the DateTime of the last time any file in the root was modified (within the last 5.6 years).
# We do multiple checks, looking back 1 day, 2 days, 4 days, and so on until 2048.
#   The API times out if there's no result in about 5 minutes, so this can potentially take a long time, especially if there are roots with large numbers of files.
Function Get-AnchorRootLastModified {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]$OauthToken,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor root id')][string[]]$id
    )
    process{
        foreach ($rootId in $id){
            $lookBackDays = -1 #Initialize
            $Since = (Get-Date).AddDays($lookBackDays) #Initialize
            Do{
                Write-Progress -Id $rootID -Activity "Analyzing root $rootID" -Status "LookBackDays = $lookBackDays"
                $apiEndpoint = "files/$rootId/modified_since"
                $apiQuery = @{'since' = "$(Get-Date($Since) -Format 'yyyy-MM-ddThh:mm:ss')"}
                try {
                    $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
                } catch {
                    $results = [PSCustomObject]@{'root_id' = "$rootId";'modified'='api_error'}
                }
                $results | Sort-Object -Property modified -Descending | Select-Object root_id, modified -First 1 | Add-Member -MemberType AliasProperty -Name id -Value root_id -PassThru | Select-Object id, modified
                $lookBackDays = $lookBackDays * 2
                $Since = (Get-Date).AddDays($lookBackDays)
            }Until($results -or ($lookBackDays -lt -2048) -or $halt) # Let's not get carried away. 5.6 years ought to be enough! Also, remember, we're counting backward.
            If ($lookBackDays -lt -2555){[PSCustomObject]@{'id' = "$rootId";'modified'='no_files_found'}}
            Write-Progress -Id $RootID -Activity "Analyzing root $RootID" -Completed
        }
    }
}


Function Get-AnchorMachineBackups {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor machine id')][string[]]$id, 
        [Parameter(Mandatory,Position=0)]$OauthToken
    )
    process{
        foreach ($machineId in $id){
            $apiEndpoint = "machine/$machineId/backups"
            Write-Progress -Activity "Looking for machine backups" -CurrentOperation $machineId
            $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndPoint
            # the machine backups endpoint may not always have results.
            #   Therefore, we need to do some extra work.
            If ($results){
                $results
            }
        }
    }
}

# Generic function for returning data from an Anchor API endpoint.
# The full uri of the endpoint is passed as a string.
# The query (if needed) is passed as a hash table. This is the information that will be sent in the Body.
#   The function handles pagination, so there is no need to pass the offset in the query hashtable.
# The OauthToken is an object, returned from the Oauth function.
Function Get-AnchorData {
    param(
        [Parameter(Mandatory,Position=0)]$OauthToken,
        [Parameter(Mandatory,Position=1)][string]$ApiEndpoint, 
        [Parameter(Position=2)]$ApiQuery
    )
    Validate-AnchorOauthToken -OauthToken $OauthToken #Check to make sure the Oauth token is valid and refresh if needed.
    
    $tokenType = $OauthToken.token_type
    $accessToken = $OauthToken.access_token
    $headers = @{'Authorization' = "$tokenType $accessToken"}
    $body = $ApiQuery
    
    $results = Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Get -Headers $headers -Body $body
    # Write-Host ($results | out-string)
    
    If ($results.PSobject.Properties.name -eq "results") { # The returned object contains a property named "results" and is therefore a collection. We have to do some magic to extract all the data. 
        #Write-Host "Collection"
        $results.results # Return the first set of results.
        $resultsCount = $results.results.count
        $totalResults = $results.total #The call will only return 100 objects at a time. This tells us if there are more to get.
        $body+=@{'offset' = '0'} #Because we're going to need to increment the offset, and we didn't have an offset as part of the query to begin, we have to add a zero-value offset before we can increment it.
        While ($totalResults -gt $resultsCount){ # Keep calling the endpoint until we've squeezed out all the data.
            $PageOffset+=100 # We want to get the next 100 results
            $body.offset = "$PageOffset" # Update the offset value for the next Api call.
            $results = Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Get -Headers $headers -Body $body
            $results.results # Return the next batch of results.
            $resultsCount+=$results.results.count
        }

    } Else { #This is an object (or empty). We can just return the results.
        #Write-Host "Object"
        $results
    }
}

#region DEPRECATED FUNCTIONS

# Accepts an OrgId as a string.
# Returns an AnchorOrg Object.
Function Get-AnchorOrgById {
    param(
        [string]$OrgId,
        $OauthToken
    )
    $apiEndpoint = "organization/$OrgId"
    $results = Get-AnchorData -ApiEndpoint $apiEndPoint -OauthToken $OauthToken
    Return $results
}

# This function is supurfluous as it can be accomplished by calling Get-AnchorOrgRoots and piping the results to Wehre-Object
Function Get-AnchorOrgBackupRoots {
    param(
        [string]$OrgId, 
        [int]$PageOffset, 
        $OauthToken
    )
    Validate-AnchorOauthToken -OauthToken $OauthToken
    $tokenType = $OauthToken.token_type
    $accessToken = $OauthToken.access_token
    $headers = @{'Authorization' = "$tokenType $accessToken"}
    If(-not $PageOffset){$PageOffset=0}
    $body = @{'offset' = "$PageOffset"}
    $results = Invoke-RestMethod -Uri "$apiUri`/organization/$OrgId/roots" -Method Get -Headers $headers -Body $body
    $return = $results.results | Where-Object {$_.root_type -eq "backup"}
    Return $return
}

Function Get-AnchorDataOld {
    param(
        [Parameter(Mandatory,Position=0)]$OauthToken,
        [Parameter(Mandatory,Position=1)][string]$ApiEndpoint, 
        [Parameter(Position=2)]$ApiQuery
    )
    Validate-AnchorOauthToken -OauthToken $OauthToken #Check to make sure the Oauth token is valid and refresh if needed.
    
    $tokenType = $OauthToken.token_type
    $accessToken = $OauthToken.access_token
    $headers = @{'Authorization' = "$tokenType $accessToken"}
    $body = $ApiQuery
    
    $results = Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Get -Headers $headers -Body $body
    # Write-Host ($results | out-string)
    
    If ($results.PSobject.Properties.name -eq "results") { # The returned object contains a property named "results" and is therefore a collection. We have to do some magic to extract all the data. 
        #Write-Host "Collection"
        $collection = $results.results
        $totalResults = $results.total #The call will only return 100 objects at a time. This tells us if there are more to get.
        $body+=@{'offset' = '0'} #Because we're going to need to increment the offset, and we didn't have an offset as part of the query to begin, we have to add a zero-value offset before we can increment it.
        While ($totalResults -gt $collection.Count){ # Keep calling the endpoint until we've squeezed out all the data.
            $PageOffset+=100 #We want to get the next 100 results
            $body.offset = "$PageOffset" # Update the offset value for the next Api call.
            $results = Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Get -Headers $headers -Body $body
            $collection += $results.results # Extract the objects from the results and add them to the collection that will be returned.
            $totalResults = $results.total
        }
        $return = $collection

    } Else { #This is an object. We can just return the results.
        #Write-Host "Object"
        $return = $results
    }
    Return $return
}



#endregion