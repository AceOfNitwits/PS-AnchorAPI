#region Credits and Documentation
# Bryan Sullo - bryan@clocktowertech.com
# Anchor API Documentation: http://developer.anchorworks.com/v2/

# Query parameters go in the body, formatted as a hash table @{"parameter_name"="value"}
# Format date parameters like this @{"since"=(Get-Date (Get-Date).AddDays(-1) -Format "yyyy-MM-ddThh:mm:ss")}

#endregion

# General Functions

Function Get-AnchorActivityTypes {
<#
    .LINK
    http://developer.anchorworks.com/v2/#get-a-list-of-activity-types
#>
    param(
        #[Parameter(HelpMessage='Limits the number of objects to return to the next highest multiple of 100. Default:1000')][int]$RecordCountLimit
        
    )
    Update-AnchorApiReadiness
    $apiEndpoint = "activity/types"
    try{
        Invoke-AnchorApiGet -ApiEndpoint 'activity/types'
        #$results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ResultsLimit $RecordCountLimit
    }
    catch{
        $exception = $_.Exception
        Switch ($exception.Response.StatusCode.value__){
            403 {$results=[pscustomobject]@{exception='unauthorized'}} # No soup for you!
            404 {$results=[pscustomobject]@{exception='nonexistent'}}
            default {$results = $exception}
        }
    }
    #$results
}

Function Get-AnchorApiVersion {
<#
    .SYNOPSIS
    Returns an object representing the current Anchor API Version at the given host.

    .DESCRIPTION
    Returns an object representing the current Anchor API Version at the given host.
    Requires a valid OauthToken

    .NOTES
    
    .INPUTS
    This function does not accept pipeline input

    .OUTPUTS
    AnchorApi version object

    .EXAMPLE
    C:\PS> Get-AnchorApiVersion -OauthToken $anchorOauthToken
    version   
    -------   
    2.7.2.1581

    .LINK
    http://developer.anchorworks.com/v2/#version

    .LINK
    Get-AnchorOauthToken
#>
    [CmdletBinding()]
    [Alias('AnchorApi')]
    param()
    Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
    Update-AnchorApiReadiness

    $apiEndpoint = "version"
    Invoke-AnchorApiGet -ApiEndpoint 'version'
    Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
}

# Activity Functions

Function Get-AnchorActivity {
<#
    .SYNOPSIS
    Returns a collection of AnchorActivity objects for a given activity_id or set of id's.

    .DESCRIPTION
    Returns one or more AnchorActivity objects.
    Accepts one or more AnchorActivity id's via argument or a colleciton of AnchorActivity objects from the pipeline.

    .NOTES
    
    .PARAMETER id
    One or more AnchorActivity id's.

    .INPUTS
    A collection of AnchorActivity objects

    .OUTPUTS
    A collection of AnchorActivity objects.

    .LINK
    http://developer.anchorworks.com/v2/#get-an-activity-record

#>
    [CmdletBinding()]
    [Alias('AnchorActivity')]
    param(
        [Parameter(Position=0,ValueFromPipelineByPropertyName)][string[]]$id,
        [Parameter(Position=1)][switch]$Expand
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiQuery = @{
        }
    }
    process{
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        ForEach ($activityId in $id){
            # Get the expanded data we can get before calling the Api
            If($Expand){}
            $apiEndpoint = "activity/$activityId"
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint #-ApiQuery $apiQuery
            # Process Results
            $results
            If($results){
                $classedResults = [pscustomobject]@()
                $results | ForEach-Object {
                    # Get the rest of the expanded results
                    If($Expand){
                        $myActorOrg = Get-AnchorOrg -id $_.actor_company_id
                        $myActorMachine = Get-AnchorMachine -id $_.actor_machine_id
                        #$myActorPerson = Get-AnchorPerson -id $_.actor_person_id
                        $myActorGuest = Get-AnchorGuest -id $_.actor_guest_id
                        $myOrg = Get-AnchorOrg -id $_.acted_on_company_id
                        $myMachine = Get-AnchorMachine -id $_.acted_on_machine_id
                        $myPerson = Get-AnchorPerson -id $_.acted_on_person_id
                        $myGuest = Get-AnchorGuest -id $_.acted_on_guest_id
                        $myRoot = Get-AnchorRootMetadata -id $_.acted_on_root_id
                        $myGroup = Get-AnchorGroup -id $_.acted_on_group_id
                    }
                    $classedObject = [AnchorActivity]$_
                    $classedObject.actor_company_name = $myActorOrg.name
                    $classedObject.actor_machine_name = $myActorMachine.dns_name
                    #$classedObject.actor_person_name = $myActorPerson.display_name
                    $classedObject.actor_guest_email = $myActorGuest.email
                    $classedObject.acted_on_company_name = $myOrg.name
                    $classedObject.acted_on_machine_name = $myMachine.dns_name
                    $classedObject.acted_on_person_name = $myPerson.display_name
                    $classedObject.acted_on_guest_email = $myGuest.email
                    $classedObject.acted_on_root_name = $myRoot.name
                    $classedObject.acted_on_group_name = $myGroup.name
                    $classedObject.created_ps_local = [datetime]$(Get-Date("$($_.created)Z"))
                    $classedObject.api_exception = $false
                    $classedObject.queried_on = (Get-Date)
                    $classedResults+=$classedObject
                }
                $classedResults
            }
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

# File and Folder Functions

Function Get-AnchorFileMetadata {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Root ID')][string[]]$root_id, 
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor File ID')][string[]]$id, 
        [Parameter(HelpMessage='Include collection of permissions for current user')][switch]$IncludePermissions
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiQuery = @{
            'include_permissions' = "$(If($IncludePermissions){"true"}Else{"false"})"
        }
    }
    process{
        $rootId = $root_id
        $fileId = $id
        $apiEndpoint = "files/$rootId/$fileId"
        try{
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
        }
        catch{
            Switch -regex ($Error[0].Exception){
                default {Write-Host $error[0].Exception}
            }
        }
        $results
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

Function Get-AnchorFolderMetadata {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Root ID')][string[]]$root_id, 
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor File ID')][string[]]$id, 
        [Parameter(HelpMessage='Include collection of permissions for current user')][switch]$IncludeChildren,
        [Parameter(HelpMessage='Include collection of permissions for current user')][switch]$IncludeDeleted,
        [Parameter(HelpMessage='Include collection of permissions for current user')][switch]$IncludeLockInfo,
        [Parameter(HelpMessage='Include collection of permissions for current user')][switch]$IncludePermissions,
        [Parameter()][string]$Hash

    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiQuery = @{
            'include_children' = "$(If($IncludeChildren){"true"}Else{"false"})"
            'include_deleted' = "$(If($IncludeDeleted){"true"}Else{"false"})"
            'include_lock_info' = "$(If($IncludeLockInfo){"true"}Else{"false"})"
            'include_permissions' = "$(If($IncludePermissions){"true"}Else{"false"})"
            'hash' = "$hash"
        }
    }
    process{
        $rootId = $root_id
        $folderId = $id
        $apiEndpoint = "files/$rootId/folder/$folderId"
        try{
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
        }
        catch{
            Switch -regex ($Error[0].Exception){
                default {Write-Host $error[0].Exception}
            }
        }
        $results
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

# Group Functions

Function Get-AnchorGroup {
<#
    .SYNOPSIS
    Returns a collection of AnchorGroup objects for a given AnchorGroup id or set of id's.

    .DESCRIPTION
    Returns a collection of AnchorGroup objects.
    Accepts one or more AnchorGroup id's via argument or a colleciton of AnchorGroup objects from the pipeline.

    .NOTES
    
    .PARAMETER id
    One or more AnchorGroup id's.

    .PARAMETER Expand
    If TRUE, properties are added to the output object which contain the text value of the company_name.

    .INPUTS
    A collection of AnchorGroup objects

    .OUTPUTS
    A collection of AnchorGroup objects


    .LINK
    http://developer.anchorworks.com/v2/#get-a-group

#>
    [CmdletBinding()]
    [Alias('AnchorGroup')]
    param(
        [Parameter(ParameterSetName='ById',Position=0,ValueFromPipelineByPropertyName)][string[]]$id,
        [Parameter(HelpMessage='Add names of objects referenced in the returned object')][switch]$Expand
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        ForEach ($groupId in $id){
            $apiEndpoint = "group/$groupId"
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
            #Adding a PowerShell-friendly created date field 
            $myCreatedDate = $results.created
            $myCreatedPSDate = Get-Date("$myCreatedDate`-00:00")
            $results | Add-Member -MemberType NoteProperty -Name 'created(local_offset)' -Value $myCreatedPSDate
            If($Expand){
                #$myPersonId = $results.creator_id
                #$myCreator = [string]$(Get-AnchorPerson -id $myPersonId).display_name
                #$results | Add-Member -MemberType NoteProperty -Name 'creator_name' -Value $myCreator
                $myCompanyId = $results.company_id
                $myCompany = [string]$(Get-AnchorOrg -id $myCompanyId).name
                $results | Add-Member -MemberType NoteProperty -Name 'company_name' -Value $myCompany
            }
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

Function Get-AnchorGroupMembers {
# http://developer.anchorworks.com/v2/#list-group-members
# subscribers are returned in a three-tuple format that is not object-friendly. Need to work on converting this.
# Accessing the elements of the tuple goes something like this: $results.group_subscribers[0][0]
# May have to rebuild the entire object from scratch.
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Group ID')][string[]]$id,
        [Parameter(HelpMessage='Return individual subscribers from groups')][switch]$IncludeFromGroup,
        [Parameter(HelpMessage='Return expanded output (person and group names)')][switch]$Expand
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiQuery = @{
            'include_from_group' = "$(If($IncludeFromGroup){"true"}Else{"false"})"
        }
    }
    process{
        $groupId = $id
        $apiEndpoint = "group/$groupId/members"
        $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
        If($expand){
            $cleanedResults = [pscustomobject]@{}
            foreach ($property in $results.PSObject.Properties){
                $myName = $property.Name
                $myMembers = @()
                Switch ($property.Name -match 'member_groups'){
                    $true {
                        foreach ($node in $property.Value) {
                            foreach($myId in $node){
                                Write-Verbose $myId
                                $myMemberName = (Get-AnchorGroup -id $myId).name
                                $myMember = [pscustomobject]@{}
                                $myMember | Add-Member -MemberType NoteProperty -Name 'id' -Value $myId
                                $myMember | Add-Member -MemberType NoteProperty -Name 'display_name' -Value $myMemberName
                                $myMembers += $myMember
                            }
                        }
                    }
                    $false { 
                        foreach ($node in $property.Value) {
                            foreach($myId in $node){
                                Write-Verbose $myId
                                $myMemberName = (Get-AnchorPerson -id $myId).display_name
                                $myMember = [pscustomobject]@{}
                                $myMember | Add-Member -MemberType NoteProperty -Name 'id' -Value $myId
                                $myMember | Add-Member -MemberType NoteProperty -Name 'display_name' -Value $myMemberName
                                $myMembers += $myMember
                            }
                        }
                    }
                }
                $cleanedResults | Add-Member -MemberType NoteProperty -Name $myName -Value $myMembers
            }
            $cleanedResults
        }
        Else{
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

# Guest Functions

Function Get-AnchorGuest {
<#
    .SYNOPSIS
    Returns a collection of AnchorGuest objects for a given AnchorGuest id or set of id's or a given email address or set of email addresses.

    .DESCRIPTION
    Returns a collection of AnchorGuest objects.
    Accepts one or more AnchorGuest id's via argument or a colleciton of AnchorGuest objects from the pipeline.
    Accepts one or more email addresses via argument or a colleciton of AnchorGuest objects from the pipeline.

    .NOTES
    
    .PARAMETER id
    One or more AnchorGuest id's.

    .PARAMETER ByEmail
    Changes the functionality of the function to accept email address instead of id.

    .PARAMETER Expand
    If TRUE, properties are added to the output object which contain the text value of the comapny_name and creator_name.

    .INPUTS
    A collection of AnchorPerson objects

    .OUTPUTS
    A collection of AnchorPerson objects


    .LINK
    http://developer.anchorworks.com/v2/#get-a-guest

    .LINK
    Get-AnchorOauthToken
#>
    [CmdletBinding()]
    [Alias('AnchorGuest')]
    param(
        [Parameter(ParameterSetName='ById',Position=0,ValueFromPipelineByPropertyName)][string[]]$id,
        [Parameter(ParameterSetName='ByEmail',Position=0,ValueFromPipelineByPropertyName)][string[]]$email,
        [Parameter(ParameterSetName='ByEmail',Position=1,HelpMessage='Accept email address instead of person id.')][switch]$ByEmail,
        [Parameter(HelpMessage='Add names of objects referenced in the returned object')][switch]$Expand
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        If($ByEmail){
            ForEach ($emailAddr in $email){
                $apiEndpoint = "guest/$emailAddr"
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
                If($Expand){
                    $myOrgId = $results.company_id
                    $myPersonId = $results.creator_id
                    $myCompany = [string]$(Get-AnchorOrg -id $myOrgId).name
                    $myCreator = [string]$(Get-AnchorPerson -id $myPersonId).display_name
                    $results | Add-Member -MemberType NoteProperty -Name 'company_name' -Value $myCompany
                    $results | Add-Member -MemberType NoteProperty -Name 'creator_name' -Value $myCreator
                }
                $results
            }
        } Else {
            ForEach ($guestId in $id){
                $apiEndpoint = "guest/$guestId"
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
                If($Expand){
                    $myOrgId = $results.company_id
                    $myPersonId = $results.creator_id
                    $myCompany = [string]$(Get-AnchorOrg -id $myOrgId).name
                    $myCreator = [string]$(Get-AnchorPerson -id $myPersonId).display_name
                    $results | Add-Member -MemberType NoteProperty -Name 'company_name' -Value $myCompany
                    $results | Add-Member -MemberType NoteProperty -Name 'creator_name' -Value $myCreator
                }
                $results
            }
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

Function Get-AnchorGuestFileShares {
<#
    .SYNOPSIS
    Returns a collection of AnchorFileShare objects for a given AnchorGuest id or set of id's.

    .DESCRIPTION
    Returns a collection of AnchorFileShare objects.
    Accepts one or more AnchorGuest id's via argument or a colleciton of AnchorGuest objects from the pipeline.

    .NOTES
    
    .PARAMETER id
    One or more AnchorGuest id's.

    .PARAMETER Expand
    If TRUE, properties are added to the output object which contain the text value of the creator_name.

    .INPUTS
    A collection of AnchorGuest objects

    .OUTPUTS
    A collection of AnchorFileShare objects


    .LINK
    http://developer.anchorworks.com/v2/#get-files-and-folders-shared-with-a-guest

#>
    [CmdletBinding()]
    [Alias('AnchorGuestShares')]
    param(
        [Parameter(ParameterSetName='ById',Position=0,ValueFromPipelineByPropertyName)][string[]]$id,
        [Parameter(HelpMessage='Add names of objects referenced in the returned object')][switch]$Expand
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        ForEach ($guestId in $id){
            $apiEndpoint = "guest/$guestId"
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
            #Adding a PowerShell-friendly created date field 
            $myCreatedDate = $results.created
            $myCreatedPSDate = Get-Date("$myCreatedDate`-00:00")
            $results | Add-Member -MemberType NoteProperty -Name 'created(local_offset)' -Value $myCreatedPSDate
            If($Expand){
                $myPersonId = $results.creator_id
                $myCreator = [string]$(Get-AnchorPerson -id $myPersonId).display_name
                $results | Add-Member -MemberType NoteProperty -Name 'creator_name' -Value $myCreator
                $myCompanyId = $results.company_id
                $myCompany = [string]$(Get-AnchorOrg -id $myCompanyId).name
                $results | Add-Member -MemberType NoteProperty -Name 'company_name' -Value $myCompany
            }
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

# Root Functions

Function Get-AnchorRootMetadata {
<#
    .NOTES
    The -Include* switches must be explicitly called, despite the fact that some are on by default in the API.

#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Root ID')][string[]]$id, 
        [Parameter(HelpMessage='Include collection of child objects (files and folders)')][switch]$IncludeChildren,
        [Parameter(HelpMessage='Include deleted items in child objects')][switch]$IncludeDeleted,
        [Parameter(HelpMessage='Include information about locks')][switch]$IncludeLockInfo,
        [Parameter(HelpMessage='Include collection of permissions for current user')][switch]$IncludePermissions,
        [Parameter(HelpMessage='Hash value returned from previous call to this endpoint. If hash is identical, return will include root id and a "modified" property with a value of false, indicating that the children have not been modified.')][ValidateLength(40,40)][string]$Hash,
        [Parameter()][switch]$NoRefreshToken
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
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
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery -NoRefreshToken
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
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Find-RootFilesAndFolders {
<#
    .LINK
    http://developer.anchorworks.com/v2/#search-files-and-folders
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Root ID')][string[]]$id, 
        [Parameter(HelpMessage='Search term')][string]$SearchTerm
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiQuery = @{
            'q' = $SearchTerm
        }
    }
    process{
        foreach ($rootId in $id){
            $apiEndpoint = "files/$rootId/search"
            try{
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
            }
            catch{
                Switch -regex ($Error[0].Exception){
                    default {Write-Host $error[0].Exception}
                }
            }
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorRootFilesModifiedSince {
<#
    .SYNOPSIS
    Returns file objects that have been modified since a given date.

    .DESCRIPTION
    Returns file objects that have been modified since a given date.
    Accepts a collection of AnchorRoot objects from the pipeline or a number of AnchorRootId strings in the arguments, as well as a DateTime from which to begin the search.
    
    .NOTES
    (As of at least 2020-01-19) there seems to be a discrepency between the 'since' date in the API call, and the 'modified' property of the files, as you can receive files with 'modified' dates prior to the 'since' date.

    .PARAMETER id
    AnchorRoot id number. Can accept an array of id numbers.

    .PARAMETER Since
    PowerShell DateTime object indicating the oldest modified file to return.

    .INPUTS
    AnchorRoot object, containing at least the .id property.

    .OUTPUTS
    AnchorFile objects

    .EXAMPLE
    C:\PS> Get-AnchorRootFilesModifiedSince -id 123456 -Since (Get-Date).AddDays(-7)
    created        : 2020-01-15T20:45:03
    id             : 33219
    is_deleted     : False
    is_locked      : False
    locks          : {}
    modified       : 2020-01-15T20:45:03
    path           : /ATT00/00426820200115155049001.pdf
    revision_id    : 34387
    root_id        : 123456
    size           : 258338
    size_formatted : 252.28 KB
    type           : file
    (...)

    .EXAMPLE
    C:\PS> Get-AnchorRootFilesModifiedSince -id 123456, 123457 -Since (Get-Date).AddDays(-7)
    created        : 2020-01-15T20:45:03
    id             : 33219
    is_deleted     : False
    is_locked      : False
    locks          : {}
    modified       : 2020-01-15T20:45:03
    path           : /ATT00/00426820200115155049001.pdf
    revision_id    : 34387
    root_id        : 123456
    size           : 258338
    size_formatted : 252.28 KB
    type           : file
    (...)

    .EXAMPLE
    C:\PS> Get-AnchorRootFilesModifiedSince -id $myIdArray -Since (Get-Date).AddDays(-7)
    created        : 2020-01-15T20:45:03
    id             : 33219
    is_deleted     : False
    is_locked      : False
    locks          : {}
    modified       : 2020-01-15T20:45:03
    path           : /ATT00/00426820200115155049001.pdf
    revision_id    : 34387
    root_id        : 123456
    size           : 258338
    size_formatted : 252.28 KB
    type           : file
    (...)

    .EXAMPLE
    C:\PS> $myAnchorRoots | Get-AnchorRootFilesModifiedSince -Since (Get-Date).AddDays(-7)
    created        : 2020-01-15T20:45:03
    id             : 33219
    is_deleted     : False
    is_locked      : False
    locks          : {}
    modified       : 2020-01-15T20:45:03
    path           : /ATT00/00426820200115155049001.pdf
    revision_id    : 34387
    root_id        : 123456
    size           : 258338
    size_formatted : 252.28 KB
    type           : file
    (...)

    .LINK
    API reference: http://developer.anchorworks.com/v2/#list-recently-modified-files

    .LINK
    Get-AnchorOauthToken
#>
    [CmdletBinding()]
    [Alias("AnchorRootModSince")]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor root id')][string[]]$id,
        [Parameter(Mandatory,Position=1,HelpMessage='PowerShell DateTime object indicating the oldest modified file to return')][datetime]$Since
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiQuery = @{'since' = "$(Get-Date($Since) -Format 'yyyy-MM-ddThh:mm:ss')"}
    }
    process{
        foreach ($rootId in $id){
            $apiEndpoint = "files/$rootId/modified_since"
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorRootLastModified {
<#
    .SYNOPSIS
    Returns the last time any file in a root was modified.

    .DESCRIPTION
    Returns the last time any file in a root was modified.
    Accepts a collection of AnchorRoot objects from the pipeline or a number of AnchorRootId strings in the arguments.
    
    .NOTES
    If no files are found that have been modified in the last 5.6 years, the .modified value returned will be 'no_files_found'.
    If there is an error while calling the API, including a timeout, the .modified value returned will be 'api_error'.
    (As of at least 2020-01-19) there seems to be a discrepency between the 'since' date in the API call, and the 'modified' property of the files, as you can receive files with 'modified' dates prior to the 'since' date.

    .PARAMETER id
    AnchorRoot id number. Can accept an array of id numbers.

    .PARAMETER MaxThreads
    The modified_since API call can be time-consuming for roots with many files. When checking multiple roots, each root is devoted its own PowerShell runspace. This parameter controls how many runspaces are allowed to exist at a time. Default is 100.

    .INPUTS
    AnchorRoot object, containing at least the .id property.

    .OUTPUTS
    A collection of objects listing the root ID and the last time a file was modified in that root.

    .EXAMPLE
    C:\PS> Get-AnchorRootLastModified -id 123456
        id modified           
        -- --------           
    123456 2020-01-20T11:30:01

    .EXAMPLE
    C:\PS> Get-AnchorRootLastModified -id 123456, 123457
        id modified           
        -- --------           
    123456 2020-01-20T11:30:01
    123457 2020-01-20T04:05:03

    .EXAMPLE
    C:\PS> Get-AnchorRootFilesModifiedSince -id $myIdArray
        id modified           
        -- --------           
    487079 2020-01-20T11:30:01
    488087 2020-01-20T04:05:03
    488699 2004-09-17T16:45:20
    (...)

    .EXAMPLE
    C:\PS> $myAnchorRoots | Get-AnchorRootLastModified
        id modified           
        -- --------           
    487079 2020-01-20T11:30:01
    488087 2020-01-20T04:05:03
    488699 2004-09-17T16:45:20
    (...)

    .LINK
    API reference: http://developer.anchorworks.com/v2/#list-recently-modified-files

    .LINK
    Get-AnchorOauthToken
#>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor root id')][string[]]$id,
        [Parameter(ValueFromPipelineByPropertyName,Position=1,HelpMessage='RegEx string or array of Regex strings defining a pattern of root names to ignore')][string[]]$IgnorePath,
        [Parameter(ValueFromPipelineByPropertyName,Position=2,HelpMessage='Maximum number of days to look back when searching for modified files')][int]$MaxLookback=32,
        [Parameter(Position=3,HelpMessage='Number of threads to use when querying multiple roots. Default = number of processors + 1')][int]$MaxThreads = $env:NUMBER_OF_PROCESSORS + 1
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        [string]$ignorePathString = $IgnorePath -join '|'
        #region BLOCK 1: Create and open runspace pool, setup runspaces array with min and max threads
        #   Special thanks to Chrissy LeMaire (https://blog.netnerds.net/2016/12/runspaces-simplified/) for helping me to (sort of) understand how to utilize runspaces.

        # Custom functions are not available to runspaces. 🤦‍
        # We need to import some custom functions and script variables into the runspacepool, so we'll have to jump through hoops now.
        #   https://stackoverflow.com/questions/51818599/how-to-call-outside-defined-function-in-runspace-scriptblock
        $bagOfFunctions = @(
            'Get-AnchorData',
            'Validate-AnchorOauthToken',
            'Refresh-AnchorOauthToken',
            'Get-AnchorOauthStatus',
            'Get-AnchorRootMetadata'
        )
        $bagOfVariables = @(
            'apiUri',
            'MaxLookback',
            'IgnorePath'
        )

        $InitialSessionState = [initialsessionstate]::CreateDefault() #CreateDefault is important. If we just use Create, it creates a blank-slate session that has almost no functionality.
        foreach ($function in $bagOfFunctions){
            #Get body of function
            $functionDefinition = Get-Content "Function:\$function" -ErrorAction Stop
            #Create a sessionstate function entry
            $SessionStateFunction = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList "$function", $functionDefinition
            #Create a SessionStateFunction
            $InitialSessionState.Commands.Add($SessionStateFunction)
        }
        foreach ($varName in $bagOfVariables){
            #Get variable
            $variable = Get-Variable -Name $varName
            #Create a sessionstate variable entry
            $SessionStateVariable = New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry($variable.Name, $variable.Value, $null)
            #Create a SessionStateVariable
            $InitialSessionState.Variables.Add($SessionStateVariable)
        }
        # End Hoops

        # Now back to our regularly scheduled runspace pool creation
        Write-Verbose "Creating runspace pool with $MaxThreads concurrent threads."
        $pool = [RunspaceFactory]::CreateRunspacePool(1,$MaxThreads,$InitialSessionState,$Host)
        $pool.ApartmentState = "MTA"
        $pool.Open()
        $runspaces = @()
        #endregion

        #region BLOCK 2: Create reusable scriptblock. This is the workhorse of the runspace. Think of it as a function.
        
        $scriptblock = {
            Param (
                [string]$rootId,
                [object]$OauthToken,
                [string]$IgnorePathString,
                [int]$MaxLookback
            )
            $Global:anchorOauthToken = $OauthToken
            # First, let's see if we can ignore this root.
            $root = Get-AnchorRootMetadata -id $rootId -NoRefreshToken
            If($IgnorePathString -and ($root.name -match $ignorePathString)){$ignoreByPath=$true}
            If($root.space_used -eq 0){$ignoreByEmpty=$true}
            If($false){$ignoreByRootId=$true} #placeholder for later feature
            If($ignoreByPath -or $ignoreByEmpty -or $ignoreByRootId){
                If($ignoreByPath){
                    [PSCustomObject]@{id = $rootId;modified='ignored_by_name'; 'lookback_days'=$null;itterations=0}
                }
                ElseIf($ignoreByEmpty){
                    [PSCustomObject]@{id = $rootId;modified='empty_root'; 'lookback_days'=$null;itterations=0}
                }
            }
            Else{

                $apiEndpoint = "files/$rootId/modified_since"
                #$lookBackDays = -1 #Initialize
                #We want to start with a number that's less than or equal to 1 day and end up on the exact number specified in the function call.
                $lookBackDays = -($MaxLookback) #Don't forget, we need to use negative numbers                
                While($lookBackDays -lt -1){
                    $lookBackDays = $lookBackDays / 2
                }
                [datetime]$now = Get-Date
                [int]$i=0
                Do{
                    $i++
                    [datetime]$mySince = $now.AddDays($lookBackDays)
                    $apiQuery = @{'since' = "$(Get-Date($mySince) -Format 'yyyy-MM-ddThh:mm:ss')"}
                
                    try {
                        $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery -NoRefreshToken #Adding NoRefreshToken, because it doesn't work within a runspace.
                    } catch {
                        [PSCustomObject]@{id = $rootId;modified='api_error';lookback_days = $lookBackDays;itterations=$i}
                        $halt = $true
                    }
                    #Return the results here.
                    $results | Sort-Object -Property modified -Descending | Select-Object root_id, modified -First 1 | Add-Member -MemberType AliasProperty -Name id -Value root_id -PassThru | Select-Object id, modified | Add-Member -MemberType NoteProperty -Name 'lookback_days' -Value $lookBackDays -PassThru | Add-Member -MemberType NoteProperty -Name 'itterations' -Value $i -PassThru
                    $lookBackDays = $lookBackDays * 2
                }Until($results -or ($lookBackDays -lt -($MaxLookback)) -or $halt) # Remember, we're counting backward.
                If (!$results -and !$halt){
                    [PSCustomObject]@{id = $rootId;modified='no_modified_files'; 'lookback_days'=($lookBackDays/2);itterations=$i}
                }
            }
        }
        #endregion
    }
    process{
        foreach ($rootId in $id){
            #region BLOCK 3: Create runspace and add to runspace pool
            $runspaceParams = @{'rootId'="$rootId";'OauthToken'=$Global:anchorOauthToken; 'IgnorePathString'=$ignorePathString; 'MaxLookback'=$MaxLookback}
            $runspace = [PowerShell]::Create()
            $null = $runspace.AddScript($scriptblock)
            $null = $runspace.AddParameters($runspaceParams)
            $runspace.RunspacePool = $pool
            #endregion

            #region BLOCK 4: Add runspace to runspaces collection and "start" it
            # Asynchronously runs the commands of the PowerShell object pipeline
            $runspaces += [PSCustomObject]@{ Pipe = $runspace; Status = $runspace.BeginInvoke() }
            #endregion
        }
    }
    end{
        #region BLOCK 5: Wait for runspaces to finish
        Write-Verbose "Created $($runspaces.Count) PowerShell runspaces. Awaiting completion of all runspaces."
        while ($runspaces.Status -ne $null){
            $completed = $runspaces | Where-Object { $_.Status.IsCompleted -eq $true }

            #Monitor
            $notCompleted = $runspaces | Where-Object { $_.Status.IsCompleted -eq $false }
            [int]$notCompletedCount = $notCompleted.Count
            Write-Progress -Activity "Roots remaining to analyze (out of $($runspaces.Count))..." -Status $($notCompletedCount) -PercentComplete (($notCompletedCount / $runspaces.Count) * 100) -ErrorAction SilentlyContinue
            #End Monitor

            foreach ($runspace in $completed)
            {
                $runspace.Pipe.EndInvoke($runspace.Status)
                $runspace.Status = $null
            }
        }
        Write-Verbose "All runspaces complete."
        #endregion

        #region BLOCK 6: Clean up
        $pool.Close() 
        $pool.Dispose()
        #endregion
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

#region DEPRECATED FUNCTIONS

Function Get-AnchorOrgMachinesOLD {
<#
    .SYNOPSIS
    Returns AnchorMachine objects for a given AnchorOrganization.

    .DESCRIPTION
    Accepts a collection of AnchorOrganization objects from the pipeline or a number of AnchorOrganization id strings in the arguments.
    Returns a collection of AnchorMachine objects.
    
    .NOTES
    The owning company_id is not returned in the API call, so we add it from the supplied value.
    Also, the API call returns all machines from the organization and all child organizations.
    Therefore, the company_id does not always represent the owning organization of a particular machine.
    Use the -ExcludeChildren property to return machines that are not from child organizations.

    .PARAMETER id
    AnchorOrganization id number. Can accept an array of id numbers.

    .PARAMETER ExcludeChildren
    Do not return machines from child organizations.
    (This functionality is not part of the API. In order to achieve this, we have to make an additional API call to get the children of the given organization, then an API call for each child to get the machines. We then select only the machines that do not appear in the list of child organization machines.)

    .PARAMETER IncludeApiMachines
    Each time a machine is granted an Oauth token through the API, it creates a machine record that gets returned as part of the collection of machines.
    This function discards these API machine objects by default.
    This switch causes these objects to be returned.
    (This functionality is not part of the API, and there is no property to determine this type of machine. In order to achieve this, we exclude machines where agent_version -eq $null -and machine_type -eq 'agent' -and os_type -eq $null.)

    .INPUTS
    AnchorOrganization object, containing at least the .id property.

    .OUTPUTS
    A collection of AnchorMachine objects.

    .EXAMPLE
    C:\PS> Get-AnchorOrgMachines -id 123456
    agent_version                : 2.7.1.1550
    bandwidth_throttle           : 
    created                      : 2019-12-26T15:08:29
    dns_name                     : PC001
    guid                         : c5b26ffc-xxxx-40da-b4d9-a76b636816e0
    health_report_period_minutes : 
    id                           : 132465
    last_disconnect              : 
    last_login                   : 2020-01-20T10:57:44
    locked                       : False
    machine_type                 : server
    manual_collisions            : False
    nickname                     : 
    os_type                      : win
    os_version                   : Windows Server 2016
    throttle_exception_days      : 
    throttle_exception_dow       : 
    throttle_exception_end       : 
    throttle_exception_start     : 
    throttle_exception_throttle  : 
    throttled                    : False
    type                         : machine
    company_id              : 123456

    .EXAMPLE
    C:\PS> Get-AnchorOrgMachines -id 123456, 123457 -ExcludeChildren
    agent_version                : 2.7.1.1550
    bandwidth_throttle           : 
    created                      : 2019-12-26T15:08:29
    dns_name                     : PC001
    guid                         : c5b26ffc-xxxx-40da-b4d9-a76b636816e0
    health_report_period_minutes : 
    id                           : 132465
    last_disconnect              : 
    last_login                   : 2020-01-20T10:57:44
    locked                       : False
    machine_type                 : server
    manual_collisions            : False
    nickname                     : 
    os_type                      : win
    os_version                   : Windows Server 2016
    throttle_exception_days      : 
    throttle_exception_dow       : 
    throttle_exception_end       : 
    throttle_exception_start     : 
    throttle_exception_throttle  : 
    throttled                    : False
    type                         : machine
    company_id              : 123456
    (...)

    .EXAMPLE
    C:\PS> $anchorOrganizations | Get-AnchorOrgMachines -ExcludeChildren
    agent_version                : 2.7.1.1550
    bandwidth_throttle           : 
    created                      : 2019-12-26T15:08:29
    dns_name                     : PC001
    guid                         : c5b26ffc-xxxx-40da-b4d9-a76b636816e0
    health_report_period_minutes : 
    id                           : 132465
    last_disconnect              : 
    last_login                   : 2020-01-20T10:57:44
    locked                       : False
    machine_type                 : server
    manual_collisions            : False
    nickname                     : 
    os_type                      : win
    os_version                   : Windows Server 2016
    throttle_exception_days      : 
    throttle_exception_dow       : 
    throttle_exception_end       : 
    throttle_exception_start     : 
    throttle_exception_throttle  : 
    throttled                    : False
    type                         : machine
    company_id              : 123456
    (...)

    .LINK
    API reference: http://developer.anchorworks.com/v2/#machine-methods

    .LINK
    Get-AnchorOauthToken
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true,Position=0,HelpMessage='Organization ID')][string[]]$id,
        [Parameter(Position=1,HelpMessage='Only return machines explicitly in this organization.')][switch]$ExcludeChildren,
        [Parameter(Position=2,HelpMessage='Return machines that have logged on via the API.')][switch]$IncludeApiMachines
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        #We might get multiple $id values from the parameter.
        ForEach ($orgId in $id){
            $apiEndpoint = "organization/$($orgId)/machines"
            $myMachines = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
            If($ExcludeChildren){
                $childOrgs = Get-AnchorOrgChildren -id $orgId
                If($childOrgs){
                    $childOrgMachines = $childOrgs | Get-AnchorOrgMachines #-IncludeApiMachines $IncludeApiMachines
                    $exclusiveMachines = Compare-Object $myMachines $childOrgMachines -Property id -PassThru | Where-Object SideIndicator -eq "<="
                    $results = $exclusiveMachines
                } else { # This org has no children, so we can just return the original list.
                    $results = $myMachines
                }
            } else {
                $results = $myMachines
            }
            # If there are no results, we don't want to return an empty object with just the organization property populated.
            If($results){
                # If more than one object is returned, we have to itterate.
                $results | ForEach-Object {
                    $_ | Add-Member -MemberType NoteProperty -Name 'last_login(local_offset)' -Value (Convert-UtcDateStringToLocalDateTime $_.last_login)
                    $_ | Add-Member -MemberType NoteProperty -Name 'created(local_offset)' -Value (Convert-UtcDateStringToLocalDateTime $_.created)
                    $_ | Add-Member -MemberType NoteProperty -Name 'last_disconnect(local_offset)' -Value (Convert-UtcDateStringToLocalDateTime $_.last_disconnect)
                    $_ | Add-Member -MemberType NoteProperty -Name 'company_id' -Value $orgId
                }
                If($IncludeApiMachines){
                    $results
                }
                Else{
                    $results | Where-Object {-not ($_.agent_version -eq $null -and $_.machine_type -eq 'agent' -and $_.os_type -eq $null)}
                }
            }
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}



#endregion