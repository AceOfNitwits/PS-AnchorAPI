# Functions that take Organization (Company) objects or id's as input.

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
        [Parameter(ParameterSetName='Standard',Mandatory=$true,Position=0,ValueFromPipelineByPropertyName)][AllowNull()][string[]]$id,
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
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
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
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ResultsLimit $RecordCountLimit
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
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint
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
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
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
        [Parameter(Position=2,HelpMessage='Also return machines that have logged on via the API.')][switch]$IncludeApiMachines,
        [Parameter(HelpMessage='Maximum number of API queries to run at once.')][int]$MaxThreads=[int]$([int]$env:NUMBER_OF_PROCESSORS + 1)
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiCalls=@()
    }
    process{
        # Create the array of API calls to make.
        #We might get multiple $id values from the parameter.
        ForEach ($orgId in $id){
            $apiEndpoint = "organization/$($orgId)/machines"
            $apiQuery = @{}
            $apiCall = @{'ApiEndpoint'=$apiEndpoint;'ApiQuery'=$apiQuery; 'Tag'=$orgId}
            $apiCalls += $apiCall
        }
    }
    end{
        $myMachines = $apiCalls | Invoke-AnchorApiGet -MaxThreads $MaxThreads
        #Write-Host $myMachines.Count
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
                #Write-host $_.dns_name
                $_ | Add-Member -MemberType NoteProperty -Name 'last_login(local_offset)' -Value (Convert-UtcDateStringToLocalDateTime $_.last_login)
                $_ | Add-Member -MemberType NoteProperty -Name 'created(local_offset)' -Value (Convert-UtcDateStringToLocalDateTime $_.created)
                $_ | Add-Member -MemberType NoteProperty -Name 'last_disconnect(local_offset)' -Value (Convert-UtcDateStringToLocalDateTime $_.last_disconnect)
                # The following no longer works because the results are all returned at once, and we don't know which org was called.
                $_ | Add-Member -MemberType NoteProperty -Name 'company_id' -Value $_.tag
            }
            If($IncludeApiMachines){
                $results
            }
            Else{
                $results | Where-Object {-not ($_.agent_version -eq $null -and $_.machine_type -eq 'agent' -and $_.os_type -eq $null)}
            }
        }
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorOrgRoot {
<#
    .NOTES
    I'm not sure when this API call is useful. It's easier and more flexible to just get a root by ID, rather than having to specify a company_id as well.

    .LINKS
    http://developer.anchorworks.com/v2/#get-a-root
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string]$company_id,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor Root ID')][string]$root_id        
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        $apiEndpoint = "organization/$company_id/root/$root_id"
        try{
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint
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
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint
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
        $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint
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
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint
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
        $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
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
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint
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
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ResultsLimit $RecordCountLimit
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
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint
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
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ResultsLimit $RecordCountLimit
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
