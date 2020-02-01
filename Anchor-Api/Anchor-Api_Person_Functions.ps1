# Functions where the primary input is a person_id

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
                $results =Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
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
                    $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
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
                    $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
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

Function New-AnchorPerson {
<#
    .PARAMETER FromCsv
    Accepts the path of an existing .csv file that contains the field names and appropriate values

    Notes for csv formatting:
    True/False fields: empty or nonexistent = false. Field should contain only the string 'true' or 'false'. Excel will force this to 'TRUE' and 'FALSE' but the function will convert it to lowercase.
    Fields that accept multiple values: These should be formatted as comma-separated text, enclosed in double quotes (e.g. "12345,54321"). If only passing a single value, formatting in this way is not necessary.

    .PARAMETER Confirm
    Specifies that all actions are implicitly confirmed. i.e. Will not prompt for confirmation.

    .LINK
    http://developer.anchorworks.com/v2/#create-a-person
#>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName='import')][string]$FromCsv,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=0)][int]$company_id,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=1)][string]$email,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=2)][string]$first_name,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=3)][string]$last_name,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=4)][string]$password,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=5)][switch]$generate_password,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=6)][datetime]$pw_expires,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=7)][switch]$webdav,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=8)][long]$space_quota,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=9)][string]$mobile_phone,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=10)][switch]$site_admin,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=11)][switch]$system_admin,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=12)][switch]$create_root,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=13)]$dept_shares, #unsure of the datatype or format here
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=14)]$group_ids, #unsure of datatype or format
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=15)][switch]$quota_50,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=16)][switch]$quota_80,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=17)][switch]$quota_85,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=18)][switch]$quota_90,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=19)][switch]$quota_95,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=20)][switch]$quota_100,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=21)][switch]$send_welcome_email,
        [Parameter(HelpMessage='If set, all actions are automatically confirmed without user input.')]$Confirm
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiEndpoint = "person/create"
        $apiCalls=@()
    }
    process{
        If($FromCsv){
            #File processing
            $arrayParams = @('group_ids','dept_shares') #These are the names of parameters that could possibly contain multiple values (arrays).
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
                # Two of the fields can accept multiple values. You have to pass the same field twice to the API server.
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
            # Create the array of API calls to make.
            $apiQuery = @{
                'company_id'=$company_id
                'email'=$email
                'first_name'=$first_name
                'last_name'=$last_name
                'password'=$password
                'generate_password'=$(If($generate_password){'true'}Else{'false'})
                'pw_expires'=$(If($pw_expires){$(Get-Date($pw_expires) -format 'yyyy-MM-ddThh:mm:ss')})
                'webdav'=$(If($webdav){'true'}Else{'false'})
                'space_quota'=$(If($space_quota){$space_quota}Else{''}) #$space_quota is an [int], which will become 0 if we don't supply a value.
                'mobile_phone'=$mobile_phone
                'site_admin'=$(If($site_admin){'true'}Else{'false'})
                'system_admin'=$(If($system_admin){'true'}Else{'false'})
                'create_root'=$(If($create_root){'true'}Else{'false'})
                'dept_shares'=$dept_shares
                'group_ids'=$group_ids
                'quota_50'=$(If($quota_50){'true'}Else{'false'})
                'quota_80'=$(If($quota_80){'true'}Else{'false'})
                'quota_85'=$(If($quota_85){'true'}Else{'false'})
                'quota_90'=$(If($quota_90){'true'}Else{'false'})
                'quota_95'=$(If($quota_95){'true'}Else{'false'})
                'quota_100'=$(If($quota_100){'true'}Else{'false'})
                'send_welcome_email'=$(If($send_welcome_email){'true'}Else{'false'})
            }

            # Two of the fields can accept multiple values. You have to pass the same field twice to the API server.
            # You can't have duplicate keys in a hashtable, so we have to convert the hashtable to a URL string.
            If(($group_ids -is [array]) -or ($dept_shares -is [array])) {
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
                        $apiQueryString += [System.Web.HttpUtility]::HtmlEncode($Key) + "=" + [System.Web.HttpUtility]::HtmlEncode($value);
                    }
                }
                $apiQuery = $apiQueryString
            }



            $apiCall = @{'ApiEndpoint'=$apiEndpoint;'ApiQuery'=$apiQuery}
            $apiCalls += $apiCall
        }
    }
    end{
        # Confirmation
        If($Confirm){
            $confirmation='Y'
        }
        Else {
            Write-Host "You are about to attempt to create the following user accounts:"
            $apiCalls | ForEach-Object {Write-Host $($_.ApiQuery | out-string)}
            $confirmation = Read-Host "Confirm: [Y]es, [N]o (Default: No)"
        }
        # End Confirmation
        If($confirmation -eq 'Y'){
            $results = $apiCalls | Invoke-AnchorApiPost
            If($results){
                [AnchorPerson[]]$outObject = $results
                $outObject.GeneratePwLastChangedPsLocal()
                $outObject.PopulateCompanyName() #company_name = (Get-AnchorOrg -id $($results.company_id)).name
                Write-Host "$($outObject.Count) accounts created."
                $outObject
            }
        }
        Else {
            Write-Host 'Action canceled. No accounts created.'
        }
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Remove-AnchorPerson{
<#
    .PARAMETER remove_server_files
    This parameter's function is not documented, and it is unclear what it is intended to do.

    .PARAMETER remove_user_files
    Obsensibly, setting this to true will delete the user's root. However, testing indicates this parameter does nothing.

    .PARAMETER remove_server_files
    It is unclear what this parameter is intended to do. If the documentation is to be believed, it will delete any files or folders owned by the user from all team shares. However, testing indicates this parameter is non-functional.

    .NOTES
    API Notes:
    None of the parameters seem to be functional.

    .LINK
    http://developer.anchorworks.com/v2/#delete-a-person
#>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    param(
        [Parameter(ParameterSetName='pipeline',ValueFromPipeline)][Object[]]$InputObject,
        [Parameter(ParameterSetName='commandLine',Position=0,HelpMessage='One ore more valid Anchor Person IDs')][string[]]$id,
        [Parameter(HelpMessage='If true, ?')][switch]$remove_server_files,
        [Parameter(HelpMessage='If true, delete the user''s account root')][switch]$remove_user_files,
        [Parameter(HelpMessage='If true, ?')][switch]$remove_dept_files
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiCalls=@()
        $apiQuery = @{
            'remove_server_files'=$remove_server_files
            'remove_user_files'=$remove_user_files
            'remove_dept_files'=$remove_dept_files
        }
    }
    process{
        If($InputObject){$id = $_.id} # If we were passed objects from the pipeine, we're going to extract the id from each object for use in the following code.
        ForEach ($personId in $id){
            #Create the apiCalls hash table that will be passed to the Invoke-AnchorApi function.
            $apiEndpoint = "person/$personId/delete"
            $apiCall = @{'ApiEndpoint'=$apiEndpoint;'ApiQuery'=$apiQuery; 'Tag'=$personId}
            $affectedItem = Get-AnchorPerson -id $personId | Select-Object id, display_name, email
            If($PSCmdlet.ShouldProcess("$($affectedItem.display_name) (email: $($affectedItem.email), id: $($affectedItem.id))", 'PERMANENTLY DELETE user account')){
                $apiCalls += $apiCall
            }
        }
    }
    end{
        $results = $apiCalls | Invoke-anchorAPIPost
        $results | Add-Member -MemberType AliasProperty -Name 'person_id' -Value tag -PassThru | Select-Object person_id, status
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
 }