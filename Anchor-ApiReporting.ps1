#region Credits and Documentation
# Bryan Sullo - bryan@clocktowertech.com
# Anchor API Documentation: http://developer.anchorworks.com/v2/

# Query parameters go in the body, formatted as a hash table @{"parameter_name"="value"}
# Format date parameters like this @{"since"=(Get-Date (Get-Date).AddDays(-1) -Format "yyyy-MM-ddThh:mm:ss")}

#endregion

# Base API URI
[string]$global:apiUri = "https://clocktowertech.syncedtool.com/api/2"


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
    [Alias('AnchorApi')]
    #param(
    #    [Parameter(Mandatory,Position=0)][object]$OauthToken
    #)
    $apiEndpoint = "version"
    $results = Get-AnchorData -ApiEndpoint $apiEndPoint -OauthToken $Script:anchorOauthToken
    $results
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
        #[Parameter(Mandatory=$true,Position=0)]$OauthToken,
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName)][string[]]$id
        
    )
    process{
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        ForEach ($orgId in $id){
            $apiEndpoint = "organization/$orgId"
            $results = Get-AnchorData -OauthToken $script:anchorOauthToken -ApiEndpoint $apiEndPoint
            $results
        }
    }
}

# Accepts an AnchorOrg object or collection of AnchorOrg objects.
# Returns AnchorMachine objects.
Function Get-AnchorOrgMachines {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true,Position=0,HelpMessage='Organization ID')][string[]]$id
    )
    process{
        #We might get multiple $id values from the parameter.
        ForEach ($orgId in $id){
            $apiEndpoint = "organization/$($orgId)/machines"
            $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndPoint
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
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$id
    )
    process{
        #There may be multiple $id values passed by the function -id parameter
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$orgId/organizations"
            $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndPoint
            $results
        }
    }
}


Function Get-AnchorOrgRoots {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Organization ID')][string[]]$id
        
    )
    process{
        foreach ($orgId in $id){
            $apiEndpoint = "organization/$OrgId/roots"
            $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint
            $results
        }
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
                $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
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
        $apiQuery = @{'since' = "$(Get-Date($Since) -Format 'yyyy-MM-ddThh:mm:ss')"}
    }
    process{
        foreach ($rootId in $id){
            $apiEndpoint = "files/$rootId/modified_since"
            $results = Get-AnchorData -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
            $results
        }
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
        [Parameter(Position=1,HelpMessage='Number of threads to use when querying multiple roots. Default = 100')][int]$MaxThreads=100
    )
    begin{
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
        $pool = [RunspaceFactory]::CreateRunspacePool(1,$MaxThreads,$InitialSessionState,$Host)
        $pool.ApartmentState = "MTA"
        $pool.Open()
        $runspaces = @()
        #endregion

        #region BLOCK 2: Create reusable scriptblock. This is the workhorse of the runspace. Think of it as a function.
        
        $scriptblock = {
            Param (
                [string]$rootId,
                [object]$OauthToken
            )
            $apiEndpoint = "files/$rootId/modified_since"
            [int]$lookBackDays = -1 #Initialize
            [datetime]$now = Get-Date
            Do{
                [datetime]$mySince = $now.AddDays($lookBackDays)
                $apiQuery = @{'since' = "$(Get-Date($mySince) -Format 'yyyy-MM-ddThh:mm:ss')"}
                
                try {
                    $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery -NoRefreshToken #Adding NoRefreshToken, because it doesn't work within a runspace.
                } catch {
                    [PSCustomObject]@{'id' = "$rootId";'modified'='api_error'}
                    $halt = $true
                }
                $results | Sort-Object -Property modified -Descending | Select-Object root_id, modified -First 1 | Add-Member -MemberType AliasProperty -Name id -Value root_id -PassThru | Select-Object id, modified
                $lookBackDays = $lookBackDays * 2
            }Until($results -or ($lookBackDays -lt -2048) -or $halt) # Let's not get carried away. 5.6 years ought to be enough! Also, remember, we're counting backward.
            If ($lookBackDays -lt -2048){
                [PSCustomObject]@{'id' = "$rootId";'modified'='no_files_found'}
            }
        }
        #endregion
    }
    process{
        foreach ($rootId in $id){
            #region BLOCK 3: Create runspace and add to runspace pool
            $runspaceParams = @{'rootId'="$rootId";'OauthToken'=$Script:anchorOauthToken}
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
        [Parameter(Position=2)]$ApiQuery,
        [Parameter(Position=3)][switch]$NoRefreshToken
    )
    Validate-AnchorOauthToken -OauthToken $OauthToken -NoRefresh $NoRefreshToken #Check to make sure the Oauth token is valid and refresh if needed.
    
    $tokenType = $OauthToken.token_type
    $accessToken = $OauthToken.access_token
    $headers = @{'Authorization' = "$tokenType $accessToken"}
    $body = $ApiQuery

    $results = Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Get -Headers $headers -Body $body
    
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

Function Get-AnchorRootLastModifiedOld {
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


#endregion