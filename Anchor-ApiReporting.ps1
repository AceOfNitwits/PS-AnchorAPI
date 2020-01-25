#region Credits and Documentation
# Bryan Sullo - bryan@clocktowertech.com
# Anchor API Documentation: http://developer.anchorworks.com/v2/

# Query parameters go in the body, formatted as a hash table @{"parameter_name"="value"}
# Format date parameters like this @{"since"=(Get-Date (Get-Date).AddDays(-1) -Format "yyyy-MM-ddThh:mm:ss")}

#endregion

Function Get-AnchorActivityTypes {
<#
    .LINK
    http://developer.anchorworks.com/v2/#get-a-list-of-activity-types
#>
    param(
        [Parameter(HelpMessage='Limits the number of objects to return to the next highest multiple of 100. Default:1000')][int]$RecordCountLimit
        
    )
    Update-AnchorApiReadiness
    $apiEndpoint = "activity/types"
    try{
        $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ResultsLimit $RecordCountLimit
    }
    catch{
        $exception = $_.Exception
        Switch ($exception.Response.StatusCode.value__){
            403 {$results=[pscustomobject]@{exception='unauthorized'}} # No soup for you!
            404 {$results=[pscustomobject]@{exception='nonexistent'}}
            default {$results = $exception}
        }
    }
    $results
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
    $results = Get-AnchorData -ApiEndpoint $apiEndPoint -OauthToken $Script:anchorOauthToken
    $results
    Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
}

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
            $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
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
            $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
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
            $results = Get-AnchorData -OauthToken $script:anchorOauthToken -ApiEndpoint $apiEndPoint
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
        $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
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
                $results = Get-AnchorData -OauthToken $script:anchorOauthToken -ApiEndpoint $apiEndPoint
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
                $results = Get-AnchorData -OauthToken $script:anchorOauthToken -ApiEndpoint $apiEndPoint
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
            $results = Get-AnchorData -OauthToken $script:anchorOauthToken -ApiEndpoint $apiEndPoint
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

Function Get-AnchorOrg {
<#
    .SYNOPSIS
    Returns a collection of AnchorOrg objects for a given AnchorOrg id or set of id's.

    .DESCRIPTION
    Returns a collection of AnchorOrg objects.
    Accepts one or more AnchorOrg id's via argument or a colleciton of AnchorOrg objects from the pipeline.

    .NOTES
    
    .PARAMETER id
    One or more AnchorOrg id's.

    .INPUTS
    A collection of AnchorOrg objects

    .OUTPUTS
    A collection of AnchorOrg objects

    .EXAMPLE
    C:\PS> Get-AnchorOrg -OauthToken $anchorOauthToken -id 321
    active                      : True
    bandwidth_throttle          : 
    created                     : 2013-03-19T01:07:00
    default_encryption          : 2
    description                 : 
    email                       : mailbox@domain.tld
    email_server_id             : 681
    email_templates             : True
    hostname                    : company.syncedtool.com
    i18n                        : @{id=321; locale=en; timezone=America/New_York;
                                  type=organization_i18n}
    id                          : 321
    locale                      : en
    name                        : Company, Inc.
    parent_id                   : 4871
    plan_id                     : 
    policy                      : @{ad_enabled=True; admin_browse_files=True; 
                                  admin_browse_remote=True; admin_create_users=True; 
                                  api_ratelimit=; api_ratelimit_enabled=False; 
                                  backups_enabled=True; backups_purge_deleted=True; 
                                  backups_purge_deleted_frequency=2555; 
                                  backups_trim_revisions=True; 
                                  backups_trim_revisions_frequency=2555; 
                                  branding_enabled=True; change_password_frequency=; 
                                  company_id=361; create_orgs_until=; 
                                  deactivate_token_frequency=; excluded_extensions=.$$,.$db,
                                  .113,.3g2,.3gp2,.3gpp,.3mm,.abc,.abf,.abk,.afm,.ani,.ann,.
                                  asf,.avs,.bac,.bck,.bcm,.bdb,.bdf,.bkf,.bkp,.blocked,.bmk,
                                  .bsc,.bsf,.cerber,.cf1,.chq,.chw,.cpl,.cry,.cur,.dev,.dfon
                                  t,.dmp,.dv,.dvd,.dvr,.dvr-ms,.evt,.ffa,.ffl,.ffo,.ffx,.flc
                                  ,.flv,.fnt,.fon,.ftg,.fts,.fxp,.grp,.hdd,.hxi,.hxq,.hxr,.h
                                  xs,.idb,.idx,.ilk,.ipf,.isp,.its,.jar,.jse,.kbd,.kext,.key
                                  ,.lex,.lib,.library-ms,.locky,.log,.lwfn,.m1p,.m1v,.m2p,.m
                                  2v,.m4v,.mem,.mov,.mp2v,.mpe,.mpeg,.mpv,.mpv2,.msc,.msm,.n
                                  cb,.nt,.nvram,.obj,.obs,.ocx,.old,.ost,.otf,.pch,.pf,.pfa,
                                  .pfb,.pfm,.pnf,.pol,.pref,.prf,.prg,.prn,.pvs,.pwl,.qt,.rd
                                  b,.rll,.rox,.sbr,.scf,.sdb,.shb,.silent,.suit,.swp,.theme,
                                  .tivo,.tmp,.tms,.ttc,.v2i,.vbe,.vga,.vgd,.vhd,.video,.vmc,
                                  .vmdk,.vmsd,.vmsn,.vmx,.win,.wpk; 
                                  file_server_enabled=True; locked_extensions=.doc,.docx,.xl
                                  s,.xlsx,.ppt,.pptx,.pdf,.txt,.xlsb,.xlsm,.csv,.docm,.dotx,
                                  .dotm,.pub,.wpd,.odt,.ott,.oth,.odm,.ots,.odp,.odg,.otp,.o
                                  df,.oxt,.odc,.ods,.vdx,.vsx,.vtx,.one; 
                                  max_file_size=25000; num_orgs_maximum=0; 
                                  num_users_maximum=185; num_users_minimum=0; 
                                  psa_enabled=True; purge_deleted=True; 
                                  purge_deleted_frequency=2555; require_mobile_lock=True; 
                                  require_two_step_auth=True; secure_shares=False; 
                                  service_plans_enabled=True; space_quota=194562018508800; 
                                  space_quota_formatted=176.95 TB; trial_length_days=0; 
                                  trim_revisions=True; trim_revisions_x=2555; type=policy; 
                                  user_create_backups=True; user_create_shares=True; 
                                  user_lock_files=True; user_overwrite_collisions=False; 
                                  user_purge_deleted=False; user_rollback=True; 
                                  user_trim_revisions=False; web_editor_enabled=True; 
                                  web_preview_enabled=True; web_wopi_enabled=false; 
                                  webdav_enabled=True}
    privacy_mode                : False
    share_disclaimer            : 
    slug                        : company
    subscription_uuid           : 
    throttle_exception_days     : 
    throttle_exception_dow      : 
    throttle_exception_end      : 
    throttle_exception_start    : 
    throttle_exception_throttle : 
    throttled                   : False
    timezone                    : America/New_York
    trial_until                 : 
    type                        : organization

    .EXAMPLE
    C:\PS> $anchorOrgs | Get-AnchorOrg -OauthToken $anchorOauthToken
    active                      : True
    bandwidth_throttle          : 
    created                     : 2013-03-19T01:07:00
    default_encryption          : 2
    description                 : 
    email                       : mailbox@domain.tld
    email_server_id             : 681
    email_templates             : True
    hostname                    : company.syncedtool.com
    i18n                        : @{id=321; locale=en; timezone=America/New_York;
                                  type=organization_i18n}
    id                          : 321
    locale                      : en
    name                        : Company, Inc.
    parent_id                   : 4871
    plan_id                     : 
    policy                      : @{ad_enabled=True; admin_browse_files=True; 
    (...)

    .LINK
    http://developer.anchorworks.com/v2/#get-an-organization

    .LINK
    Get-AnchorOauthToken
#>
    [CmdletBinding()]
    [Alias('AnchorOrg')]
    param(
        [Parameter(ParameterSetName='Standard',Mandatory=$true,Position=0,ValueFromPipelineByPropertyName)][string[]]$id,
        [Parameter(ParameterSetName='FindTop',Mandatory=$true,Position=0,HelpMessage='Get the top-level organization for this user.')][switch]$Top
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        If($Top){
            $anchorUser = Get-AnchorPerson -Me
            $id = $anchorUser.company_id
        }
    }
    process{
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        ForEach ($orgId in $id){
            $apiEndpoint = "organization/$orgId"
            $results = Get-AnchorData -OauthToken $script:anchorOauthToken -ApiEndpoint $apiEndPoint
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgActivity {
<#
    .LINK
    http://developer.anchorworks.com/v2/#list-recent-activity-for-an-organization
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$id,
        [Parameter(HelpMessage='Limits the number of objects to return to the next highest multiple of 100. Default:1000')][int]$RecordCountLimit
        
    )
    # The activities that will be reutrned have numeric activity types.
    #   It might be nice to add the activity names to the resulting object.
    #   To do this, we're ging to put all the activity id's and names into a hash table.
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $activityTypes = Get-AnchorActivityTypes | Select-Object id, activity
        $activityTypesHash = @{}
        $activityTypes | ForEach-Object {
            $activityTypesHash[$_.id] = $_.activity
        }

    }
    process{
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$OrgId/activity"
            try{
                $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ResultsLimit $RecordCountLimit
                $results = $results | Select-Object *, @{N='activity';E={$activityTypesHash[$_.activity_type_id]}}
            }
            catch{
                $exception = $_.Exception
                Switch ($exception.Response.StatusCode.value__){
                    403 {$results=[pscustomobject]@{exception='unauthorized'}}
                    404 {$results=[pscustomobject]@{exception='nonexistent_id'}}
                    default {$results = $exception}
                }
            }
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgAuthSources {
<#
    .LINK
    http://developer.anchorworks.com/v2/#list-an-organization's-authentication-sources
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$id
        
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$OrgId/auth_sources"
            try{
                $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint
            }
            catch{
                $exception = $_.Exception
                Switch ($exception.Response.StatusCode.value__){
                    403 {$results=[pscustomobject]@{exception='unauthorized'}}
                    404 {$results=[pscustomobject]@{exception='nonexistent_id'}}
                    default {$results = $exception}
                }
            }
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgChildren {
# Accepts an AnchorOrg object or collection of AnchorOrg objects.
# Returns AnchorOrg objects.
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$id
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        #There may be multiple $id values passed by the function -id parameter
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$orgId/organizations"
            $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndPoint
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgMachines {
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
        [Parameter(Position=1,HelpMessage='Only return machines explicitly in this organization.')][switch]$ExcludeChildren
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        #We might get multiple $id values from the parameter.
        ForEach ($orgId in $id){
            $apiEndpoint = "organization/$($orgId)/machines"
            $myMachines = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndPoint
            If($ExcludeChildren){
                $childOrgs = Get-AnchorOrgChildren -id $orgId
                If($childOrgs){
                    $childOrgMachines = $childOrgs | Get-AnchorOrgMachines
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
                $results | Select-Object *, @{N='company_id';E={"$orgId"}} #, @{N='org_name';E={$orgName}}
            }
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgRoots {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$id
        
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$OrgId/roots"
            try{
                $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint
            }
            catch{
                $exception = $_.Exception
                Switch ($exception.Response.StatusCode.value__){
                    403 {$results=[pscustomobject]@{exception='unauthorized'}}
                    404 {$results=[pscustomobject]@{exception='nonexistent_id'}}
                    default {$results = $exception}
                }
            }
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgShare {
# http://developer.anchorworks.com/v2/#get-a-share
# This doesn't seem to return anything different than Get-AnchorRootMetadata -IncludeLockInfo.
#   The major difference is it requires two parameters, making it harder to use, and it returns an error if the root specified is not a share.
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$company_id,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor Root ID')][string[]]$id
        
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        $orgId = $company_id
        $rootId = $id
        $apiEndpoint = "organization/$orgId/share/$rootId"
        $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint
        $results
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgShares {
# http://developer.anchorworks.com/v2/#list-an-organization's-shares
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$id
        
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$OrgId/shares"
            $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgShareSubscribers {
# http://developer.anchorworks.com/v2/#list-share-subscribers
# subscribers are returned in a three-tuple format that is not object-friendly. Need to work on converting this.
# Accessing the elements of the tuple goes something like this: $results.group_subscribers[0][0]
# May have to rebuild the entire object from scratch.
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$company_id,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor Root ID')][string[]]$id,
        [Parameter(HelpMessage='Return individual subscribers from groups')][switch]$IncludeFromGroup,
        [Parameter(HelpMessage='Return unmodified output (with 3-tuples for subscribers) instead of object-formatted output')][switch]$Raw
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiQuery = @{
            'include_from_group' = "$(If($IncludeFromGroup){"true"}Else{"false"})"
        }
    }
    process{
        $orgId = $company_id
        $rootId = $id
        $apiEndpoint = "organization/$orgId/share/$rootId/subscribers"
        $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
        If($Raw){ # I'm sorry I ever made this option.
            $results
        }
        Else{
            #Loose your mind...
            $cleanedResults = [pscustomobject]@{}
            foreach ($property in $results.PSObject.Properties){
                $myName = $property.Name
                $mySubscribers = @()
                Switch ($property.Name){
                    'external_subscribers' { #These are formatted differently in a dictionary, which is sort of like a hashtable, but not at all compatible with PowerShell.
                        $property.Value.PSObject.Properties | ForEach-Object {
                            $myEmail = $_.Name
                            $myResponse = $_.Value
                            $mySubscriber = [pscustomobject]@{}
                            $mySubscriber | Add-Member -MemberType NoteProperty -Name 'email' -Value $myEmail
                            $mySubscriber | Add-Member -MemberType NoteProperty -Name 'response' -Value $myResponse
                            $mySubscribers += $mySubscriber
                        }
                    }
                    {($_ -eq 'from_group') -or ($_ -eq 'group_subscribers') -or ($_ -eq 'subscribers')} { # These are all formatted in three-tuple arrays, which are not all that easy to use in PowerShell.
                        foreach ($tuple in $property.value){
                            $myId = $tuple[0]
                            If($tuple[1] -is [int]){ # It's a number, which is a machine_id
                                $myMachine = $tuple[1]
                                $mySubscriptionType = 'machine'
                            }
                            Else{
                                $mySubscriptionType =$tuple[1]
                                $myMachine = $null
                            }
                            $myPermissions = $tuple[2]
                            $mySubscriber = [pscustomobject]@{}
                            $mySubscriber | Add-Member -MemberType NoteProperty -Name 'id' -Value $myId
                            $mySubscriber | Add-Member -MemberType NoteProperty -Name 'subscription_type' -Value $mySubscriptionType
                            $mySubscriber | Add-Member -MemberType NoteProperty -Name 'machine_id' -Value $myMachine
                            $mySubscriber | Add-Member -MemberType NoteProperty -Name 'permissions' -Value $myPermissions
                            $mySubscribers += $mySubscriber
                        }
                    }
                }
                $cleanedResults | Add-Member -MemberType NoteProperty -Name $myName -Value $mySubscribers
            }
            $cleanedResults
            # There. I fixed it for you.
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgUsers {
<#
    .LINK
    http://developer.anchorworks.com/v2/#list-an-organization's-users
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$id
        
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$OrgId/persons"
            try{
                $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint
            }
            catch{
                $exception = $_.Exception
                Switch ($exception.Response.StatusCode.value__){
                    403 {$results=[pscustomobject]@{exception='unauthorized'}}
                    404 {$results=[pscustomobject]@{exception='nonexistent_id'}}
                    default {$results = $exception}
                }
            }
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgGuests {
<#
    .LINK
    http://developer.anchorworks.com/v2/#list-an-organization's-guests
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$id,
        [Parameter(HelpMessage='Limits the number of objects to return to the next highest multiple of 100. Default:1000')][int]$RecordCountLimit
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$OrgId/guests"
            try{
                $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ResultsLimit $RecordCountLimit
            }
            catch{
                $exception = $_.Exception
                Switch ($exception.Response.StatusCode.value__){
                    403 {$results=[pscustomobject]@{exception='unauthorized'}}
                    404 {$results=[pscustomobject]@{exception='nonexistent_id'}}
                    default {$results = $exception}
                }
            }
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgGroups {
<#
    .LINK
    http://developer.anchorworks.com/v2/#list-an-organization's-groups
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$id
        
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$OrgId/groups"
            try{
                $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint
            }
            catch{
                $exception = $_.Exception
                Switch ($exception.Response.StatusCode.value__){
                    403 {$results=[pscustomobject]@{exception='unauthorized'}}
                    404 {$results=[pscustomobject]@{exception='nonexistent_id'}}
                    default {$results = $exception}
                }
            }
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgUsage {
<#
    .LINK
    http://developer.anchorworks.com/v2/#get-usage-for-an-organization
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$id,
        [Parameter(HelpMessage='Limits the number of objects to return to the next highest multiple of 100. Default:1000')][int]$RecordCountLimit
        
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$OrgId/metrics/usage"
            try{
                $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ResultsLimit $RecordCountLimit
                $results = $results | Select-Object *, @{N='activity';E={$activityTypesHash[$_.activity_type_id]}}
            }
            catch{
                $exception = $_.Exception
                Switch ($exception.Response.StatusCode.value__){
                    403 {$results=[pscustomobject]@{exception='unauthorized'}}
                    404 {$results=[pscustomobject]@{exception='nonexistent_id'}}
                    default {$results = $exception}
                }
            }
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorPerson {
<#
    .SYNOPSIS
    Returns a collection of AnchorPerson objects for a given AnchorPerson id or set of id's or a given email address or set of email addresses.

    .DESCRIPTION
    Returns a collection of AnchorPerson objects.
    Accepts one or more AnchorPerson id's via argument or a colleciton of AnchorPerson objects from the pipeline.
    Accepts one or more email addresses via argument or a colleciton of AnchorPerson objects from the pipeline.

    .NOTES
    
    .PARAMETER id
    One or more AnchorPerson id's.

    .PARAMETER Me
    Switch to return the AnchorPerson object for the authenticated user.

    .PARAMETER ByEmail
    Changes the functionality of the function to accept email address instead of id.

    .INPUTS
    A collection of AnchorPerson objects

    .OUTPUTS
    A collection of AnchorPerson objects


    .LINK
    http://developer.anchorworks.com/v2/#get-a-person

    .LINK
    Get-AnchorOauthToken
#>
    [CmdletBinding()]
    [Alias('AnchorPerson')]
    param(
        [Parameter(ParameterSetName='ById',Position=0,ValueFromPipelineByPropertyName)][string[]]$id,
        [Parameter(ParameterSetName='ByEmail',Position=0,ValueFromPipelineByPropertyName)][string[]]$email,
        [Parameter(ParameterSetName='ByEmail',Position=1,HelpMessage='Accept email address instead of person id.')][switch]$ByEmail,
        [Parameter(ParameterSetName='Me',Position=0,HelpMessage='Return the person object for the authenticated user.')][switch]$Me
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        # This endpoint can be called wihout an id to get the data for the currently logged-on person.
        If($Me){
            Write-Verbose "$($MyInvocation.MyCommand) called with -Me switch."
            $apiEndpoint = "person"
            try{
                $results =Get-AnchorData -OauthToken $script:anchorOauthToken -ApiEndpoint $apiEndPoint
            }
            catch{
                $exception = $_.Exception
                Switch ($exception.Response.StatusCode.value__){
                    403 {$results=[pscustomobject]@{exception='unauthorized'}}
                    404 {$results=[pscustomobject]@{exception='nonexistent_id'}}
                    default {$results = $exception}
                }
            }
            $results
        }
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        If($ByEmail){
            Write-Verbose "$($MyInvocation.MyCommand) called with -ByEmail switch."
            ForEach ($emailAddr in $email){
                $apiEndpoint = "person/$emailAddr"
                try{
                    $results = Get-AnchorData -OauthToken $script:anchorOauthToken -ApiEndpoint $apiEndPoint
                }
                catch{
                    $exception = $_.Exception
                    Switch ($exception.Response.StatusCode.value__){
                        403 {$results=[pscustomobject]@{exception='unauthorized'}}
                        404 {$results=[pscustomobject]@{exception='nonexistent_id'}}
                        default {$results = $exception}
                    }
                }
                $results
            }
        } Else {
            ForEach ($personId in $id){
                $apiEndpoint = "person/$personId"
                try{
                    $results = Get-AnchorData -OauthToken $script:anchorOauthToken -ApiEndpoint $apiEndPoint
                }
                catch{
                    $exception = $_.Exception
                    Switch ($exception.Response.StatusCode.value__){
                        403 {$results=[pscustomobject]@{exception='unauthorized'}}
                        404 {$results=[pscustomobject]@{exception='nonexistent_id'}}
                        default {$results = $exception}
                    }
                }
                $results
            }
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorPersonActivity {
<#
    .LINK
    http://developer.anchorworks.com/v2/#list-recent-activity-for-a-person
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Person ID')][string[]]$id,
        [Parameter(HelpMessage='Limits the number of objects to return to the next highest multiple of 100. Default:1000')][int]$RecordCountLimit
        
    )
    # The activities that will be reutrned have numeric activity types.
    #   It might be nice to add the activity names to the resulting object.
    #   To do this, we're ging to put all the activity id's and names into a hash table.
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $activityTypes = Get-AnchorActivityTypes | Select-Object id, activity
        $activityTypesHash = @{}
        $activityTypes | ForEach-Object {
            $activityTypesHash[$_.id] = $_.activity
        }

    }
    process{
        foreach ($personId in $id){
            $apiEndpoint = "person/$personId/activity"
            try{
                $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ResultsLimit $RecordCountLimit
                $results = $results | Select-Object *, @{N='activity';E={$activityTypesHash[$_.activity_type_id]}}
            }
            catch{
                $exception = $_.Exception
                Switch ($exception.Response.StatusCode.value__){
                    403 {$results=[pscustomobject]@{exception='unauthorized'}}
                    404 {$results=[pscustomobject]@{exception='nonexistent_id'}}
                    default {$results = $exception}
                }
            }
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

# Note that the Include switches must be explicitly called, despite the fact that some are on by default in the API.
Function Get-AnchorRootMetadata {
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
                $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery -NoRefreshToken
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

#http://developer.anchorworks.com/v2/#search-files-and-folders
Function Find-RootFilesAndFolders {
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
                $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
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
            $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
            $results
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

# Accepts one or more Anchor root IDs or objects containing a parameter named "id" with values of root IDs
# Returns the DateTime of the last time any file in the root was modified (within the last 5.6 years).
# We do multiple checks, looking back 1 day, 2 days, 4 days, and so on until 2048.
#   The API times out if there's no result in about 5 minutes, so this can potentially take a long time, especially if there are roots with large numbers of files.
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
            $Script:anchorOauthToken = $OauthToken
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
            $runspaceParams = @{'rootId'="$rootId";'OauthToken'=$Script:anchorOauthToken; 'IgnorePathString'=$ignorePathString; 'MaxLookback'=$MaxLookback}
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

# Accepts a number of Anchor machine id's or a piped collection of machine objects with .id properties.
# Returns the backup roots associated with each machine ID.
# It was a 500% increase in the lines of code, but it runs 210% faster using runspaces when passing all machines.
Function Get-AnchorMachineBackups {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor machine id')][string[]]$id
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        #region BLOCK 1: Create and open runspace pool, setup runspaces array with min and max threads
        #   Special thanks to Chrissy LeMaire (https://blog.netnerds.net/2016/12/runspaces-simplified/) for helping me to (sort of) understand how to utilize runspaces.

        # Custom functions are not available to runspaces. 🤦‍
        # We need to import some custom functions and script variables into the runspacepool, so we'll have to jump through hoops now.
        #   https://stackoverflow.com/questions/51818599/how-to-call-outside-defined-function-in-runspace-scriptblock
        $bagOfFunctions = @(
            'Get-AnchorData',
            'Validate-AnchorOauthToken',
            'Refresh-AnchorOauthToken',
            'Get-AnchorOauthStatus'
        )
        $bagOfVariables = @(
            'apiUri'
        )
        $InitialSessionState = [initialsessionstate]::Create()
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
            $InitialSessionState.LanguageMode = 'FullLanguage' #Without this, you get an error when you try to call EndInvoke at the end.

        # Now back to our regularly scheduled runspace pool creation
        $pool = [RunspaceFactory]::CreateRunspacePool(1,[int]$env:NUMBER_OF_PROCESSORS+1,$InitialSessionState,$Host)
        $pool.ApartmentState = "MTA"
        $pool.Open()
        $runspaces = @() #$results = @()
        #endregion

        #region BLOCK 2: Create reusable scriptblock. This is the workhorse of the runspace. Think of it as a function.
        $scriptblock = {
            Param (
                [string]$machineId,
                [object]$OauthToken
            )
            $apiEndpoint = "machine/$machineId/backups"
            $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndPoint -NoRefreshToken #Adding NoRefreshToken, because it doesn't work within a runspace.
            $results
        }
        #endregion
    }
    process{
        foreach ($machineId in $id){
            #region BLOCK 3: Create runspace and add to runspace pool
            $runspaceParams = @{'machineId'="$machineId";'OauthToken'=$Script:anchorOauthToken}
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
        while ($runspaces.Status -ne $null){
            $completed = $runspaces | Where-Object { $_.Status.IsCompleted -eq $true }
            #Monitor
            $notCompleted = $runspaces | Where-Object { $_.Status.IsCompleted -eq $false }
            [int]$notCompletedCount = $notCompleted.Count
            Write-Progress -Activity "Roots remaining to analyze (out of $($runspaces.Count))..." -Status $($notCompletedCount) -PercentComplete (($notCompletedCount / $runspaces.Count) * 100) -ErrorAction SilentlyContinue
            foreach ($runspace in $completed)
            {
                $runspace.Pipe.EndInvoke($runspace.Status)
                $runspace.Status = $null
            }
        }
        #endregion

        #region BLOCK 6: Clean up
        $pool.Close() 
        $pool.Dispose()
        #endregion
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}


# Generic function for returning data from an Anchor API endpoint.
# The full uri of the endpoint is passed as a string.
# The query (if needed) is passed as a hash table. This is the information that will be sent in the Body.
#   The function handles pagination, so there is no need to pass the offset in the query hashtable.
# The OauthToken is an object, returned from the Oauth function.
Function Get-AnchorData {
    #[CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][AllowNull()][object]$OauthToken,
        [Parameter(Mandatory,Position=1)][string]$ApiEndpoint, 
        [Parameter(Position=2)]$ApiQuery,
        [Parameter(HelpMessage='Limits the number of results returned. Will be the next highest multiple of 100.')][int]$ResultsLimit=1000,
        [Parameter()][switch]$NoRefreshToken
    )
    Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
    #Validate-AnchorOauthToken -OauthToken $OauthToken -NoRefresh $NoRefreshToken #Check to make sure the Oauth token is valid and refresh if needed.
    
    $tokenType = $OauthToken.token_type
    $accessToken = $OauthToken.access_token
    $headers = @{'Authorization' = "$tokenType $accessToken"}
    $body = $ApiQuery
    #try{
        Write-Verbose "Invoke-RestMethod for $Global:apiUri`/$ApiEndpoint begin at $(Get-Date)"
        $results = Invoke-RestMethod -Uri "$Global:apiUri`/$ApiEndpoint" -Method Get -Headers $headers -Body $body
        Write-Verbose "Invoke-RestMethod for $Global:apiUri`/$ApiEndpoint complete at $(Get-Date)"
    #}
    #catch{
    #    Switch ($Error[0].Exception){
    #        default {$results = $Error[0].Exception}
    #    }
    #}
    If ($results.PSobject.Properties.name -eq "results") { # The returned object contains a property named "results" and is therefore a collection. We have to do some magic to extract all the data. 
        $results.results # Return the first set of results.
        $resultsCount = $results.results.count
        $totalResults = $results.total #The call will only return 100 objects at a time. This tells us if there are more to get.
        $body+=@{'offset' = '0'} #Because we're going to need to increment the offset, and we didn't have an offset as part of the query to begin, we have to add a zero-value offset before we can increment it.
        While ($resultsCount -lt $totalResults -and $resultsCount -lt $ResultsLimit){ # Keep calling the endpoint until we've squeezed out all the data.
            $PageOffset+=100 # We want to get the next 100 results
            $body.offset = "$PageOffset" # Update the offset value for the next Api call.
            $results = Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Get -Headers $headers -Body $body
            $results.results # Return the next batch of results.
            $resultsCount+=$results.results.count
        }

    } Else { #This is an object (or empty). We can just return the results.
        $results
    }
    Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"

}

#region DEPRECATED FUNCTIONS



#endregion