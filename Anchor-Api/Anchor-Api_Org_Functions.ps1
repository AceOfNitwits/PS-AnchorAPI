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

Function New-AnchorOrgChild{
<#
    .LINK
    http://developer.anchorworks.com/v2/#create-an-organization
#>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Medium')]
    [Alias('New-AnchorCompanyChild')]
    param(
        [Parameter(ParameterSetName='csv')][string]$FromCsv,
        [Parameter(ParameterSetName='commandLine',Mandatory,Position=0,HelpMessage='The company_id of the parent organization')][int]$id,
        [Parameter(ParameterSetName='commandLine',Mandatory,Position=1,HelpMessage='Name of the new organization')][string]$name,
        [Parameter(ParameterSetName='commandLine',Mandatory,Position=2,HelpMessage='the new organization''s contact email address.')][string]$email,
        [Parameter(ParameterSetName='commandLine',Position=3,HelpMessage='a unique hostname for the organization, used in links to resources and shares. This should be only the third-level portion of the hostname (e.g. "company" in "company.example.com"). Not required for single host configurations.')][string]$hostname,
        [Parameter(ParameterSetName='commandLine',Position=4,HelpMessage='a unique, URL-friendly organization identifier. For example, an organization named "Widgets, Ltd." may have the slug "widgets-ltd".')][string]$slug,
        [Parameter(ParameterSetName='commandLine',HelpMessage='a description of the organization. Defaults to empty.')][string]$description,
        #[Parameter(ParameterSetName='commandLine',HelpMessage='the ID of the parent organization. Defaults to the root organization.')][int]$parent_id, #This does nothing.
        [Parameter(ParameterSetName='commandLine',HelpMessage='a date/time the organization trial period expires. Defaults to no trial period.')][datetime]$trial_until,
        [Parameter(ParameterSetName='commandLine',HelpMessage='a block of text that will be sent with each share notification email.')][string]$share_disclaimer,
        #[Parameter(ParameterSetName='commandLine',HelpMessage='whether users must log in to access the share. "true" or "false". Default "false".')][switch]$login_required,
        #[Parameter(ParameterSetName='commandLine',HelpMessage='a date the share expires. Defaults to no expiration.')][datetime]$expires,
        #[Parameter(ParameterSetName='commandLine',HelpMessage='a comma-separated list of subscribers by email address.')][string[]]$subscribers,
        #[Parameter(ParameterSetName='commandLine',HelpMessage='"true" or "false". Default "false".')][switch]$notify_subscribers,
        #[Parameter(ParameterSetName='commandLine',HelpMessage='the total number of downloads allowed for the share. Defaults to unlimited.')][int]$download_limit,
        #[Parameter(ParameterSetName='commandLine',HelpMessage='whether you want to be notified of downloads. "true" or "false". Default "false".')][switch]$download_notify,
        [Parameter(ParameterSetName='commandLine',HelpMessage='space quota in bits(?). Default 107374182400.')][long]$space_quota,
        [Parameter(ParameterSetName='commandLine',HelpMessage='max file size in MB. Default 300.')][int]$max_file_size,
        [Parameter(ParameterSetName='commandLine',HelpMessage='excluded extensions. Default ".$$,.$db,.113,.3g2,.3gp,.3gp2,.3gpp,.3mm,.a,.abf,.abk,.afm,.ani,.ann,.asf,.avi,.avs,.bac,.bak,.bck,.bcm,.bd2,.bdb,.bdf,.bkf,.bkp,.bmk,.bsc,.bsf,.cab,.cf1,.chm,.chq,.chw,.cnt,.com,.cpl,.cur,.dbs,.dev,.dfont,.dll,.dmp,.drv,.dv,.dvd,.dvr,.dvr-ms,.eot,.evt,.exe,.ffa,.ffl,.ffo,.ffx,.flc,.flv,.fnt,.fon,.ftg,.fts,.fxp,.gid,.grp,.hdd,.hlp,.hxi,.hxq,.hxr,.hxs,.ico,.idb,.idx,.ilk,.img,.inf,.ini,.ins,.ipf,.iso,.isp,.its,.jar,.jse,.kbd,.kext,.key,.lex,.lib,.library-ms,.lnk,.log,.lwfn,.m1p,.m1v,.m2p,.m2v,.m4v,.mem,.mkv,.mov,.mp2,.mp2v,.mp4,.mpe,.mpeg,.mpg,.mpv,.mpv2,.msc,.msi,.msm,.msp,.mst,.ncb,.nt,.nvram,.o,.obj,.obs,.ocx,.old,.ost,.otf,.pch,.pd6,.pf,.pfa,.pfb,.pfm,.pnf,.pol,.pref,.prf,.prg,.prn,.pst,.pvs,.pwl,.QBA,.QBA.TLG,.QBW,.QBW.TLG,.qt,.rdb,.reg,.rll,.rox,.sbr,.scf,.scr,.sdb,.shb,.suit,.swf,.swp,.sys,.theme,.tivo,.tmp,.tms,.ttc,.ttf,.v2i,.vbe,.vga,.vgd,.vhd,.video,.vmc,.vmdk,.vmsd,.vmsn,.vmx,.vxd,.win,.wpk".')][string[]]$excluded_extensions,
        [Parameter(ParameterSetName='commandLine',HelpMessage='allow users to erase revisions? Default "false".')][switch]$user_trim_revisions,
        [Parameter(ParameterSetName='commandLine',HelpMessage='auto-erase revisions? Default "false".')][switch]$trim_revisions,
        [Parameter(ParameterSetName='commandLine',HelpMessage='erase revisions for files unchanged after a certain number of days. Default.')][int]$trim_revisions_x,
        [Parameter(ParameterSetName='commandLine',HelpMessage='allow users to erase deleted files? Default "false".')][switch]$user_purge_deleted,
        [Parameter(ParameterSetName='commandLine',HelpMessage='auto-erase deleted files? Default "false".')][switch]$purge_deleted,
        [Parameter(ParameterSetName='commandLine',HelpMessage='erase deleted files after a certain number of days. Default never.')][int]$purge_deleted_frequency,
        [Parameter(ParameterSetName='commandLine',HelpMessage='deactivate API tokens after a certain number of days. Default 30.')][int]$deactivate_token_frequency,
        [Parameter(ParameterSetName='commandLine',HelpMessage='allow users to create their own backups? Default "true".')][switch]$user_create_backups,
        [Parameter(ParameterSetName='commandLine',HelpMessage='allow users to share files? Default "true".')][switch]$user_create_shares,
        [Parameter(ParameterSetName='commandLine',HelpMessage='force new share links to require login? Default "false".')][switch]$secure_shares,
        [Parameter(ParameterSetName='commandLine',HelpMessage='allow users to overwrite collisions? Default "false".')][switch]$user_overwrite_collisions,
        [Parameter(ParameterSetName='commandLine',HelpMessage='allow users to lock files? Default "false".')][switch]$user_lock_files,
        [Parameter(ParameterSetName='commandLine',HelpMessage='use filesystem permissions to enforce locks on. Default ".doc,.docx,.xls,.xlsx,.ppt,.pptx,.pdf,.txt,.xlsb,.xlsm,.csv,.docm,.dotx,.dotm,.pub,.wpd,.odt,.ott,.oth,.odm,.ots,.odp,.odg,.otp,.odf,.oxt,.odc,.ods,.vdx,.vsx,.vtx,.one".')][string[]]$locked_extensions,
        [Parameter(ParameterSetName='commandLine',HelpMessage='let organization admins browse user files? Default "true".')][switch]$admin_browse_files,
        [Parameter(ParameterSetName='commandLine',HelpMessage='let organization admins browse remote files? Default "true".')][switch]$admin_browse_remote,
        [Parameter(ParameterSetName='commandLine',HelpMessage='let organization admins create users? Default "true".')][switch]$admin_create_users,
        [Parameter(ParameterSetName='commandLine',HelpMessage='force password change after a certain number of days. Default never.')][int]$change_password_frequency,
        [Parameter(ParameterSetName='commandLine',HelpMessage='require two-step authentication? Default "false".')][switch]$require_two_step_auth,
        [Parameter(ParameterSetName='commandLine',HelpMessage='min number of users. Default 0.')][int]$num_users_minimum,
        [Parameter(ParameterSetName='commandLine',HelpMessage='max number of users. Default none.')][int]$num_users_maximum,
        [Parameter(ParameterSetName='commandLine',HelpMessage='max number of suborganizations. Default 10.')][int]$num_orgs_maximum,
        [Parameter(ParameterSetName='commandLine',HelpMessage='enable backup creation? Default "true".')][switch]$backups_enabled,
        [Parameter(ParameterSetName='commandLine',HelpMessage='enable branding support? Default "true".')][switch]$branding_enabled,
        [Parameter(ParameterSetName='commandLine',HelpMessage='enable WebDAV support? Default "true".')][switch]$webdav_enabled,
        [Parameter(ParameterSetName='commandLine',HelpMessage='enable PSA support? Default "true".')][switch]$psa_enabled,
        [Parameter(ParameterSetName='commandLine',HelpMessage='enable directory server authentication support? Default "true".')][switch]$ad_enabled,
        [Parameter(ParameterSetName='commandLine',HelpMessage='enable File Server Enablement? Default "true".')][switch]$file_server_enabled,
        [Parameter(ParameterSetName='commandLine',HelpMessage='trial length in days. Default 30.')][int]$trial_length_days,
        [Parameter(ParameterSetName='commandLine',HelpMessage='enable service plans? Default "false".')][switch]$service_plans_enabled,
        [Parameter(ParameterSetName='commandLine',HelpMessage='require passcode lock on mobile devices? Default "false".')][switch]$require_mobile_lock,
        [Parameter(ParameterSetName='commandLine',HelpMessage='allow users to preview files on the web? Default "true".')][switch]$web_preview_enabled
    
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiCalls=@()
        $apiQuery = @{
            name=$name
            email=$email
            hostname=$hostname
            slug=$slug
        }
        If($description){$apiQuery+=@{description=$description}}
        #If($parent_id){$apiQuery+=@{parent_id=$parent_id}}
        If($trial_until){$apiQuery+=@{trial_until=$trial_until}}
        If($share_disclaimer){$apiQuery+=@{share_disclaimer=$share_disclaimer}}
        #If($login_required){$apiQuery+=@{login_required=$login_required}}
        #If($expires){$apiQuery+=@{expires=$expires}}
        #If($subscribers){$apiQuery+=@{subscribers=$subscribers}} # Is this really a new org parameter?
        #If($notify_subscribers){$apiQuery+=@{notify_subscribers=$notify_subscribers}} # Really?
        #If($download_limit){$apiQuery+=@{download_limit=$download_limit}} # Really?
        #If($download_notify){$apiQuery+=@{download_notify=$download_notify}} # Really?
        If($space_quota){$apiQuery+=@{space_quota=$space_quota}}
        If($max_file_size){$apiQuery+=@{max_file_size=$max_file_size}}
        If($excluded_extensions){$apiQuery+=@{excluded_extensions=($excluded_extensions -join ',')}}
        If($user_trim_revisions){$apiQuery+=@{user_trim_revisions=$user_trim_revisions}}
        If($trim_revisions){$apiQuery+=@{trim_revisions=$trim_revisions}}
        If($trim_revisions_x){$apiQuery+=@{trim_revisions_x=$trim_revisions_x}}
        If($user_purge_deleted){$apiQuery+=@{user_purge_deleted=$user_purge_deleted}}
        If($purge_deleted){$apiQuery+=@{purge_deleted=$purge_deleted}}
        If($purge_deleted_frequency){$apiQuery+=@{purge_deleted_frequency=$purge_deleted_frequency}}
        If($deactivate_token_frequency){$apiQuery+=@{deactivate_token_frequency=$deactivate_token_frequency}}
        If($user_create_backups){$apiQuery+=@{user_create_backups=$user_create_backups}}
        If($user_create_shares){$apiQuery+=@{user_create_shares=$user_create_shares}}
        If($secure_shares){$apiQuery+=@{secure_shares=$secure_shares}}
        If($user_overwrite_collisions){$apiQuery+=@{user_overwrite_collisions=$user_overwrite_collisions}}
        If($user_lock_files){$apiQuery+=@{user_lock_files=$user_lock_files}}
        If($locked_extensions){$apiQuery+=@{locked_extensions=($locked_extensions -join ',')}}
        If($admin_browse_files){$apiQuery+=@{admin_browse_files=$admin_browse_files}}
        If($admin_browse_remote){$apiQuery+=@{admin_browse_remote=$admin_browse_remote}}
        If($admin_create_users){$apiQuery+=@{admin_create_users=$admin_create_users}}
        If($change_password_frequency){$apiQuery+=@{change_password_frequency=$change_password_frequency}}
        If($require_two_step_auth){$apiQuery+=@{require_two_step_auth=$require_two_step_auth}}
        If($num_users_minimum){$apiQuery+=@{num_users_minimum=$num_users_minimum}}
        If($num_users_maximum){$apiQuery+=@{num_users_maximum=$num_users_maximum}}
        If($num_orgs_maximum){$apiQuery+=@{num_orgs_maximum=$num_orgs_maximum}}
        If($backups_enabled){$apiQuery+=@{backups_enabled=$backups_enabled}}
        If($branding_enabled){$apiQuery+=@{branding_enabled=$branding_enabled}}
        If($webdav_enabled){$apiQuery+=@{webdav_enabled=$webdav_enabled}}
        If($psa_enabled){$apiQuery+=@{psa_enabled=$psa_enabled}}
        If($ad_enabled){$apiQuery+=@{ad_enabled=$ad_enabled}}
        If($file_server_enabled){$apiQuery+=@{file_server_enabled=$file_server_enabled}}
        If($trial_length_days){$apiQuery+=@{trial_length_days=$trial_length_days}}
        If($service_plans_enabled){$apiQuery+=@{service_plans_enabled=$service_plans_enabled}}
        If($require_mobile_lock){$apiQuery+=@{require_mobile_lock=$require_mobile_lock}}
        If($web_preview_enabled){$apiQuery+=@{web_preview_enabled=$web_preview_enabled}}
    }
    process{
        If($FromCsv){
            # File processing
            $arrayParams = @() #These are the names of parameters that could possibly contain multiple values (arrays) and need to be passed multiple times.
            $csvData = Import-Csv -Path $FromCsv
            #$csvFields = Get-Member -InputObject $csvData[0] | Where-Object MemberType -eq NoteProperty
            $csvData | ForEach-Object {
                $apiQuery = @{}
                foreach ($property in $_.PSObject.Properties){
                    If ($property.Name -in $arrayParams){ 
                        # This parameter needs to be formatted as an array so that it can later be passed twice.
                        $apiQuery[$($property.Name)] = $property.Value.Replace('"','').split(',')
                    }
                    Else{
                        $apiQuery[$($property.Name)] = $property.Value
                    }
                }
                # If fields with multiple values need to be passed multiple times to the API server...
                # You can't have duplicate keys in a hashtable, so we have to convert the hashtable to a URL string.
                If(($apiQuery.group_ids -is [array]) -or ($apiQuery.dept_shares -is [array])) {
                    $apiQueryString=''
                    $first=$true
                    ForEach ($key in $apiQuery.keys){
                        ForEach ($value in $apiQuery[$key]) {
                            If($first){
                                $first=$false
                            }
                            Else{
                                $apiQueryString += '&'
                            }
                            If($value -eq 'TRUE'){$value='true'}
                            $apiQueryString += [System.Web.HttpUtility]::HtmlEncode($Key) + "=" + [System.Web.HttpUtility]::HtmlEncode($value);
                        }
                    }
                    $apiQuery = $apiQueryString
                }
            $apiCall = @{'ApiEndpoint'=$apiEndpoint;'ApiQuery'=$apiQuery}
            $apiCalls += $apiCall
            }
        }
        Else{
            #Create the apiCalls hash table that will be passed to the Invoke-AnchorApi function.
            $apiEndpoint = "organization/$id/organizations/create"
            $apiCall = @{'ApiEndpoint'=$apiEndpoint;'ApiQuery'=$apiQuery}
            $affectedItem = Get-AnchorOrg -id $parent_id | Select-Object id, name
            If($PSCmdlet.ShouldProcess("New Organization: $name; Parent: $($affectedItem.name) (id: $($affectedItem.id))", 'Create Organization')){
                $apiCalls += $apiCall
            }
        }
    }
    end{
        $results = $apiCalls | Invoke-anchorAPIPost
        [AnchorOrg]$results
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
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
